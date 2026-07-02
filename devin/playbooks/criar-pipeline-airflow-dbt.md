# Playbook — Criar pipeline Airflow + dbt

Prompt reutilizável para pipelines de dados ponta a ponta (Terraform → Glue/Lambda → dbt → Airflow).

## Fonte de verdade

- [04 — Airflow](../../docs/engineering-handbook/04-airflow.md)
- [05 — dbt](../../docs/engineering-handbook/05-dbt.md)
- [02 — Arquitetura transversal](../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

---

## Nomenclatura de código

Ao implementar ou revisar código:

- Use português para identificadores internos criados pelo time.
- Preserve nomes externos, SDKs, frameworks, contratos públicos, schemas, comandos e tags técnicas.
- Não renomeie contrato público existente sem versionamento/migração.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).


## Prompt

```
Projete e implemente um pipeline de dados no ecossistema {nome-projeto} (multi-repo).

## Contexto
Repos envolvidos (ajustar):
- {org}/{nome-projeto}-terraform — IAM, buckets, filas
- {org}/{nome-projeto}-glue — job de ingestão/transformação (se aplicável)
- {org}/{nome-projeto}-dbt — modelos staging → mart
- {org}/{nome-projeto}-airflow — DAG de orquestração

Contrato de dados:
- Grain: {ex. pedido por dia}
- Chave: {ex. pedido_id}
- Path S3: s3://{bucket}/{prefix}/{data_referencia}/
- correlation_id: propagado em dag_run.conf e logs
- data_referencia: formato {YYYY-MM-DD}

Objetivo: {resultado de negócio observável — ex. mart pedidos_diario atualizado D+1}

## Antes de editar (obrigatório)
Apresente **plano multi-repo** com:
1. Diagrama textual da ordem: TF → Glue → dbt → Airflow
2. Um PR por repositório (não misturar)
3. Idempotência e estratégia de backfill
4. SLAs e owner da DAG
5. Testes: unitários + TaaC do contrato S3/schema
6. Observabilidade: métricas Datadog por etapa
7. Dúvidas de negócio não documentadas

## Implementação por fase
### Fase 1 — Infra ({nome-projeto}-terraform)
Skill: criar-modulo-terraform. IAM least privilege, tags, alarmes.

### Fase 2 — Processamento ({nome-projeto}-glue ou lambda)
Skill: criar-job-glue ou criar-lambda-python. Transforms testáveis.

### Fase 3 — Modelagem ({nome-projeto}-dbt)
Skill: criar-modelo-dbt. staging → intermediate → mart; testes schema.yml.

### Fase 4 — Orquestração ({nome-projeto}-airflow)
Skill: criar-dag-airflow. DAG fina; callbacks Datadog; doc_md com SLA.

### Fase 5 — TaaC
Skill: criar-taac. Validar contrato ponta a ponta na CI.

## Evidências finais
- terraform plan/validate por repo
- dbt build + test
- airflow dags list / parse test
- TaaC verde
- Links dos PRs irmãos
- Dashboard/monitor Datadog se fluxo crítico

Critério: [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md) em todos os repos tocados.
```

---

## Quando usar

- Novo fluxo de ingestão até mart
- Pipeline que cruza 3+ repositórios
- Substituição de pipeline legado com contrato novo
