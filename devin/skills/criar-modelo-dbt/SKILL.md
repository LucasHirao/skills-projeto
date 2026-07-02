---
name: criar-modelo-dbt
description: >-
  Procedimento Devin para criar ou alterar models dbt com camadas, testes, incremental
  e contratos multi-repo. Use no repositório {nome-projeto}-dbt.
---

# Criar modelo dbt (Devin)

**Playbook relacionado:** `devin/playbooks/criar-pipeline-airflow-dbt.devin.md` (se incluir orquestração)

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-dbt`** — este é o único repo que você edita para SQL dbt.
2. Acesso de leitura ao repo de padrões para `docs/padroes/03-dbt.md`.
3. Na descrição da sessão: domínio, entidade, camada (`stg`/`int`/`fct`), fonte upstream (Glue/S3), consumidores.

## Busca obrigatória no repo dbt

```text
models/staging/              → padrão stg_ e filtros
models/intermediate/         → joins reutilizáveis
models/marts/                → fct_/dim_ e materialização
models/**/schema.yml         → testes e descriptions
sources.yml                  → contratos com origem
dbt_project.yml              → tags, vars, materializations
```

Copie estrutura do **mesmo** projeto — não de outro cliente.

## Especificação do model

| Item | Valor |
|------|-------|
| Nome | `stg_{fonte}__{entidade}` / `int_` / `fct_{dominio}_{entidade}` |
| Materialização | view / table / incremental (justificar volume) |
| `unique_key` | obrigatório se incremental |
| Vars | `data_referencia`, `lookback_days` se late arriving |

## Passos de implementação

1. **Staging** — tipagem, rename, filtro cedo; zero join de negócio.
2. **Intermediate** — lógica compartilhada; CTEs legíveis.
3. **Mart** — colunas explícitas; pergunta de negócio clara.
4. **schema.yml** — description + `not_null`/`unique`/`relationships` nas chaves.
5. **sources/exposures** — freshness se SLA; exposure se dashboard crítico.
6. **README** — vars de execução, dependência de job Glue/Airflow.

## Coordenação multi-repo

| Se o model... | Ação em outro repo |
|---------------|-------------------|
| Lê tabela Glue nova | PR `-glue-*` com schema + README |
| Depende de path S3 | PR produtor com contrato de partição |
| É disparado por DAG | PR `-airflow` com tag/selector e `vars` |
| Alimenta API | Documentar em exposure; avisar `-api-*` |

**Liste PRs irmãos no reporte** — Devin costuma encerrar só no dbt.

## Validação

```bash
dbt build --select {model}+ --vars '{"data_referencia": "YYYY-MM-DD"}'
dbt test --select {model}
```

CI do ambiente deve estar verde. Verifique lineage: `dbt ls --select {model}+`.

## Checklists

- `checklists/code-review-dbt.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-dbt

## Models
- stg_... / fct_... (camada, materialização, unique_key)

## Arquivos
- models/...
- schema.yml

## Testes
dbt build --select ... → resultado

## Downstream
models impactados: ...

## PRs irmãos
- [ ] datalake-glue-vendas: schema curated
- [ ] datalake-airflow: tag vendas_diario

## Riscos
backfill, breaking change em coluna, ...
```

## Não fazer

- Editar `.claude/` (Claude Code)
- `select *` em mart de produção
- Incremental sem `unique_key` documentado
- Fechar sem atualizar contrato com repo Glue/Airflow
