# Exemplos mínimos por stack

Referência versionada — copiar e adaptar ao repositório real. Detalhes em `docs/padroes/`.

| Stack | Pasta | Descrição |
|-------|-------|-----------|
| Airflow | `airflow/` | DAG, sensor S3, dataset, dbt Cosmos |
| dbt | `dbt/` | sources freshness, exposure, unit test, incremental |
| Terraform | `terraform/` | módulo Lambda+S3+IAM, backend, DLQ |
| Lambda | `lambda/` | handler, Pydantic, Powertools |
| Spring | `spring/` | controller, use case, repository, WireMock |
| Glue | `glue/` | transforms, bookmarks, Spark test |
| TaaC | `taac/` | LocalStack, contrato evento |
| Fixtures | `fixtures/` | dados para testes |

## Como usar

1. Leia o exemplo antes de criar componente novo.
2. Mantenha naming do seu `{nome-projeto}` — exemplos usam `datalake`.
3. Não importe `examples/` em produção; copie para o **repositório de código** correspondente.
