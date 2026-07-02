# ADR-0001: Materialização incremental com merge no mart de pedidos

- **Status:** Aceita (exemplo)
- **Data:** 2025-01-15
- **Autores:** time de dados
- **Decisores:** arquitetura de dados

## Contexto

O mart `fct_vendas_pedidos` cresce ~2M linhas/mês. Full refresh diário aumenta custo e tempo de pipeline. Há atualizações de status (late arriving) até D+3.

## Decisão

- Materializar `fct_vendas_pedidos` como **incremental** com estratégia **merge**.
- `unique_key`: `pedido_id`.
- Janela de lookback: `lookback_days: 3` em `dbt_project.yml` vars.
- Full refresh apenas sob demanda com flag `var('full_refresh', false)` e aprovação ops.

## Alternativas consideradas

| Alternativa | Prós | Contras |
|-------------|------|---------|
| Table diária | Simples | Custo alto, janela longa |
| Incremental append | Rápido | Duplicata em reprocessamento |
| **Merge incremental** | Idempotente, trata updates | Merge mais caro que append |

## Consequências

- Airflow deve passar `data_referencia` e respeitar `max_active_runs=1` na DAG de carga.
- Testes dbt: `unique` + `not_null` em `pedido_id`.
- Runbook de backfill: `docs/runbooks/carga-diaria-atraso.md`.

## Referências

- `docs/padroes/03-dbt.md`
- `examples/dbt/incremental_merge.sql`
