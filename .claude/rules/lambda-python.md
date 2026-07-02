# Regra: Lambda Python

**Doc:** `docs/padroes/05-lambda-python.md` | **Checklist:** `checklists/code-review-lambda-python.md`

## Escopo

Repo `{nome-projeto}-lambda-{funcao}/`.

## Estrutura

`handler.py` (fino) → `application/` → `domain/` | `infrastructure/`

## Faça

- Powertools: Logger, Tracer, Metrics.
- Pydantic na borda do evento.
- Clientes boto3 fora do handler (warm start).
- Secrets via Secrets Manager/SSM.
- Log JSON + `correlation_id`.
- Classificar erro: recuperável (retry/DLQ) vs contrato (não retry).
- pytest ≥90%; mutmut em domain/application.

## Não faça

- Regra de negócio no handler.
- Credencial hardcoded.
- `except Exception: pass`.

## Critérios de aceite

- [ ] Domínio testável sem AWS
- [ ] README com formato evento e idempotência
