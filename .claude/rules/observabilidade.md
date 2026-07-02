# Regra: Observabilidade

**Doc:** `docs/padroes/11-observabilidade.md` | **Checklist:** `checklists/code-review-observabilidade.md`

## Campos mínimos de log JSON

`timestamp`, `level`, `service`, `environment`, `correlation_id`, `operation`, `status`, `duration_ms`

## Faça

- Propagar `correlation_id` entre Airflow conf → Glue/Lambda → logs.
- Métricas: sucesso, erro, duração, volume.
- Alerta com sintoma operacional + link runbook.
- Mascarar PII; hash em business keys.

## Não faça

- Remover telemetria existente.
- Logar payload completo ou credencial.
