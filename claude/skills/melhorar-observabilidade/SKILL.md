---
name: melhorar-observabilidade
description: Adicionar ou corrigir logs JSON, métricas, traces e alertas Datadog em componentes {nome-projeto}.
---

# Melhorar observabilidade

## Quando usar

- Componente sem logs estruturados ou métricas
- Incidente difícil de debugar (sem `correlation_id`)
- Novo fluxo crítico sem monitor/runbook
- Migração de alerta email → Datadog

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [13 — Observabilidade (Datadog)](../../../docs/engineering-handbook/13-observabilidade.md) — [Logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
- Capítulo da stack (04–09)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md) §1.4

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Observabilidade: preserve tags técnicas (`service`, `env`, `correlation_id`); operações internas em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Componente | Sim | Lambda `processa-arquivo` |
| Criticidade | Sim | Alta / média / baixa |
| Fluxo | Sim | S3 trigger → SQS |
| Gaps atuais | Sim | Log texto, sem métrica de erro |
| `service` name | Sim | `datalake-lambda-processa-arquivo` |

## Passos

1. Mapear pontos de entrada/saída e falhas esperadas.
2. Padronizar logs JSON: `correlation_id`, `service`, `env`, `status`, `mensagem`.
3. Propagar `correlation_id` de upstream (DAG conf, header HTTP, message attribute).
4. Emitir métricas: sucesso, erro, duração, volume (tags baixa cardinalidade).
5. Habilitar trace APM se serviço HTTP/Lambda com latência relevante.
6. Criar/atualizar dashboard ([template](../../../docs/engineering-handbook/templates/dashboard.md)).
7. Se crítico: monitor + runbook ([template](../../../docs/engineering-handbook/templates/runbook.md)).
8. Validar [checklist de logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#checklist-de-logging-seguro): sem payload, PII, credenciais; tags Datadog sem alta cardinalidade.
9. Documentar no README como debugar no Datadog.

## Checklist de qualidade

- [ ] Mensagens de log acionáveis em português
- [ ] Campos consistentes com outros serviços `{nome-projeto}`
- [ ] Níveis de log adequados (INFO/WARN/ERROR)

## Checklist de testes

- [ ] Teste que log/métrica chave é emitida (cap. 13)
- [ ] TaaC propaga `correlation_id` se integração

## Checklist de observabilidade

- [ ] Tags `env`, `service`, `version`, `team`
- [ ] Métricas de sucesso, erro, duração, volume
- [ ] Dashboard documentado
- [ ] Monitor com runbook se crítico

## Checklist de desempenho

- [ ] Logging não síncrono bloqueante em hot path
- [ ] Cardinalidade de tags controlada

## Checklist de segurança

- [ ] [Logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#checklist-de-logging-seguro): allowlist, sem payload/PII/credenciais
- [ ] Tags Datadog sem PII nem alta cardinalidade
- [ ] Sem segredo em mensagem de log

## O que não fazer

- Log de payload completo (`extra={"payload": event}`)
- Log de objeto inteiro com dados sensíveis
- Tag `user_id` ou timestamp como dimensão de métrica
- Dashboard sem owner
- Alerta sem runbook em fluxo crítico

## Critérios de aceite

- DoD §1.4 em [18](../../../docs/engineering-handbook/18-definition-of-done.md)
- Query Datadog por `correlation_id` funciona ponta a ponta
- Checklist de logging seguro atendido

## Como reportar

- Campos de log adicionados
- Métricas e nomes no Datadog
- Link do dashboard/monitor (placeholder se ainda não deployado)
- Query de exemplo para debug

## Fonte de verdade

- [13 — Observabilidade](../../../docs/engineering-handbook/13-observabilidade.md)
- [Template — dashboard](../../../docs/engineering-handbook/templates/dashboard.md)
- [Template — runbook](../../../docs/engineering-handbook/templates/runbook.md)
