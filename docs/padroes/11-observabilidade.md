# Observabilidade

## Três pilares complementares

Logs (eventos discretos) + Métricas (agregação temporal) + Traces (caminho da requisição/job).

## Log estruturado — campos obrigatórios

```json
{
  "timestamp": "2025-07-02T10:15:30.123Z",
  "level": "INFO",
  "service": "datalake-lambda-processa-arquivo",
  "environment": "prod",
  "component": "ProcessarArquivoUseCase",
  "correlation_id": "abc-123",
  "operation": "processar_lote",
  "status": "SUCCESS",
  "duration_ms": 452,
  "record_count": 1500,
  "business_key_hash": "sha256:...",
  "error_type": null
}
```

| Campo | Regra |
|-------|-------|
| `business_key` | Hash/mascarar se PII |
| `file/key/path` | Só se não sensível |
| Payload completo | **Nunca** logar |

## Métricas técnicas

- Latência (p50, p95, p99)
- Throughput, taxa de erro, retries, timeouts
- Duração de job, registros processados/rejeitados
- Filas, concorrência, CPU/memória

## Métricas de negócio/processo

- Arquivos recebidos/processados
- Lotes e entidades processadas
- Falhas por tipo, pendências, atrasos, reprocessamentos

## Traces

- Propagar `correlation_id` / trace context entre Lambda → SQS → Glue.
- Spans em chamadas externas e etapas críticas.

## Alertas

- Alertar **sintoma** (atraso, taxa de erro), não só causa técnica.
- Severidade definida; link para runbook.
- Evitar ruído — thresholds revisados.

```yaml
# Exemplo conceitual
alert: pipeline_vendasAtrasoCarga
expr: datalake_vendas_atraso_minutos > 60
severity: high
runbook: docs/runbooks/carga-diaria-atraso.md
```

## Dashboards

| Tipo | Perguntas que responde |
|------|------------------------|
| Saúde executiva | Está processando? Atrasado? |
| Operacional | Onde falha? Precisa intervenção? |
| Técnico | Latência, erro, recursos |
| Dados | Volume, qualidade, freshness |
| Custo | Custo por job, scan dbt |

Template: `docs/padroes/templates/template-dashboard.md`.

## Por stack

| Stack | Sinal mínimo |
|-------|--------------|
| Airflow | callback falha + métrica task duration |
| dbt | `dbt run` artifacts + freshness |
| Lambda | Powertools metrics + structured logs |
| Spring | Micrometer + MDC correlation |
| Glue | custom metrics CloudWatch |
| Terraform | alarmes em recursos críticos |

## SLI / SLO (exemplo pipeline crítico)

| SLI | SLO | Janela |
|-----|-----|--------|
| % execuções DAG bem-sucedidas | ≥ 99% | 30 dias |
| Atraso vs SLA (minutos) | p95 < 30 min | 7 dias |
| Freshness source vendas | erro após 24h | diário |

**Burn rate:** alertar se taxa de falha na última 1h excede 5× o orçamento de erro mensal.

Runbook exemplo: `docs/runbooks/carga-diaria-atraso.md`.

## Integração com ferramentas

| Ferramenta | Logs | Métricas | Traces |
|------------|------|----------|--------|
| CloudWatch | Log groups JSON | Metric filters / EMF | X-Ray |
| Datadog | Agent / forwarder | Custom metrics | APM |
| Grafana + OTel | Loki | Prometheus/Mimir | Tempo |

Escolha a stack do ambiente; padrão de campos de log permanece igual.

## Propagação ponta a ponta de correlation_id

```
Airflow dag_run.conf → task env → Glue job args → Lambda payload → log dbt (vars)
```

Documentar no README do fluxo. Ver `docs/padroes/02-airflow.md`.

## Checklist no PR

- [ ] Logs JSON com correlation_id
- [ ] Métricas de sucesso/erro/duração
- [ ] Sem dados sensíveis em log
- [ ] Alerta/runbook se novo fluxo crítico

Ver `checklists/code-review-observabilidade.md`.
