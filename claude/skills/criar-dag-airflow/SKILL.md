---
name: criar-dag-airflow
description: Criar ou alterar DAGs no repositório {nome-projeto}-airflow seguindo padrões de orquestração, idempotência e observabilidade Datadog.
---

# Criar DAG Airflow

## Quando usar

- Nova DAG de orquestração (Glue, dbt/Cosmos, Lambda, S3)
- Alteração de schedule, sensors, callbacks ou `dag_run.conf`
- Backfill ou idempotência em pipeline existente

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [04 — Airflow](../../../docs/engineering-handbook/04-airflow.md)
- [02 — Arquitetura transversal](../../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [13 — Observabilidade](../../../docs/engineering-handbook/13-observabilidade.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Airflow: `dag_id`, `task_id`, funções auxiliares e nomes de DAG em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `{nome-projeto}-airflow` |
| Path da DAG | Sim | `dags/vendas/processar_vendas_diario.py` |
| Objetivo | Sim | Orquestrar Glue → dbt com `data_referencia` |
| Dependências externas | Se houver | S3 path, fila, dataset |
| SLA e dono | Sim | 06:00 UTC, squad dados-vendas |

## Passos

1. Plano em 5–10 bullets antes de editar (tasks, dependências, contratos).
2. Criar DAG com `doc_md` (propósito, SLA, dono, idempotência).
3. Zero I/O no import — conexões só dentro de tasks/callables.
4. Definir `max_active_runs`, pools e `catchup` conscientemente.
5. Propagar `correlation_id` e `data_referencia` via `dag_run.conf`.
6. Configurar `on_failure_callback` → log JSON + métrica Datadog.
7. Sensors longos com `mode="reschedule"`.
8. Delegar processamento a Glue/dbt/Lambda — sem regra de negócio na DAG.
9. Teste de parse na CI (`airflow dags list` / teste equivalente).
10. TaaC se integra S3/fila/DB externo.

## Checklist de qualidade

- [ ] DAG legível; uma responsabilidade de orquestração
- [ ] `doc_md` completo
- [ ] Estilo alinhado à DAG vizinha
- [ ] Sem Variable com segredo

## Checklist de testes

- [ ] Parse test na CI
- [ ] Testes de lógica de conf/datas em módulo separado
- [ ] TaaC para integração externa, se aplicável

## Checklist de observabilidade

- [ ] `on_failure_callback` com log JSON e métrica
- [ ] `correlation_id` propagado
- [ ] Tags `dag_id`, `task_id` em telemetria

## Checklist de desempenho

- [ ] Sem tasks dinâmicas opacas em massa
- [ ] Pools para limitar concorrência
- [ ] Sensor com reschedule, não poke infinito

## Checklist de segurança

- [ ] Conexões via Secrets Manager/conn Airflow — não hardcoded
- [ ] Sem PII em `dag_run.conf` logado

## Critérios de aceite

- CI verde com parse test
- DoD Airflow em [18](../../../docs/engineering-handbook/18-definition-of-done.md) §2.1
- Runbook linkado se fluxo crítico

## O que não fazer

- SQL, HTTP ou Spark pesado dentro da DAG
- `catchup=True` sem análise de impacto
- Email como único alerta
- God DAG com regra de negócio embutida

## Como reportar

- Resumo do plano e tasks criadas
- Comandos para validar localmente
- Links para PR, dashboard e runbook
- Dúvidas de negócio como bullets separados

## Fonte de verdade

- [04 — Airflow](../../../docs/engineering-handbook/04-airflow.md)
- [Template — readme-componente](../../../docs/engineering-handbook/templates/readme-componente.md)
