# Regra Cursor

Espelha `.claude/rules/airflow.md`. Detalhes em `docs/padroes/`.

---

# Regra: Airflow

**Doc:** `docs/padroes/02-airflow.md` | **Checklist:** `checklists/code-review-airflow.md`

## Faça

- `dag_id`: `{nome-projeto}_{dominio}_{fluxo}`
- `task_id`: `{verbo}_{objeto}`
- `max_active_runs=1` se escrita não idempotente
- Extraia lógica para `include/app/{dag}/tasks.py`
- Teste parse + estrutura na CI

## Não faça

- HTTP/boto3 no import do módulo DAG
- Processar volume grande na task Python da DAG
- Múltiplos DAGs não relacionados no mesmo arquivo

## Defaults

- `catchup=False`, retries com backoff, `on_failure_callback` com log estruturado
