---
name: criar-job-glue
description: Cria ou altera jobs AWS Glue (PySpark/Spark) no {nome-projeto} com argumentos tipados, transforms testáveis e métricas Datadog. Use ao criar ETL, job Spark ou alterar transformação de dados.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{nome-projeto}-glue jobs/{nome_job}/ {objetivo}"
triggers:
  - criar job glue
  - etl glue
  - transform spark
  - aws glue pyspark
---

# criar-job-glue

## Fonte de verdade

- [09 — AWS Glue](../../docs/engineering-handbook/09-aws-glue.md)
- [14 — Performance](../../docs/engineering-handbook/14-performance.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Novo job ou alteração em `{nome-projeto}-glue`
- Refatoração de transforms para módulos testáveis
- Ajuste de particionamento, bookmark ou argumentos do job

## Passos

1. Ler job vizinho; mapear argumentos (`getResolvedOptions`) e contrato S3.
2. **Plano** com volume, particionamento e dependências Terraform/Airflow.
3. Separar `transforms/` (funções puras/testáveis) de `job.py` (bootstrap Glue).
4. Testes unitários das transforms; TaaC se integração S3 crítica.
5. Métricas de registros processados, duração e erro no Datadog.
6. Documentar bookmark, idempotência e custo estimado.

## Checklist DoD (recorte)

- [ ] Transforms testáveis fora do contexto Spark quando possível
- [ ] Argumentos documentados; sem path hardcoded de ambiente
- [ ] Particionamento adequado ao volume
- [ ] Cobertura ≥ 90% em lógica de negócio
- [ ] README do job atualizado

## Templates

- [readme-componente](../../docs/engineering-handbook/templates/readme-componente.md)
- [teste-integrado](../../docs/engineering-handbook/templates/teste-integrado.md)

## Não fazer

Ver anti-padrões em [09 — AWS Glue](../../docs/engineering-handbook/09-aws-glue.md).
