"""dbt via Astronomer Cosmos — esboço. Ajuste profile e paths ao ambiente."""
# from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig
# from airflow.decorators import dag
#
# @dag(...)
# def datalake_dbt_vendas():
#     DbtTaskGroup(
#         group_id="dbt_vendas",
#         project_config=ProjectConfig(dbt_project_path="/opt/dbt"),
#         profile_config=ProfileConfig(...),
#         operator_args={"vars": {"data_referencia": "{{ ds }}"}},
#     )
