# 09 — AWS Glue

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Repositório:** `glue-jobs-{dominio}` ou `etl-{nome-projeto}-{contexto}`  
> **Escopo:** jobs ETL/ELT PySpark no AWS Glue da plataforma `{nome-projeto}`

---

## Objetivo

Definir **como estruturamos, testamos, otimizamos e operamos** jobs Glue: separação leitura/transformação/escrita, transformações puras testáveis com pytest, Spark local em CI, bookmarks e processamento incremental, observabilidade **Datadog**, **90% cobertura** em lógica pura e **TaaC** para wiring S3/catalog.

Glue é **motor de transformação distribuída** — não um script Jupyter jogado em produção.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Engenheiro(a) de dados** | Desenvolver jobs ETL/ELT |
| **Analytics engineer** | Entender dependências bronze → silver |
| **Revisor** | Performance Spark, testes, particionamento |
| **SRE** | Falhas de job, custo DPU, reprocessamento |
| **Júnior** | Separar função pura de código Spark |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Solução |
|----------|---------|---------|
| Script monolítico | 800 linhas, zero teste | Módulos + transforms puras |
| `collect()` em big data | OOM driver | Agregações distribuídas |
| UDF Python desnecessária | Shuffle lento | Funções nativas Spark |
| Full scan diário | Custo DPU alto | Bookmark + incremental |
| Schema drift silencioso | Dados quebrados downstream | Validação de schema + testes |
| Job sem observação | Falha descoberta pelo negócio | Métricas Datadog + alarmes |

---

## Princípios

1. **Separação de responsabilidades** — `read`, `transform`, `write`, `config`, `observability`.
2. **Transformação pura testável** — lógica sem SparkSession em funções isoladas quando possível.
3. **Spark nativo primeiro** — UDF só com ADR e benchmark.
4. **Particionamento explícito** — colunas de partição documentadas no contrato.
5. **Formatos colunares** — Parquet com compressão snappy/zstd em camadas silver+.
6. **Idempotência e reprocessamento** — documentar semântica overwrite/merge.
7. **Bookmarks quando aplicável** — fontes JDBC/S3 incrementais.
8. **90% cobertura** em módulos Python puros; TaaC para job entrypoint.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa | Motivo |
|---------|---------|-------------|--------|
| Linguagem | PySpark no Glue 4.x+ | Scala | Alinhamento com Lambda/Python |
| Estrutura | Pacote Python importável | `job.py` único | Testes locais |
| Catálogo | Glue Data Catalog | Hive manual | Integração AWS nativa |
| Escrita | Parquet particionado | CSV | Performance e schema |
| Orquestração | Airflow dispara job | Cron Glue | Controle central ([04 — Airflow](04-airflow.md)) |
| Qualidade | Great Expectations / checks custom | Sem validação | Falha cedo |

---

## Trade-offs

| Trade-off | A | B | A quando | B quando |
|-----------|---|---|----------|----------|
| Glue ETL vs Spark | Glue com bookmarks | EMR | Padrão corporativo AWS | Controle fino cluster |
| `merge` vs `overwrite` | Delta/Iceberg merge | Partition overwrite | Slowly changing | Snapshot diário full |
| Broadcast join | `broadcast(df)` | Shuffle join | Dimensão pequena (<10MB) | Fato grande |
| DynamicFrame vs DataFrame | DynamicFrame | DataFrame puro | Schema evolving JDBC | Controle Spark idiomático |

---

## Quando usar / quando não usar

### Use Glue quando

- Volume e transformação exigem Spark distribuído.
- Fonte no Data Catalog, S3, JDBC, Kinesis.
- Job batch de minutos a horas com escala automática Glue.

### Não use Glue quando

- Poucos MB e lógica simples — [07 — Lambda Python](07-lambda-python.md).
- Transformação SQL semântica de negócio — [05 — dbt](05-dbt.md) no warehouse.
- Streaming sub-segundo — Kinesis Analytics / outro serviço.

---

## Estrutura de repositório e pastas

```
glue-jobs-vendas/
├── src/
│   ├── jobs/
│   │   └── bronze_para_silver_vendas.py    # entrypoint Glue
│   ├── transforms/
│   │   ├── normalizacao.py                 # funções puras
│   │   └── enriquecimento.py
│   ├── io/
│   │   ├── readers.py
│   │   └── writers.py
│   ├── config/
│   │   └── job_config.py
│   └── observability/
│       └── metrics.py
├── tests/
│   ├── unit/
│   ├── spark/                              # Spark local, datasets pequenos
│   └── taac/
├── scripts/
│   └── run_local.sh
├── pyproject.toml
├── .github/workflows/ci.yml
└── docs/
    ├── README.md
    └── runbooks/
```

---

## Padrões de código da stack

Índice rápido — detalhes neste capítulo:

