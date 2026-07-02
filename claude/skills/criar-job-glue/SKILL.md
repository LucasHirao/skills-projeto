---
name: criar-job-glue
description: Criar ou alterar jobs AWS Glue em {nome-projeto} com transformações testáveis, argumentos tipados e observabilidade Datadog.
---

# Criar job Glue

## Quando usar

- Novo job ETL PySpark ou Python shell
- Alteração de transformação, partições ou argumentos
- Integração com S3, Catálogo e downstream dbt/Airflow

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [09 — AWS Glue](../../../docs/engineering-handbook/09-aws-glue.md)
- [02 — Arquitetura transversal](../../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [14 — Performance](../../../docs/engineering-handbook/14-performance.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Glue/PySpark: funções de transformação e módulos internos em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `{nome-projeto}-glue` |
| Job name | Sim | `processar_vendas_diario` |
| Fonte / destino | Sim | `s3://raw/vendas/` → `s3://trusted/vendas/` |
| Volume | Sim | 5M registros/dia |
| Orquestração | Sim | DAG `{nome-projeto}-airflow` |

## Passos

1. Plano: schema, partições, idempotência, custo DPU.
2. Separar transformações testáveis (`transforms/`) do entrypoint Glue.
3. Argumentos via `getResolvedOptions` — tipados e documentados.
4. Escrita idempotente por `data_referencia`/partição.
5. Logs JSON + métricas Datadog (duração, registros, erros).
6. Evitar collect/shuffle desnecessário; broadcast quando cabível.
7. Testes unitários em funções puras de transformação.
8. TaaC com amostra de dados sintéticos se integração S3.
9. README com argumentos, SLA e reprocessamento.
10. Coordenar Terraform (IAM, job definition) e DAG Airflow.

## Checklist de qualidade

- [ ] Transformação legível; sem god script
- [ ] Schema de saída documentado
- [ ] Compatível com contrato downstream (dbt source)

## Checklist de testes

- [ ] Unitários em transforms ≥ 90%
- [ ] TaaC se valida escrita S3/catálogo
- [ ] Fixture de dados representativa (sem PII real)

## Checklist de observabilidade

- [ ] Logs JSON com `correlation_id`, `data_referencia`
- [ ] Métricas de volume e duração
- [ ] Alarme Glue + runbook se crítico

## Checklist de desempenho

- [ ] Partição e predicate pushdown
- [ ] DPU/worker dimensionados ao volume
- [ ] Sem O(n²) em joins

## Checklist de segurança

- [ ] IAM least privilege no job role
- [ ] Dados sensíveis mascarados ou excluídos
- [ ] Bucket policies alinhadas

## Critérios de aceite

- DoD Glue em [18](../../../docs/engineering-handbook/18-definition-of-done.md) §2.6
- Job roda em hml com `data_referencia` de teste

## O que não fazer

- Toda lógica no `main` do script Glue
- Full scan sem filtro de partição
- Schema implícito sem contrato
- Ignorar custo de shuffle

## Como reportar

- Argumentos do job e paths S3
- Estimativa de volume e DPU
- Comandos de teste local/pytest
- PRs irmãos (Terraform, Airflow)

## Fonte de verdade

- [09 — AWS Glue](../../../docs/engineering-handbook/09-aws-glue.md)
