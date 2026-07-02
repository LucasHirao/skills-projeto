# 11 — TaaC — Testes integrados na pipeline

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Escopo:** testes automatizados de integração executados na CI da plataforma `{nome-projeto}` (multi-repo)

---

## Objetivo

Definir **TaaC (Tests as a Code)**: testes acima do unitário, versionados no repositório, executados na pipeline CI/CD, validando **integração realista** entre componentes com ambiente **autocontido** sempre que possível. Complementa [10 — Testes unitários](10-testes-unitarios.md) sem substituí-lo.

TaaC garante que **o wiring funciona** — não só que a função isolada funciona.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Desenvolvedor(a)** | Escrever e manter testes de integração |
| **Revisor** | Avaliar custo/tempo vs valor do TaaC |
| **Plataforma** | Padronizar Testcontainers/LocalStack |
| **QA / negócio** | Cenários BDD críticos (quando adotado) |
| **Júnior** | Diferença unit vs TaaC vs E2E |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Solução TaaC |
|----------|---------|--------------|
| Mock excessivo | Unit verde, prod quebrado | Container real ou LocalStack |
| Ambiente compartilhado | Flaky, dados sujos | Autocontido por pipeline |
| E2E lento demais | CI de 40 min | Poucos E2E; TaaC focado |
| Contrato quebrado | Consumer falha em prod | Contract tests na CI |
| Pipeline sem dados | Deploy sem validação | TaaC obrigatório em integrações |

---

## Princípios

1. **Versionado como código** — mesmo repo, mesmo review que produção.
2. **Autocontido** — Testcontainers, LocalStack, moto, WireMock.
3. **Determinístico** — seed de dados; cleanup após teste.
4. **Rápido o suficiente** — meta 5–10 min por suite TaaC (ajustar por módulo).
5. **Focado** — valida integração, não re-testa toda lógica de domínio.
6. **Marcado explicitamente** — `@pytest.mark.taac`, `@Tag("taac")`.
7. **Falha bloqueia merge** — gate de CI igual a unitário.
8. **Observável** — logs estruturados em falha; CI Visibility no Datadog.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa | Motivo |
|---------|---------|-------------|--------|
| Definição TaaC | Integration/component na CI | QA manual | Repetível, rápido feedback |
| AWS local | LocalStack / moto | Conta dev compartilhada | Isolamento |
| DB | Testcontainers Postgres | H2 em memória | Paridade SQL |
| API externa | WireMock | Serviço real sandbox | Estável, rápido |
| BDD | behave/Cucumber só fluxos críticos | BDD em tudo | Custo vs legibilidade |
| E2E | 1–3 por domínio | E2E por feature | Tempo de CI |

---

## Trade-offs

| Trade-off | A | B | A quando | B quando |
|-----------|---|---|----------|----------|
| LocalStack vs moto | LocalStack multi-serviço | moto leve | S3+SQS+Lambda | Só DynamoDB/S3 |
| `@SpringBootTest` | Contexto completo | Slice + mocks | Fluxo API+DB | Só repository |
| Dados fixture | SQL seed | Factory em código | Schema complexo | Objetos simples |
| Paralelismo TaaC | Serial em containers | Paralelo com Ryuk | Recursos CI limitados | Runners potentes |

---

## Quando usar / quando não usar

### Use TaaC quando

- Integração com AWS (S3, SQS, DynamoDB, Lambda invoke).
- API persiste em banco real.
- Pipeline Airflow dispara task com side effect verificável.
- Contrato OpenAPI/evento entre repos.
- dbt lê source materializado por Glue (fixture reduzida).

### Não use TaaC quando

- Lógica pura — [10 — Testes unitários](10-testes-unitarios.md).
- E2E completo multi-sistema — smoke pós-deploy separado.
- Teste exploratório manual.

### Tipos de teste (referência)

| Tipo | Escopo | Velocidade | Onde |
|------|--------|------------|------|
| Unit | Função/classe | ms | Cap. 10 |
| Component | Módulo + deps mock realistas | s | TaaC leve |
| Integration/TaaC | Múltiplos componentes reais | s–min | **Este capítulo** |
| Contract | Schema API/evento | s | CI consumidor/produtor |
| E2E | Fluxo prod-like | min | Poucos, pós-deploy |
| Smoke | Saúde básica | s | Pós-deploy |
| Data quality | Regras em dataset | var | dbt test / GE |

---

## Estrutura de repositório e pastas

