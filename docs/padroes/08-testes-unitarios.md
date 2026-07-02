# Testes unitários

## Metas obrigatórias

| Métrica | Mínimo | Exceções (justificar no PR) |
|---------|--------|----------------------------|
| Line coverage | 90% | DTO puro, bootstrap, código gerado |
| Branch coverage | quando ferramenta permitir | idem |
| Mutation score | 90% em lógica de negócio | ver `10-testes-de-mutacao.md` |

## Princípios

- Testar **comportamento**, não implementação interna.
- Testes rápidos, determinísticos, independentes.
- Nome: `deve_{resultado}_quando_{condição}` ou Given/When/Then em comentários.
- Mocks na borda (I/O); domínio sem mocks excessivos.

## Pirâmide adaptada (data engineering)

```
        smoke / sanity
      TaaC (integração focada)
    unitários (domínio, transforms, helpers)
  contratos (schema, API, dbt tests)
```

## Por stack

### Java Spring Boot

```java
@ExtendWith(MockitoExtension.class)
class CriarPedidoUseCaseTest {
    @Mock PedidoRepository repository;
    @InjectMocks CriarPedidoUseCase useCase;

    @Test
    void deve_persistir_pedido_valido() {
        when(repository.salvar(any())).thenAnswer(i -> i.getArgument(0));
        var result = useCase.executar(new CriarPedidoCommand("c1", List.of(item())));
        assertThat(result.id()).isNotNull();
    }
}
```

### Python Lambda

```python
def test_rejeita_valor_negativo():
    with pytest.raises(ValorInvalidoError):
        validar_valor(-1)
```

### Glue — transform pura

```python
def test_normalizar_status_none():
    assert normalizar_status(None) == "DESCONHECIDO"
```

### Airflow

```python
def test_dag_sem_ciclos(dag_bag):
    dag = dag_bag.get_dag("datalake_vendas_carga_diaria")
    assert not dag.test_cycle()
```

### dbt

```yaml
columns:
  - name: pedido_id
    tests: [unique, not_null]
```

### Terraform

```bash
terraform fmt -check -recursive && terraform validate
```

## Anti-padrões

```python
# ❌ Teste que só executa sem assert relevante
def test_handler():
    handler(event, context)

# ❌ Assert em ordem de chamadas internas frágil
mock_s3.get_object.assert_called_once_with(...)
```

## Pipeline

```bash
# Python
pytest --cov=src --cov-fail-under=90

# Java
./mvnw test jacoco:check
```

## Exceções

Documentar no PR: arquivo, motivo, plano para cobrir depois.
