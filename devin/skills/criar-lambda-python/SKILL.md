---
name: criar-lambda-python
description: >-
  Procedimento Devin para criar ou alterar Lambda Python em camadas com testes e
  integração AWS. Use no repositório {nome-projeto}-lambda-{componente}.
---

# Criar Lambda Python (Devin)

**Playbook relacionado:** `devin/playbooks/criar-componente-aws.devin.md`

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-lambda-{componente}`**.
2. Leitura de `docs/padroes/05-lambda-python.md`.
3. Na sessão: trigger (S3/SQS/API), schema do evento, idempotência, DLQ, PR infra necessário.

## Busca obrigatória no repo lambda

```text
src/handler.py               → padrão de entrada
src/domain/                  → regras testáveis
src/application/             → orquestração
src/infrastructure/          → clientes AWS
tests/unit/                  → cobertura e mutmut
pyproject.toml               → deps e scripts
README.md                    → evento exemplo
```

## Especificação

| Item | Valor |
|------|-------|
| Handler | fino; Powertools logger/metrics/tracer |
| Domínio | sem boto3; pytest ≥ 90% |
| Idempotência | documentada no README |
| Erros | recuperável (retry) vs fatal (DLQ) |

## Passos de implementação

1. **domain/** — funções puras com type hints.
2. **application/** — caso de uso; injeção de portas.
3. **infrastructure/** — parse evento, clientes boto3.
4. **handler.py** — wiring; `correlation_id` no log.
5. **tests/unit/** — domínio sem mock AWS; handler com mock na borda.
6. **mutmut** em domain/application se configurado.
7. **README** — trigger, env vars, exemplo JSON, link para TF.

## Coordenação multi-repo

| Dependência | Repo | Ordem |
|-------------|------|-------|
| Lambda, IAM, trigger | `-infra` | TF antes ou paralelo |
| Bucket/path origem | `-glue-*` | contrato de objeto |
| Destino analítico | `-dbt` | source se grava curated |

Não fazer deploy manual sem outputs do infra documentados.

## Validação

```bash
pytest tests/unit/ -v --cov=src --cov-fail-under=90
mutmut run   # se configurado
```

TaaC: ver skill `criar-taac` se integração na pipeline.

## Checklists

- `checklists/code-review-lambda-python.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-lambda-{componente}

## Trigger
S3 / SQS / ...

## Arquivos
- src/...
- tests/...

## Testes
pytest → cobertura X%

## Env vars novas
...

## PRs irmãos
- [ ] datalake-infra: módulo lambda + IAM

## Riscos
timeout, volume, DLQ
```

## Não fazer

- Editar `.claude/`
- Toda lógica no handler
- Credenciais no código
- Merge sem PR infra quando Lambda nova
