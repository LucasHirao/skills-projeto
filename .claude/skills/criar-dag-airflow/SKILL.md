---
name: criar-dag-airflow
description: >-
  Cria ou altera DAG Airflow com naming, idempotência, testes e integração Glue/Lambda/dbt.
  Use para orquestração, sensors, datasets, schedules ou callbacks no repo {nome-projeto}-airflow.
disable-model-invocation: true
---

# Criar DAG Airflow (Claude Code)

**Repo alvo:** `{nome-projeto}-airflow` | **Rule:** `.claude/rules/airflow.md` | **Doc:** `docs/padroes/02-airflow.md`

## Pré-voo

1. Confirmar repo correto (não monorepo).
2. Ler DAG similar em `dags/` e `include/`.
3. Ler `02-airflow.md` seções: naming, idempotência, integrações.
4. Plano: `dag_id`, tasks, contratos com Glue/dbt/S3.

## Entradas

- `{nome-projeto}`, `{dominio}`, `{fluxo}`
- SLA, schedule, `data_referencia` / chave idempotência
- Dependências externas (bucket, job Glue, tag dbt)

## Procedimento

### 1. Estrutura de arquivos

```
dags/{nome-projeto}_{dominio}_{fluxo}.py
include/app/{dominio}_{fluxo}/tasks.py
include/app/{dominio}_{fluxo}/config.yaml   # opcional
tests/dags/test_{dominio}_{fluxo}.py
tests/unit/test_tasks_{dominio}.py
```

### 2. Módulo `tasks.py`

- Funções puras ou com injeção de clientes (testável com pytest).
- Sem import pesado de Airflow no domínio.

### 3. DAG declarativa

- `DEFAULT_ARGS`: retries, backoff, `on_failure_callback` → log JSON + `correlation_id`.
- `max_active_runs=1` se escrita não idempotente.
- `doc_md`: SLA, reprocessamento, contratos upstream/downstream **outros repos**.
- Tags: `datalake`, domínio, ambiente.

### 4. Integração

| Cenário | Abordagem |
|---------|-----------|
| Arquivo S3 | `S3KeySensor`, reschedule, timeout |
| Dataset | `outlets` / `schedule=[Dataset(...)]` |
| Glue | Operator, job name por Variable/env |
| dbt | Cosmos/`dbt build` com `vars: data_referencia` |

### 5. Testes

```python
def test_dag_loads(dag_bag):
    assert dag_bag.get_dag("datalake_vendas_carga_diaria") is not None

def test_max_active_runs(dag_bag):
    assert dag_bag.get_dag("...").max_active_runs == 1
```

### 6. Documentação

- README do repo airflow: nova DAG, parâmetros conf, link runbook se crítico.
- Se novo contrato S3: atualizar README repo Glue/dbt consumidor (issue/PR irmão).

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-airflow.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Parse lento | Remover I/O do import |
| Duplicata em reprocessamento | `max_active_runs` + idempotência downstream |
| SQL na DAG | Mover para dbt ou `tasks.py` |

## Reporte Claude

- Arquivos alterados
- `dag_id` e contratos
- Comando teste executado
- PRs necessários em outros repos

## Prompt

```
Repo datalake-airflow. Skill criar-dag-airflow. Plano primeiro.
DAG datalake_vendas_carga_diaria: sensor S3, Glue, correlation_id no conf.
Testes parse + tasks.py unitário.
```
