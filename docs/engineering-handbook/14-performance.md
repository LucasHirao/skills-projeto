# 14 — Performance

Performance é preocupação **transversal** — avaliar volume, cardinalidade, concorrência e custo **antes** de implementar, não depois do incidente.

**Objetivo:** latência previsível, custo AWS controlado e comportamento estável sob 10× o volume esperado.

---

## 1. Checklist mental (obrigatório no design)

1. Qual **volume** (registros, GB, RPS, arquivos/dia)?
2. Qual **cardinalidade** das chaves de join/agrupamento?
3. Há **loop com I/O** de rede/AWS/DB?
4. Dá para **batch**, paginar ou stream?
5. Qual **impacto de custo** AWS (compute, scan, transferência)?
6. O que acontece com **10×** o volume? E com pico sazonal?
7. Há operação **O(n²)** escondida (nested loop, cross join)?

Documentar respostas no PR ou plano de implementação para mudanças relevantes.

---

## 2. Anti-padrões comuns

### 2.1 N+1 em APIs e Lambdas

```python
# ❌ Uma chamada por item
for item in items:
    dynamodb.get_item(Key={"id": item.id})

# ✅ Batch (limite 100 itens por chamada)
dynamodb.batch_get_item(RequestItems={...})
```

### 2.2 Full scan evitável

```sql
-- ❌ Scan amplo sem filtro de partição
select * from vendas where data > '2025-01-01';

-- ✅ Filtrar cedo + colunas necessárias
select pedido_id, valor
from vendas
where data_referencia = @ref;
```

### 2.3 Collect em Spark/Glue

```python
# ❌ Traz milhões de linhas para o driver
total = df.collect()

# ✅ Agregação distribuída — coleta uma linha
total = df.agg(F.sum("valor")).collect()[0][0]
```

### 2.4 I/O no import do Airflow

```python
# ❌ Conecta S3 no parse da DAG
dados = s3_client.list_objects_v2(Bucket="...")  # no topo do arquivo

# ✅ I/O só dentro do callable da task
@task
def listar_arquivos():
    return s3_client.list_objects_v2(Bucket="...")
```

### 2.5 Cliente AWS recriado a cada invocação

```python
# ❌
def handler(event, context):
    s3 = boto3.client("s3")  # cold path repetido

# ✅ Módulo level — reutiliza entre invocações warm
s3 = boto3.client("s3")

def handler(event, context):
    ...
```

---

## 3. Performance por stack

### 3.1 Airflow

| Foco | Regra |
|------|-------|
| Parse time | DAG leve; zero I/O no import |
| `max_active_runs` | `1` em fluxos não idempotentes |
| Pools/queues | Limitar concorrência em recursos escassos |
| Sensors | `mode="reschedule"` em vez de `poke` longo |
| XCom | Não passar datasets grandes — usar S3 path |
| Task duration | Métrica no Datadog; alerta se p95 dobra |

### 3.2 dbt

| Foco | Regra |
|------|-------|
| Materialização | `incremental` com `unique_key` para fatos grandes |
| Filtro | `where` no incremental — processar só delta |
| Joins | Evitar fan-out; pré-agregar em staging |
| Clustering | Chaves de filtro frequentes (data, região) |
| Tests | `store_failures` com moderação (custo) |
| Full refresh | Exigir aprovação explícita em prod |

```sql
{{ config(
    materialized='incremental',
    unique_key='pedido_id',
    incremental_strategy='merge',
    cluster_by=['data_referencia']
) }}

select ...
{% if is_incremental() %}
where data_referencia >= (select max(data_referencia) from {{ this }}) - interval '3 days'
{% endif %}
```

### 3.3 Terraform

| Foco | Regra |
|------|-------|
| Dimensionamento | Lambda memory, Glue DPU, RDS instance right-sized |
| Lifecycle | `prevent_destroy` só com ADR |
| State | Backend remoto; lock habilitado |
| Alarmes de custo | Budget alerts + métricas de uso |
| `depends_on` | Evitar cadeias desnecessárias que serializam apply |

### 3.4 Lambda Python

| Foco | Regra |
|------|-------|
| Memória | Testar 256/512/1024 MB — mais memória = mais CPU |
| Package size | Layers; excluir deps de teste do deploy |
| Cold start | Provisioned concurrency só com ADR (custo) |
| Timeout | Explícito; menor que o upstream |
| Conexões | Pool/reuse de clientes HTTP e DB |
| Batch | Processar SQS em lotes (`batch_size`, `batch_window`) |

