---
name: criar-taac
description: >-
  Procedimento Devin para criar testes integrados autocontidos (TaaC) na pipeline
  com LocalStack, Testcontainers ou WireMock. Use no repo da stack com integração real.
---

# Criar TaaC (Devin)

**Playbook relacionado:** `devin/playbooks/criar-taac.devin.md` (sessões longas ou pipeline E2E)

## Configuração da sessão Devin

1. Clone/checkout o repo que contém o componente integrado (`-lambda-*`, `-api-*`, etc.).
2. Leitura de `docs/padroes/09-taac-testes-integrados-pipeline.md`.
3. Na sessão: fluxo a validar, ferramenta (LocalStack/TC/WireMock), requisito Docker na CI.

## Busca obrigatória no repo

```text
tests/integration/ ou tests/taac/
tests/conftest.py            → lifecycle de containers
.github/workflows/ci.yml     → estágio integration
docker-compose.yml           → se existir
README.md                    → como rodar local
```

Se não existir TaaC no repo, copie padrão de outro repo **da mesma stack** do time.

## Quando TaaC (e quando não)

| Vale TaaC | Fica no unitário |
|-----------|------------------|
| Handler + S3 emulado | Regra de domínio pura |
| API + Postgres TC | Use case com mock |
| Contrato de escrita S3 | Parse de DAG |

## Passos de implementação

1. **Cenário único** por teste — focado, não E2E gigante.
2. **Fixture** sobe container/emulador; teardown garantido.
3. **Dados sintéticos** — sem PII; seed por teste.
4. **Assert** estado final (objeto S3, HTTP status, row DB).
5. **CI** — estágio `integration` separado; timeout explícito.
6. **README** — `docker required`, comando local.

## Coordenação multi-repo

| Fluxo | Onde validar |
|-------|--------------|
| Glue escreve → dbt lê | TaaC no Glue (saída); unit dbt com fixture |
| Lambda → fila → Lambda | TaaC no consumidor com LocalStack SQS |
| API → evento | WireMock ou TC no `-api-*` |

Documentar contrato entre repos no reporte; não um TaaC monolítico cross-clone.

## Validação

```bash
pytest tests/integration/ -v
# ou job CI integration
```

Medir tempo — se > limite da pipeline, propor nightly ou escopo menor.

## Checklists

- `checklists/code-review-testes.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-lambda-x

## Cenário TaaC
upload S3 → handler → DynamoDB

## Ferramenta
LocalStack 3.x

## Arquivos
tests/integration/test_fluxo_taac.py

## CI
estágio integration — tempo ~Xs

## Limitações
emulador vs AWS real

## PRs irmãos
contrato documentado em ...
```

## Não fazer

- Editar `.claude/`
- Depender de ambiente dev compartilhado
- Testes flaky sem cleanup
- Substituir unitários por TaaC lento em todo PR