| Tópico | Seção |
|--------|-------|
| Estrutura de pastas | [Estrutura de repositório](#estrutura-de-repositório-e-pastas) |
| Convenções | [Convenções e naming](#convenções-e-naming) |
| Práticas / anti-padrões | [Práticas obrigatórias](#práticas-obrigatórias) · [Anti-padrões](#anti-padrões) |
| Exemplos | [Exemplos](#exemplos-bom-vs-ruim) |
| Testes / observabilidade | [Estratégia de testes](#estratégia-de-testes) · [Observabilidade](#observabilidade-datadog) |
| Checklists | [Checklist de implementação](#checklist-de-implementação) |

Transversal: [03 — Padrões de código](03-padroes-de-codigo.md) · [18 — DoD](18-definition-of-done.md)

---

## Convenções e naming

| Item | Convenção |
|------|-----------|
| Job Glue | `{nome-projeto}-{camada}-{entidade}-{env}` |
| Script S3 | `s3://artifacts-{env}/glue/{job}/` |
| Partição | `ano`, `mes`, `dia` ou `dt=YYYY-MM-DD` |
| Tabela catálogo | `{nome-projeto}_{camada}_{entidade}` |
| Métrica custom | `glue.{job}.{metrica}` no Datadog |
| Argumentos job | `--conf`, `--partition-dt` via `getResolvedOptions` |

---

## Práticas obrigatórias

- [ ] Entrypoint fino: parse args → wire → `read` → `transform` → `write`
- [ ] Funções puras em `transforms/` com pytest
- [ ] Cobertura ≥ 90% em `transforms/` e `config/`
- [ ] Testes Spark local para transforms críticos (dataset pequeno)
- [ ] TaaC: leitura/escrita em bucket de teste (LocalStack ou conta dev)
- [ ] Particionamento documentado no README
- [ ] Schema de saída explícito (não inferir silenciosamente)
- [ ] Logs estruturados JSON com `job_name`, `run_id`, `partition`
- [ ] Alarme CloudWatch → Datadog: falha, duração, DPU
- [ ] Job parametrizado por data (`--partition-dt`) para reprocessamento
- [ ] Sem `collect()` / `toPandas()` em produção sem ADR

---

## Práticas recomendadas

- Glue Job Bookmark para fontes suportadas
- Predicate pushdown em leitura Parquet
- `coalesce`/`repartition` consciente (não `repartition(1)` por padrão)
- Compressão zstd em camadas frias
- Data quality checks antes de promover partição
- Airflow Dataset ou flag para downstream dbt
- Salvar métricas de linhas lidas/escritas/rejeitadas

---

## Anti-padrões

```python
# ❌ Tudo no main
if __name__ == "__main__":
    # 500 linhas de transform inline

# ❌ collect para contar milhões de linhas
total = df.count()  # ok em teste pequeno; em prod use métrica agregada se necessário
amostra = df.collect()  # OOM

# ❌ UDF Python para trim/upper
from pyspark.sql.functions import udf
trim_udf = udf(lambda x: x.strip())  # use trim(col)

# ❌ Escrita sem partição em tabela grande
df.write.mode("overwrite").parquet(path)

# ❌ Credencial no código
jdbc_url = "jdbc:postgresql://...?user=admin&password=secret"
```

---

## Exemplos (bom vs ruim)

### Transform pura — bom

```python
# transforms/normalizacao.py
def normalizar_status(status: str | None) -> str:
    if status is None:
        return "DESCONHECIDO"
    return status.strip().upper()

def test_normalizar_status_none():
    assert normalizar_status(None) == "DESCONHECIDO"
```

### Transform Spark — bom

```python
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, trim, upper

def aplicar_normalizacao_status(df: DataFrame) -> DataFrame:
    return df.withColumn(
        "status_norm",
        upper(trim(col("status"))),
    )
```

### Entrypoint — bom

```python
from awsglue.utils import getResolvedOptions
from transforms.enriquecimento import aplicar_regras
from io.readers import ler_bronze
from io.writers import escrever_silver

args = getResolvedOptions(sys.argv, ["JOB_NAME", "partition_dt", "env"])
df = ler_bronze(spark, args["partition_dt"])
df = aplicar_regras(df)
escrever_silver(df, args["partition_dt"])
```

### Escrita particionada — bom

```python
def escrever_silver(df: DataFrame, partition_dt: str) -> None:
    (
        df.write.mode("overwrite")
        .partitionBy("dt")
        .option("partitionOverwriteMode", "dynamic")
        .parquet(output_path)
    )
```

---

## Estratégia de testes

| Camada | O quê | Ferramenta | Meta |
|--------|-------|------------|------|
| Unitário | `transforms/`, `config/` | pytest | 90% line |
| Spark local | Transforms DataFrame | pytest + `SparkSession` fixture | Casos críticos |
| Mutation | Lógica pura | mutmut | 90% onde aplicável |
| TaaC | Read/write S3, catálogo mock | LocalStack / conta dev | 1+ fluxo por job |
| Contrato | Schema Parquet / colunas | assert schema | Breaking detectado |

```python
# tests/spark/conftest.py
@pytest.fixture(scope="session")
def spark():
    return SparkSession.builder.master("local[2]").appName("test").getOrCreate()
```

Ver [10](10-testes-unitarios.md), [11](11-taac-testes-integrados-na-pipeline.md), [12](12-testes-de-mutacao.md).

---

## Observabilidade (Datadog)

| Sinal | Implementação |
|-------|---------------|
| Logs | CloudWatch → Forwarder; JSON com `job`, `partition`, `rows_in/out` |
| Métricas | Custom metrics via API ou log-based metrics |
| Traces | Menos comum; duração por stage como métrica |
| Alertas | Job failed, duration > SLA, DPU anomaly |

```python
logger.info(
    "escrita_concluida",
    extra={
        "job_name": args["JOB_NAME"],
        "partition_dt": partition_dt,
        "rows_written": rows_written,
        "output_path": output_path,
    },
)
```

- Integrar com Airflow callback para correlacionar `dag_run_id`
- Dashboard: duração, taxa de sucesso, custo estimado DPU

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Técnica | Detalhe |
|---------|---------|
| Particionamento | Filtrar `dt` na leitura; pushdown |
| Join | Broadcast dimensões pequenas; evitar cartesian |
| Skew | Salting ou `AQE` (Adaptive Query Execution) |
| Formato | Parquet + colunas necessárias apenas |
| Workers | Right-size `G.1X` vs `G.2X`; auto-scaling |
| Bookmark | Evitar reprocessar histórico inteiro |
| Shuffle | Minimizar `groupBy` desnecessários |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Credenciais JDBC via Secrets Manager (Glue connection)
- IAM job role least privilege por bucket/prefix
- Sem dados sensíveis em logs
- Criptografia SSE-KMS em buckets
- Lake Formation / políticas de catálogo quando adotado

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

README por job:

- Fonte e destino (paths, tabelas)
- Grain e particionamento
- Parâmetros (`--partition-dt`)
- Semântica idempotente (overwrite/merge)
- Como rodar local e testes
- SLA e dependências Airflow/dbt
- Runbook de reprocessamento

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Estrutura jobs/transforms/io/config
- [ ] Transforms puras testadas
- [ ] Spark tests para lógica distribuída crítica
- [ ] Cobertura ≥ 90% em módulos puros
- [ ] Particionamento e schema documentados
- [ ] TaaC read/write
- [ ] Alarmes configurados
- [ ] Job parametrizado para reprocessamento

---

## Checklist de code review

- [ ] Sem `collect`/`toPandas` perigosos
- [ ] UDF justificada ou removida
- [ ] Partições e `mode` de escrita corretos
- [ ] Impacto de custo DPU considerado
- [ ] Schema change comunicado a consumidores dbt
- [ ] Testes representativos (não só happy path vazio)

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Runbook: falha, retry, backfill de partição
- [ ] Monitor Datadog job duration e failures
- [ ] Procedimento de reprocessamento (`--partition-dt`)
- [ ] Validação downstream (dbt test / TaaC) após backfill

---

## Critérios de aceite

1. CI verde: unit + spark local + TaaC.
2. Job executado em dev com partição de teste.
3. Dados na silver com schema esperado.
4. Métricas visíveis no Datadog.
5. Airflow DAG (se aplicável) integrada.

---

## Definition of Done (tema Glue)

- [ ] Merge + deploy script S3 + job definition Terraform
- [ ] Testes e cobertura atendidos
- [ ] Documentação e runbook
- [ ] Monitores ativos
- [ ] [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**Posso usar pandas no Glue?**  
Evite em volume. Se usar, só em amostra pequena ou após `filter` agressivo — preferir Spark.

**Bookmark não funciona na minha fonte?**  
Use particionamento por data e filtro incremental manual.

**Quem dono do schema silver?**  
Job Glue materializa; dbt pode consumir como source — contrato em README + dbt `sources.yml`.

**Como testar local sem Glue?**  
SparkSession local + pytest; TaaC com LocalStack S3.

---

## Guia de uso para júnior

1. Escreva a regra em função pura + teste pytest.
2. Aplique no DataFrame em `transforms/`.
3. Conecte em `jobs/` com leitura/escrita separadas.
4. Rode testes Spark com fixture pequena.
5. Execute local com `run_local.sh` antes do PR.

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Plano de execução Spark (shuffle, skew)
- Custo DPU projetado vs SLA
- Semântica de overwrite e backfill
- Contrato com camada dbt downstream
- Estratégia de schema evolution
- Adequação Glue vs Lambda vs EMR

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 04 | [Airflow](04-airflow.md) |
| 05 | [dbt](05-dbt.md) |
| 06 | [Terraform](06-terraform.md) |
| 07 | [Lambda Python](07-lambda-python.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 11 | [TaaC](11-taac-testes-integrados-na-pipeline.md) |
| 12 | [Testes de mutação](12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
