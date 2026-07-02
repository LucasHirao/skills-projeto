---
name: criar-modelo-dbt
description: Cria ou altera modelos dbt (staging, intermediate, mart) no {nome-projeto} com testes, documentação e contratos de dados. Use ao criar model SQL, incremental, source freshness ou exposure.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{nome-projeto}-dbt models/{camada}/{nome_modelo}.sql {objetivo}"
triggers:
  - criar modelo dbt
  - novo mart dbt
  - incremental dbt
  - source freshness
---

# criar-modelo-dbt

## Fonte de verdade

- [05 — dbt](../../../docs/engineering-handbook/05-dbt.md)
- [02 — Arquitetura transversal](../../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Novo modelo em `{nome-projeto}-dbt`
- Materialização incremental, snapshot ou seed
- Testes de schema, uniqueness, relationships, unit tests dbt

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- dbt: models internos em português após prefixo técnico (ex.: `stg_{nome-projeto}__arquivos_recebidos`).
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Passos

1. Ler modelos da mesma camada (`staging` → `intermediate` → `mart`).
2. **Plano** com grain, chaves, impacto downstream e ordem vs Glue/Airflow.
3. SQL legível; CTEs nomeadas; sem `SELECT *` em produção.
4. `schema.yml` com descrição, testes e tags.
5. `dbt build` / `dbt test` local; documentar backfill se incremental.
6. Exposures se consumidor externo (BI, API).

## Checklist DoD (recorte)

- [ ] Grain e PK documentados
- [ ] Testes dbt no `schema.yml`
- [ ] Materialização consciente (table/incremental/view)
- [ ] Sem PII exposta sem mascaramento
- [ ] CI dbt verde

## Templates

- [readme-componente](../../../docs/engineering-handbook/templates/readme-componente.md)
- [decisao-tecnica](../../../docs/engineering-handbook/templates/decisao-tecnica.md)

## Não fazer

Ver anti-padrões em [05 — dbt](../../../docs/engineering-handbook/05-dbt.md).
