# Regra: Lambda Python

**Doc:** `docs/padroes/05-lambda-python.md` | **Checklist:** `checklists/code-review-lambda-python.md`

## Faça

- Handler fino; domínio em `domain/`
- Powertools: Logger, Tracer, Metrics
- Clientes boto3 fora do handler (reuse)
- Secrets via Secrets Manager/SSM
- pytest 90% + mutmut em domain/application

## Não faça

- Credencial no código
- `except Exception: pass`
- Log de payload sensível

## Erros

- Recuperável → retry/DLQ | Contrato inválido → não retry cego
