---
name: criar-dag-airflow
description: Cria ou altera DAGs Apache Airflow para orquestração no {nome-projeto}, com idempotência, callbacks Datadog e zero I/O no import. Use ao criar pipeline, sensor, dataset ou task group.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{nome-projeto}-airflow dags/{nome_dag}.py {objetivo}"
triggers:
  - criar dag airflow
  - nova dag
  - orquestrar pipeline
  - task group airflow
---

# criar-dag-airflow

## Fonte de verdade

- [04 — Airflow](../../docs/engineering-handbook/04-airflow.md)
- [02 — Arquitetura transversal](../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Nova DAG ou alteração em `{nome-projeto}-airflow`
- Integração com Glue, Lambda, dbt, S3 via operadores padrão do projeto
- Sensors, Datasets, `dag_run.conf` com `correlation_id`

## Passos

1. Ler DAGs vizinhas; seguir convenções de `tags`, `owner`, `doc_md`.
2. **Plano** com dependências, SLA, idempotência e ordem de deploy multi-repo.
3. DAG fina: orquestra apenas; processamento em Glue/dbt/Lambda.
4. Zero I/O e conexões no import do módulo.
5. `on_failure_callback` → log JSON + métrica Datadog.
6. Testes de parse (`airflow dags list`, testes unitários de estrutura).
7. Documentar backfill e `max_active_runs` em `doc_md`.

## Checklist DoD (recorte)

- [ ] Parse test / CI verde
- [ ] `correlation_id` em `dag_run.conf`
- [ ] Idempotência e reprocessamento documentados
- [ ] Sem SQL ou regra de negócio pesada na DAG
- [ ] TaaC se DAG dispara integração crítica

## Templates

- [readme-componente](../../docs/engineering-handbook/templates/readme-componente.md)
- [runbook](../../docs/engineering-handbook/templates/runbook.md)

## Não fazer

Ver anti-padrões em [04 — Airflow](../../docs/engineering-handbook/04-airflow.md).
