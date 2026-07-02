# Playbook: Investigar falha em pipeline

## Objetivo

Diagnosticar e corrigir falha em DAG/job/Lambda/dbt com causa raiz e prevenção.

## Escopo

Investigação, fix, teste de regressão, atualização runbook — não refatoração ampla não relacionada.

## Contexto

- Runbooks em `docs/` ou README do componente
- `docs/padroes/11-observabilidade.md`

## O que procurar no repositório

- Logs estruturados com correlation_id / run_id
- Histórico de execuções Airflow
- Métricas e alertas
- Mudanças recentes no PR/git log

## Como planejar

1. Reproduzir com dados/fixture mínima.
2. Hipóteses ordenadas (dados, código, infra, dependência externa).
3. Isolar camada (orquestração vs processamento vs fonte).

## Como implementar

1. Coletar evidência (log, stack, amostra dados).
2. Criar teste que reproduz a falha.
3. Corrigir causa raiz (não só sintoma).
4. Atualizar runbook/alerta se necessário.

## Como testar

- Teste de regressão obrigatório
- Validar reprocessamento/idempotência

## Como revisar

- Fix mínimo
- Sem remoção de observabilidade

## Como reportar resultado

Post-mortem leve: sintoma, causa, fix, prevenção, link runbook.

## Critérios de aceite

- [ ] Teste de regressão
- [ ] Runbook atualizado se gap
- [ ] Reprocessamento seguro documentado

## O que não fazer

- Corrigir sem reproduzir
- Desligar alerta sem entender
- Retry infinito mascarando bug
