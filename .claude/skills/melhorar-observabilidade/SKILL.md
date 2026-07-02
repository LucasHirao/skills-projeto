---
name: melhorar-observabilidade
description: >-
  Adiciona ou corrige logs estruturados, métricas, traces e alertas conforme padrões do repositório.
  Use quando faltar correlation_id, telemetria, runbook ou dashboard em componente existente.
disable-model-invocation: true
---

# Melhorar observabilidade (Claude Code)

**Repo alvo:** repo do componente | **Rule:** `.claude/rules/observabilidade.md` | **Doc:** `docs/padroes/11-observabilidade.md`

## Pré-voo

1. Identificar componente e stack (Lambda, API, Glue, Airflow, dbt exposures).
2. Ler telemetria **existente** — não remover sem ADR.
3. Ler `11-observabilidade.md`: logs JSON, métricas, traces, alertas, runbooks.
4. Plano: gaps (correlation_id, métricas sucesso/erro, alertas), fluxo crítico?

## Entradas

- Caminho do componente (`handler.py`, DAG, job Glue, controller)
- Fluxo crítico? (SLA, on-call)
- Ferramentas do time (CloudWatch, Datadog, OpenTelemetry, Powertools)
- Dados sensíveis — o que **não** logar

## Procedimento

### 1. Logs estruturados

```python
logger.info("registro_processado", extra={
    "correlation_id": correlation_id,
    "componente": "processa_vendas",
    "registros_ok": n,
    "registros_erro": e,
})
```

| Campo | Obrigatório |
|-------|-------------|
| `correlation_id` | Propagar do trigger (SQS, API header, `dag_run`) |
| `componente` / `servico` | Identificação no agregador |
| Contadores | sucesso, erro, duração |

- JSON; sem PII; nível adequado (INFO operacional, ERROR com contexto).

### 2. Métricas

| Tipo | Exemplos |
|------|----------|
| Contador | `registros_processados`, `falhas_validacao` |
| Histograma | `duracao_processamento_ms` |
| Gauge | `fila_pendente` (se aplicável) |

- Dimensões: `ambiente`, `dominio`, `versao` (baixa cardinalidade).
- Airflow: callback métricas custom ou statsd se repo usa.

### 3. Traces

- OpenTelemetry ou X-Ray em handlers/API.
- Span por chamada externa (S3, DB, HTTP).

### 4. Alertas e runbooks

Fluxo **crítico** novo ou alterado:

- Alerta: condição, severidade, canal.
- Runbook: sintoma, diagnóstico, mitigação, rollback.
- Link runbook no `doc_md` da DAG ou README do componente.

### 5. Por stack

| Stack | Foco |
|-------|------|
| Lambda | Powertools Logger/Metrics/Tracer |
| Spring | MDC + Micrometer |
| Airflow | `on_failure_callback` JSON; SLA miss |
| Glue | logs driver + métricas job custom |
| dbt | exposures + freshness alerts |

### 6. Multi-repo

- Alertas em `-infra` (CloudWatch alarms TF) vs código no repo da app.
- Documentar dashboard compartilhado no README do time.

### 7. Testes

- Assert que log contém `correlation_id` (caplog em pytest).
- Não quebrar testes existentes ao adicionar telemetria.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-observabilidade.md` + checklist da stack

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| `print` / log texto livre | JSON estruturado |
| PII em log | Mascarar ou omitir |
| Métrica alta cardinalidade | Reduzir labels |
| Remover métrica legada | ADR + período de transição |
| Alerta sem runbook | Documentar antes do merge |

## Reporte Claude

- Campos/métricas/traces adicionados
- Alertas e runbooks criados ou referenciados
- PR `-infra` se alarm TF necessário
- Como validar em dev/staging

## Prompt

```
Repo datalake-lambda-processa-vendas. Skill melhorar-observabilidade.
Adicionar correlation_id, métricas registros_ok/erro, trace S3/DynamoDB.
Runbook se fluxo crítico. Testes caplog para correlation_id.
```
