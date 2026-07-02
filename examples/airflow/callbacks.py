"""Callback de falha — log estruturado para alertas."""
import logging

logger = logging.getLogger(__name__)


def padrao_on_failure_callback(context):
    ti = context["task_instance"]
    logger.error(
        "dag_task_failed",
        extra={
            "dag_id": ti.dag_id,
            "task_id": ti.task_id,
            "run_id": context.get("run_id"),
            "correlation_id": (context.get("dag_run").conf or {}).get("correlation_id"),
            "execution_date": str(context.get("execution_date")),
        },
    )
