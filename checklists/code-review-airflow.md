# Checklist: Code Review Airflow

## Perguntas objetivas

- [ ] `dag_id` segue `{nome-projeto}_{dominio}_{fluxo}`?
- [ ] `task_id` é `{verbo}_{objeto}`?
- [ ] `max_active_runs` adequado para idempotência?
- [ ] `catchup` justificado?
- [ ] Retries, timeout e callback de falha configurados?
- [ ] Sem I/O ou HTTP no import do módulo?
- [ ] Regra de negócio fora da DAG?
- [ ] `doc_md` com SLA e reprocessamento?
- [ ] Teste de parse/estrutura da DAG?

## 🔴 Bloqueio

- Lógica de negócio pesada na DAG
- Sem controle de concorrência em escrita não idempotente
- Chamada externa no top-level do módulo
- DAG sem teste de carregamento

## 🟡 Atenção

- DAG > 200 linhas sem extração
- Schedule sem documentação de dependência
- Pool não usado em recurso limitado

## Exemplos de comentário

> 🔴 Task `calcular_imposto` contém SQL de negócio — mover para dbt ou módulo `tasks.py` testável.

> 🟡 Considerar `max_active_runs=1` — duas execuções podem escrever na mesma partição.
