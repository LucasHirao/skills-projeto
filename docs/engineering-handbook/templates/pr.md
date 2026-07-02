## Descrição

{Resumo em 2–4 frases: o que mudou e por quê. Incluir link para ticket/issue.}

## Tipo de mudança

- [ ] Feature
- [ ] Bugfix
- [ ] Refactor
- [ ] Infra / Terraform
- [ ] Observabilidade
- [ ] Documentação
- [ ] Breaking change ⚠️

## Stack afetada

- [ ] Airflow  [ ] dbt  [ ] Terraform  [ ] Lambda  [ ] Spring  [ ] Glue  [ ] Doc  [ ] Outro

## Repositórios relacionados (multi-repo)

| Repositório | PR | Status |
|-------------|-----|--------|
| {org/repo} | #{n} | {aberto/merged} |

**Ordem de merge/deploy:** {ex.: TF → Glue → dbt → Airflow}

## Checklist DoD

### Código e testes

- [ ] Padrões do [Engineering Handbook](../18-definition-of-done.md) seguidos
- [ ] Testes unitários — cobertura **≥ 90%**
- [ ] Mutation **≥ 90%** em domain/application (se aplicável)
- [ ] **TaaC** se integração real
- [ ] Lint/format/CI **verde**

### Transversal

- [ ] **Observabilidade** — logs JSON, `correlation_id`, métricas Datadog
- [ ] **Performance** — volume considerado; sem N+1 / full scan
- [ ] **Segurança** — IAM least privilege; sem segredos; sem PII em log
- [ ] **Documentação** — README / ADR / runbook atualizados
- [ ] **Idempotência** e reprocessamento documentados
- [ ] **Rollback** considerado

### Stack específica

- [ ] {Item do capítulo 18 — ex.: dbt build, airflow parse test, tf plan}

## Impacto

| Área | Descrição |
|------|-----------|
| **Dados** | {schema, backfill, qualidade} |
| **Contratos** | {API, eventos, exposures dbt} |
| **Ops / alertas** | {novos monitors, runbooks} |
| **Custo AWS** | {estimativa ou N/A} |

## Breaking changes

{Nenhum / descrever migração, consumidores afetados, prazo}

## Como testar

```bash
# Unitários
{comando}

# Integração / TaaC
{comando}

# Stack específica (dbt build, terraform plan, etc.)
{comando}
```

## Evidências

- [ ] Screenshot ou log de testes locais
- [ ] Link pipeline CI
- [ ] Coverage report (≥ 90%)
- [ ] Datadog — screenshot de métrica/log (se obs)

## Débito técnico / follow-ups

- [ ] {Issue # — descrição}

## Reviewers

- [ ] {revisor — domínio}
- [ ] {revisor — stack}
