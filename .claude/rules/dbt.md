# Regra: dbt

**Doc:** `docs/padroes/03-dbt.md` | **Checklist:** `checklists/code-review-dbt.md`

## Faça

- Prefixos: `stg_`, `int_`, `fct_`, `dim_`
- `schema.yml` com testes em chaves
- Incremental com `unique_key` + estratégia documentada
- `dbt build` no CI

## Não faça

- Lógica de mart na staging
- `select *` em produção
- Model sem testes em colunas críticas

## Materialização

- view: staging leve | incremental: volume alto | table: mart controlado
