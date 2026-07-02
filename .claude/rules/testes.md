# Regra: Testes

**Docs:** `08-testes-unitarios.md`, `09-taac-testes-integrados-pipeline.md`, `10-testes-de-mutacao.md`

## Metas

- Cobertura **90%** line (branch quando disponível).
- Mutation **90%** em domain/application/transforms.
- TaaC quando há integração real — repo com `docker-compose` ou pipeline do ambiente.

## Faça

- Nome: `deve_{resultado}_quando_{condicao}`.
- Assert em comportamento observável.
- TaaC autocontido — LocalStack, Testcontainers, WireMock.
- Um teste de regressão por bug corrigido.

## Não faça

- Teste sem assert.
- E2E frágil duplicando TaaC.
- BDD em todo teste técnico.

## Exceções (justificar no PR)

DTO, bootstrap, código gerado, DAG declarativa, SQL literal dbt.
