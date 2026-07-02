# AWS Glue

## Princípio

Glue job é ETL/ELT **distribuído** — separar leitura, transformação pura, escrita e observabilidade.

## Estrutura

```
glue/jobs/carga_vendas/
├── job.py              # entrypoint, wiring Spark/GlueContext
├── config.py
├── io/
│   ├── reader.py
│   └── writer.py
├── transforms/
│   └── vendas.py       # funções puras testáveis
└── tests/
    ├── unit/
    └── spark_local/
```

## Transformação testável

```python
# transforms/vendas.py — testável sem Spark
def normalizar_status(status: str | None) -> str:
    if not status:
        return "DESCONHECIDO"
    return status.strip().upper()

# Uso em PySpark — preferir colunas nativas
from pyspark.sql import functions as F

def aplicar_normalizacao(df):
    return df.withColumn("status", F.upper(F.trim(F.col("status"))))
```

**Por quê evitar UDF:** menos otimização Catalyst, mais serialização Python-JVM.

## Job — wiring

```python
def run_job():
    args = parse_glue_args()
    spark = build_spark_session()
    df = read_parquet(spark, args["input_path"])
    df = aplicar_normalizacao(df)
    df = filtrar_por_data(df, args["data_referencia"])
  write_partitioned(df, args["output_path"], partition_cols=["data_referencia"])
    emit_metric("registros_escritos", df.count())  # ok em job controlado; evitar em loop
```

## Escrita particionada

```python
def write_partitioned(df, path, partition_cols):
    (df.write
       .mode("overwrite")  # ou append — documentar idempotência
       .partitionBy(*partition_cols)
       .parquet(path))
```

## Performance Spark

| Faça | Não faça |
|------|----------|
| Predicate pushdown em Parquet | `collect()` em dataset grande |
| Broadcast join em dimensão pequena | Join sem filtro prévio |
| Particionar por `data_referencia` | Converter para pandas sem necessidade |
| Tratar skew (salting) quando medido | UDF para trim/upper |

## Testes

- Funções puras: pytest.
- Transformações DataFrame: Spark local com fixture pequena (10-100 linhas).
- Schema validation com `assertSchemaEquals` ou Great Expectations.

## Bookmarks e incremental

Ver `examples/glue/job_args.py` — `job-bookmark-enable` e reprocessamento documentado.

## Skew

```python
# Salting em join com skew conhecido
df = df.withColumn("salt", (F.rand() * num_salts).cast("int"))
```

## Exemplos

- `examples/glue/transforms_vendas.py`
- `examples/glue/job_args.py`

## Code review

Ver `checklists/code-review-glue.md`.
