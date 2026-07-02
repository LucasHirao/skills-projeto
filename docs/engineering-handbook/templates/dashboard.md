# Dashboard Datadog: {Nome}

- **Owner:** {time/pessoa}
- **Criado em:** YYYY-MM-DD
- **Última revisão:** YYYY-MM-DD
- **Ambiente principal:** `prod`

## Objetivo

{Qual pergunta operacional este dashboard responde em uma frase.}

**Exemplo:** “A pipeline de vendas está dentro do SLA de entrega e qualidade?”

## Audiência

- [ ] Operação / plantão
- [ ] Engenharia de dados
- [ ] Engenharia backend
- [ ] Negócio / gestão
- [ ] FinOps

## Links

| Ambiente | URL |
|----------|-----|
| **Produção** | {https://app.datadoghq.com/dashboard/...} |
| **Homologação** | {URL ou N/A} |

## Escopo técnico

| Tag | Valor |
|-----|-------|
| `service` | `{lista}` |
| `env` | `prod`, `hml` |
| `team` | `{time}` |

## Layout — painéis

### Linha 1 — Saúde executiva

| Widget | Query / métrica | Threshold | Ação se violar |
|--------|-----------------|-----------|----------------|
| Query value | `avg:datalake.{domínio}.lag_minutes{env:prod}` | > 60 min | [Runbook](../runbooks/{nome}.md) |
| Query value | `sum:{domínio}.arquivo.processado{status:success}.as_count()` | — | — |
| SLO | `{nome SLO}` — disponibilidade 30d | budget < 10% | Escalar tech lead |

### Linha 2 — Operacional

| Widget | Query / métrica | Notas |
|--------|-----------------|-------|
| Timeseries | taxa de erro por `error_type` | últimas 24h |
| Log stream | `service:{*} status:FAILURE` | facet `correlation_id` |
| Top list | duração por `task_id` / `dbt_model` | identificar gargalo |

### Linha 3 — Técnico

| Widget | Query / métrica | Notas |
|--------|-----------------|-------|
| Heatmap | latência Lambda p95 por `version` | deploy recente? |
| Timeseries | Glue DPU / duração job | custo |
| APM | latency breakdown | dependências externas |

### Linha 4 — Dados e qualidade

| Widget | Query / métrica | Notas |
|--------|-----------------|-------|
| Query | `dbt.source.freshness_hours` | source crítico |
| Timeseries | registros rejeitados | qualidade entrada |

### Linha 5 — Custo (opcional)

| Widget | Query | Notas |
|--------|-------|-------|
| Cloud cost | por `service` tag | FinOps |

## Filtros obrigatórios (template variables)

| Variável | Default | Valores |
|----------|---------|---------|
| `env` | `prod` | `prod`, `hml`, `dev` |
| `service` | `*` | lista de serviços do fluxo |
| `data_referencia` | último dia | se aplicável |

## SLOs vinculados

| SLO | Target | Monitor burn rate |
|-----|--------|-------------------|
| {nome} | 99% / 30d | {link monitor} |

## Monitors relacionados

| Monitor | Prioridade | Runbook |
|---------|------------|---------|
| `{nome}` | P2 | [link](../runbooks/{nome}.md) |

## Legenda e convenções

- **Verde:** dentro do SLO
- **Amarelo:** degradação — investigar em horário comercial
- **Vermelho:** fora do SLA — acionar runbook

## Manutenção

- Revisão **trimestral** ou após mudança estrutural no fluxo
- Após deploy: validar que `version` tag reflete release
- Dashboard sem uso em 90 dias → arquivar ou fundir

## Checklist de criação

- [ ] Tags `env`, `service`, `team` em todas as queries
- [ ] Links para runbooks nos widgets críticos
- [ ] Template variables testadas
- [ ] Owner nomeado
- [ ] README do componente atualizado com URL

## Referências

- [13 — Observabilidade](../13-observabilidade.md)
- Runbook: [templates/runbook.md](runbook.md)
