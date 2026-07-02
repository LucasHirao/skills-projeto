# Runbook: Carga diária atrasada

## Sintoma

- Alerta: `pipeline_atraso_minutos > 60`
- Dashboard operacional mostra última execução bem-sucedida há mais de 1 h do SLA
- Consumidores reportam dados desatualizados

## Severidade

**Alta** — impacto em relatórios e downstream dbt/marts.

## Impacto

Mart `fct_vendas_pedidos` e exposições dependentes podem estar defasados.

## Diagnóstico rápido

1. Airflow UI → DAG `datalake_vendas_carga_diaria` → última run e task falha.
2. Logs com `correlation_id` / `run_id` da execução.
3. Verificar sensor S3: arquivo de entrada chegou? (`s3://.../vendas/incoming/`)
4. Glue job: duração anormal? throttling?
5. dbt: último `dbt build` na task downstream.

## Causas comuns

| Causa | Como confirmar | Ação |
|-------|----------------|------|
| Arquivo fonte atrasou | S3 empty / sensor timeout | Contatar origem; reagendar |
| Glue falhou | CloudWatch logs job | Corrigir + reprocessar data_referencia |
| dbt test falhou | logs task dbt | Corrigir model; `dbt build --select fct+` |
| Concorrência indevida | 2 runs ativas | Pausar; `max_active_runs=1` |

## Reprocessamento

```bash
# Airflow CLI (ajustar ao ambiente)
airflow dags trigger datalake_vendas_carga_diaria \
  --conf '{"data_referencia": "2025-01-14", "correlation_id": "reprocess-manual-001"}'

# dbt pontual (se necessário)
dbt build --select tag:vendas --vars '{"data_referencia": "2025-01-14", "lookback_days": 3}'
```

**Idempotência:** merge por `pedido_id` — reprocessar mesma data é seguro (ver ADR-0001).

## Escalação

- Time de dados (plantão) — _preencher contato_
- Infra AWS se falha de capacidade Glue/Lambda

## Pós-incidente

- [ ] Atualizar este runbook se nova causa
- [ ] Revisar threshold do alerta se falso positivo
- [ ] ADR se mudança estrutural