```
# Python Lambda
tests/
├── unit/
├── integration/           # ou taac/
│   ├── test_handler_s3.py
│   └── conftest.py        # localstack fixture
└── contract/
    └── test_event_schema.py

# Java API
src/test/java/integration/
└── PedidoApiIT.java

# Airflow
tests/taac/
└── test_dag_dbt_run.py    # com mock ou container

# dbt
tests/fixtures/
└── taac_pedidos.yml
```

Template: [templates/teste-integrado.md](templates/teste-integrado.md).

---

## Convenções e naming

| Item | Convenção |
|------|-----------|
| Marcador Python | `@pytest.mark.taac` |
| Marcador Java | `@Tag("taac")` |
| Arquivo | `test_*_integration.py` ou `*IT.java` |
| Timeout CI | 10 min job step TaaC |
| Dados | prefixo `taac_` em buckets/tabelas |
| Correlation | `taac_run_id` em logs para debug |

---

## Práticas obrigatórias

- [ ] Pelo menos um TaaC por integração externa nova (S3, DB, fila, API)
- [ ] Ambiente autocontido (container/LocalStack) — não depender de dev compartilhado
- [ ] Cleanup de recursos criados (bucket, tabela, fila)
- [ ] Marcador `taac` separado do unitário no CI
- [ ] Template de teste integrado preenchido para fluxos críticos
- [ ] Falha de TaaC bloqueia merge
- [ ] Dados sintéticos; sem PII real
- [ ] Logs em falha capturados no artefato CI

---

## Práticas recomendadas

- Reutilizar fixtures em `conftest.py` / `@TestConfiguration`
- Wait strategies explícitas (não `sleep(30)` fixo)
- Contract test no repo consumidor com schema do produtor
- Rodar TaaC em paralelo com unitário (jobs CI separados)
- Datadog CI Visibility para flaky detection
- Retry 0 em TaaC (flaky = bug)

---

## Anti-padrões

```python
# ❌ Depende de bucket dev compartilhado "sempre lá"
BUCKET = "dev-dados-compartilhado"

# ❌ sleep fixo
time.sleep(60)

# ❌ TaaC testando toda matriz de regra de negócio
# (isso é unitário)

# ❌ Sem cleanup
def test_deve_criar_tabela():
    dynamodb.create_table(...)  # fica lixo

# ❌ E2E duplicando cada TaaC em prod
```

---

## Exemplos (bom vs ruim)

### Python Lambda + moto — bom

```python
import pytest

@pytest.mark.taac
def test_handler_deve_gravar_metadados_no_dynamodb(dynamodb_table, lambda_context):
    from handler import handler

    event = evento_s3_exemplo()
    response = handler(event, lambda_context)

    assert response["status"] == "OK"
    item = dynamodb_table.get_item(Key={"pk": "arquivo#vendas.csv"})
    assert item["Item"]["status"] == "PROCESSADO"
```

### Java + Testcontainers — bom

```java
@Testcontainers
@SpringBootTest(webEnvironment = RANDOM_PORT)
@Tag("taac")
class PedidoApiIT {
    @Container
    static PostgreSQLContainer<?> db = new PostgreSQLContainer<>("postgres:16-alpine");

    @Autowired TestRestTemplate rest;

    @Test
    void deve_criar_pedido_via_api() {
        var body = Map.of("clienteId", "c1", "itens", List.of(Map.of("sku", "A", "qtd", 1)));
        var resp = rest.postForEntity("/api/v1/pedidos", body, PedidoResponse.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }
}
```

### Contract OpenAPI — bom

```python
@pytest.mark.contract
def test_resposta_deve_respeitar_openapi(openapi_spec, pedido_response_fixture):
    schema = openapi_spec["components"]["schemas"]["PedidoResponse"]
    validate(instance=pedido_response_fixture, schema=schema)
```

### dbt com fixture — bom

```yaml
# unit test ou taac com dados seed
unit_tests:
  - name: test_fato_vendas_soma
    model: fato_vendas
    given:
      - input: ref('stg_pedidos')
        rows:
          - {pedido_id: 1, valor: 100}
    expect:
      rows:
        - {pedido_id: 1, valor_total: 100}
```

### WireMock API externa — bom

```java
@RegisterExtension
static WireMockExtension wireMock = WireMockExtension.newInstance().options(wireMockConfig().dynamicPort()).build();

@Test
void deve_consultar_credito_externo() {
    wireMock.stubFor(get("/credito/c1").willReturn(okJson("{\"aprovado\": true}")));
    // executa use case que chama adapter HTTP
}
```

---

## Estratégia de testes

```
Unit (rápido, sempre) → TaaC (integração, CI) → Smoke (pós-deploy) → E2E (raro)
```

