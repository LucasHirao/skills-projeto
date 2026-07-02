# Template: Diagrama C4 — {nome do fluxo}

Use Mermaid ou ferramenta do time. Níveis mínimos: **Contexto** e **Container**.

## Nível 1 — Contexto

```mermaid
flowchart LR
  Origem[Origem de dados] -->|arquivos/API| Pipeline[Pipeline de dados]
  Pipeline --> Consumidor[Consumidores analíticos]
  Ops[Operação] --> Pipeline
```

## Nível 2 — Container

```mermaid
flowchart TB
  S3[(S3 raw)]
  AF[Airflow]
  Glue[Glue ETL]
  DBT[dbt]
  WH[(Warehouse)]
  API[API Spring]

  S3 --> AF
  AF --> Glue
  Glue --> S3
  AF --> DBT
  DBT --> WH
  API --> WH
```

## Componentes

| Container | Responsabilidade | Repo/pasta |
|-----------|------------------|------------|
| Airflow | Orquestração, SLA | `airflow/` |
| Glue | Transformação batch | `glue/jobs/` |
| dbt | Modelagem analítica | `dbt/` |
| Lambda | Eventos leves | `lambdas/` |

## Contratos críticos

| De | Para | Contrato |
|----|------|----------|
| Origem | S3 | Schema arquivo, particionamento |
| Glue | S3 curated | Parquet, `data_referencia` |
| dbt | Warehouse | Models documentados em schema.yml |

## Decisões relacionadas

- ADRs: `docs/adr/`

## Manutenção

Atualizar quando adicionar/remover container ou mudar contrato público.
