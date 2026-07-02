# Arquitetura transversal

## Escopo

Esqueleto arquitetural do ecossistema `{nome-projeto}`: camadas, fronteiras e contratos entre repositórios.

## Camadas

| Camada | Responsabilidade | Onde vive |
|--------|------------------|-----------|
| **Domínio** | Regras de negócio puras | `domain/` |
| **Aplicação** | Orquestração de casos de uso | `application/` |
| **Infraestrutura** | AWS, DB, filas, HTTP | `infrastructure/` |
| **Entrada** | Handler, controller, DAG (fino) | `handler/`, `api/`, `dags/` |

**Regra:** lógica de negócio **não** em handler, DAG, Terraform nem SQL de orquestração.

## Multi-repo

- Um repo por capacidade (`{nome-projeto}-glue`, `{nome-projeto}-dbt`, etc.)
- Contratos: paths S3, schemas, filas, `correlation_id`, `data_referencia`
- PRs coordenados com referências cruzadas quando a mudança cruza repos
- Ordem típica de deploy: Terraform → Glue/Lambda → dbt → Airflow

## Contratos

- Versionar breaking changes com migração e comunicação
- Documentar em README, OpenAPI, `schema.yml` ou ADR
- Propagar `correlation_id` ponta a ponta para debug no Datadog

## Anti-padrões

- God module misturando domínio e I/O
- Consumidor acoplado a tabela staging ou path interno
- Mudança de contrato sem PR irmão no repo dependente

## Fonte de verdade

- [02 — Arquitetura transversal](../../docs/engineering-handbook/02-arquitetura-transversal.md)