### 3.5 Java Spring Boot

| Foco | Regra |
|------|-------|
| N+1 JPA | `@EntityGraph`, fetch join, DTO projection |
| Paginação | `Pageable` obrigatório em listagens |
| Pool | HikariCP dimensionado; monitorar wait time |
| Serialização | DTOs enxutos; evitar lazy fora de transação |
| Cache | TTL + invalidação documentada |

```java
// ✅ Paginação — memória estável, latência previsível
public Page<PedidoResumo> listar(Pageable pageable) {
    return repository.findAllResumo(pageable);
}
```

### 3.6 AWS Glue / Spark

| Foco | Regra |
|------|-------|
| Particionamento | Escrita por `data_referencia` / chave de negócio |
| Pushdown | Predicate pushdown em Parquet/Delta |
| Broadcast | Tabelas dimensão pequenas (< 100 MB) |
| Skew | Salting ou `repartition` em chaves desbalanceadas |
| Shuffle | Minimizar `groupBy` sem necessidade |
| Formato | Parquet com compressão snappy/zstd |
| Bookmarks | Glue job bookmarks para incremental |

```python
# ✅ Broadcast join — dimensão pequena
from pyspark.sql.functions import broadcast
df = fato.join(broadcast(dimensao), "chave")
```

---

## 4. Resiliência e degradação graciosa

| Padrão | Quando |
|--------|--------|
| **Timeout explícito** | Toda chamada HTTP, DB, AWS API |
| **Retry com backoff + jitter** | Erros transitórios (throttling, 503) |
| **Circuit breaker** | Dependência instável ou externa |
| **Bulkhead** | Isolar pools por dependência |
| **Cache** | Leitura frequente, TTL definido, invalidação documentada |
| **Dead letter queue** | Falha após retries — nunca perder mensagem silenciosamente |
| **Idempotência** | Retry seguro — ver README do componente |

```python
from tenacity import retry, stop_after_attempt, wait_exponential_jitter

@retry(stop=stop_after_attempt(3), wait=wait_exponential_jitter(initial=1, max=10))
def chamar_api_externa(payload):
    ...
```

---

## 5. Performance testing

| Tipo | Quando | Ferramenta sugerida |
|------|--------|---------------------|
| Microbenchmark | Hot path disputado — raramente | `pytest-benchmark` |
| Carga API | Endpoints críticos | k6, Gatling |
| Volume job | Glue/dbt com dataset representativo | Ambiente hml + subset 10× |
| Baseline | Antes/depois em PR relevante | Métricas Datadog + relatório no PR |
| Soak test | Memory leak, conexão | 1h+ em hml antes de release grande |

**Dataset de teste:** representativo em schema e cardinalidade, nunca só 10 registros para validar fluxo de GB.

---

## 6. Custo como métrica de performance

| Serviço | Alavanca |
|---------|----------|
| Glue | DPU, job bookmarks, formato colunar |
| Athena | Partições, colunas projetadas |
| Lambda | Memória right-sized, duração |
| S3 | Lifecycle, Intelligent-Tiering |
| dbt | Incremental, evitar full refresh |
| Datadog | Cardinalidade de tags, log indexing |

Incluir estimativa de custo no PR quando mudança alterar scan, DPU ou invocações em > 20%.

---

## 7. Code review — perguntas obrigatórias

- O que acontece com **10×** o volume?
- Há operação **O(n²)** ou N+1?
- Custo AWS estimado **mudou**? Em quanto?
- Timeout e retry estão **explícitos**?
- Reprocessamento do mesmo lote é **seguro** (idempotência)?
- Métrica de duração/volume será visível no Datadog?

Template de review: [`templates/code-review.md`](templates/code-review.md).

---

## 8. Checklist no PR

- [ ] Volume esperado e pico documentados
- [ ] Sem N+1, full scan evitável ou collect massivo
- [ ] Batch/paginação/partição aplicados onde couber
- [ ] Timeouts e retry com backoff
- [ ] Baseline ou justificativa em mudança de hot path
- [ ] Custo AWS considerado se impacto relevante

---

## 9. Referências

- [13 — Observabilidade](13-observabilidade.md) — métricas de latência e duração
- [16 — Code review](16-code-review.md)
- [18 — Definition of Done](18-definition-of-done.md)
- Skill: `revisar-desempenho` (derivada deste capítulo)
