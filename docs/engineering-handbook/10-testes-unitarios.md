# 10 — Testes unitários

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Escopo:** testes unitários transversais na plataforma `{nome-projeto}` (multi-repo)

---

## Objetivo

Estabelecer **como escrevemos, organizamos, medimos e mantemos** testes unitários em todas as stacks: comportamento sobre implementação, **90% de cobertura de linha**, determinismo, velocidade e integração com CI. Complementa [11 — TaaC](11-taac-testes-integrados-na-pipeline.md) e [12 — Testes de mutação](12-testes-de-mutacao.md).

Teste unitário valida **unidade de comportamento** — não configuração de framework.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Todo autor de PR** | Meta de cobertura e estilo |
| **Revisor** | Detectar testes frágeis ou cosméticos |
| **Júnior** | O que testar primeiro |
| **Sênior** | Exceções justificadas e estratégia por camada |
| **Plataforma** | Gates de CI multi-repo |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Solução |
|----------|---------|---------|
| Teste de implementação | Quebra em refactor sem mudança de comportamento | Assert em resultado, não em mocks internos |
| Cobertura cosmética | 90% com asserts vazios | Mutation + review |
| Suite lenta | Devs pulam testes | Unitário < 1s por teste; sem I/O real |
| Flaky | CI intermitente | Sem clock/rede real; fixtures determinísticas |
| Sem teste em dados | Bug em transform | Testar funções puras e macros isoladas |

---

## Princípios

1. **Comportamento, não implementação** — assert no efeito observável.
2. **Rápido** — milissegundos; sem DB, rede ou disco em unitário.
3. **Determinístico** — mesmo resultado em toda execução.
4. **Independente** — ordem de testes não importa.
5. **Legível** — nome descreve cenário: `deve_X_quando_Y`.
6. **90% line coverage** — gate de CI; exceções documentadas no PR.
7. **Mock na borda** — I/O externo mockado; domínio sem mock excessivo.
8. **Falha clara** — mensagem de assert útil.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa | Motivo |
|---------|---------|-------------|--------|
| Meta cobertura | 90% line global | 80% | Qualidade corporativa |
| Branch coverage | Quando ferramenta suporta | Só line | Caminhos condicionais |
| Mutation | 90% em lógica de negócio | Só coverage | Detecta asserts fracos |
| Naming | `deve_*_quando_*` / Given-When-Then | `test_1` | Review e debug |
| CI gate | `--cov-fail-under=90` | Warning only | Não mergear vermelho |
| Exceções | Lista no PR + ticket follow-up | Silencioso | Dívida visível |

---

## Trade-offs

| Trade-off | A | B | A quando | B quando |
|-----------|---|---|----------|----------|
| Mock vs fake | unittest.mock | Implementação in-memory | Porta simples | Comportamento complexo do adapter |
| Parametrize | `@pytest.mark.parametrize` | Testes duplicados | Múltiplos inputs equivalentes | Cenários com setup distinto |
| Testar privado | Não | `_method` direto | — | Nunca — teste via público |
| Snapshot | Aprovado para serialização estável | Tudo snapshot | JSON/API response | Lógica de negócio |

---

## Quando usar / quando não usar

### Teste unitário quando

- Regra de negócio, validação, transformação, mapeamento.
- Handler/use case com dependências mockadas.
- Macro dbt testável via compilado (unit test dbt 1.8+).
- Função Terraform helper (se existir em módulo).

### Não é teste unitário quando

- Postgres real, S3 real, API real — é [TaaC](11-taac-testes-integrados-na-pipeline.md).
- DAG inteira rodando no Airflow — teste de estrutura + TaaC seletivo.
- `terraform apply` — plan/test/terratest.

---

## Estrutura de repositório e pastas

```
# Python (Lambda, Glue transforms)
tests/
├── unit/
├── conftest.py
└── fixtures/

# Java Spring Boot
src/test/java/
├── unit/domain/
├── unit/application/
└── ...

# Airflow
tests/
├── unit/
│   ├── test_dag_integrity.py
│   └── test_callbacks.py
└── ...

# dbt
models/.../schema.yml    # tests declarativos
tests/unit/              # unit tests dbt quando aplicável
```

**Multi-repo:** cada repositório tem sua pasta `tests/` e gate de CI próprio; padrões são idênticos.

---

## Convenções e naming

| Stack | Ferramenta | Comando CI |
|-------|------------|------------|
| Python | pytest + pytest-cov | `pytest --cov=src --cov-fail-under=90` |
| Java | JUnit 5 + Mockito + AssertJ + JaCoCo | `./mvnw test jacoco:check` |
| Airflow | pytest | `pytest tests/unit` |
| dbt | `dbt test` + unit tests | `dbt build --select test_type:unit` |
| Terraform | validate/fmt/test | ver [06 — Terraform](06-terraform.md) |

| Padrão de nome | Exemplo |
|----------------|---------|
| Python | `test_deve_rejeitar_valor_negativo` |
| Java | `deve_persistir_pedido_valido` |
| Comportamento | `deve_retornar_vazio_quando_lista_nula` |

---

## Práticas obrigatórias

- [ ] Todo bugfix inclui teste que falharia antes
- [ ] Todo caso de uso novo com happy path + pelo menos um erro
- [ ] CI bloqueia PR abaixo de 90% coverage (line)
- [ ] Sem `sleep` em unitário
- [ ] Sem dependência de ordem entre testes
- [ ] Fixtures compartilhadas em `conftest.py`
- [ ] Exceções à meta documentadas no PR
- [ ] Código gerado / DTO puro excluído via config de cobertura (com justificativa)

---

## Práticas recomendadas

