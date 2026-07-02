# Regra: dbt

**Doc:** `docs/padroes/03-dbt.md` | **Checklist:** `checklists/code-review-dbt.md`

## Escopo

`models/`, `macros/`, `tests/`, `snapshots/`, `seeds/`, `dbt_project.yml` no repo `{nome-projeto}-dbt`.

## Camadas e prefixos

| Camada | Prefixo | Regra |
|--------|---------|-------|
| staging | `stg_` | Próximo da fonte; tipagem; sem join de negócio pesado |
| intermediate | `int_` | Lógica reutilizável |
| marts | `fct_`, `dim_`, `mart_` | Perguntas de negócio |
| snapshots | `snp_` | SCD quando necessário |

## Faça

- `schema.yml` com `description` + testes em **todas** as colunas chave.
- Incremental: `unique_key`, estratégia (`merge`/`append`), `lookback_days` para late arriving.
- Filtrar cedo; listar colunas explicitamente em produção.
- `sources.yml` com `freshness` quando SLA de origem existir.
- `exposures` para dashboards/APIs downstream críticos.
- `dbt build` verde antes do PR.

## Não faça

```sql
-- ❌ select * em mart de produção
select * from {{ ref('stg_pedidos') }}

-- ❌ lógica de mart na staging
select p.*, c.segmento, sum(x) ...  -- join de negócio em stg_
```

```sql
-- ✅ staging enxuta
select
    cast(id as varchar) as pedido_id,
    cast(valor as decimal(18,2)) as valor
from {{ source('raw', 'pedidos') }}
where data_pedido >= {{ var('data_corte', '2020-01-01') }}
```

## Incremental

- Documentar full refresh controlado (quem aprova, comando).
- ADR se mudar estratégia de merge vs append.

## Contratos

- `contract: enforced: true` em marts com consumidores externos.
- Testes customizados SQL para regras que `accepted_values` não cobre.

## Critérios de aceite

- [ ] Prefixo e pasta corretos
- [ ] Testes em chaves e regras críticas
- [ ] Lineage downstream considerado
- [ ] Dicionário de dados se mart novo crítico

## Erros comuns de agentes

- Model sem `schema.yml`
- Incremental sem `unique_key`
- Duplicar SQL entre models sem macro
