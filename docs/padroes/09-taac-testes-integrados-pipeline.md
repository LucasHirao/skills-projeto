# TaaC — Testes automatizados integrados na pipeline

## Definição

**TaaC** = testes acima do unitário, executados na CI, validando integração realista com ambiente **autocontido** sempre que possível.

## Quando usar

- Há integração com AWS, DB, fila, API externa ou pipeline de dados.
- Contrato entre componentes é crítico.
- Unitários sozinhos não garantem wiring correto.

## Tipos de teste

| Tipo | Escopo | Velocidade |
|------|--------|------------|
| Unit | Função/classe isolada | ms |
| Component | Módulo com deps mockadas realistas | s |
| Integration/TaaC | Múltiplos componentes reais em container | s-min |
| Contract | Schema API/evento | s |
| E2E | Fluxo completo prod-like | min — **poucos** |
| Smoke | Saúde pós-deploy | s |
| Data quality | Regras em dataset | var |

## Estratégia recomendada

1. Preferir **autocontido** — Testcontainers, LocalStack, moto, WireMock.
2. Evitar ambiente compartilhado instável.
3. Evitar E2E lento que duplica cobertura dos TaaC.
4. Tempo máximo TaaC por suite: **5-10 min** (ajustar por módulo).

## BDD — quando sim/não

| Use BDD (Cucumber/behave) | Não use como padrão |
|---------------------------|---------------------|
| Fluxo crítico legível por negócio/QA | Teste técnico de transform/repository |
| Alinhamento explícito de regras | Toda função utilitária |

Para testes técnicos: pytest/JUnit com nomes descritivos.

## Exemplo Java + Testcontainers

```java
@Testcontainers
@SpringBootTest
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

## Exemplo Python + LocalStack

```python
@pytest.mark.taac
def test_lambda_grava_dynamodb(localstack, lambda_client, tabela_pedidos):
    invoke(lambda_client, evento_exemplo())
    item = tabela_pedidos.get_item(Key={"pk": "pedido#1"})
    assert item["Item"]["status"] == "PROCESSADO"
```

## Teste contrato API

```python
def test_schema_resposta_pedidos(openapi_spec, response_fixture):
    validate(instance=response_fixture, schema=openapi_spec["components"]["schemas"]["PedidoResponse"])
```

## dbt com fixtures

```yaml
# unit test dbt com inputs YAML
given:
  - input: ref('stg_vendas__pedidos')
    rows: [{pedido_id: '1', status: 'APROVADO', valor: 10}]
expect:
  rows: [{pedido_id: '1', valor_liquido: 10}]
```

## Glue Spark local

```python
def test_aplicar_normalizacao(spark):
    df = spark.createDataFrame([("  ok  ",)], ["status"])
    result = aplicar_normalizacao(df).collect()
    assert result[0]["status"] == "OK"
```

## Gestão de dados de teste

- Fixtures versionadas em `tests/fixtures/`.
- Cleanup após cada teste (truncate, delete prefix S3).
- IDs determinísticos (`test-{uuid fixo por caso}`).
- Paralelismo só com isolamento garantido.

## Pipeline

```yaml
# estágio separado na CI
integration-tests:
  services: [docker]
  script:
    - pytest -m taac --timeout=300
```

## Critérios para não exagerar no E2E

- TaaC já cobre integração do componente? → não duplicar E2E.
- Depende de dados prod? → recusar; usar fixture.
- > 15 min? → quebrar em níveis ou rodar nightly.

## Debug local

```bash
pytest tests/integration/ -k "nome" -s --pdb
docker compose -f docker-compose.test.yml up -d
```

Ver template: `docs/padroes/templates/template-teste-integrado.md`.