- Arrange-Act-Assert (ou Given-When-Then em comentário)
- Factory/fixtures para objetos de domínio
- `freezegun` / `Clock` injetável para tempo
- Property-based (`hypothesis`) em validações complexas
- `@pytest.mark.parametrize` para tabela de casos
- Mutation testing em módulos críticos ([12](12-testes-de-mutacao.md))

---

## Anti-padrões

```python
# ❌ Executa sem assert relevante
def test_handler():
    handler(event, context)

# ❌ Assert em ordem interna de chamadas frágil
mock_repo.salvar.assert_called_once_with(exact_internal_object)

# ❌ Teste da implementação privada
assert obj._cache == {}

# ❌ I/O real em unit/
def test_salva_no_s3():
    s3.put_object(...)  # → TaaC

# ❌ assert True
assert response is not None
```

---

## Exemplos (bom vs ruim)

### Python domínio — bom

```python
def test_deve_filtrar_apenas_aprovados():
    registros = [
        RegistroVenda("1", 10.0, "APROVADO"),
        RegistroVenda("2", 5.0, "CANCELADO"),
    ]
    result = filtrar_aprovados(registros)
    assert [r.pedido_id for r in result] == ["1"]
```

### Java use case — bom

```java
@Test
void deve_rejeitar_pedido_sem_itens() {
    assertThatThrownBy(() -> useCase.executar(cmdSemItens()))
        .isInstanceOf(RegraNegocioException.class)
        .hasMessageContaining("itens");
}
```

### Glue transform pura — bom

```python
def test_normalizar_status_none():
    assert normalizar_status(None) == "DESCONHECIDO"
```

### Airflow integridade DAG — bom

```python
def test_dag_sem_ciclos(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert dag is not None
    assert not dag.test_cycle()
```

### dbt schema test — bom

```yaml
columns:
  - name: pedido_id
    tests: [unique, not_null]
  - name: valor_total
    tests:
      - dbt_expectations.expect_column_values_to_be_between:
          min_value: 0
```

---

## Estratégia de testes (pirâmide)

```
        smoke / sanity (pós-deploy)
      TaaC (integração focada)
    unitários (domínio, transforms, helpers)  ← ESTE CAPÍTULO
  contratos (schema, OpenAPI, dbt tests)
```

| Camada | % esforço típico | Velocidade |
|--------|------------------|------------|
| Unitário | 60–70% | ms |
| Contrato | 10–15% | s |
| TaaC | 15–25% | s–min |
| E2E | < 5% | min |

---

## Observabilidade (Datadog)

Testes unitários não geram telemetria de produção, mas:

- CI deve reportar métricas de duração e flaky rate (Datadog CI Visibility quando habilitado)
- Tags: `repo`, `branch`, `test_suite`
- Falhas repetidas em `main` → alerta para squad

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Prática | Motivo |
|---------|--------|
| Parallelize pytest (`-n auto`) | Feedback rápido |
| `@SpringBootTest` só em TaaC | Evitar contexto pesado |
| Spark local `local[2]` | Testes Spark enxutos |
| Cache de deps CI | Pipeline mais barata |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Fixtures sem secrets reais
- Dados sintéticos; anonimizar se usar amostra
- Não commitar credenciais em `conftest.py`

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

- README: como rodar testes localmente
- PR: mencionar novos cenários cobertos
- Exceções de cobertura listadas com motivo

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Happy path + erro relevante
- [ ] Nome descritivo
- [ ] Sem I/O em `tests/unit`
- [ ] Coverage local ≥ 90%
- [ ] Mutation rodado se lógica de negócio nova
- [ ] Fixture reutilizável quando repetido

---

## Checklist de code review

- [ ] Teste falharia se bug voltasse?
- [ ] Assert específico (não genérico)
- [ ] Sem flakiness óbvia
- [ ] Não duplica cenário já coberto
- [ ] Mock proporcional (não over-mock)
- [ ] Exceção de cobertura justificada

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] CI verde em `main` após merge
- [ ] Tendência de cobertura não cai > 2% sem explicação
- [ ] Tempo de suite unitária dentro do SLA de PR (< 5 min típico)

---

## Critérios de aceite

1. Coverage ≥ 90% ou exceções aprovadas no PR.
2. Testes novos para código novo (não só happy path).
3. CI verde em todos os repos afetados (multi-repo).
4. Mutation score ≥ 90% onde aplicável (domínio).

---

## Definition of Done (tema testes unitários)

- [ ] Código com testes unitários adequados
- [ ] Gate de cobertura verde
- [ ] Mutation verificado em lógica de negócio
- [ ] [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**DTO/record puro conta na cobertura?**  
Pode excluir via config (`omit`) com justificativa no README de testes.

**Preciso 90% no repo inteiro ou por módulo?**  
Global no repo; domínio não pode compensar código morto em outro pacote.

**Como testar código com boto3?**  
Mock no adapter `infrastructure/`; domínio sem boto3.

**Airflow: testo operador executando?**  
Estrutura da DAG em unit; execução real em TaaC seletivo.

---

## Guia de uso para júnior

1. Leia o caso de uso / função.
2. Escreva o teste que descreve o comportamento esperado (vai falhar).
3. Implemente até passar.
4. Adicione caso de erro.
5. Rode coverage local antes do PR.

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Qualidade do assert (detecta regressão real?)
- Over-mocking que esconde integração quebrada
- Exceções de cobertura aceitáveis?
- Necessidade de TaaC complementar
- Testes que congelam design errado

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 06 | [Terraform](06-terraform.md) |
| 07 | [Lambda Python](07-lambda-python.md) |
| 08 | [Java Spring Boot](08-java-spring-boot.md) |
| 09 | [AWS Glue](09-aws-glue.md) |
| 11 | [TaaC](11-taac-testes-integrados-na-pipeline.md) |
| 12 | [Testes de mutação](12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
