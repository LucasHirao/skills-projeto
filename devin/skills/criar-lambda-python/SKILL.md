---
name: criar-lambda-python
description: Cria ou altera funções AWS Lambda em Python no {nome-projeto} com handler fino, validação Pydantic, testes e observabilidade Datadog. Use ao criar lambda, handler, integração SQS/S3/API Gateway.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{nome-projeto}-lambda src/{modulo}/ {objetivo}"
triggers:
  - criar lambda python
  - nova função lambda
  - handler aws lambda
  - integração sqs lambda
---

# criar-lambda-python

## Fonte de verdade

- [07 — Lambda Python](../../../docs/engineering-handbook/07-lambda-python.md)
- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Nova Lambda ou alteração em `{nome-projeto}-lambda` (ou repo equivalente)
- Handler para API Gateway, SQS, S3, EventBridge
- Refatoração extraindo domain testável do handler

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Lambda/Python: classes, funções e variáveis internas em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Passos

1. Ler handler vizinho; seguir layout `handler` → `application` → `domain`.
2. **Plano** com triggers, IAM, timeout, memória e contrato de evento.
3. Handler fino: parse/validação → caso de uso → resposta.
4. Pydantic (ou equivalente) para input/output na borda.
5. Testes unitários ≥ 90%; mutation em domain; TaaC se integração real.
6. Logs JSON (`correlation_id`, `service`, `env`, `status`); métricas Datadog.
7. Terraform/IaC alinhado (módulo separado se multi-repo).

## Checklist DoD (recorte)

- [ ] Regra de negócio fora do handler
- [ ] Idempotência documentada para retries SQS/Lambda
- [ ] Sem segredo em env var plain text
- [ ] Cold start e timeout considerados
- [ ] CI verde (pytest, ruff/mypy se aplicável)

## Templates

- [readme-componente](../../../docs/engineering-handbook/templates/readme-componente.md)
- [pr](../../../docs/engineering-handbook/templates/pr.md)

## Não fazer

Ver anti-padrões em [07 — Lambda Python](../../../docs/engineering-handbook/07-lambda-python.md).
