---
name: criar-modelo-dbt
description: >-
  Cria ou altera models dbt (staging, intermediate, marts) com testes, documentação,
  materialização e contratos upstream. Use no repo {nome-projeto}-dbt para SQL, incrementais,
  schema.yml, macros ou refatoração de camadas.
disable-model-invocation: true
---

# Criar modelo dbt (Claude Code)

**Repo alvo:** `{nome-projeto}-dbt` | **Rule:** `.claude/rules/dbt.md` | **Doc:** `docs/padroes/03-dbt.md`

## Pré-voo

1. Confirmar repo correto (`-dbt`, não monorepo).
2. Ler model similar na mesma camada (`models/staging/`, `intermediate/`, `marts/`).
3. Ler `03-dbt.md`: camadas, incremental, `schema.yml`, contratos com Glue/Airflow.
4. Plano: camada, prefixo, refs/sources, materialização, testes, impacto downstream.

## Entradas

- `{nome-projeto}`, `{dominio}`, `{entidade}` (ex.: `vendas`, `pedidos`)
- Camada: `stg_` / `int_` / `fct_` / `dim_` / `snp_`
- Fonte upstream: `source()` ou `ref()`
- Chave única, regra incremental, `data_referencia` / lookback
- SLA de freshness e consumidores (exposures)

## Procedimento

### 1. Estrutura de arquivos

```
models/staging/{fonte}/stg_{fonte}__{entidade}.sql
models/intermediate/{dominio}/int_{dominio}__{descricao}.sql
models/marts/{dominio}/fct_{dominio}_{entidade}.sql
models/marts/{dominio}/schema.yml          # ou _models.yml por domínio
tests/generic/                             # se teste customizado
```

### 2. SQL por camada

| Camada | Regra |
|--------|-------|
| `stg_` | Tipagem, rename, filtro cedo; sem join de negócio |
| `int_` | Joins reutilizáveis; CTEs nomeadas |
| `fct_`/`dim_` | Pergunta de negócio; colunas explícitas |
| incremental | `unique_key`, estratégia, bloco `is_incremental()` |

```sql
-- staging: filtro cedo + colunas explícitas
where data_pedido >= {{ var('data_corte', '2020-01-01') }}

-- incremental: late arriving documentado
{% if is_incremental() %}
where data_atualizacao > (select coalesce(max(data_atualizacao), '1900-01-01') from {{ this }})
{% endif %}
```

### 3. schema.yml

- `description` no model e nas colunas chave.
- Testes: `not_null`, `unique`, `relationships`, `accepted_values`.
- `sources.yml`: `freshness` se SLA de origem existir.
- `exposures` para dashboards/APIs críticos novos.

### 4. Config e materialização

```yaml
# dbt_project.yml ou config no model
materialized: view|table|incremental
tags: ['{dominio}', 'diario']
```

- Volume alto → `incremental` com `merge` ou `append` justificado.
- `on_schema_change: append_new_columns` quando ADR permitir.

### 5. Contratos multi-repo

| Origem | Repo produtor | Contrato |
|--------|---------------|----------|
| Tabela Glue/catalog | `-glue-*` | schema, partição, `data_referencia` |
| Path S3 raw | `-glue-*` ou ingestão | colunas, formato, `_SUCCESS` |
| Orquestração | `-airflow` | tag/selector, `vars.data_referencia` |

Documentar em `doc_md` do model ou README: colunas, chave, janela de reprocessamento.

### 6. Testes

```bash
dbt build --select stg_vendas__pedidos+ --vars '{"data_referencia": "2026-07-01"}'
dbt test --select fct_vendas_pedidos
```

- Unit tests dbt (`tests/unit/`) para lógica SQL complexa com inputs YAML.
- CI do repo deve passar antes do PR.

### 7. Documentação

- README do repo dbt: novo model, vars, dependências.
- Se novo contrato de coluna: issue/PR no repo produtor (Glue) ou consumidor (API).

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-dbt.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Mart na staging | Mover joins para `int_` |
| Incremental sem `unique_key` | Definir chave + estratégia merge |
| `select *` em mart | Listar colunas explicitamente |
| Full refresh diário em tabela grande | Incremental + lookback |
| Teste só `not_null` em tudo | Testes de negócio relevantes |

## Reporte Claude

- Models criados/alterados e camada
- Materialização e `unique_key` (se incremental)
- Comando `dbt build` executado
- Impacto downstream (`dbt ls --select model+`)
- PRs irmãos (airflow tag, glue schema)

## Prompt

```
Repo datalake-dbt. Skill criar-modelo-dbt. Plano primeiro.
Criar stg_vendas__pedidos e fct_vendas_pedidos incremental com unique_key pedido_id.
schema.yml com testes. vars data_referencia. dbt build --select +.
```
