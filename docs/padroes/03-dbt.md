# dbt

## Estrutura do projeto

```
dbt/
├── models/
│   ├── staging/{fonte}/
│   ├── intermediate/{dominio}/
│   ├── marts/{dominio}/
│   └── exports/           # opcional
├── snapshots/
├── seeds/
├── tests/
├── macros/
├── analyses/
└── dbt_project.yml
```

## Camadas

| Camada | Prefixo | Propósito |
|--------|---------|-----------|
| sources | `source()` | Contrato com origem |
| staging | `stg_` | Limpeza, tipagem, renomear — próximo da fonte |
| intermediate | `int_` | Joins e lógica reutilizável |
| marts | `fct_`, `dim_`, `mart_` | Próximo do negócio |
| snapshots | `snp_` | SCD tipo 2 quando necessário |

**Regra:** staging espelha fonte; marts respondem perguntas de negócio.

## Model staging — exemplo

```sql
-- models/staging/vendas/stg_vendas__pedidos.sql
-- Por quê: tipagem e padronização na borda; sem join de negócio aqui.
with source as (
    select * from {{ source('vendas_raw', 'pedidos') }}
),
renamed as (
    select
        cast(id_pedido as varchar) as pedido_id,
        cast(data_pedido as date) as data_pedido,
        upper(status) as status,
        cast(valor as decimal(18, 2)) as valor
    from source
    where data_pedido >= {{ var('data_corte', '2020-01-01') }}
)
select * from renamed
```

## Model incremental — exemplo

```sql
-- models/marts/vendas/fct_vendas_pedidos.sql
{{
  config(
    materialized='incremental',
    unique_key='pedido_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
  )
}}
select * from {{ ref('int_vendas__pedidos_enriquecidos') }}
{% if is_incremental() %}
where data_atualizacao > (select coalesce(max(data_atualizacao), '1900-01-01') from {{ this }})
{% endif %}
```

**Late arriving data:** janela de reprocessamento (`lookback_days` var) ou merge por `unique_key`.

## schema.yml — documentação e testes

```yaml
version: 2
models:
  - name: stg_vendas__pedidos
    description: Pedidos brutos padronizados da fonte vendas.
    columns:
      - name: pedido_id
        tests: [not_null, unique]
      - name: status
        tests:
          - accepted_values:
              values: ['APROVADO', 'CANCELADO', 'PENDENTE']
      - name: valor
        tests: [not_null]
```

## Testes

| Tipo | Uso |
|------|-----|
| `not_null`, `unique`, `relationships` | Contratos básicos |
| `dbt_utils.expression_is_true` | Regras de negócio SQL |
| freshness | SLA de origem |
| unit tests (dbt 1.8+) | Lógica em inputs fixture |
| teste customizado | Regras específicas do domínio |

## Materializações — quando usar

| Tipo | Quando |
|------|--------|
| view | Staging leve, sempre atual |
| table | Mart pequeno/médio, rebuild aceitável |
| incremental | Volume alto, append/merge |
| ephemeral | CTE reutilizável, não expor |

## Performance

- Filtrar cedo (`where` na staging).
- Evitar `select *` em produção.
- Particionar/clusterizar conforme engine (Redshift, BigQuery, etc.).
- Medir tempo e bytes scanned no CI quando possível.

## Integração Airflow

```bash
dbt deps
dbt build --select tag:vendas --vars '{"data_referencia": "{{ ds }}"}'
```

Orquestrar **após** dados disponíveis (sensor S3 ou dataset).

## sources.yml com freshness

Ver `examples/dbt/sources_freshness.yml` — `loaded_at_field`, `warn_after`, `error_after`.

## Exposures e lineage

Ver `examples/dbt/exposures.yml` — documentar dashboards/APIs que dependem do mart.

## Data contracts

```yaml
models:
  - name: fct_vendas_pedidos
    config:
      contract:
        enforced: true
    columns:
      - name: pedido_id
        data_type: varchar
        constraints: [not_null]
```

## Teste customizado

```sql
-- tests/assert_valor_nao_negativo.sql
select pedido_id from {{ ref('fct_vendas_pedidos') }} where valor < 0
```

## Unit test dbt

Ver `examples/dbt/unit_test_exemplo.yml`.

## Incremental + late arriving

```yaml
# dbt_project.yml
vars:
  lookback_days: 3
```

Ver `examples/dbt/incremental_merge.sql` e ADR `docs/adr/0001-exemplo-materializacao-incremental-dbt.md`.

## Engine alvo (ajustar ao warehouse)

| Engine | Particionamento | Cluster |
|--------|-----------------|---------|
| Redshift | `distkey` / `sortkey` | sortkey em filtros frequentes |
| BigQuery | `partition_by` | clustering columns |
| Athena/Iceberg | `partitioned_by` | bucketing se necessário |

## PR checklist dbt

- [ ] Nome segue prefixo da camada
- [ ] `schema.yml` com descrição e testes
- [ ] Incremental com `unique_key` e estratégia documentada
- [ ] `dbt build` verde
- [ ] Impacto em downstream (lineage) avaliado
- [ ] Dicionário de dados se mart crítico (`templates/template-dicionario-dados.md`)