| Repo | TaaC mínimo esperado |
|------|---------------------|
| `lambda-*` | invoke + side effect (DynamoDB/S3) |
| `*-api` | POST/GET + persistência |
| `glue-jobs-*` | read/write bucket teste |
| `airflow-*` | integridade DAG + task test (mock ou container) |
| `dbt-*` | unit test + source freshness em hml |

**Tempo:** se suite > 10 min, dividir por domínio ou otimizar containers.

---

## Observabilidade (Datadog)

| Prática | Detalhe |
|---------|---------|
| CI Visibility | Reportar testes TaaC com tags `test.type:taac` |
| Logs em falha | Upload artefato + link no PR |
| Correlação | `correlation_id` nos logs do serviço durante TaaC |
| Métrica | `ci.taac.duration`, `ci.taac.flaky` |

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Prática | Motivo |
|---------|--------|
| Reuso de container entre testes da mesma classe | Startup JDBC |
| Imagens Alpine slim | Pull mais rápido |
| LocalStack só serviços necessários | Menos RAM no runner |
| Não duplicar E2E e TaaC | CI mais barata |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Sem credenciais prod em CI — role OIDC ou keys efêmeras dev
- Dados 100% sintéticos
- Buckets TaaC com lifecycle delete automático
- Não expor LocalStack para rede pública

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

Cada TaaC crítico documentado com [templates/teste-integrado.md](templates/teste-integrado.md):

- Objetivo e componentes envolvidos
- Pré-condições e dados
- Como executar local (`docker compose -f docker-compose.test.yml`)
- Resultado esperado
- Troubleshooting

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Marcador `taac` aplicado
- [ ] Container/LocalStack sobe e desce limpo
- [ ] Dados sintéticos
- [ ] Assert em efeito observável (não só status 200)
- [ ] Documentação template preenchida (fluxos críticos)
- [ ] Job CI separado ou stage `integration`
- [ ] Tempo < 10 min (ou justificativa)

---

## Checklist de code review

- [ ] Não duplica cobertura unitária desnecessária
- [ ] Ambiente autocontido
- [ ] Sem dependência de ordem entre testes
- [ ] Cleanup garantido
- [ ] Flaky potential revisado (waits, ports)
- [ ] Valor claro vs custo de CI

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Runner CI com Docker habilitado
- [ ] Imagens pinadas (não `latest` flutuante)
- [ ] Alerta se TaaC flaky > threshold no Datadog CI
- [ ] Procedimento se LocalStack/Testcontainers falha por recurso

---

## Critérios de aceite

1. TaaC verde na CI do PR.
2. Integração nova tem TaaC correspondente.
3. Documentação para fluxos críticos.
4. Sem flaky conhecido sem issue aberta.

---

## Definition of Done (tema TaaC)

- [ ] TaaC implementado para integrações do escopo
- [ ] CI verde
- [ ] Template teste integrado atualizado se fluxo crítico
- [ ] [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**TaaC vs E2E?**  
TaaC = subset integrado autocontido na CI. E2E = fluxo completo em ambiente próximo de prod, poucos casos.

**Preciso Testcontainers se tenho moto?**  
Postgres/Redis reais → Testcontainers. S3/SQS → moto ou LocalStack.

**BDD obrigatório?**  
Não. Use para fluxos que negócio/QA precisa ler. Técnico: pytest/JUnit descritivo.

**Multi-repo: contract test onde?**  
Consumidor valida contra schema publicado pelo produtor (OpenAPI, Avro, JSON Schema).

**Airflow TaaC roda DAG inteira?**  
Preferir task isolada + mock ou `dag.test()`; DAG completa só se tempo aceitável.

---

## Guia de uso para júnior

1. Identifique a integração (o que cruza fronteira de processo).
2. Copie [templates/teste-integrado.md](templates/teste-integrado.md).
3. Suba container no `conftest.py`.
4. Escreva um fluxo feliz com assert no side effect.
5. Rode `pytest -m taac` local antes do PR.

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- ROI do TaaC vs tempo de CI
- Paridade suficiente com produção?
- Contract entre repos coberto?
- Estratégia de dados e idempotência no teste
- Risco de flaky em escala

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 04 | [Airflow](04-airflow.md) |
| 05 | [dbt](05-dbt.md) |
| 07 | [Lambda Python](07-lambda-python.md) |
| 08 | [Java Spring Boot](08-java-spring-boot.md) |
| 09 | [AWS Glue](09-aws-glue.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 12 | [Testes de mutação](12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
