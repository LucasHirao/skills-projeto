---
name: criar-lambda-python
description: >-
  Cria ou altera Lambda Python projeto com handler fino, domínio testável, logs
  estruturados e integração AWS. Use para novas funções Lambda, handlers, layers
  ou refatoração domain/application/infrastructure.
---

# Criar Lambda Python

**Referência:** `docs/padroes/05-lambda-python.md` | **Regra:** `.claude/rules/lambda-python.md`

## Quando usar

Nova Lambda, handler, integração S3/SQS/DynamoDB, refatoração para camadas.

## Entradas esperadas

- Trigger (S3, API Gateway, SQS, etc.)
- Formato do evento
- Regras de negócio
- Requisitos de idempotência e DLQ

## Passo a passo

1. Estrutura: `handler.py`, `domain/`, `application/`, `infrastructure/`, `tests/`.
2. Implementar domínio puro testável.
3. Handler fino com Powertools (log, trace, metrics).
4. Clientes boto3 fora do handler.
5. Secrets via Secrets Manager/SSM.
6. pytest ≥90%; mutmut em domain/application.
7. README do componente.

## Checklist de qualidade

- [ ] Handler < 30 linhas de lógica
- [ ] Type hints / Pydantic na borda
- [ ] Erros classificados (recuperável vs não)

## Checklist de testes

- [ ] Unitários domínio sem mock AWS
- [ ] Mock boto3 na borda
- [ ] TaaC com moto/LocalStack se integração
- [ ] mutmut ≥90% em paths configurados

## Checklist de observabilidade

- [ ] Log JSON + correlation_id
- [ ] Métrica registros processados/erros
- [ ] Tracing em handler

## Checklist de performance

- [ ] Package enxuto
- [ ] Paginação/batch em I/O
- [ ] Memória adequada

## Armadilhas comuns

- Tudo no handler
- Credencial hardcoded
- Retry infinito em erro de contrato

## Resultado esperado

Lambda testável, observável, idempotente, com Terraform associado se nova.

## Exemplo de prompt

```
Use criar-lambda-python. Lambda processa evento S3 JSON, filtra APROVADO em
domain/, grava DynamoDB. Powertools, pytest 90%, mutmut domain/.
```
