---
name: revisar-performance
description: >-
  Procedimento Devin para analisar e melhorar performance e custo AWS em código
  do projeto. Use para gargalos, queries lentas, jobs Spark, cold start ou SLA miss.
---

# Revisar performance (Devin)

**Playbook relacionado:** `devin/playbooks/hardening-performance-observabilidade.devin.md`

## Configuração da sessão Devin

1. Clone/checkout o repo onde está o gargalo (`-dbt`, `-glue-*`, `-lambda-*`, `-api-*`, `-airflow`).
2. Leitura de `docs/padroes/12-performance.md`.
3. Na sessão: sintoma (latência, custo, timeout), volume esperado, evidência (métrica, log, EXPLAIN).

## Busca obrigatória no repo

```text
hot path identificado no ticket/PR
métricas CloudWatch/Datadog se disponíveis
queries SQL / transforms / handler I/O
config memória timeout (Lambda, Glue DPU)
README com volume documentado
```

Meça ou peça baseline **antes** de otimizar.

## Diagnóstico por stack

| Repo | Sinais |
|------|--------|
| `-dbt` | full refresh grande, scan sem filtro, join cartesiano |
| `-glue-*` | skew, shuffle alto, UDF lenta |
| `-lambda-*` | timeout, cold start, loop S3 |
| `-api-*` | N+1, payload grande, sem paginação |
| `-airflow` | paralelismo excessivo, sensor agressivo |

## Passos de implementação

1. Documentar baseline (tempo, custo, registros).
2. Hipótese única por mudança — diff mínimo.
3. Aplicar padrão: filtro cedo → batch → partition → rightsizing.
4. Validar sem regressão funcional (testes existentes).
5. Medir depois ou estimar ganho com justificativa.
6. Documentar trade-off no PR (complexidade, custo infra).

## Coordenação multi-repo

| Gargalo observado | Provável fix em |
|-------------------|-----------------|
| Mart lento | `-dbt` incremental |
| Curated enorme | `-glue-*` particionamento |
| DAG espera demais | `-airflow` sensor/reschedule |
| Lambda timeout | `-lambda-*` + memória em `-infra` |

Otimização ponta a ponta pode exigir PRs coordenados — liste no reporte.

## Validação

```bash
# dbt
dbt build --select {model}+

# glue/lambda
pytest tests/unit/

# benchmark local se repo tiver tests/perf/
```

Incluir no PR: antes/depois ou EXPLAIN resumido.

## Checklists

- `checklists/code-review-performance.md`
- `docs/padroes/checklist-transversal.md` (Performance)

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-dbt

## Sintoma
full refresh 45min → alvo 10min

## Causa raiz
scan completo stg_ sem filtro data_referencia

## Mudanças
- filtro em stg_
- fct_ incremental merge

## Evidência
EXPLAIN / tempo dbt build: antes X, depois Y

## PRs irmãos
nenhum / glue particionamento

## Riscos
duplicata incremental — mitigação unique_key
```

## Não fazer

- Editar `.claude/`
- Otimizar sem baseline
- Aumentar DPU/memória sem análise de custo
- Incremental incorreto (duplicata ou perda)
