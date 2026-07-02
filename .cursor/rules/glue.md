# Regra Cursor

Espelha `.claude/rules/glue.md`. Detalhes em `docs/padroes/`.

---

# Regra: Glue

**Doc:** `docs/padroes/07-aws-glue.md` | **Checklist:** `checklists/code-review-glue.md`

## Faça

- Separar read / transform / write
- Funções puras em `transforms/` com pytest
- Funções Spark nativas antes de UDF
- Escrita particionada (Parquet)
- Documentar idempotência do write

## Não faça

- `collect()` em dataset grande
- Pandas em volume distribuído sem necessidade
- Job monolítico sem testes

## Performance

- Predicate pushdown, broadcast join em dimensão pequena
