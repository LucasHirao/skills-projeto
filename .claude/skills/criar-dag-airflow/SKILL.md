---
name: criar-dag-airflow
description: >-
  Cria ou altera DAG Airflow no padrão projeto com naming, testes e idempotência.
  Use ao implementar orquestração, schedule, tasks Airflow, sensors ou integração
  Glue/Lambda/dbt via DAG.
---

# Criar DAG Airflow

**Referência:** `docs/padroes/02-airflow.md` | **Regra:** `.claude/rules/airflow.md`

## Quando usar

Nova DAG, nova task, alteração de schedule, callback de falha ou integração orquestrada.

## Entradas esperadas

- Domínio e fluxo (`vendas`, `carga_diaria`)
- Dependências (S3, Glue, dbt, REST)
- SLA e regra de idempotência
- Schedule e restrição de concorrência

## Passo a passo

1. Buscar DAG similar em `airflow/dags/`.
2. Definir `dag_id` = `{nome-projeto}_{dominio}_{fluxo}`.
3. Criar módulo `include/app/{dag}/tasks.py` para lógica testável.
4. DAG fina: defaults, tags, `doc_md`, tasks com `task_id` `{verbo}_{objeto}`.
5. Configurar `max_active_runs`, retries, `on_failure_callback`.
6. Adicionar testes em `tests/dags/`.
7. Atualizar README/runbook se fluxo crítico.

## Checklist de qualidade

- [ ] Sem I/O no import
- [ ] `doc_md` com SLA e reprocessamento
- [ ] Naming projeto
- [ ] Lógica fora da DAG

## Checklist de testes

- [ ] `test_dag_loads`
- [ ] `test_dag_structure` (tasks, max_active_runs)
- [ ] Testes unitários em `tasks.py`

## Checklist de observabilidade

- [ ] Callback de falha com log JSON + correlation_id
- [ ] Métrica ou log de início/fim de fluxo crítico

## Checklist de performance

- [ ] Parse da DAG leve
- [ ] Processamento pesado delegado a Glue/Lambda/dbt

## Armadilhas comuns

- SQL de negócio na DAG
- `catchup=True` sem planejamento
- Duas execuções escrevendo mesma partição

## Resultado esperado

DAG revisável, testada na CI, com módulo auxiliar testável e documentação operacional.

## Exemplo de prompt

```
Use a skill criar-dag-airflow. Crie DAG datalake_vendas_carga_diaria que valida
arquivo S3 e aciona job Glue. Idempotente por data_referencia, max_active_runs=1.
Inclua testes de parse e tasks.py testável.
```
