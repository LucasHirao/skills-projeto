# TaaC: {Nome do teste}

## Objetivo

{Qual integração este teste valida.}

## Escopo

- **In:** {componentes sob teste}
- **Out:** {o que é mockado/containerizado}

## Pré-requisitos

```bash
docker compose -f docker-compose.test.yml up -d
```

Ver `docker-compose.test.yml` na raiz (LocalStack, Postgres, WireMock).

## Estrutura

```
tests/integration/test_{nome}.py
tests/fixtures/{nome}/
```

## Cenários

| ID | Cenário | Resultado esperado |
|----|---------|-------------------|
| 1 | | |

## Dados de teste

- Fixture: `tests/fixtures/{nome}/input.json`
- Cleanup: {estratégia}

## Execução

```bash
pytest tests/integration/test_{nome}.py -m taac -v
```

## Tempo máximo

{ex: 120s}

## Pipeline

```yaml
# estágio integration na CI
```

## Debug

{Comandos, logs, ports}
