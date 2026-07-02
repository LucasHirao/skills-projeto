# Regra: Glue

**Doc:** `docs/padroes/07-aws-glue.md` | **Checklist:** `checklists/code-review-glue.md`

## Faça

- Separar read / transform / write / args.
- `transforms/` com funções puras + pytest.
- Spark nativo antes de UDF; sem `collect()` em volume grande.
- Escrita particionada Parquet; modo write documentado.
- Job bookmarks se append-only; args via `getResolvedOptions`.
- Métricas: registros processados/rejeitados.

## Não faça

- Script monolítico 500+ linhas.
- pandas em dataset distribuído sem necessidade.
