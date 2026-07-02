# Playbook: Criar pipeline Airflow + dbt

## Objetivo

Pipeline orquestrado: dados disponíveis → transformação dbt → validação → observabilidade.

## Escopo

DAG Airflow, models dbt afetados, testes, sensors/datasets — não processamento pesado na DAG.

## Contexto

- `docs/padroes/02-airflow.md`
- `docs/padroes/03-dbt.md`
- Skills `criar-dag-airflow`, `criar-modelo-dbt`

## O que procurar no repositório

- DAGs do mesmo domínio
- Sources e marts existentes
- Variáveis dbt (`data_referencia`)

## Como planejar

1. Definir trigger (schedule vs sensor S3/dataset).
2. Ordem: staging → int → marts.
3. Idempotência por `data_referencia`.
4. Testes: DAG parse + `dbt build`.

## Como implementar

1. Models dbt com schema.yml.
2. DAG com task dbt após pré-condição (sensor).
3. Callback falha + métricas.
4. Documentar SLA em `doc_md`.

## Como testar

```bash
pytest tests/dags/ -k {nome-projeto}_{dominio}
dbt build --select tag:{dominio} --vars '{"data_referencia": "2025-01-01"}'
```

## Como revisar

Checklists Airflow + dbt.

## Como reportar resultado

PR descrevendo lineage, SLA, reprocessamento/backfill.

## Critérios de aceite

- [ ] `max_active_runs` adequado
- [ ] dbt tests em chaves
- [ ] Sem lógica SQL na DAG

## O que não fazer

- Rodar transformação pesada em PythonOperator
- dbt sem testes em colunas críticas
