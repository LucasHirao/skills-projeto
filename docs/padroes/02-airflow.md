# Airflow

## Princípio central

DAG é **código de produção** que **orquestra** — não processa grandes volumes nem concentra regra de negócio.

## Estrutura de pastas

```
airflow/
├── dags/
│   └── {nome-projeto}_{dominio}_{fluxo}.py
├── plugins/app/
│   ├── operators/
│   ├── hooks/
│   └── sensors/
├── include/app/{dag_name}/
│   ├── config.yaml
│   └── tasks.py
└── tests/
    ├── dags/
    └── unit/
```

## Convenções de naming

| Campo | Padrão | Exemplo |
|-------|--------|---------|
| `dag_id` | `{nome-projeto}_{dominio}_{fluxo}` | `datalake_vendas_carga_diaria` |
| `task_id` | `{verbo}_{objeto}` | `validar_arquivo_entrada` |
| tags | nome do projeto, domínio, ambiente | `["datalake", "vendas", "prod"]` |

## Defaults recomendados

```python
DEFAULT_ARGS = {
    "owner": "time-dados",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=30),
    "execution_timeout": timedelta(hours=2),
    "email_on_failure": False,  # preferir alertas via observabilidade
    "on_failure_callback": padrao_on_failure_callback,
}
```

| Parâmetro | Recomendação |
|-----------|--------------|
| `catchup` | `False` salvo backfill explícito |
| `max_active_runs` | `1` quando execuções não podem sobrepor |
| `schedule` | cron ou datasets; documentar SLA |
| `pool` | usar quando recurso é limitado (Glue concurrent) |

## DAG mínima

```python
"""DAG: carga diária de vendas. SLA: 06:00 UTC. Idempotente por data_referencia."""
from datetime import datetime, timedelta
from airflow.decorators import dag, task
from app.vendas.tasks import validar_lote, acionar_glue_carga

@dag(
    dag_id="datalake_vendas_carga_diaria",
    start_date=datetime(2025, 1, 1),
    schedule="0 4 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["datalake", "vendas"],
    default_args=DEFAULT_ARGS,
    doc_md=__doc__,
)
def datalake_vendas_carga_diaria():
    @task(task_id="validar_lote_entrada")
    def validar():
        return validar_lote()  # lógica em módulo testável

    @task(task_id="executar_glue_carga")
    def glue():
        acionar_glue_carga()

    validar() >> glue()

datalake_vendas_carga_diaria()
```

## Integrações

| Destino | Quando usar |
|---------|-------------|
| Glue | Processamento batch pesado |
| Lambda | tarefas leves, event-driven |
| ECS | containers customizados |
| dbt | `BashOperator`/`Cosmos` após dados na staging |
| S3 | sensors para arquivo; paths versionados |
| REST | `HttpOperator` com timeout e retry; sem lógica pesada |

## Idempotência e reprocessamento

- Chave de idempotência: `data_referencia`, `lote_id` ou `execution_date` documentado.
- Backfill: `max_active_runs=1` + flag de compatibilidade.
- Não sobrepor execuções que escrevem no mesmo partition sem estratégia merge/overwrite documentada.

## Callback de falha

```python
def padrao_on_failure_callback(context):
  # Emitir log estruturado + métrica; linkar runbook
  logger.error("dag_failed", extra={
      "dag_id": context["dag"].dag_id,
      "task_id": context["task_instance"].task_id,
      "run_id": context["run_id"],
      "correlation_id": context["dag_run"].conf.get("correlation_id"),
  })
```

## Testes

### Parse/import

```python
def test_dag_loads_without_import_error(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert dag is not None
    assert len(dag.tasks) > 0
```

### Estrutural

```python
def test_dag_structure(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert dag.max_active_runs == 1
    assert "validar_lote_entrada" in dag.task_ids
```

## Performance — faça / não faça

| Faça | Não faça |
|------|----------|
| Config declarativa em YAML | Chamada HTTP no import do módulo |
| Funções auxiliares em módulo separado | DAG com 50+ tasks dinâmicas opacas |
| Um DAG por arquivo | Múltiplos DAGs não relacionados no mesmo arquivo |
| Lazy load de configs pesadas | `collect()` ou processamento no parse |

## Variables e Connections

| Tipo | Convenção | Segredo |
|------|-----------|---------|
| Variable | `{nome-projeto}_{chave}` ex. `datalake_env` | Não colocar senha em Variable |
| Connection | `{servico}_{ambiente}` ex. `aws_default_prod` | Usar backend Secrets/SSM |
| `dag_run.conf` | `correlation_id`, `data_referencia` | Propagar para tasks downstream |

Nunca hardcodar bucket, ARN ou URL em produção — usar Variable ou env do deployment.

## Backfill

```bash
# CLI — ajustar ao ambiente Airflow
airflow dags backfill datalake_vendas_carga_diaria \
  -s 2025-01-01 -e 2025-01-07 \
  --reset-dagruns --yes
```

| Situação | `catchup` | `max_active_runs` |
|----------|-----------|-------------------|
| Reprocessar histórico pontual | `False` + backfill manual | `1` |
| Nova DAG com histórico legítimo | `True` com janela limitada | `1` |
| DAG contínua | `False` | conforme idempotência |

## Pools e concorrência

```python
glue_task = GlueJobOperator(
    task_id="executar_glue_carga",
    pool="glue_pool",           # limitar jobs Glue simultâneos
    pool_slots=2,
    priority_weight=10,
    ...
)
```

## HttpOperator / REST

```python
HttpOperator(
    task_id="notificar_sistema_externo",
    endpoint="/api/v1/eventos",
    method="POST",
    data='{"correlation_id": "{{ run_id }}"}',
    timeout=30,
    extra_options={"check_response": True},
    # 4xx: não retry infinito — falha de contrato
    # 5xx: retry via default_args
)
```

## Airflow Datasets

Ver `examples/airflow/dag_datasets.py` — produtor com `outlets`, consumidor com `schedule=[Dataset(...)]`.

## dbt via Cosmos

Ver `examples/airflow/dbt_cosmos.py` — preferir Cosmos em vez de BashOperator cru para lineage e seleção de models.

## Propagação de correlation_id

```python
# DAG passa conf para tasks; tasks repassam a Glue/Lambda/dbt vars
@task
def build_conf(**context):
    return {
        "correlation_id": context["run_id"],
        "data_referencia": context["ds"],
    }
```

## Exemplos adicionais

- `examples/airflow/dag_s3_sensor.py`
- `examples/airflow/dag_datasets.py`
- `examples/airflow/callbacks.py`

## Code review

Ver `checklists/code-review-airflow.md` e `docs/padroes/14-code-review.md`.
