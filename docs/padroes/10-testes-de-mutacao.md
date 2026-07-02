# Testes de mutação

## Meta

**Mutation score mínimo: 90%** em código de regra de negócio, validação, cálculo, decisão e mapeamento.

## Onde aplicar

| Aplicar | Evitar exigência pesada |
|---------|-------------------------|
| `domain/`, `application/` | DTO puro, config, bootstrap |
| Transforms Glue puras | Job Spark inteiro |
| Helpers Airflow | DAG declarativa |
| Services Java | Terraform, SQL dbt literal |

## Java — PIT

```xml
<configuration>
  <mutationThreshold>90</mutationThreshold>
  <coverageThreshold>90</coverageThreshold>
  <targetClasses>
    <param>com.empresa.projeto.pedidos.domain.*</param>
  </targetClasses>
</configuration>
```

```bash
./mvnw pitest:mutationCoverage
```

## Python — mutmut

```bash
mutmut run --paths-to-mutate=domain,application
mutmut results
mutmut show <id>
```

Excluir `handler.py`, `__init__.py` vazios.

## Glue

Mutar apenas `transforms/` com funções puras.

## dbt — abordagem equivalente

Mutation tradicional não se aplica direto. Use:

1. Testes negativos (`expression_is_true` que deve falhar se regra mudar).
2. Fixtures com variação controlada — alterar fixture deve falhar teste.
3. Data quality tests em casos limite.

## Airflow

Mutar funções em `include/app/*/tasks.py`, não o arquivo da DAG.

## Interpretar sobreviventes

| Sobrevivente | Ação |
|--------------|------|
| Equivalente | Aceitar com comentário |
| Sem teste do branch | Adicionar caso de teste |
| Teste frágil (só executa) | Melhorar assert |

## Evitar "matar mutante" com teste frágil

```python
# ❌ Só verifica que não explodiu
def test_processar():
    processar(dados)

# ✅ Assert no resultado observável
def test_processar_soma_aprovados():
    assert processar([...]).total == Decimal("15.00")
```

## Estratégia incremental

- **Código novo:** 90% obrigatório.
- **Legado:** baseline + convergência por módulo crítico.
- Pipeline: falhar se mutation score < threshold em paths configurados.

## Relatório esperado

```
>> Generated 42 mutations
>> Killed 39 (93%)
>> Survived 3
```

Investigar os 3 sobreviventes no PR.
