---
name: criar-dag-airflow
description: >-
  Procedimento Devin para criar ou alterar DAG Airflow com naming, idempotência,
  testes e integração multi-repo. Use no repositório {nome-projeto}-airflow.
---

# Criar DAG Airflow (Devin)

**Playbook relacionado:** `devin/playbooks/criar-pipeline-airflow-dbt.devin.md` (se incluir dbt)

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-airflow`** — este é o repo que você edita.
2. Tenha acesso de leitura ao repo de padrões (este) para `docs/padroes/02-airflow.md`.
3. Na descrição da sessão: domínio, fluxo, SLA, repos downstream (Glue/dbt).

## Busca obrigatória no repo airflow

```text
dags/*.py                    → padrão de DAG existente
include/**/tasks.py          → extração de lógica
tests/dags/                  → fixtures dag_bag
README.md                    → convenções do time
```

Não assumir estrutura de outro cliente — copiar do **mesmo** repo.

## Especificação da DAG

| Item | Valor |
|------|-------|
| dag_id | `{nome-projeto}_{dominio}_{fluxo}` |
| max_active_runs | `1` se escrita partilhada |
| catchup | `False` (salvo ADR) |
| Idempotência | `data_referencia` em conf + doc |

## Passos de implementação

1. **tasks.py** — funções testáveis; zero regra de negócio opaca na DAG.
2. **DAG file** — wiring apenas; `doc_md` completo para operação.
3. **Callback falha** — estruturado; campo `correlation_id` do `dag_run`.
4. **Testes** — `test_dag_loads`, estrutura, unitários tasks.
5. **README** — como trigger, conf JSON exemplo, repos dependentes.

## Coordenação multi-repo

| Se a DAG... | Ação em outro repo |
|-------------|-------------------|
| Aciona Glue job | PR em `-infra` ou README Glue com job name/params |
| Dispara dbt | PR em `-dbt` com tag/selector documentado |
| Espera path S3 | PR produtor com contrato de path `_SUCCESS` |

Liste PRs irmãos no reporte final — Devin costuma esquecer.

## Validação

```bash
# na raiz do repo airflow
pytest tests/dags/ tests/unit/ -v
```

Pipeline do ambiente deve estar verde antes de encerrar.

## Checklists

- `checklists/code-review-airflow.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-airflow

## DAG
dag_id: ...

## Arquivos
- ...

## Testes
comando + resultado

## PRs irmãos
- [ ] repo-glue: ...
- [ ] repo-dbt: ...

## Riscos
...
```

## Não fazer

- Editar `.claude/` (Claude Code)
- Colocar transformação SQL pesada na DAG
- Fechar sem listar contratos cross-repo
