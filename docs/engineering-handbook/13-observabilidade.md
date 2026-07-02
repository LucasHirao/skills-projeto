# 13 — Observabilidade (Datadog)

**Ferramenta padrão:** [Datadog](https://www.datadoghq.com/) para logs, métricas, APM (traces), alertas, SLOs e dashboards.

**Princípio:** se não dá para **ver**, **medir** e **alertar** em produção, o componente não está pronto para merge em fluxo crítico.

---

## 1. Três pilares complementares

| Pilar | O que é | Quando usar |
|-------|---------|-------------|
| **Logs** | Eventos discretos com contexto | Debug, auditoria, causa raiz |
| **Métricas** | Agregação temporal (contadores, gauges, histogramas) | Alertas, SLO, tendências, custo |
| **Traces** | Caminho da requisição/job entre serviços | Latência ponta a ponta, gargalos |

Os três devem compartilhar **tags e identificadores** (`service`, `env`, `version`, `correlation_id`) para correlação no Datadog.

---

## 2. Taxonomia de tags (obrigatória)

Toda telemetria enviada ao Datadog deve carregar, no mínimo:

| Tag | Exemplo | Regra |
|-----|---------|-------|
| `env` | `prod`, `hml`, `dev` | Alinhado ao ambiente AWS/conta |
| `service` | `datalake-lambda-processa-arquivo` | Um nome por deployável (Lambda, API, job Glue) |
| `version` | `1.4.2` ou git SHA curto | Release/deploy atual |
| `team` | `dados-vendas` | Owner operacional |

Tags adicionais recomendadas por domínio:

| Tag | Uso |
|-----|-----|
| `component` | Classe/módulo lógico (`ProcessarArquivoUseCase`) |
| `operation` | Operação de negócio (`processar_lote`) |
| `data_referencia` | Partição de negócio (baixa cardinalidade: dia, não timestamp) |
| `dag_id` / `task_id` | Airflow |
| `dbt_model` | dbt |
| `job_name` | Glue |

**Cardinalidade:** evitar tags com milhões de valores (`user_id`, `cpf`, `s3_key` completa). Para rastreio, usar hash ou amostragem.

---

## 3. Log estruturado — contrato

### 3.1 Campos obrigatórios

```json
{
  "timestamp": "2025-07-02T10:15:30.123Z",
  "level": "INFO",
  "service": "datalake-lambda-processa-arquivo",
  "env": "prod",
  "version": "1.4.2",
  "component": "ProcessarArquivoUseCase",
  "correlation_id": "abc-123-def",
  "operation": "processar_lote",
  "status": "SUCCESS",
  "duration_ms": 452,
  "record_count": 1500,
  "business_key_hash": "sha256:a1b2c3...",
  "error_type": null,
  "dd.trace_id": "1234567890",
  "dd.span_id": "9876543210"
}
```

| Campo | Regra |
|-------|-------|
| `correlation_id` | Propagado ponta a ponta (ver §10) |
| `business_key` / `business_key_hash` | Hash ou mascarar se PII |
| `file` / `key` / `path` | Só se não sensível; preferir prefixo de bucket |
| Payload completo | **Nunca** logar |
| `status` | `SUCCESS`, `FAILURE`, `PARTIAL`, `SKIPPED` |
| `error_type` | Classe/tipo estável (não stack trace inteiro no campo) |

### 3.2 Níveis de log

| Nível | Quando |
|-------|--------|
| `ERROR` | Falha que exige ação ou retry esgotado |
| `WARN` | Degradação, retry, dado inesperado recuperável |
| `INFO` | Início/fim de operação, contadores, marcos de negócio |
| `DEBUG` | Apenas em `dev`/`hml`; desligado em `prod` por padrão |

### 3.3 Stack trace

- Em `ERROR`: incluir stack trace **uma vez** no evento de falha.
- Não repetir o mesmo erro em loop (N+1 de log).

---

## 4. Ingestão de logs no Datadog

### 4.1 Arquitetura por tipo de workload

| Workload | Mecanismo recomendado | Notas |
|----------|----------------------|-------|
| **Lambda** | [Datadog Lambda Extension](https://docs.datadoghq.com/serverless/libraries_integrations/extension/) | Menor latência que Forwarder; layer + `DD_API_KEY` |
| **ECS/EKS/EC2** | Datadog Agent (sidecar ou daemonset) | Coleta logs do stdout JSON |
| **CloudWatch Logs** | [Forwarder](https://docs.datadoghq.com/logs/guide/forwarder/) ou integração AWS | Para legado ou quando Extension não couber |
| **Airflow (MWAA/self-hosted)** | Agent no worker + log task em JSON | Callbacks enviam métricas custom |
| **Glue** | CloudWatch → Forwarder ou subscription filter | Logs do driver/executor em JSON |

### 4.2 Configuração Lambda (referência)

```python
# handler.py — AWS Lambda Powertools + trace correlation automático
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger()
tracer = Tracer()
metrics = Metrics(namespace="Datalake")

@logger.inject_lambda_context(correlation_id_path="correlation_id")
@tracer.capture_lambda_handler
@metrics.log_metrics(capture_cold_start_metric=True)
def handler(event, context):
    correlation_id = event.get("correlation_id") or context.aws_request_id
    logger.append_keys(correlation_id=correlation_id, operation="processar_lote")
    # ...
    metrics.add_metric(name="RecordsProcessed", unit=MetricUnit.Count, value=1500)
```

Variáveis de ambiente mínimas:

```bash
DD_SITE=datadoghq.com          # ou datadoghq.eu
DD_API_KEY_SECRET_ARN=arn:...  # Secrets Manager, nunca plain text no TF
DD_SERVICE=datalake-lambda-processa-arquivo
DD_ENV=prod
DD_VERSION=1.4.2
DD_LOGS_INJECTION=true
DD_TRACE_ENABLED=true
```

### 4.3 Pipelines e índices

| Etapa | Ação |
|-------|------|
| **Pipeline** | Parser JSON → remapper de `service`/`env` → grok só se legado |
| **Índice** | `prod` indexado 15d; `dev` 3d; logs de debug excluídos |
| **Exclusion filter** | Health checks, ALB noise, logs `DEBUG` em prod |
| **Sensitive Data Scanner** | Mascarar CPF, cartão, e-mail em pipelines |

**Custo:** revisar volume indexado mensalmente. Log que não será consultado → exclusion filter ou retenção menor.

---

## 5. Métricas

### 5.1 Métricas técnicas (toda stack)

- Latência: p50, p95, p99 (`duration_ms`, APM)
- Throughput: registros/s, requests/s
- Taxa de erro: `errors / total`
- Retries, timeouts, throttling
- Duração de job, cold start (Lambda)
- Filas: depth, age of oldest message
- Recursos: CPU, memória, disco (quando aplicável)

### 5.2 Métricas de negócio/processo

- Arquivos recebidos / processados / rejeitados
- Lotes e entidades processadas por `data_referencia`
- Falhas por `error_type`
- Atraso vs SLA (`lag_minutes`, `freshness_hours`)
- Reprocessamentos e backfills manuais

### 5.3 Envio de custom metrics

| Método | Quando |
|--------|--------|
| **DogStatsD** (via Agent/Extension) | Lambda, containers, EC2 |
| **API HTTP** | Batch jobs pontuais |
| **EMF** (Embedded Metric Format) | CloudWatch → Datadog integration |
| **dbt artifacts** | `run_results.json` → métrica de duração/testes |

Exemplo DogStatsD (Python):

```python
from datadog import statsd

statsd.increment("datalake.arquivo.processado", tags=["env:prod", "status:success"])
statsd.histogram("datalake.arquivo.duration_ms", 452, tags=["env:prod"])
```

### 5.4 Naming convention

```
{domínio}.{entidade}.{métrica}
```

Exemplos: `datalake.vendas.lag_minutes`, `api.pedidos.latency_ms`, `dbt.fct_vendas.build_duration_s`.

---

## 6. APM (Distributed Tracing)

### 6.1 Instrumentação por stack

| Stack | Biblioteca | Spans mínimos |
|-------|------------|---------------|
| **Lambda Python** | `ddtrace` via Extension | handler, boto3, httpx |
| **Spring Boot** | `dd-java-agent` | controller, service, repository, HTTP client |
| **Glue** | Manual / OpenTelemetry bridge | leitura S3, transform, escrita |
| **Airflow** | Callback + trace context em env | task execute, operadores externos |
| **dbt** | Span em wrapper CI (opcional) | `dbt run` por model |

### 6.2 Propagação de contexto

- HTTP: headers `x-datadog-trace-id`, `x-datadog-parent-id`, `traceparent` (W3C).
- Assíncrono (SQS, EventBridge): incluir trace context no **body** ou **message attributes**.
- Batch (Glue, dbt): propagar `correlation_id` como mínimo; trace como desejável.

### 6.3 Service Map

Manter **um serviço Datadog por deployável**. Dependências (S3, RDS, DynamoDB, APIs) aparecem como nós externos — útil para identificar gargalo e blast radius.

---

## 7. Alertas e monitores

### 7.1 Princípios

1. Alertar **sintoma** (atraso, taxa de erro, freshness), não só causa técnica interna.
2. Todo alerta `high`/`critical` tem **runbook** linkado.
3. Evitar ruído: thresholds revisados após 2 semanas de baseline.
4. Preferir **composite monitors** (sintoma + confirmação) a alertas isolados ruidosos.

### 7.2 Tipos de monitor

| Tipo | Uso |
|------|-----|
| **Metric alert** | Threshold fixo (`error_rate > 5%`) |
| **Anomaly detection** | Volume sazonal (arquivos/dia) |
| **Log alert** | Padrão `status:FAILURE` > N em 5min |
| **APM alert** | Latência p95, error trace rate |
| **SLO alert** | Burn rate (ver §8) |
| **Composite** | `lag > 60min AND error_rate > 1%` |

### 7.3 Exemplo — atraso de pipeline

```yaml
# Conceito — criar no Datadog UI ou Terraform datadog_monitor
name: "[PROD] Pipeline vendas — atraso > 60 min"
type: metric alert
query: avg(last_15m):avg:datalake.vendas.lag_minutes{env:prod} > 60
message: |
  Pipeline de vendas atrasada. Ver runbook:
  https://github.com/org/repo/blob/main/docs/runbooks/carga-diaria-atraso.md
  @slack-dados-oncall
priority: P2
tags:
  - team:dados-vendas
  - runbook:carga-diaria-atraso
```

### 7.4 Severidade e roteamento

| Prioridade | Critério | Canal |
|------------|----------|-------|
| P1 | Dados críticos parados, impacto financeiro/regulatório | On-call + telefone |
| P2 | Degradação com workaround | Slack on-call |
| P3 | Risco iminente ou não-crítico | Slack time |
| P4 | Informativo / tendência | Dashboard only |

---

## 8. SLI, SLO e error budget

### 8.1 Exemplo — pipeline crítico de vendas

| SLI | Definição | SLO | Janela |
|-----|-----------|-----|--------|
| Disponibilidade | % execuções DAG `success` | ≥ 99% | 30 dias |
| Latência de entrega | `lag_minutes` p95 | < 30 min | 7 dias |
| Freshness | source `vendas_raw` atualizada | erro após 24h | diário |
| Qualidade | % `dbt test` passando no fluxo | ≥ 99.5% | 30 dias |

### 8.2 Burn rate alerting

Configurar no Datadog SLO:

- **Fast burn** (1h): consome 5× o error budget mensal → P1
- **Slow burn** (6h): consome 2× → P2

### 8.3 Error budget policy

Quando o budget estiver < 10%:

1. Freeze de features no fluxo afetado.
2. Priorizar hardening e débito de confiabilidade.
3. Postmortem se incidente causou burn significativo.

---

## 9. Dashboards

### 9.1 Tipos e audiência

| Dashboard | Perguntas | Audiência |
|-----------|-----------|-----------|
| **Executivo** | Está processando? Atrasado? Volume OK? | Negócio, gestão |
| **Operacional** | Onde falhou? Precisa intervenção? | Plantão, dados |
| **Técnico** | Latência, erro, cold start, recursos | Engenharia |
| **Dados** | Volume, qualidade, freshness, rejeições | Analytics, dados |
| **Custo** | Custo por job, scan dbt, invocações Lambda | FinOps, tech lead |

### 9.2 Template widgets Datadog

| Widget | Métrica exemplo |
|--------|-----------------|
| Query value | `avg:datalake.vendas.lag_minutes{env:prod}` |
| Timeseries | `sum:datalake.arquivo.processado{*}.as_count()` by `status` |
| Top list | `top(dbt.model.duration_s)` by `dbt_model` |
| Heatmap | Latência Lambda por versão |
| Log stream | `service:datalake-* status:FAILURE` |
| SLO widget | Disponibilidade pipeline vendas 30d |

Template completo: [`templates/dashboard.md`](templates/dashboard.md).

### 9.3 Manutenção

- **Owner** nomeado em cada dashboard.
- Revisão **trimestral** ou após mudança estrutural no fluxo.
- Dashboard sem uso em 90 dias → arquivar ou fundir.

---

## 10. Propagação de `correlation_id` ponta a ponta

```
Airflow dag_run.conf
  → task env (CORRELATION_ID)
    → Glue job args (--correlation_id)
      → Lambda payload (correlation_id)
        → dbt vars (correlation_id no log)
          → log JSON em todos os elos
```

**Regras:**

1. Gerar no **início** do fluxo (sensor, API, upload).
2. Se reprocessamento manual, prefixar: `reprocess-manual-{uuid}`.
3. Documentar no README do componente e no runbook.
4. No Datadog Logs: facet `correlation_id` para busca com um clique.

---

## 11. Observabilidade por stack

### 11.1 Airflow

| Sinal | Implementação |
|-------|---------------|
| Falha de task | Callback `on_failure_callback` → log JSON + métrica `airflow.task.failure` |
| Duração | `on_success_callback` → `airflow.task.duration_s` |
| SLA miss | Métrica custom ou log `SLA_MISS` |
| DAG parse | CI `airflow dags list` + teste de import |

```python
def on_failure_callback(context):
  ti = context["task_instance"]
  logger.error(
    "airflow_task_failed",
    extra={
      "dag_id": ti.dag_id,
      "task_id": ti.task_id,
      "run_id": context["run_id"],
      "correlation_id": context["dag_run"].conf.get("correlation_id"),
      "try_number": ti.try_number,
    },
  )
```

### 11.2 dbt

| Sinal | Implementação |
|-------|---------------|
| Build/test | Artefatos `run_results.json`, `sources.json` |
| Freshness | Source freshness → métrica `dbt.source.freshness_hours` |
| Duração por model | `dbt.model.build_duration_s` tag `dbt_model` |
| Falhas | Log estruturado no wrapper CI + alerta em `test_failure` |

### 11.3 Terraform

| Sinal | Implementação |
|-------|---------------|
| Alarmes | `datadog_monitor` ou CloudWatch → Datadog |
| Integração AWS | Conta AWS linked no Datadog (métricas CW) |
| Custo | Tags `env`, `service`, `team` em todos os recursos |

Recursos críticos que **devem** ter alarme: DLQ depth, Lambda errors, API 5xx, RDS CPU, fila age.

### 11.4 Lambda Python

- Powertools: Logger + Tracer + Metrics.
- Cold start metric habilitada.
- DLQ: alarme em `ApproximateNumberOfMessagesVisible > 0`.
- Ver capítulo [07 — Lambda Python](07-lambda-python.md).

### 11.5 Java Spring Boot

```java
// logback-spring.xml — MDC
MDC.put("correlation_id", correlationId);

// Micrometer → Datadog via Agent
@Timed(value = "api.pedidos.listar", percentiles = {0.95, 0.99})
public Page<PedidoResumo> listar(Pageable pageable) { ... }
```

- `dd-java-agent` em runtime (ECS/EKS/EC2).
- Actuator health **não** exposto publicamente sem auth.

### 11.6 AWS Glue

| Sinal | Implementação |
|-------|---------------|
| Job success/failure | Callback SNS/EventBridge → métrica |
| Duração | CloudWatch `glue.driver.aggregate.elapsedTime` |
| Registros | Custom metric no final do job |
| Skew | Log de partições desbalanceadas em `WARN` |

```python
# Final do job Glue
logger.info(
    "glue_job_completed",
    extra={
        "job_name": args["JOB_NAME"],
        "correlation_id": args["correlation_id"],
        "record_count": total,
        "duration_ms": elapsed,
        "status": "SUCCESS",
    },
)
```

---

## 12. Segurança em telemetria

| Risco | Mitigação |
|-------|-----------|
| PII em log | Sensitive Data Scanner + revisão de PR |
| API key Datadog | Secrets Manager; rotação trimestral |
| Cardinalidade explosiva | Review de tags em PR |
| Log de payload | Proibido — usar contadores e hashes |
| Acesso a dashboards | RBAC Datadog por time |

Ver [17 — Segurança, conformidade e dados sensíveis](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## 13. Checklist no PR

- [ ] Logs JSON com `correlation_id`, `service`, `env`, `status`
- [ ] Métricas de sucesso, erro, duração e volume (onde aplicável)
- [ ] Sem dados sensíveis em log ou tag de alta cardinalidade
- [ ] Trace/span em chamadas externas e hot path (APM)
- [ ] Monitor + runbook se fluxo novo ou criticidade alterada
- [ ] Dashboard atualizado ou criado (template `dashboard.md`)
- [ ] Tags `env`, `service`, `version`, `team` consistentes
- [ ] Exclusion filters consideradas se volume de log alto

---

## 14. Referências

- [Datadog — Logging Best Practices](https://docs.datadoghq.com/logs/guide/best-practices-for-logging/)
- [Datadog — Serverless](https://docs.datadoghq.com/serverless/)
- [Datadog — SLOs](https://docs.datadoghq.com/service_management/service_level_objectives/)
- Template dashboard: [`templates/dashboard.md`](templates/dashboard.md)
- Template runbook: [`templates/runbook.md`](templates/runbook.md)
- Runbook exemplo: [`../runbooks/carga-diaria-atraso.md`](../runbooks/carga-diaria-atraso.md)
- Capítulos relacionados: [14 — Performance](14-performance.md), [18 — Definition of Done](18-definition-of-done.md)
