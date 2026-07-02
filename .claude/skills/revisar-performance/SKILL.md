---
name: revisar-performance
description: >-
  Analisa e propõe melhorias de performance e custo AWS em código do projeto.
  Use para gargalos, N+1, scans, cold start Lambda, jobs Spark lentos ou queries dbt caras.
disable-model-invocation: true
---

# Revisar performance (Claude Code)

**Repo alvo:** repo do componente | **Rule:** `.claude/rules/performance.md` | **Doc:** `docs/padroes/12-performance.md`

## Pré-voo

1. Definir sintoma: latência, custo AWS, timeout, SLA miss, query lenta.
2. Ler código no hot path; métricas/traces existentes se disponíveis.
3. Ler `12-performance.md`: volume, batch, partition, anti-padrões.
4. Plano: hipótese, medição, mudança mínima, risco de regressão.

## Entradas

- Componente e operação (endpoint, task DAG, job Glue, model dbt)
- Volume esperado (registros/dia, RPS, tamanho partição)
- Métricas atuais ou evidência (log, trace, EXPLAIN)
- Orçamento/custo se relevante

## Procedimento

### 1. Diagnóstico

| Stack | Verificar |
|-------|-----------|
| Lambda | cold start, memória, package size, I/O em loop |
| API Java | N+1, pool conexão, payload grande |
| Glue/Spark | skew, shuffle, UDF, full scan |
| dbt | full table scan, incremental ausente, join cartesiano |
| Airflow | paralelismo excessivo, sensor polling |
| Terraform | N/A código — rightsizing recursos |

### 2. Padrões de melhoria

```
Filtro cedo → batch/paginação → partition/cluster → cache consciente → escala horizontal
```

- **dbt:** incremental, pré-agregação em `int_`, `where` em staging.
- **Glue:** partition pushdown, broadcast join pequeno, salting skew.
- **Lambda:** batch SQS, connection reuse, arm/memory tuning.
- **API:** projeção DTO, paginação cursor, índice DB.

### 3. Medição

- Antes/depois com mesma carga (benchmark script ou métrica CloudWatch).
- Documentar no PR: baseline, ganho esperado, trade-off (complexidade/custo).

### 4. Custo AWS

- Glue DPU-hours, Lambda GB-s, S3 requests, Athena scanned data.
- Propor rightsizing com dados — não chute.

### 5. Multi-repo

| Gargalo | Repo provável |
|---------|---------------|
| Query cara no mart | `-dbt` |
| Job lento curated | `-glue-*` |
| Orquestração serial demais | `-airflow` |
| Lambda timeout | `-lambda-*` + memória TF em `-infra` |

Coordenar PRs se otimização cruza camadas (ex.: particionar no Glue + filtrar no dbt).

### 6. Testes

- Testes unitários não regredem.
- Benchmark opcional em `tests/perf/` se repo tiver padrão.
- Não otimizar prematuramente fora do hot path documentado.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md` (seção Performance)
- Stack: `checklists/code-review-performance.md` + checklist da stack

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Otimizar sem medir | Baseline primeiro |
| Micro-otimização em código frio | Focar hot path |
| Incremental errado (duplicata) | Validar `unique_key` + merge |
| Aumentar memória sem limite | Custo vs ganho |
| Cache sem TTL/invalidação | Definir política |

## Reporte Claude

- Gargalo identificado (evidência)
- Mudanças propostas/implementadas
- Ganho esperado ou medido
- Trade-offs e PRs irmãos

## Prompt

```
Repo datalake-dbt. Skill revisar-performance.
fct_vendas_pedidos lento em full refresh. Analisar plano, propor incremental + filtro staging.
Documentar baseline e ganho esperado. dbt build para validar.
```
