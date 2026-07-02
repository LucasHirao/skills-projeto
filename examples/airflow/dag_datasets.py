"""Produtor e consumidor com Airflow Datasets (Airflow 2.4+)."""
from datetime import datetime

from airflow.decorators import dag, task
from airflow.datasets import Dataset

CURATED_VENDAS = Dataset("s3://datalake-vendas-curated/vendas/")


@dag(
    dag_id="datalake_vendas_publica_dataset",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["datalake", "vendas"],
)
def publica():
    @task(outlets=[CURATED_VENDAS])
    def marcar_pronto():
        return "ok"

    marcar_pronto()


@dag(
    dag_id="datalake_vendas_dbt_pos_carga",
    schedule=[CURATED_VENDAS],
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["datalake", "vendas", "dbt"],
)
def consumir():
    @task(task_id="executar_dbt_vendas")
    def dbt_build():
        # Integração real: Cosmos ou BashOperator — ver examples/airflow/dbt_cosmos.py
        pass

    dbt_build()


publica()
consumir()
