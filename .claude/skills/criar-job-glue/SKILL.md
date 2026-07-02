---
name: criar-job-glue
description: >-
  Cria ou altera jobs AWS Glue com PySpark, transforms testáveis e escrita particionada.
  Use no repo {nome-projeto}-glue-* para ETL/ELT, bookmarks, integração com data lake S3
  e contratos com dbt/Airflow.
disable-model-invocation: true
---

# Criar job Glue (Claude Code)

**Repo alvo:** `{nome-projeto}-glue-{dominio}` | **Rule:** `.claude/rules/glue.md` | **Doc:** `docs/padroes/07-aws-glue.md`

## Pré-voo

1. Confirmar repo `-glue-*` (job por domínio ou fluxo).
2. Ler job similar: `jobs/`, `transforms/`, `tests/`.
3. Ler `07-aws-glue.md`: transforms testáveis, particionamento, skew, bookmarks.
4. Plano: fontes S3/catalog, schema de saída, partição, job params, contrato dbt source.

## Entradas

- `{nome-projeto}`, `{dominio}`, `{fluxo}`
- Fontes (S3 path, Glue Catalog, JDBC)
- Schema de saída e particionamento (`data_referencia`, etc.)
- Volume, SLA, `data_referencia` para idempotência
- Bookmark ou full/incremental

## Procedimento

### 1. Estrutura de arquivos

```
jobs/{dominio}_{fluxo}_job.py
transforms/{dominio}.py
transforms/common.py
tests/unit/test_transforms_{dominio}.py
tests/integration/                    # opcional, TaaC
README.md
```

### 2. Separação testável

```python
# transforms/vendas.py — testável sem Spark
def normalizar_status(status: str) -> str:
    return status.strip().upper()

# jobs/vendas_carga_job.py — wiring Spark
df = df.withColumn("status", normalizar_status_udf(col("status")))
```

- Lógica de negócio em funções puras ou testáveis com pandas local.
- UDF só quando necessário; preferir funções nativas Spark.

### 3. Escrita e particionamento

```
s3://{bucket}/curated/{dominio}/{entidade}/data_referencia=YYYY-MM-DD/
```

- `_SUCCESS` ou manifesto se contrato com Airflow sensor.
- Compressão (snappy/parquet) e schema estável documentado.
- Idempotência: overwrite na partição ou merge documentado.

### 4. Performance

- Filtro pushdown cedo (`data_referencia`).
- Repartition/coalesce consciente; salting em join com skew.
- Evitar `collect()` em volume alto.

### 5. Contratos multi-repo

| Consumidor | Repo | Contrato |
|------------|------|----------|
| dbt `source()` | `-dbt` | tabela/path, colunas, partição |
| Orquestração | `-airflow` | job name, `--data_referencia` |
| Infra job/role | `-infra` | Glue job TF, IAM S3 |

Atualizar `sources.yml` no dbt em PR irmão.

### 6. Testes

```bash
pytest tests/unit/ -v --cov=transforms --cov-fail-under=90
```

- Unitários em `transforms/` sem cluster Glue.
- TaaC com LocalStack/pyspark local se pipeline suportar.

### 7. Documentação

- README: parâmetros do job, paths, schema, reprocessamento.
- Exemplo de execução: `aws glue start-job-run --arguments ...`

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-glue.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Toda lógica no script do job | Extrair `transforms/` |
| Schema drift silencioso | Contrato + teste de colunas |
| Full scan diário | Partição + filtro |
| Join skew | Salting ou broadcast quando couber |
| Sem `_SUCCESS` | Alinhar com sensor Airflow |

## Reporte Claude

- Job e transforms alterados
- Path de saída e particionamento
- Comando pytest executado
- PRs irmãos (dbt sources, infra, airflow)

## Prompt

```
Repo datalake-glue-vendas. Skill criar-job-glue. Plano primeiro.
Job vendas_carga_diaria: raw → curated parquet particionado data_referencia.
transforms/ testável. pytest 90%. Documentar schema para dbt source.
```
