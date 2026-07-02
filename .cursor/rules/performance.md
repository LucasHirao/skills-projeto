# Regra Cursor

Espelha `.claude/rules/performance.md`. Detalhes em `docs/padroes/`.

---

# Regra: Performance

**Doc:** `docs/padroes/12-performance.md` | **Checklist:** `checklists/code-review-performance.md`

## Antes de codificar

Pergunte: volume? cardinalidade? custo AWS?

## Faça

- Batch/paginação/stream em vez de loop I/O
- Filtro cedo (SQL/Spark)
- Timeouts + retry com jitter
- Baseline em mudança crítica

## Não faça

- N+1 (DB, DynamoDB, S3)
- Full scan evitável
- Cache sem TTL/invalidação

## Por stack

Lambda: package/cold start | Spring: pool/N+1 | Glue: partition/pushdown | dbt: incremental
