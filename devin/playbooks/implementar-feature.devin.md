# Playbook Devin: Implementar feature ponta a ponta

## Objetivo

Entregar capacidade de dados/integração através de **PRs coordenados** em múltiplos repositórios, sem inventar negócio.

## Escopo

| In | Out |
|----|-----|
| Código, testes, IaC, orquestração, observabilidade, docs | Regra de negócio não documentada |

## Pré-requisitos da sessão

1. Issue/épico com requisito aprovado (ou listar dúvidas bloqueantes).
2. Mapa de repos: `docs/padroes/18-estrutura-repositorios.md`.
3. Acesso de escrita aos repos necessários.
4. Este playbook + skills em `devin/skills/` conforme stack.

## Fase 0 — Descoberta (não pular)

Por repo que **pode** ser afetado:

```text
README.md
Últimos PRs similares
Contratos (schema.yml, OpenAPI, TF outputs, doc_md DAG)
```

Produza tabela:

| Repo | Muda? | Motivo |
|------|-------|--------|
| {nome}-infra | sim/não | |
| {nome}-glue-* | | |
| {nome}-dbt | | |
| {nome}-airflow | | |

## Fase 1 — Plano (obrigatório)

Documente antes de codificar:

1. **Contratos:** S3 paths, schemas, ARNs, eventos, `data_referencia`.
2. **Ordem de merge:** infra → processamento → dbt → airflow (ajustar).
3. **Idempotência** por componente.
4. **Testes** por repo.
5. **ADR** se decisão estrutural.

## Fase 2 — Implementação por repo

### 2.1 Infra (`devin/skills/criar-modulo-terraform`)

- IAM least privilege; outputs para consumidores.
- PR #1 — não mergear sem plan revisado.

### 2.2 Processamento (Glue ou Lambda)

- Skill `criar-job-glue` ou `criar-lambda-python`.
- Domain testável; correlation_id nos logs.
- PR #2 — referenciar outputs TF.

### 2.3 dbt

- Skill `criar-modelo-dbt`.
- staging → int → mart; schema.yml completo.
- PR #3 — documentar dependência de path S3/curated.

### 2.4 Airflow

- Skill `criar-dag-airflow`.
- Sensor/dataset alinhado ao contrato real do PR #2/#3.
- PR #4.

### 2.5 API (se aplicável)

- Skill `criar-api-spring-boot`.
- PR separado.

## Fase 3 — TaaC e observabilidade

- Skill `criar-taac` onde há integração.
- Alertas/runbooks novos: `melhorar-observabilidade`.
- ADR em `docs/adr/` (repo padrões) se aplicável.

## Fase 4 — Validação

Por PR:

- [ ] DoD `16-definition-of-done.md`
- [ ] Pipeline do ambiente verde
- [ ] Checklist da stack
- [ ] README atualizado

## Fase 5 — Reporte final

```markdown
## Feature
{nome}

## PRs
| Repo | PR | Status |
|------|-----|--------|

## Contratos
...

## Reprocessamento
...

## Débitos / follow-ups
...
```

## O que não fazer

- Monorepo imaginário
- Um commit com tudo
- Merge airflow antes de dbt estar pronto
- Fechar sem testes

## Critérios de aceite

Todos PRs mergeáveis; contratos escritos; reprocessamento documentado.
