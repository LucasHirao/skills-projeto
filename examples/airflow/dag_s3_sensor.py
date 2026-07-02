"""Exemplo: S3 sensor + conf com correlation_id. Ver docs/padroes/02-airflow.md."""
from datetime import datetime, timedelta

from airflow.decorators import dag, task
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor

from examples.airflow.callbacks import padrao_on_failure_callback

DEFAULT_ARGS = {
    "owner": "time-dados",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": padrao_on_failure_callback,
}


@dag(
    dag_id="datalake_vendas_aguarda_arquivo",
    schedule="0 3 * * *",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    max_active_runs=1,
    tags=["datalake", "vendas"],
    default_args=DEFAULT_ARGS,
)
def datalake_vendas_aguarda_arquivo():
    aguardar = S3KeySensor(
        task_id="aguardar_arquivo_entrada",
        bucket_name="datalake-vendas-raw-{{ var.value.get('env', 'dev') }}",
        bucket_key="vendas/incoming/{{ ds }}/_SUCCESS",
        poke_interval=60,
        timeout=60 * 60,
        mode="reschedule",
    )

    @task(task_id="registrar_correlation_id")
    def registrar(**context):
        return {"correlation_id": context["run_id"], "data_referencia": context["ds"]}

    aguardar >> registrar()


datalake_vendas_aguarda_arquivo()
