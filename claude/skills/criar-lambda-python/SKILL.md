---
name: criar-lambda-python
description: Implementar funções AWS Lambda Python em {nome-projeto} com handler fino, domínio testável, observabilidade Datadog e TaaC.
---

# Criar Lambda Python

## Quando usar

- Nova função ou alteração de handler/evento
- Integração S3, SQS, DynamoDB, API Gateway
- Ajuste de idempotência, DLQ ou cold start

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [07 — Lambda Python](../../../docs/engineering-handbook/07-lambda-python.md)
- [02 — Arquitetura transversal](../../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [10 — Testes unitários](../../../docs/engineering-handbook/10-testes-unitarios.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Lambda/Python: classes, funções e variáveis internas em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `lambda-processa-arquivo` |
| Trigger | Sim | S3 `ObjectCreated` |
| Caso de uso | Sim | Validar e enfileirar arquivo |
| Contrato do evento | Sim | Schema do payload |
| SLA / timeout | Sim | 30s, 256MB |

## Passos

1. Plano: camadas, fluxo feliz/erro, idempotência.
2. Estrutura `domain/`, `application/`, `infrastructure/`, `handler/`.
3. Handler fino — delega para caso de uso.
4. Clientes AWS fora do handler (reuso em warm start).
5. Logs JSON com `correlation_id`, `service`, `env`, `status`.
6. Métricas Datadog: sucesso, erro, duração, volume.
7. Classificar erros recuperáveis vs fatais; DLQ configurada.
8. Idempotência com chave de negócio.
9. Testes unitários ≥ 90%; mutation em domínio.
10. TaaC para wiring real (LocalStack/Testcontainers).

## Checklist de qualidade

- [ ] Handler < ~50 linhas
- [ ] Regra de negócio em `domain/` testável
- [ ] Pacote enxuto para cold start

## Checklist de testes

- [ ] Cobertura ≥ 90%
- [ ] Mutation ≥ 90% em domain/application
- [ ] TaaC se integra AWS real

## Checklist de observabilidade

- [ ] Logs JSON estruturados
- [ ] Métricas e trace APM se aplicável
- [ ] Alarme + runbook se crítico

## Checklist de desempenho

- [ ] Batch em vez de N+1
- [ ] Timeout e memória dimensionados
- [ ] Retry consciente (sem loop infinito)

## Checklist de segurança

- [ ] IAM least privilege via Terraform
- [ ] Input validado na borda
- [ ] Sem segredo em env plain text no código

## Critérios de aceite

- DoD Lambda em [18](../../../docs/engineering-handbook/18-definition-of-done.md) §2.4
- CI verde com coverage e lint

## O que não fazer

- Handler monolítico com 400 linhas
- `except Exception: pass`
- Log texto livre
- Reprocessamento sem idempotência

## Como reportar

- Estrutura de pastas e fluxo
- Comandos de teste local
- Métricas/alertas criados
- Dúvidas de contrato do evento

## Fonte de verdade

- [07 — Lambda Python](../../../docs/engineering-handbook/07-lambda-python.md)
