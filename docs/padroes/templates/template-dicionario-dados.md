# Template: Dicionário de dados — {nome do mart}

## Metadados

| Campo | Valor |
|-------|-------|
| Model dbt | `fct_{dominio}_{entidade}` |
| Owner | {time} |
| Atualização | {frequência} |
| Granularidade | {ex.: 1 linha por pedido} |

## Descrição de negócio

{O que este mart responde; quem consome.}

## Colunas

| Coluna | Tipo | Descrição | PII | Testes dbt |
|--------|------|-----------|-----|------------|
| pedido_id | varchar | Identificador único do pedido | Não | unique, not_null |
| data_pedido | date | Data do pedido (timezone UTC) | Não | not_null |
| valor | decimal | Valor líquido | Não | not_null |
| status | varchar | APROVADO, CANCELADO, PENDENTE | Não | accepted_values |

## Linhagem

- **Sources:** `raw.vendas.pedidos`
- **Staging:** `stg_vendas__pedidos`
- **Intermediate:** `int_vendas__pedidos_enriquecidos`
- **Exposures:** {dashboard, API, relatório}

## Regras de qualidade

- {ex.: valor >= 0}
- {ex.: pedidos cancelados com valor zero}

## Reprocessamento

- Chave: `pedido_id`
- Estratégia incremental: merge; lookback {N} dias

## Histórico de mudanças

| Data | Mudança | ADR/PR |
|------|---------|--------|
| | | |
