---
name: melhorar-observabilidade
description: Adiciona ou corrige logs JSON, métricas, traces APM e monitors Datadog em componentes do {nome-projeto}. Use quando faltar correlation_id, alertas, dashboard ou debug em produção for difícil.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{repo} {componente} {sintoma — ex. MTTR alto, sem alerta}"
triggers:
  - melhorar observabilidade
  - adicionar logs datadog
  - criar monitor alerta
  - correlation id
  - apm trace
---

# melhorar-observabilidade

## Fonte de verdade

- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md)
- [15 — Documentação](../../docs/engineering-handbook/15-documentacao.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Componente sem logs estruturados ou métricas
- Incidente com MTTR alto por falta de contexto
- Fluxo crítico sem monitor/runbook

## Passos

1. Mapear fluxo e pontos de falha; ler logs atuais no Datadog (se acesso).
2. **Plano** com campos de log, métricas, tags e cardinalidade.
3. Implementar logs JSON: `correlation_id`, `service`, `env`, `status`, duração.
4. Métricas: sucesso, erro, latência, volume — tags de baixa cardinalidade.
5. Trace APM se serviço suportar; propagar `correlation_id`.
6. Monitor + runbook para fluxos críticos; dashboard se novo domínio.

## Checklist DoD (recorte)

- [ ] Sem PII em log ou tags
- [ ] `correlation_id` rastreável ponta a ponta
- [ ] Monitor com threshold e runbook linkado
- [ ] Evidência de log/métrica no output do agente
- [ ] README atualizado (seção operação)

## Templates

- [dashboard](../../docs/engineering-handbook/templates/dashboard.md)
- [runbook](../../docs/engineering-handbook/templates/runbook.md)

## Não fazer

Ver anti-padrões em [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md).
