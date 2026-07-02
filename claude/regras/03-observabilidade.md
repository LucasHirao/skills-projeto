# Observabilidade

## Escopo

Telemetria padrão com **Datadog** em todos os componentes `{nome-projeto}`.

## Pilares

| Pilar | Uso |
|-------|-----|
| **Logs** | JSON estruturado, debug e auditoria |
| **Métricas** | Alertas, SLO, tendências |
| **Traces** | Latência ponta a ponta (APM) |

## Tags obrigatórias

`env`, `service`, `version`, `team` — mais `correlation_id` em todo fluxo.

## Logs

- Formato JSON
- Campos mínimos: `correlation_id`, `service`, `env`, `status`, `mensagem`
- **Sem PII** — mascarar ou omitir dados sensíveis
- Tags de **baixa cardinalidade** em métricas

## Fluxos críticos

- Dashboard Datadog documentado
- Monitor com runbook linkado
- `on_failure_callback` em DAGs com métrica de falha

## Anti-padrões

- `print` ou log texto livre sem estrutura
- Alta cardinalidade em tags (user_id, timestamp como tag)
- Alerta só por e-mail sem Datadog
- Deploy sem como debugar em produção

## Fonte de verdade

- [13 — Observabilidade (Datadog)](../../docs/engineering-handbook/13-observabilidade.md)
- [Template — dashboard](../../docs/engineering-handbook/templates/dashboard.md)
- [Template — runbook](../../docs/engineering-handbook/templates/runbook.md)
