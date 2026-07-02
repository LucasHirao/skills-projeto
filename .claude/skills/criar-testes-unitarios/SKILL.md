---
name: criar-testes-unitarios
description: >-
  Cria ou melhora testes unitários com cobertura 90% e asserts de comportamento.
  Use em qualquer repo de código para pytest, JUnit, testes de DAG parse, transforms
  ou domínio sem integração real.
disable-model-invocation: true
---

# Criar testes unitários (Claude Code)

**Repo alvo:** repo da stack em edição | **Rule:** `.claude/rules/testes.md` | **Doc:** `docs/padroes/08-testes-unitarios.md`

## Pré-voo

1. Identificar módulo alvo e stack (Python, Java, Airflow, dbt unit, etc.).
2. Ler testes existentes no mesmo pacote/pasta.
3. Ler `08-testes-unitarios.md`: pirâmide, cobertura, mutation, anti-padrões.
4. Plano: comportamentos a cobrir, fixtures, mocks na borda, meta 90%.

## Entradas

- Caminho do código sob teste (`domain/`, `transforms/`, `tasks.py`, etc.)
- Comportamentos críticos e casos de borda
- Ferramenta: pytest, JUnit 5, unittest dbt, dag_bag
- Meta mutation (domain/application) se aplicável

## Procedimento

### 1. O que testar (por stack)

| Stack | Alvo unitário | Evitar |
|-------|---------------|--------|
| Lambda Python | `domain/`, `application/` | boto3 real |
| Spring | use cases, domain | `@SpringBootTest` para unit |
| Airflow | `tasks.py`, parse DAG | cluster Airflow |
| Glue | `transforms/` | Spark cluster |
| dbt | SQL com inputs YAML | warehouse real |
| Terraform | `tftest.hcl` | apply em prod |

### 2. Estrutura

```
tests/unit/test_{modulo}.py
tests/conftest.py          # fixtures compartilhadas
tests/fixtures/            # JSON/YAML de entrada
```

### 3. Padrão de teste

```python
def test_rejeita_pedido_sem_id():
    with pytest.raises(ValidationError, match="pedido_id"):
        validar_pedido(Pedido(pedido_id=None, status="APROVADO"))
```

- Arrange / Act / Assert explícitos.
- Um conceito por teste; nome descreve comportamento.
- Parametrize para matriz de entradas equivalentes.

### 4. Mocks

- Mock só na **borda** (boto3, HTTP, DB).
- Não mockar a unidade sob teste.
- Evitar assert em ordem interna de chamadas frágil.

### 5. Cobertura e mutation

```bash
# Python
pytest tests/unit/ --cov=src/domain --cov-fail-under=90
mutmut run --paths-to-mutate src/domain/

# Java
./mvnw test jacoco:report

# Airflow
pytest tests/dags/ tests/unit/
```

- Justificar no PR se < 90% em módulo legado (plano de remediação).

### 6. Multi-repo

Testes unitários vivem no **mesmo repo** do código. Não criar pasta de testes no repo de padrões.

Se o teste precisa de integração real → skill `criar-taac`.

### 7. Documentação

- Comentário mínimo; nome do teste deve bastar.
- README ou PR: comando para rodar subset de testes.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-testes.md` + checklist da stack afetada

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Teste sem assert relevante | Assert resultado ou exceção |
| Cobertura fake (só import) | Testar comportamento |
| Teste flaky (sleep, rede) | Unit puro ou TaaC |
| Mock excessivo no domain | Testar lógica real |
| 100% no handler | Focar domain/application |

## Reporte Claude

- Arquivos de teste criados
- Comando executado + cobertura obtida
- Gaps conhecidos e justificativa
- Mutation score se rodado

## Prompt

```
Repo datalake-lambda-processa-vendas. Skill criar-testes-unitarios.
Cobrir domain/validacao.py: casos APROVADO, REJEITADO, pedido inválido.
pytest --cov=src/domain --cov-fail-under=90. mutmut em domain/.
```
