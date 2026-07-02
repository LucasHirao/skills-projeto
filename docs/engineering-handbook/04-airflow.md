# 04 — Airflow

> **Versão:** 1.0 · **Repo:** `{nome-projeto}-airflow` · **Observabilidade:** Datadog · **Orquestração apenas — não processamento pesado**

---

## Sumário

1. [Objetivo](#1-objetivo)
2. [Público-alvo](#2-público-alvo)
3. [Problemas comuns](#3-problemas-comuns)
4. [Princípios](#4-princípios)
5. [Decisões](#5-decisões)
6. [Trade-offs](#6-trade-offs)
7. [Quando usar / não usar Airflow](#7-quando-usar--não-usar-airflow)
8. [Estrutura de pastas](#8-estrutura-de-pastas)
9. [Convenções](#9-convenções)
10. [Práticas obrigatórias e recomendadas](#10-práticas-obrigatórias-e-recomendadas)
11. [Anti-padrões](#11-anti-padrões)
12. [Exemplos bom / ruim](#12-exemplos-bom--ruim)
13. [Código de referência](#13-código-de-referência)
14. [Integrações](#14-integrações)
15. [Idempotência e backfill](#15-idempotência-e-backfill)
16. [Estratégias transversais](#16-estratégias-transversais)
17. [Checklists](#17-checklists)
18. [Critérios de aceite](#18-critérios-de-aceite)
19. [Definition of Done](#19-definition-of-done)
20. [FAQ](#20-faq)
21. [Guia júnior](#21-guia-júnior)
22. [Guia sênior](#22-guia-sênior)

---

## 1. Objetivo

Padronizar **orquestração de pipelines** com Apache Airflow no ecossistema `{nome-projeto}`: DAGs legíveis, testáveis, idempotentes, observáveis no **Datadog** e integradas a Glue, Lambda, dbt e S3 sem concentrar regra de negócio.

**Regra de ouro:** a DAG **coordena**; Glue/dbt/Lambda **executam**; domain modules **decidem** regras testáveis.

---

## 2. Público-alvo

Engenheiros de dados que mantêm `{nome-projeto}-airflow`, revisores de PR de DAG, SRE que opera backfill e alertas, e integradores que consomem Datasets ou `dag_run.conf`.

---

## 3. Problemas comuns

| Problema | Sintoma | Impacto |
|----------|---------|---------|
| God DAG | Um arquivo com SQL, HTTP, Spark | Untestable, MTTR alto |
| Import pesado no parse | Conexão DB no topo do módulo | Scheduler lento / timeout |
| Sem idempotência | Re-run duplica dados | Incidente de qualidade |
| `catchup=True` acidental | Centenas de runs | Custo e caos |
| Email como alerta | Caixa ignorada | Falha notada tarde |
| Variable com secret | Senha em metadata DB | Vazamento |
| Tasks dinâmicas opacas | `for i in range(1000)` sem pool | Worker OOM |

---

## 4. Princípios

### AF1 — DAG é código de produção

Versionada, revisada, testada no CI como qualquer serviço.

### AF2 — Orquestração ≠ transformação

Volume e SQL pertencem a Glue/dbt; DAG dispara e valida pré-condições.

### AF3 — Declarativo quando possível

Dependências explícitas; `doc_md` e tags; config em YAML.

### AF4 — Idempotência por `data_referencia`

Reprocessamento seguro documentado.

### AF5 — Observabilidade Datadog, não email

Callbacks estruturados; métricas por task; link runbook.

### AF6 — Falha controlada

Retries com backoff; pools para recursos escassos; timeout em toda task.

### AF7 — Um DAG por arquivo

Facilita ownership e testes de import.

---

## 5. Decisões

| ID | Decisão | Detalhe |
|----|---------|---------|
| AF-D01 | TaskFlow API (`@task`) como padrão | Operators legados só se necessário |
| AF-D02 | `catchup=False` default | Backfill manual documentado |
| AF-D03 | `max_active_runs=1` para escritas | Salvo leitura paralela segura |
| AF-D04 | Airflow Datasets para deps entre DAGs | Preferir a cron acoplado |
| AF-D05 | dbt via Astronomer Cosmos | BashOperator cru só exceção |
| AF-D06 | `email_on_failure=False` | Datadog monitor |
| AF-D07 | Variables `{nome-projeto}_{chave}` | Secrets em backend seguro |
| AF-D08 | `correlation_id` = `run_id` ou conf | Propagar a downstream |

---

## 6. Trade-offs

### 6.1 TaskFlow vs. Operators clássicos

| TaskFlow | Operators |
|----------|-----------|
| Python idiomático | Integração nativa AWS |
| XCom tipado implícito | UI familiar ops |

**Híbrido comum:** `@task` para lógica leve + `GlueJobOperator` para jobs.

### 6.2 Sensor vs. Dataset

| Sensor S3 | Dataset |
|-----------|---------|
| Polling (custo) | Push declarativo |
| Simples | Melhor lineage AF2.4+ |

### 6.3 BashOperator dbt vs. Cosmos

Cosmos: seleção de models, renderização de vars, menos shell injection.

---

## 7. Quando usar / não usar Airflow

### Use Airflow quando

- Schedule cron ou baseado em dados (Datasets)
- Pipeline batch com múltiplas etapas e dependências
- Necessidade de backfill auditável
- Coordenação Glue + dbt + validações

### Não use Airflow quando

- Latência sub-segundo (use Lambda/API)
- Streaming contínuo (Kinesis/Flink — fora escopo padrão)
- Script one-shot sem schedule (CLI/Step Functions)
- Toda lógica caberia em um único job Glue com mesmo custo operacional

---

## 8. Estrutura de pastas

```
{nome-projeto}-airflow/
├── README.md
├── dags/
│   └── {nome-projeto}_{dominio}_{fluxo}.py    # Um DAG por arquivo
├── plugins/
│   └── app/
│       ├── operators/                          # Custom operators finos
│       ├── hooks/
│       └── sensors/
├── include/app/{dag_name}/
│   ├── config.yaml                             # Config não-secreto
│   └── tasks.py                                # Funções @task delegam aqui
├── tests/
│   ├── dags/                                   # Import, structure, cycles
│   └── unit/                                   # tasks.py, domain
├── docs/
│   └── runbooks/
└── .github/workflows/ ou CI equivalente
```

**Não colocar:** Terraform (→ `{nome-projeto}-infra`), models dbt (→ `{nome-projeto}-dbt`).

---

## Padrões de código da stack

Índice rápido — detalhes neste capítulo:

| Tópico | Seção |
|--------|-------|
| Estrutura de pastas | [§8](#8-estrutura-de-pastas) |
| Convenções e nomenclatura | [§9](#9-convenções) |
| Práticas obrigatórias | [§10](#10-práticas-obrigatórias-e-recomendadas) |
| Anti-padrões | [§11](#11-anti-padrões) |
| Exemplos | [§12](#12-exemplos-bom--ruim) |
| Checklists | [§17](#17-checklists) |
| Logging seguro | [13 — Observabilidade](13-observabilidade.md#logging-seguro-e-dados-sensíveis) |

Transversal: [03 — Padrões de código](03-padroes-de-codigo.md) · [18 — DoD](18-definition-of-done.md)

---

## 9. Convenções

### 9.1 Naming

| Campo | Padrão | Exemplo |
|-------|--------|---------|
| `dag_id` | `{nome-projeto}_{dominio}_{fluxo}` | `datalake_vendas_carga_diaria` |
| `task_id` | `{verbo}_{objeto}` | `validar_arquivo_entrada` |
| Arquivo DAG | igual ao `dag_id` | `datalake_vendas_carga_diaria.py` |
| tags | projeto, domínio, criticidade | `["datalake", "vendas", "critical"]` |
| pool | `{recurso}_pool` | `glue_pool` |

### 9.2 DEFAULT_ARGS

```python
from datetime import timedelta
from include.app.common.callbacks import callback_falha_datadog, callback_sucesso_datadog

DEFAULT_ARGS = {
    "owner": "time-dados",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay": timedelta(minutes=30),
    "execution_timeout": timedelta(hours=2),
    "email_on_failure": False,
    "on_failure_callback": callback_falha_datadog,
    "on_success_callback": callback_sucesso_datadog,  # opcional métricas
}
```

### 9.3 Variables e Connections

| Tipo | Convenção | Segredo? |
|------|-----------|----------|
| Variable | `{nome-projeto}_{chave}` | **Não** |
| Connection | `{servico}_{ambiente}` | Credencial no backend |
| `dag_run.conf` | `correlation_id`, `data_referencia` | — |

Nunca hardcodar bucket, ARN ou URL de prod.

---

## 10. Práticas obrigatórias e recomendadas

### Obrigatórias

1. `doc_md` na DAG com SLA, idempotência e owner
2. Testes: import sem erro + estrutura mínima
3. Callback Datadog em falha (log + métrica)
4. `correlation_id` propagado a Glue/dbt/Lambda
5. Lógica em `include/app/.../tasks.py` testável
6. Pools para Glue concorrente
7. Runbook linkado em monitor de DAG crítica

### Recomendadas

1. `render_template_as_native_obj=True` quando útil
2. SLA miss callback para métrica de atraso
3. `priority_weight` em tasks críticas
4. Deferrable operators quando disponível (reduz worker slot)
5. Tag `version` alinhada ao deploy para Datadog

---

## 11. Anti-padrões

| Anti-padrão | Correção |
|-------------|----------|
| SQL inline na DAG | dbt model |
| `time.sleep` em task | Sensor ou deferrable |
| Variable rotativa manual | TF + env |
| 50 tasks geradas dinamicamente sem doc | SubDAGs/grupos ou job único Glue |
| XCom gigante (dataframe) | S3 path pequeno no XCom |
| Múltiplos DAGs no mesmo arquivo | Separar arquivos |
| `depends_on_past=True` sem análise | Documentar ou remover |

---

## 12. Exemplos bom / ruim

### 12.1 Estrutura DAG

**Ruim:**

```python
# dags/tudo.py — 3 DAGs, SQL, requests no import
def dag1(): ...
def dag2(): ...
requests.get("https://api.example.com/health")  # no import!
```

**Bom:**

```python
"""DAG: carga diária de arquivos. SLA: 06:00 UTC. Idempotente por data_referencia."""
from airflow.decorators import dag, task
from include.app.arquivos.tasks import validar_arquivo_entrada, executar_processamento_glue
from include.app.common.callbacks import callback_falha_datadog
from include.app.common.defaults import DEFAULT_ARGS

@dag(
    dag_id="datalake_carga_diaria_arquivos",
    schedule="0 4 * * *",
    catchup=False,
    max_active_runs=1,
    tags=["datalake", "carga-diaria"],
    default_args=DEFAULT_ARGS,
    doc_md=__doc__,
    on_failure_callback=callback_falha_datadog,
)
def datalake_carga_diaria_arquivos():
    @task(task_id="validar_arquivo_entrada")
    def validar():
        return validar_arquivo_entrada()

    @task(task_id="executar_processamento_glue")
    def executar_glue():
        executar_processamento_glue()

    validar() >> executar_glue()

datalake_carga_diaria_arquivos()
```

### 12.2 Callback Datadog

**Ruim:** `print(context)` no callback.

**Bom:**

```python
import logging
from datadog import statsd

logger = logging.getLogger(__name__)

def callback_falha_datadog(context):
    ti = context["task_instance"]
    dag_id = ti.dag_id
    task_id = ti.task_id
    run_id = context["run_id"]
    logger.error(
        "airflow_task_failed",
        extra={
            "correlation_id": run_id,
            "dag_id": dag_id,
            "task_id": task_id,
            "run_id": run_id,
            "operation": "airflow_task",
            "status": "ERROR",
            "try_number": ti.try_number,
            "log_url": ti.log_url,
        },
    )
    statsd.increment(
        "airflow.task.failure",
        tags=[f"dag_id:{dag_id}", f"task_id:{task_id}", "env:prod"],
    )
```

---

## 13. Código de referência

### 13.1 DAG com S3 Sensor + Glue

```python
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.decorators import dag
from datetime import datetime

@dag(
    dag_id="datalake_vendas_carga_diaria",
    start_date=datetime(2025, 1, 1),
    schedule="0 4 * * *",
    catchup=False,
    max_active_runs=1,
    default_args=DEFAULT_ARGS,
)
def vendas_carga():
    aguardar_arquivo = S3KeySensor(
        task_id="aguardar_arquivo_pedidos",
        bucket_key="vendas/pedidos/dt={{ ds }}/_SUCCESS",
        bucket_name="{{ var.value.datalake_landing_bucket }}",
        timeout=60 * 60 * 2,
        poke_interval=300,
        mode="reschedule",
    )
    executar_glue = GlueJobOperator(
        task_id="executar_glue_carga_vendas",
        job_name="datalake-vendas-carga-{{ var.value.env }}",
        script_args={
            "--data_referencia": "{{ ds }}",
            "--correlation_id": "{{ run_id }}",
        },
        pool="glue_pool",
        pool_slots=2,
    )
    aguardar_arquivo >> executar_glue

vendas_carga()
```

### 13.2 Airflow Datasets (produtor / consumidor)

```python
# Produtor
from airflow.datasets import Dataset

LANDING_DATASET = Dataset("s3://datalake-landing/vendas/pedidos")

@task(outlets=[LANDING_DATASET])
def publicar_dataset(): ...

# Consumidor — schedule por dataset
@dag(schedule=[LANDING_DATASET], ...)
def datalake_dbt_vendas(): ...
```

### 13.3 dbt via Cosmos (resumo)

```python
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig

dbt_tg = DbtTaskGroup(
    group_id="dbt_vendas",
    project_config=ProjectConfig("/opt/dbt/{nome-projeto}-dbt"),
    profile_config=ProfileConfig(...),
    operator_args={
        "vars": {"data_referencia": "{{ ds }}", "correlation_id": "{{ run_id }}"},
        "select": ["tag:vendas"],
    },
)
```

Detalhes dbt: [05-dbt.md](05-dbt.md).

### 13.4 HttpOperator

```python
HttpOperator(
    task_id="notificar_sistema_externo",
    endpoint="/api/v1/eventos",
    method="POST",
    data='{"correlation_id": "{{ run_id }}", "data_referencia": "{{ ds }}"}',
    timeout=30,
    extra_options={"check_response": True},
)
```

4xx: falha de contrato — não retry infinito. 5xx: retry via `default_args`.

### 13.5 Testes

```python
# tests/dags/test_vendas_carga_diaria.py
def test_dag_deve_carregar_sem_erro(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert dag is not None
    assert len(dag.tasks) > 0

def test_dag_deve_ter_estrutura_esperada(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert dag.max_active_runs == 1
    assert dag.catchup is False
    assert "validar_lote_entrada" in dag.task_ids

def test_dag_nao_deve_ter_ciclos(dag_bag):
    assert len(dag_bag.import_errors) == 0
```

---

## 14. Integrações

| Destino | Padrão | Notas |
|---------|--------|-------|
| **Glue** | `GlueJobOperator`, pool | Job em `{nome-projeto}-glue-*` |
| **Lambda** | `LambdaInvokeOperator` | Payload com correlation_id |
| **dbt** | Cosmos TaskGroup | Após staging disponível |
| **S3** | Sensor ou Dataset | Path versionado em contrato |
| **ECS** | `EcsRunTaskOperator` | Container custom |
| **REST** | `HttpOperator` | Timeout + idempotency key |

Contratos cross-repo: [02-arquitetura-transversal.md](02-arquitetura-transversal.md).

---

## 15. Idempotência e backfill

### Chaves

- `data_referencia` = `{{ ds }}` ou `dag_run.conf`
- Partição S3 `dt={{ ds }}`
- dbt vars alinhadas

### Backfill CLI

```bash
airflow dags backfill datalake_vendas_carga_diaria \
  -s 2025-01-01 -e 2025-01-07 \
  --reset-dagruns --yes
```

| Situação | catchup | max_active_runs |
|----------|---------|-----------------|
| Reprocessar histórico pontual | False + backfill manual | 1 |
| Nova DAG com histórico legítimo | True com janela limitada | 1 |
| DAG contínua diária | False | 1 |

Documentar em runbook: impacto em marts downstream e ordem com dbt.

---

## 16. Estratégias transversais

### Testes

- DAG: import, cycles, estrutura, SLA defaults
- Unit: `tasks.py`, domain
- TaaC: pipeline staging com dados sintéticos — [11-taac-testes-integrados-na-pipeline.md](11-taac-testes-integrados-na-pipeline.md)

### Observabilidade (Datadog)

- Log JSON em callbacks
- Métricas: `airflow.task.failure`, `airflow.dag.duration`, `airflow.sla.miss`
- Dashboard por domínio — [templates/dashboard.md](templates/dashboard.md)
- Trace: opcional via OpenTelemetry se plataforma habilitar

[13-observabilidade.md](13-observabilidade.md)

### Performance

- `mode="reschedule"` em sensors longos
- Evitar task Python pesada — mover para Glue
- Limitar dynamic task mapping

[14-performance.md](14-performance.md)

### Segurança

- RBAC Airflow; Connection sem senha em Variable
- `dag_run.conf` validado antes de passar a shell

[17-seguranca-conformidade-e-dados-sensiveis.md](17-seguranca-conformidade-e-dados-sensiveis.md)

### Documentação

- `doc_md` + README com diagrama
- Runbook backfill e falha de sensor

[15-documentacao.md](15-documentacao.md)

---

## 17. Checklists

### 17.1 Implementação

- [ ] `dag_id` segue convenção
- [ ] Um DAG por arquivo
- [ ] `catchup` e `max_active_runs` conscientes
- [ ] DEFAULT_ARGS completos
- [ ] Sem secret em Variable
- [ ] tasks.py testado
- [ ] correlation_id propagado
- [ ] Pools configurados
- [ ] Testes DAG no CI

### 17.2 Code review

- [ ] Sem negócio pesado na DAG?
- [ ] Sem I/O no import?
- [ ] Integração com contrato S3 atual?
- [ ] Monitor Datadog/runbook se crítico?
- [ ] [16-code-review.md](16-code-review.md)

### 17.3 Operação

- [ ] Runbook de backfill
- [ ] SLA documentado
- [ ] Escalonamento owner
- [ ] Pause DAG procedure

---

## 18. Critérios de aceite

- [ ] DAG parseia sem erro em staging
- [ ] Backfill de 1 dia idempotente verificado
- [ ] Falha de task gera log Datadog pesquisável por `correlation_id`
- [ ] Downstream (dbt) notificado se schedule muda

---

## 19. Definition of Done

[18-definition-of-done.md](18-definition-of-done.md) + específico Airflow:

- [ ] Testes DAG verdes
- [ ] doc_md completo
- [ ] Callback Datadog configurado
- [ ] Runbook se DAG critical tag
- [ ] PR referencia [04-airflow.md](04-airflow.md)

---

## 20. FAQ

**P: Posso rodar dbt no PythonOperator?**  
R: Use Cosmos; BashOperator só com justificativa no PR.

**P: Quantas tasks por DAG?**  
R: Sem limite rígido; se > 30, avaliar consolidar em Glue ou grupos lógicos.

**P: Variable vs. env?**  
R: Variable para config operacional Airflow; secrets sempre backend seguro.

**P: Falha de sensor às 3h — o que fazer?**  
R: Runbook: verificar landing S3, produtor Glue, atraso upstream; re-trigger com conf.

---

## 21. Guia júnior

Comece copiando DAG mínima da seção 12. Escreva teste de import antes de pedir review. Nunca coloque senha na DAG — pergunte onde fica a Connection.

---

## 22. Guia sênior

Proteja o scheduler: bloqueie imports pesados no review. Exija Dataset em vez de cadeia cron frágil entre times. Calibre pools com métricas Glue real. Incidentes de duplicate data → revisar idempotência e ordem com dbt.

---

*Anterior:* [03 — Padrões de código](03-padroes-de-codigo.md) · *Próximo:* [05 — dbt](05-dbt.md)
