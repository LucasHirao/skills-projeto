---
name: criar-lambda-python
description: >-
  Cria ou altera Lambda Python com handler fino, domínio testável, logs estruturados
  e integração AWS. Use no repo {nome-projeto}-lambda-* para handlers, layers,
  domain/application/infrastructure e testes com mutmut.
disable-model-invocation: true
---

# Criar Lambda Python (Claude Code)

**Repo alvo:** `{nome-projeto}-lambda-{componente}` | **Rule:** `.claude/rules/lambda-python.md` | **Doc:** `docs/padroes/05-lambda-python.md`

## Pré-voo

1. Confirmar repo `-lambda-*` dedicado (um componente por repo ou convenção do time).
2. Ler Lambda similar: `handler.py`, `domain/`, `tests/`.
3. Ler `05-lambda-python.md`: camadas, Powertools, idempotência, DLQ.
4. Plano: trigger, formato evento, IAM necessário (PR em `-infra`?), contrato S3/SQS.

## Entradas

- `{nome-projeto}`, `{componente}`, trigger (S3, SQS, API GW, EventBridge)
- Schema do evento e payload
- Regras de negócio e idempotência
- DLQ, timeout, memória, reprocessamento

## Procedimento

### 1. Estrutura de arquivos

```
src/
  handler.py
  domain/{modulo}.py
  application/{caso_uso}.py
  infrastructure/{cliente_aws}.py
tests/
  unit/domain/test_{modulo}.py
  unit/application/test_{caso}.py
  unit/test_handler.py
pyproject.toml
README.md
```

### 2. Camadas

| Camada | Responsabilidade |
|--------|------------------|
| `domain/` | Regras puras, sem boto3 |
| `application/` | Orquestração, transações lógicas |
| `infrastructure/` | Clientes AWS, parsing de evento |
| `handler.py` | Wiring, Powertools, < 30 linhas de lógica |

```python
# handler.py — fino
@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
@tracer.capture_lambda_handler
def handler(event, context):
    comando = parse_event(event)
    resultado = processar(comando)
    return {"statusCode": 200, "body": resultado.model_dump_json()}
```

### 3. Observabilidade

- Log JSON: `correlation_id`, `componente`, contadores sucesso/erro.
- Métricas: registros processados, latência, falhas por tipo.
- Sem PII em log.

### 4. Integração e idempotência

| Trigger | Padrão |
|---------|--------|
| S3 | Validar bucket/key prefix; dedup por etag/versionId se necessário |
| SQS | Batch parcial; delete só após sucesso; DLQ configurada |
| API GW | Validação Pydantic na borda; Problem Details em erro |

### 5. Contratos multi-repo

| Dependência | Repo | Ação |
|-------------|------|------|
| IAM, Lambda, trigger | `-infra` | PR módulo TF antes ou em paralelo |
| Bucket/path S3 | produtor Glue/ingestão | README com contrato de objeto |
| Downstream dbt | `-dbt` | schema source se Lambda grava curated |

### 6. Testes

```bash
pytest tests/unit/ -v --cov=src --cov-fail-under=90
mutmut run   # domain/ e application/
```

- Domínio: zero mock AWS.
- Handler: mock clientes na borda.
- TaaC (skill `criar-taac`) se integração S3/SQS real na pipeline.

### 7. Documentação

- README: trigger, variáveis de ambiente, exemplo de evento, idempotência.
- Link para ARN/role no README `-infra` após merge.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-lambda-python.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Tudo no handler | Extrair domain/application |
| Credencial hardcoded | SSM/Secrets Manager |
| Retry infinito em erro de schema | Classificar erro recuperável vs fatal |
| Package gigante | Layer ou dependências mínimas |
| Sem DLQ em SQS | Configurar DLQ + alarme |

## Reporte Claude

- Arquivos alterados e trigger
- Cobertura e mutmut executados
- Variáveis de ambiente novas
- PR `-infra` necessário (ARN, IAM, trigger)

## Prompt

```
Repo datalake-lambda-processa-vendas. Skill criar-lambda-python. Plano primeiro.
Trigger S3 JSON em raw/vendas/. domain/ filtra APROVADO. Powertools, pytest 90%, mutmut domain/.
README com exemplo de evento.
```
