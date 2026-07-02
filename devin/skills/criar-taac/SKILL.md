---
name: criar-taac
description: Cria testes integrados na pipeline (TaaC) para o {nome-projeto}, validando contratos S3, filas, DB ou APIs em CI. Use ao adicionar teste end-to-end de pipeline ou integração entre componentes.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{repo} tests/taac/{nome_teste}.py {fluxo integrado}"
triggers:
  - criar taac
  - teste integrado pipeline
  - teste end to end dados
  - contrato s3 fila
---

# criar-taac

## Fonte de verdade

- [11 — TaaC](../../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [10 — Testes unitários](../../../docs/engineering-handbook/10-testes-unitarios.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Integração real entre componentes (S3, SQS, Glue, dbt, API)
- Validação de contrato de dados na CI
- Regressão de pipeline após incidente

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Testes integrados: nomes de casos em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Passos

1. Identificar **contrato** (schema, path, correlation_id, evento).
2. **Plano** com fixtures, ambiente (LocalStack/ephemeral) e tempo de execução na CI.
3. Escrever teste determinístico com dados sintéticos — sem PII real.
4. Assert de comportamento observável (arquivo no S3, mensagem na fila, row count).
5. Integrar na pipeline CI com tag `taac` ou stage dedicado.
6. Documentar com template de teste integrado.

## Checklist DoD (recorte)

- [ ] Dados sintéticos; sem dependência de prod
- [ ] Timeout e cleanup de recursos
- [ ] Falha com mensagem acionável
- [ ] Linkado ao componente no README
- [ ] Execução na CI documentada no PR

## Templates

- [teste-integrado](../../../docs/engineering-handbook/templates/teste-integrado.md)
- [runbook](../../../docs/engineering-handbook/templates/runbook.md)

## Não fazer

Ver anti-padrões em [11 — TaaC](../../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md).
