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
- Campos mínimos: `correlation_id`, `service`, `env`, `status`, `operation`
- **Allowlist** — só campos permitidos; em dúvida, não logar
- **Sem payload completo**, PII, credenciais ou tags de alta cardinalidade
- Hash/máscara para identificadores de negócio quando indispensável
- Revisar logs no PR contra [Logging seguro](../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)

## Fluxos críticos

- Dashboard Datadog documentado
- Monitor com runbook linkado
- `on_failure_callback` em DAGs com métrica de falha

## Anti-padrões

- `print` ou log texto livre sem estrutura
- `logger.info(..., extra={"payload": event})`
- Alta cardinalidade em tags (`user_id`, `cpf`, timestamp como tag)
- Alerta só por e-mail sem Datadog
- Deploy sem como debugar em produção

## Fonte de verdade

- [13 — Observabilidade (Datadog)](../../docs/engineering-handbook/13-observabilidade.md)
- [Template — dashboard](../../docs/engineering-handbook/templates/dashboard.md)
- [Template — runbook](../../docs/engineering-handbook/templates/runbook.md)
