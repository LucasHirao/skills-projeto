# Plano de implementação: {Feature / iniciativa}

- **Autor:** {nome}
- **Data:** YYYY-MM-DD
- **Status:** Rascunho | Em execução | Concluído
- **Tech lead:** {nome}
- **Ticket:** {JIRA/Linear #}

## Objetivo

{Resultado de negócio e técnico observável em produção.}

## Escopo

### Dentro

- 
- 

### Fora

- 
- 

## Repositórios e contratos (multi-repo)

| Repo | Responsável | Entrega | Contrato exposto |
|------|-------------|---------|------------------|
| `org/terraform-*` | | IAM, buckets, alarmes | outputs TF |
| `org/glue-*` | | job ingestão | path S3, schema parquet |
| `org/dbt-*` | | models | exposures, tests |
| `org/airflow-*` | | DAG | schedule, conf vars |
| `org/api-*` | | endpoint | OpenAPI |

**Ordem de deploy:** {1 → 2 → 3 → …}

## Fases e PRs

| Fase | PR | DoD resumida | Dependência |
|------|-----|--------------|-------------|
| 0 — ADR | `orientacoes` ou `repo/docs` | ADR aceito | — |
| 1 — Infra | `terraform-*` | plan, alarmes, tags | ADR |
| 2 — Core | `{repo}` | código + 90% cov + obs | Fase 1 |
| 3 — Orquestração | `airflow-*` | DAG + callbacks | Fase 2 |
| 4 — TaaC | `{repo}` | integração na CI | Fase 2–3 |
| 5 — Ops | Datadog + runbook | dashboard + monitor | Fase 3 |

## Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| | | | |

## Observabilidade e SLO

| SLI | SLO alvo | Dashboard / monitor |
|-----|----------|---------------------|
| | | |

Ver [13 — Observabilidade](../13-observabilidade.md) e template [dashboard.md](dashboard.md).

## Segurança e dados

- Classificação: {Interno | Confidencial}
- PII: {ausente | mascarada em staging}
- IAM: {roles novas — princípio least privilege}

Ver [17 — Segurança](../17-seguranca-conformidade-e-dados-sensiveis.md).

## Testes

| Tipo | Meta | Onde |
|------|------|------|
| Unitário | ≥ 90% cov | CI |
| Mutação | ≥ 90% domain | CI |
| TaaC | cenários § cenários | `tests/integration/` |

## Rollout e rollback

| Etapa | Ação | Rollback |
|-------|------|----------|
| hml | deploy + TaaC | revert PR |
| prod canário | {flag / % tráfego} | {desligar flag} |
| prod full | | {backfill / revert} |

## Comunicação

- Consumidores a avisar: {times}
- Breaking changes: {nenhum / lista + prazo}

## Critérios de conclusão

- [ ] Todos os PRs merged na ordem definida
- [ ] DoD [18](../18-definition-of-done.md) em cada PR
- [ ] Dashboard e runbook em produção
- [ ] TaaC verde na CI
- [ ] Consumidores validaram em hml

## Referências

- ADR: {link}
- Handbook: {capítulos}
- Template PR: [pr.md](pr.md)
