---
name: criar-taac
description: >-
  Cria testes integrados autocontidos (TaaC) na pipeline com Testcontainers,
  LocalStack ou WireMock. Use para validar integração AWS, DB, API ou pipeline
  entre componentes sem ambiente compartilhado.
disable-model-invocation: true
---

# Criar TaaC (Claude Code)

**Repo alvo:** repo da stack com integração | **Rule:** `.claude/rules/testes.md` | **Doc:** `docs/padroes/09-taac-testes-integrados-pipeline.md`

## Pré-voo

1. Confirmar **qual integração** justifica TaaC (não substituir unitário).
2. Ler TaaC existente no repo (`tests/integration/`, `tests/taac/`).
3. Ler `09-taac-testes-integrados-pipeline.md`: isolamento, CI, ferramentas.
4. Plano: componentes sob teste, containers/mocks, dados seed, estágio CI.

## Entradas

- Componentes (Lambda + S3, API + DB, Airflow task + mock Glue, etc.)
- Ferramenta: LocalStack, Testcontainers, WireMock, moto
- Contrato de entrada/saída
- Tempo aceitável na pipeline CI

## Procedimento

### 1. Quando usar TaaC

| Cenário | TaaC | Unitário |
|---------|------|----------|
| Handler chama S3 real (emulado) | Sim | Mock na borda |
| SQL dbt com fixtures | Unit dbt | — |
| Fluxo HTTP API → DB | Sim (Testcontainers) | Use case mockado |
| Parse DAG | Unit | — |

### 2. Estrutura

```
tests/integration/test_{fluxo}_taac.py
tests/integration/conftest.py       # LocalStack/TC lifecycle
tests/integration/fixtures/         # payloads, SQL seed
.github/workflows/ci.yml            # estágio integration separado
```

### 3. Isolamento

- Container sobe no teste ou session fixture; **teardown** garantido.
- Portas dinâmicas; sem dependência de ambiente dev compartilhado.
- Dados sintéticos; sem PII real.

```python
@pytest.fixture(scope="module")
def s3_client(localstack):
    client = boto3.client("s3", endpoint_url=localstack.get_url())
    client.create_bucket(Bucket="test-bucket")
    yield client
```

### 4. Assert de contrato

- Validar estado final (objeto no S3, registro no DB, status HTTP).
- Não assertar implementação interna.

### 5. CI

- Estágio `integration` separado do `unit` (paralelo ou sequencial).
- Timeout explícito; retry só para infra flaky documentado.
- Imagem CI com Docker se Testcontainers.

### 6. Multi-repo

TaaC valida contrato **dentro** de um repo ou entre adapter e emulador.

Contratos cross-repo (Glue → dbt): documentar em ambos; TaaC no produtor valida saída; no consumidor valida leitura com fixture.

| Repo | TaaC típico |
|------|-------------|
| `-lambda-*` | LocalStack S3/SQS/DynamoDB |
| `-api-*` | Testcontainers Postgres |
| `-glue-*` | PySpark local ou sample parquet |
| `-airflow` | task com mock operator + fixture S3 |

### 7. Documentação

- README: como rodar TaaC local (`docker required`).
- Playbook relacionado: `devin/playbooks/criar-taac.devin.md` (sessões longas).

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-testes.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| TaaC lento demais na PR | Reduzir escopo; rodar em estágio nightly se necessário |
| Depende de AWS dev | LocalStack/Testcontainers |
| Sem cleanup | Fixture com yield/teardown |
| Testa tudo E2E | Um fluxo por teste focado |
| Dados compartilhados entre testes | Isolamento por teste |

## Reporte Claude

- Cenário integrado coberto
- Ferramenta e estágio CI
- Comando local + tempo aproximado
- Limitações conhecidas do emulador

## Prompt

```
Repo datalake-lambda-processa-vendas. Skill criar-taac.
TaaC: upload S3 LocalStack → handler → item DynamoDB. Fixture isolada.
Estágio integration na CI. README com docker compose se necessário.
```
