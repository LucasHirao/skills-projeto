# Playbook: Implementar feature ponta a ponta

## Objetivo

Entregar uma feature de dados/integração completa seguindo os padrões e a Definition of Done.

## Escopo

Código, testes, infra, orquestração, observabilidade e documentação — **sem inventar regra de negócio**.

**Multi-repo:** a feature pode exigir PRs em vários repositórios (infra, Glue, dbt, Airflow, etc.). Um PR por repo; coordene contratos entre eles.

## Contexto

- Leia `AGENTS.md` e `docs/padroes/00-visao-geral.md`.
- Mapa de repos: `docs/padroes/18-estrutura-repositorios.md`.
- Confirme requisito com issue/ADR existente.

## O que procurar antes de alterar

- No **repo de código da stack**: componentes similares, README, testes.
- No **repo de padrões** (ou docs linkados): convenções, ADRs, exemplos.
- Contratos entre repos: paths S3, ARNs, schemas (README + Terraform outputs).

## Como planejar

1. Listar componentes: API? Lambda? Glue? dbt? DAG? Terraform?
2. Identificar ordem de dependência.
3. Definir contratos entrada/saída.
4. Planejar testes (unit + TaaC) e observabilidade.
5. ADR se decisão arquitetural.

## Como implementar

1. Infra (`{nome-projeto}-infra`) se necessário.
2. Processamento (repo Glue ou Lambda).
3. Modelagem (repo dbt).
4. Orquestração (repo Airflow).
5. Observabilidade e alertas.
6. Documentação (README em cada repo tocado).

Cada etapa = PR no repositório correspondente.

Use skills: `criar-modulo-terraform`, `criar-lambda-python`, `criar-job-glue`, `criar-modelo-dbt`, `criar-dag-airflow`.

## Como testar

```bash
# Ajustar por stack — ver AGENTS.md
pytest --cov-fail-under=90
dbt build --select ...
terraform validate
```

## Como revisar

- Checklists em `checklists/`
- Skill `revisar-pr`
- DoD `docs/padroes/16-definition-of-done.md`

## Como reportar resultado

- PR com template `docs/padroes/templates/template-pr.md`
- Impactos: dados, custo, ops, breaking changes
- Evidência CI verde

## Critérios de aceite

- [ ] DoD completa
- [ ] Sem regra de negócio inventada
- [ ] Reprocessamento documentado

## O que não fazer

- Implementar sem ler docs do projeto
- Pular testes ou observabilidade
- Merge sem review humano
