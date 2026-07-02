# Playbook — Investigar falha de pipeline

Prompt reutilizável para investigação de incidentes em pipelines de dados ou integrações do `{nome-projeto}`.

## Fonte de verdade

- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md)
- [16 — Code review](../../docs/engineering-handbook/16-code-review.md)
- [Template runbook](../../docs/engineering-handbook/templates/runbook.md)
- Capítulo da stack afetada em [`docs/engineering-handbook/`](../../docs/engineering-handbook/)

---

## Prompt

```
Investigue uma falha de pipeline no ecossistema {nome-projeto}.

## Sintoma
- O que quebrou: {task falhou | dados ausentes | duplicata | atraso SLA}
- Quando: {timestamp UTC, primeira ocorrência, frequência}
- Ambiente: {prod | staging | dev}
- Componente: {DAG | Glue job | Lambda | dbt model | Airflow sensor}
- correlation_id / dag_run_id / execution_id: {ids se disponíveis}
- Impacto: {downstream afetados, SLAs, volume}

## Evidência inicial
- Logs Datadog: {query ou trecho sanitizado — sem PII}
- Métricas: {spike de erro, duração, volume}
- Stack trace / mensagem de erro: {copiar}
- Mudanças recentes: {PRs, deploys, alteração de schema}

## Antes de corrigir (obrigatório)
1. Apresente **hipóteses ordenadas por probabilidade** (mín. 3).
2. Para cada hipótese: evidência a favor/contra e próximo passo de validação.
3. Plano de reprodução: teste unitário ou TaaC mínimo **antes** do fix.
4. Avalie impacto em dados: reprocessar? backfill? idempotência?

## Investigação
- Rastreie correlation_id ponta a ponta (Airflow → Glue/Lambda → S3 → dbt)
- Verifique contrato (schema, path, partição, data_referencia)
- Compare com run bem-sucedido recente
- Não alterar produção sem plano de rollback

## Correção
- Fix **mínimo** + teste de regressão
- Atualizar runbook se lacuna operacional ([template](../../docs/engineering-handbook/templates/runbook.md))
- Se regra de negócio unclear: escalar humano — não inventar

## Evidências finais
- Causa raiz (1 parágrafo)
- Timeline do incidente
- PR com fix + teste
- Ações preventivas (monitor, alerta, TaaC)
- Plano de reprocessamento se necessário

Critério: incidente reproduzível por teste; MTTR reduzido na próxima ocorrência.
```

---

## Quando usar

- Task Airflow vermelha
- Dados incorretos ou ausentes no lake/warehouse
- Falha intermitente em Lambda/Glue/dbt
- Pós-mortem inicial antes do documento formal
