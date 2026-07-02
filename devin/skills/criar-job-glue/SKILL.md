---
name: criar-job-glue
description: >-
  Procedimento Devin para criar ou alterar jobs AWS Glue com PySpark e transforms
  testáveis. Use no repositório {nome-projeto}-glue-{dominio}.
---

# Criar job Glue (Devin)

**Playbook relacionado:** `devin/playbooks/criar-pipeline-airflow-dbt.devin.md` (pipeline completo)

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-glue-{dominio}`**.
2. Leitura de `docs/padroes/07-aws-glue.md`.
3. Na sessão: fontes S3/catalog, schema saída, partição `data_referencia`, volume, job params.

## Busca obrigatória no repo glue

```text
jobs/                        → entrypoint PySpark
transforms/                  → lógica testável
tests/unit/                  → pytest sem cluster
README.md                    → parâmetros e paths
```

Extraia lógica para `transforms/` como jobs existentes do repo.

## Especificação do job

| Item | Valor |
|------|-------|
| Job name | `{dominio}_{fluxo}` (alinhar com TF/Airflow) |
| Saída | `s3://.../curated/.../data_referencia=YYYY-MM-DD/` |
| Formato | Parquet + compressão padrão do time |
| Idempotência | overwrite partição ou documentar merge |

## Passos de implementação

1. **transforms/** — funções puras; testes pytest locais.
2. **jobs/** — leitura, transform, escrita particionada.
3. **Filtro cedo** — `data_referencia` no read quando possível.
4. **Performance** — evitar `collect()`; tratar skew se join grande.
5. **`_SUCCESS`** — se Airflow usa S3KeySensor.
6. **README** — argumentos CLI, schema colunas, reprocessamento.
7. **Contrato dbt** — lista de colunas para PR em `-dbt`.

## Coordenação multi-repo

| Se o job... | Ação |
|-------------|------|
| Grava curated novo | PR `-dbt` em `sources.yml` |
| É orquestrado | PR `-airflow` com job name e args |
| Precisa role/bucket | PR `-infra` Glue job + IAM |

## Validação

```bash
pytest tests/unit/ -v --cov=transforms --cov-fail-under=90
```

Job run em dev: documentar comando `aws glue start-job-run` no reporte.

## Checklists

- `checklists/code-review-glue.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-glue-{dominio}

## Job
{dominio}_{fluxo}

## Path saída
s3://...

## Schema
coluna: tipo, ...

## Testes
pytest → resultado

## PRs irmãos
- [ ] datalake-dbt: source vendas_curated
- [ ] datalake-airflow: operator Glue
- [ ] datalake-infra: job TF

## Riscos
volume, skew, bookmark
```

## Não fazer

- Editar `.claude/`
- Toda lógica no script do job sem `transforms/`
- Schema de saída sem documentar para dbt
- Full scan diário sem justificativa
