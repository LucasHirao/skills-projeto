---
name: criar-testes-unitarios
description: >-
  Procedimento Devin para criar ou melhorar testes unitários com cobertura 90% e
  asserts de comportamento. Use no repositório de código da stack em edição.
---

# Criar testes unitários (Devin)

## Configuração da sessão Devin

1. Clone/checkout o **repo de código** onde vive o módulo (não o repo de padrões).
2. Leitura de `docs/padroes/08-testes-unitarios.md`.
3. Na sessão: caminho do código, comportamentos críticos, ferramenta (pytest/JUnit/dag_bag).

## Busca obrigatória no repo

```text
tests/unit/ ou src/test/     → padrão de teste existente
tests/conftest.py            → fixtures
pyproject.toml / pom.xml     → cobertura e mutmut
.github/workflows/           → como CI roda testes
```

Replique estilo de assert e naming do **mesmo** repo.

## Escopo unitário por stack

| Repo | Testar | Não testar aqui |
|------|--------|-----------------|
| `-lambda-*` | `domain/`, `application/` | S3 real |
| `-api-*` | use cases, domain | DB real |
| `-airflow` | `tasks.py`, parse DAG | cluster |
| `-glue-*` | `transforms/` | Glue cluster |
| `-dbt` | unit SQL YAML | warehouse |
| `-infra` | `tftest.hcl` | apply prod |

## Passos de implementação

1. Listar comportamentos: happy path, bordas, erros esperados.
2. Um teste por comportamento; nome descritivo.
3. Mock **só na borda** (boto3, HTTP, DB).
4. Fixtures em `conftest.py` ou `tests/fixtures/`.
5. Rodar cobertura; meta **≥ 90%** no módulo alvo.
6. **mutmut** / PIT em domain/application se o repo usa.
7. PR: comando para rodar subset de testes.

## Coordenação multi-repo

Testes unitários ficam no repo do código. Integração real → skill `criar-taac`.

Não adicionar testes no repo `orientacoes` (padrões).

## Validação

```bash
# Python
pytest tests/unit/ -v --cov={pacote} --cov-fail-under=90

# Java
./mvnw test jacoco:report

# Airflow
pytest tests/dags/ tests/unit/
```

## Checklists

- `checklists/code-review-testes.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-{stack}

## Módulo coberto
src/domain/validacao.py

## Arquivos de teste
tests/unit/test_validacao.py

## Comando
pytest ... → cobertura X%

## Gaps
justificativa se < 90%

## Mutation
mutmut score (se aplicável)
```

## Não fazer

- Editar `.claude/`
- Teste sem assert de comportamento
- TaaC disfarçado de unitário (LocalStack no unit/)
- Cobertura fake importando sem exercitar lógica
