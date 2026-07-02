# TaaC: {Nome do teste integrado}

- **Owner:** {time}
- **Stack:** {Lambda | Glue | Airflow | API | pipeline}
- **Repositório:** `{org}/{repo}`
- **Marcador pytest:** `taac`

## Objetivo

{Qual integração ponta a ponta este teste valida — contrato, não implementação interna.}

## Escopo

| In (real) | Out (mock/container) |
|-----------|----------------------|
| {ex.: S3 LocalStack, Postgres} | {ex.: API externa → WireMock} |

## Pré-requisitos

```bash
# Infra de teste
docker compose -f docker-compose.test.yml up -d

# Variáveis
export AWS_ENDPOINT_URL=http://localhost:4566
export DATABASE_URL=postgresql://...
```

## Estrutura

```
tests/
  integration/
    test_{nome}.py
  fixtures/
    {nome}/
      input.json
      expected_output.json
      setup_s3.sh
```

## Cenários

| ID | Cenário | Dado de entrada | Resultado esperado |
|----|---------|-----------------|-------------------|
| 1 | Happy path | `fixtures/.../input.json` | {arquivo no S3, registro no DB, status 200} |
| 2 | Entrada inválida | {fixture} | {DLQ, erro 400, métrica erro} |
| 3 | Idempotência | mesmo evento 2× | {sem duplicata} |
| 4 | {borda} | | |

## Dados de teste

- **Fixtures:** `tests/fixtures/{nome}/`
- **Anonimização:** sem PII real — dados sintéticos
- **Cleanup:** {truncate tables | delete S3 prefix | fixture autouse}

## Correlation ID no teste

```python
CORRELATION_ID = "taac-{nome}-001"

def test_deve_executar_caminho_feliz():
    event = {"correlation_id": CORRELATION_ID, ...}
    # assert logs/métricas rastreáveis por CORRELATION_ID em hml
```

## Execução

```bash
# Local
pytest tests/integration/test_{nome}.py -m taac -v --tb=short

# Com timeout
pytest tests/integration/test_{nome}.py -m taac -v --timeout=120
```

**Tempo máximo:** {ex.: 120s} — falhar cedo se travar.

## Pipeline CI

```yaml
integration:
  stage: test
  services:
    - docker:dind
  script:
    - docker compose -f docker-compose.test.yml up -d
    - pytest tests/integration -m taac -v --junitxml=report.xml
  artifacts:
    reports:
      junit: report.xml
```

## Critérios de aceite (DoD)

- [ ] Passa local e na CI
- [ ] Cobertura do **fluxo integrado**, não só unidade
- [ ] Documentado no README do componente
- [ ] Não depende de ordem de outros testes
- [ ] Cleanup garantido (sem vazamento entre runs)

## Debug

```bash
# Logs do container
docker compose -f docker-compose.test.yml logs -f {service}

# Reexecutar um cenário
pytest tests/integration/test_{nome}.py::test_happy_path -m taac -vv -s
```

## Referências

- [11 — TaaC](../11-taac-testes-integrados-na-pipeline.md)
- [18 — Definition of Done](../18-definition-of-done.md)
