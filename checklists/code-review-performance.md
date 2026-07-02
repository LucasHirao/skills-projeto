# Checklist: Code Review Performance

## Perguntas objetivas

- [ ] Volume esperado considerado?
- [ ] Sem N+1 ou I/O em loop?
- [ ] Batch/paginação onde necessário?
- [ ] Timeouts definidos?
- [ ] Filtro cedo (SQL/Spark)?
- [ ] Custo AWS estimado?
- [ ] Baseline se mudança crítica?

## 🔴 Bloqueio

- O(n²) ou full scan evitável em path crítico
- Loop síncrono para milhares de chamadas AWS
- `select *` em tabela grande sem filtro

## 🟡 Atenção

- Cache sem TTL
- Lambda subdimensionada em CPU-bound

## Exemplos de comentário

> 🔴 `get_item` por linha em 50k registros — usar batch ou scan com filtro.

> 🟡 Documentar impacto de custo do novo job Glue DPU=10.
