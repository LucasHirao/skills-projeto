# Regra Cursor

Espelha `.claude/rules/observabilidade.md`. Detalhes em `docs/padroes/`.

---

# Regra: Observabilidade

**Doc:** `docs/padroes/11-observabilidade.md` | **Checklist:** `checklists/code-review-observabilidade.md`

## Campos mínimos de log

`timestamp`, `level`, `service`, `environment`, `correlation_id`, `operation`, `status`, `duration_ms`

## Faça

- JSON estruturado
- Métricas: sucesso, erro, duração, volume
- Propagar correlation_id entre componentes
- Alerta com runbook em fluxo crítico

## Não faça

- Remover telemetria existente
- Logar PII/secrets/payload completo

## Alertas

Sintoma operacional (atraso, erro), não só exceção técnica
