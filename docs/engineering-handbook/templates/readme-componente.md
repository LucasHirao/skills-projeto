# {Nome do componente}

> Repositório: `{org}/{repo}` · Stack: {Airflow | dbt | Lambda | Spring | Glue | Terraform} · Owner: {time}

## O que é

{Uma frase descrevendo o componente.}

## Por que existe

{Contexto de negócio e técnico — qual problema resolve, quem consome.}

## Arquitetura (resumo)

```
{diagrama ASCII ou link para C4/ADR}
```

**ADRs relacionados:** [ADR-NNN](../adr/NNN-titulo.md)

## Como rodar localmente

### Pré-requisitos

- {Python 3.11, Java 21, Terraform 1.8, etc.}
- {Credenciais AWS via SSO}
- {Acesso Datadog hml — opcional para dev}

### Comandos

```bash
# Setup
{comandos}

# Executar
{comandos}

# Testes
pytest --cov=src --cov-fail-under=90
# ou: mvn test, dbt build, etc.
```

## Configuração

| Variável / parâmetro | Descrição | Obrigatória | Exemplo |
|----------------------|-----------|-------------|---------|
| `ENV` | Ambiente | Sim | `hml` |
| `CORRELATION_ID` | Rastreio ponta a ponta | Não (gerado) | `manual-001` |

**Secrets:** {Secrets Manager ARN — nunca valor real}

## Contratos

### Entrada

```json
{exemplo mínimo}
```

### Saída

```json
{exemplo mínimo}
```

**Não quebrar sem ADR:**

- {campo, schema, path S3, endpoint}

**Repos consumidores:** {links cross-repo}

## Como testar

```bash
# Unitários
{comando}

# Mutação
{comando}

# TaaC
pytest tests/integration -m taac -v
```

## Observabilidade (Datadog)

| Sinal | Onde |
|-------|------|
| **Logs** | `service:{nome}` · facet `correlation_id` |
| **Métricas** | `{domínio}.{entidade}.*` |
| **APM** | Service `{nome}` |
| **Dashboard** | {URL Datadog} |
| **Runbook** | [docs/runbooks/{nome}.md](../runbooks/{nome}.md) |
| **Monitors** | {lista ou link} |

## Operação

| Tópico | Detalhe |
|--------|---------|
| **SLA** | {janela esperada} |
| **Idempotência** | {chave — ex.: `pedido_id`, `data_referencia`} |
| **Reprocessamento** | {comando de backfill} |
| **Falhas comuns** | {sintoma → ação rápida} |
| **Rollback** | {como reverter deploy ou dados} |

## Segurança

- Classificação de dados: {Interno | Confidencial | …}
- PII: {como mascarar / se ausente}
- IAM: {role principal — link TF}

## Referências

- Handbook: [docs/engineering-handbook/{capítulo}.md](https://github.com/org/repositorio-de-padroes/blob/main/docs/engineering-handbook/{capítulo}.md)
- Template: [readme-componente.md](https://github.com/org/repositorio-de-padroes/blob/main/docs/engineering-handbook/templates/readme-componente.md)
