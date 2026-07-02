# Performance

Performance é preocupação **transversal** — avaliar volume, cardinalidade, concorrência e custo **antes** de implementar.

## Checklist mental

1. Qual volume (registros, GB, RPS)?
2. Qual cardinalidade das chaves?
3. Há loop com I/O rede/AWS/DB?
4. Dá para batch/paginar/stream?
5. Qual impacto de custo AWS?

## Anti-padrões comuns

```python
# ❌ N+1 — uma chamada por item
for item in items:
    dynamodb.get_item(Key={"id": item.id})

# ✅ Batch
dynamodb.batch_get_item(RequestItems={...})
```

```sql
-- ❌ Scan completo
select * from vendas where data > '2025-01-01'

-- ✅ Filtrar cedo + colunas necessárias
select pedido_id, valor from vendas where data_referencia = @ref
```

```python
# ❌ Spark collect em milhões de linhas
total = df.collect()

# ✅ Agregação distribuída
total = df.agg(F.sum("valor")).collect()[0][0]  # ainda coleta 1 linha
```

## Por stack

| Stack | Foco |
|-------|------|
| Lambda | memória/CPU, cold start, package size, client reuse |
| Spring | pool, N+1, paginação, serialização |
| Glue/Spark | partition, pushdown, broadcast, skew |
| dbt | filter early, incremental, clustering |
| Airflow | parse leve, sem I/O no import |
| Terraform | dimensionamento, lifecycle, alarmes custo |

## Resiliência

- Timeouts explícitos.
- Retry com backoff + jitter.
- Circuit breaker em dependências instáveis.
- Cache só com critério (TTL, invalidação).

## Performance testing

| Tipo | Quando |
|------|--------|
| Microbenchmark | Hot path disputado — raramente |
| Carga API | Endpoints críticos |
| Volume job | Glue/dbt com dataset representativo |
| Baseline | Antes/depois em PR relevante |

## Code review

Perguntas obrigatórias:

- O que acontece com 10x o volume?
- Há operação O(n²) escondida?
- Custo AWS estimado mudou?

Ver `checklists/code-review-performance.md` e skill `revisar-performance`.

## Exemplo bom — paginação Spring

```java
public Page<PedidoResumo> listar(Pageable pageable) {
    return repository.findAllResumo(pageable);
}
```

**Ganho:** memória estável, latência previsível.
