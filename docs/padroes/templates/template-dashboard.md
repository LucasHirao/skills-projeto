# Dashboard: {Nome}

## Objetivo

{Qual pergunta operacional este dashboard responde.}

## Audiência

{Operação | Engenharia | Negócio}

## Links

- **Produção:** {URL}
- **Homologação:** {URL}

## Painéis

| Painel | Métrica | Threshold | Ação se violar |
|--------|---------|-----------|----------------|
| Saúde | taxa sucesso | < 99% | Runbook X |
| Atraso | lag minutos | > 60 | Runbook Y |
| Volume | registros/h | — | investigar fonte |

## Filtros obrigatórios

- `environment`
- `service`
- `data_referencia` (se aplicável)

## Legenda

{Explicar cores, estados, SLO.}

## Manutenção

- **Owner:** 
- **Revisão:** trimestral ou após mudança no fluxo
