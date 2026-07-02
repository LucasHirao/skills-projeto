# Regra: Airflow

**Doc:** `docs/padroes/02-airflow.md` | **Checklist:** `checklists/code-review-airflow.md`

## Escopo

Aplica a arquivos em `dags/`, `include/`, `plugins/`, `tests/dags/`, `tests/unit/` de tasks Airflow.

## Naming (obrigatório)

| Campo | Padrão | Exemplo |
|-------|--------|---------|
| `dag_id` | `{nome-projeto}_{dominio}_{fluxo}` | `datalake_vendas_carga_diaria` |
| `task_id` | `{verbo}_{objeto}` | `validar_arquivo_entrada` |
| tags | projeto, domínio, ambiente | `["datalake", "vendas", "prod"]` |

## Faça

- DAG **orquestra** — processamento pesado em Glue, Lambda, dbt ou ECS.
- Lógica testável em `include/app/{dag}/tasks.py` (ou pacote equivalente no repo airflow).
- `max_active_runs=1` quando escrita na mesma partição/chave não é idempotente.
- `catchup=False` salvo backfill planejado e documentado em `doc_md`.
- `on_failure_callback` com log JSON + `correlation_id` + link runbook.
- Propagar `data_referencia` e `correlation_id` via `dag_run.conf` para downstream.
- Testes: parse DAG + estrutura + unitários das tasks.
- Variables: `{nome-projeto}_{chave}` — sem segredos em Variable.

## Não faça

```python
# ❌ I/O no import — quebra parse e testes
s3 = boto3.client("s3")
files = s3.list_objects_v2(Bucket="...")  # top-level do módulo DAG

# ❌ SQL/regra de negócio na DAG
@task
def calcular():
    return spark.sql("SELECT sum(valor) FROM ... complex business logic ...")
```

```python
# ✅ Import leve; lógica no módulo
from app.vendas.tasks import validar_lote, acionar_glue

@task(task_id="validar_lote_entrada")
def validar():
    return validar_lote()
```

## Defaults recomendados

- `retries=3`, exponential backoff, `execution_timeout` explícito.
- Sensor S3: `mode="reschedule"`, `poke_interval` ≥ 60s, `timeout` alinhado ao SLA.
- Pool `glue_pool` quando concorrência Glue é limitada.

## Integrações

| Alvo | Padrão |
|------|--------|
| Glue | Operator com job name parametrizado por env |
| dbt | Cosmos ou Bash com `vars` `data_referencia` |
| S3 | Sensor + path com `{{ ds }}` ou conf |
| REST | HttpOperator, timeout 30s, 4xx não retry cego |

## Idempotência

Documentar em `doc_md`: chave (`data_referencia`, `lote_id`), comportamento em retry e backfill.

## Critérios de aceite

- [ ] Parse test verde
- [ ] Sem I/O no import
- [ ] `doc_md` com SLA e reprocessamento
- [ ] Callback de falha estruturado

## Erros comuns de agentes

- Inventar `dag_id` fora do padrão
- Esquecer `max_active_runs` em pipeline de escrita
- DAG monolítica sem extrair tasks.py
