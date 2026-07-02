# Regra: Performance

**Doc:** `docs/padroes/12-performance.md` | **Checklist:** `checklists/code-review-performance.md`

## Antes de implementar

Volume? Cardinalidade? Custo AWS? Concorrência?

## Faça

- Batch/paginação/stream vs loop I/O.
- Filtro cedo (SQL/Spark).
- Timeouts + retry com jitter.
- Dimensionar Lambda/Glue/DPU com justificativa.

## Não faça

- N+1 DynamoDB/HTTP/DB.
- Full scan evitável.
- Cache sem TTL.

## Sinais de alerta em review

Loop com `await`/boto3; `select *` em tabela grande; `collect()` Spark em milhões de linhas.
