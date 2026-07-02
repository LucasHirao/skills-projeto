# Regra: Arquitetura

**Doc:** `docs/padroes/01-arquitetura-de-codigo.md`

## Fronteiras

| Camada | Contém | Não contém |
|--------|--------|------------|
| Domínio | Regras puras | boto3, Spring, Airflow, Spark |
| Aplicação | Casos de uso | HTTP, SQL direto |
| Infra/adapters | I/O, clients | Regra de negócio |
| Orquestração | Schedule, deps | Transformação pesada |

## Faça

- Handler / controller / DAG **finos** — delegam ao caso de uso.
- Validação na borda (Pydantic, Bean Validation, JSON Schema).
- Contratos versionados entre repos (README + schema + ADR se breaking).
- Idempotência documentada por componente.
- Funções pequenas; nomes que revelam intenção.

## Não faça

- God class, god DAG, god Lambda, god Glue script, god Terraform module.
- `a.getB().getC().mutate()` — Lei de Demeter.
- Erros engolidos; fail fast na borda.

## Exemplo

```python
# ❌
def handler(event, ctx):
    data = boto3.client("s3").get_object(...)  # + 80 linhas de regra

# ✅
def handler(event, ctx):
    cmd = ParseEvent(event)
    return ProcessarLoteUseCase().execute(cmd)
```

## Multi-repo

Cada repo mantém camadas **internas**. Contrato entre repos = payload, schema, path S3 — não importar código entre repos.

## Critérios de aceite

- [ ] Domínio testável sem framework
- [ ] Erros explícitos e tipados
- [ ] README com contratos entrada/saída
