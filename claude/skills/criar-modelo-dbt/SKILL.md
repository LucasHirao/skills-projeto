---
name: criar-modelo-dbt
description: Criar ou alterar modelos dbt em {nome-projeto}-dbt com camadas, testes, documentação e integração Airflow.
---

# Criar modelo dbt

## Quando usar

- Novo modelo staging/intermediate/mart
- Estratégia incremental, testes ou `schema.yml`
- Exposures, sources ou freshness

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [05 — dbt](../../../docs/engineering-handbook/05-dbt.md)
- [04 — Airflow](../../../docs/engineering-handbook/04-airflow.md) (integração Cosmos)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- dbt: models internos em português após prefixo técnico (ex.: `stg_{nome-projeto}__arquivos_recebidos`).
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `{nome-projeto}-dbt` |
| Camada | Sim | `staging`, `intermediate`, `mart` |
| Nome do modelo | Sim | `mart_vendas_diario` |
| Fonte / upstream | Sim | `stg_vendas`, source `raw.vendas` |
| Materialização | Sim | `view`, `table`, `incremental` |

## Passos

1. Plano: camada, grain, chaves, materialização e impacto downstream.
2. Criar SQL com CTEs legíveis; sem `select *` em produção.
3. Definir materialização e `unique_key` se incremental.
4. Documentar em `schema.yml` (model + colunas críticas).
5. Adicionar testes (`unique`, `not_null`, `relationships`) em colunas de negócio.
6. Atualizar `exposures` se consumidor externo.
7. Configurar freshness em sources críticos.
8. `dbt build` local verde.
9. Coordenar com DAG Airflow se schedule mudou.

## Checklist de qualidade

- [ ] Grain explícito; staging não exposto a consumidor final
- [ ] Descriptions em português no `schema.yml`
- [ ] Macros documentadas se usadas

## Checklist de testes

- [ ] `dbt build` (run + test) verde
- [ ] Testes em colunas críticas de negócio
- [ ] Unit test dbt se lógica complexa (ver cap. 05)

## Checklist de observabilidade

- [ ] Métricas de build na CI/Datadog
- [ ] Tag `dbt_model` onde aplicável

## Checklist de desempenho

- [ ] Materialização adequada ao volume
- [ ] Incremental com `unique_key` documentado
- [ ] Sem cross join evitável

## Checklist de segurança

- [ ] Sem PII exposta em mart sem classificação
- [ ] Acesso via roles documentado

## Critérios de aceite

- DoD dbt em [18](../../../docs/engineering-handbook/18-definition-of-done.md) §2.2
- Lineage claro; consumidores atualizados

## O que não fazer

- Lógica de negócio só no BI
- Mart sem teste
- Staging como dependência de dashboard
- Incremental sem estratégia de merge/delete

## Como reportar

- Modelos criados/alterados e grain
- Saída resumida de `dbt build`
- Impacto em exposures e DAGs irmãs

## Fonte de verdade

- [05 — dbt](../../../docs/engineering-handbook/05-dbt.md)
