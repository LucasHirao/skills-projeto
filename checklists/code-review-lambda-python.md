# Checklist: Code Review Lambda Python

## Perguntas objetivas

- [ ] Handler fino?
- [ ] Domínio testável sem boto3?
- [ ] Logs JSON + correlation_id?
- [ ] Secrets via Secrets Manager/SSM?
- [ ] DLQ/on-failure se async?
- [ ] Idempotência documentada?
- [ ] Cobertura ≥ 90%?
- [ ] mutmut em domain/application?

## 🔴 Bloqueio

- Credencial hardcoded
- `except Exception: pass`
- Regra de negócio só no handler

## 🟡 Atenção

- Cliente boto3 criado dentro do handler
- Package muito grande (cold start)

## Exemplos de comentário

> 🔴 API key em variável default no código — usar Secrets Manager.

> 🟡 Mover `boto3.client` para módulo nível com reuse.
