# Estrutura de repositórios (multi-repo)

**Não usamos monorepo.** Cada stack ou componente vive em **repositório próprio**, com pipeline e ciclo de vida independentes. Os padrões deste repositório de orientações aplicam-se a todos eles.

## Dois tipos de repositório

### 1. Repositório de padrões (este)

Contém documentação, skills, playbooks, checklists e exemplos de referência — **sem código de produção**.

```
padroes-engenharia/          # nome sugerido
├── AGENTS.md, CLAUDE.md, DEVIN.md, CURSOR.md
├── docs/padroes/, docs/adr/, docs/runbooks/
├── examples/
├── .claude/, .agents/, .cursor/
├── checklists/
└── devin-playbooks/
```

**Como consumir:** submodule, cópia periódica, ou referência por URL — o time define. Agentes devem ler estes arquivos **e** o README do repo de código em que estão trabalhando.

### 2. Repositórios de código (um por componente ou domínio)

| Repositório | Conteúdo típico | Exemplo de nome |
|-------------|-----------------|-----------------|
| Airflow | DAGs, plugins, testes | `{nome-projeto}-airflow` |
| dbt | models, macros, tests | `{nome-projeto}-dbt` |
| Infra / Terraform | módulos, envs | `{nome-projeto}-infra` |
| Lambda | uma ou poucas funções relacionadas | `{nome-projeto}-lambda-{funcao}` |
| Glue | um job ou família de jobs | `{nome-projeto}-glue-{job}` |
| API Spring | um serviço | `{nome-projeto}-api-{servico}` |

**Regra:** um PR altera **um** repositório de código. Mudanças que cruzam repos (contrato S3, schema, ARN) exigem PRs coordenados e ADR quando relevante.

## Layout interno por tipo de repo

### Repo Airflow

```
/
├── dags/
├── plugins/app/
├── include/app/{dag}/
├── tests/
└── README.md
```

### Repo dbt

```
/
├── models/
├── macros/
├── tests/
├── dbt_project.yml
└── README.md
```

### Repo Terraform

```
/
├── modules/
├── envs/{dev,hml,prod}/
└── README.md
```

### Repo Lambda Python

```
/
├── src/ ou handler.py + domain/ + application/
├── tests/
├── pyproject.toml
└── README.md
```

### Repo Glue

```
/
├── job.py
├── transforms/
├── tests/
└── README.md
```

### Repo Spring Boot

```
/
├── src/main/java/.../domain|application|adapter/
├── src/test/
├── pom.xml
└── README.md
```

## Convenção de naming AWS (transversal)

| Recurso | Padrão | Exemplo |
|---------|--------|---------|
| S3 bucket | `{nome-projeto}-{dominio}-{tipo}-{env}` | `datalake-vendas-raw-dev` |
| Lambda | `{nome-projeto}-{funcao}-{env}` | `datalake-processa-arquivo-dev` |
| Glue job | `{nome-projeto}-{dominio}-{fluxo}` | `datalake-vendas-carga` |
| IAM role | `{nome-projeto}-{componente}-{env}-role` | `datalake-lambda-processa-dev-role` |

## Convenção Airflow

| Campo | Padrão |
|-------|--------|
| `dag_id` | `{nome-projeto}_{dominio}_{fluxo}` |
| `task_id` | `{verbo}_{objeto}` |
| tags | nome do projeto, domínio, ambiente |

## Comandos locais (na raiz de cada repo de código)

Cada repositório tem seu próprio pipeline no ambiente. Localmente, rode na **raiz daquele repo**:

```bash
# Repo Lambda / Glue / libs Python
pytest tests/ -v --cov=src --cov-fail-under=90

# Repo Spring
./mvnw test

# Repo dbt
dbt deps && dbt build --select state:modified+

# Repo Terraform
terraform fmt -check -recursive && terraform validate

# Repo Airflow
pytest tests/dags/ -v
```

## Contratos entre repositórios

Sem monorepo, fronteiras são explícitas:

| Contrato | Onde documentar |
|----------|-----------------|
| Path S3, formato arquivo | README repo Glue/Lambda + ADR |
| Schema tabela / mart dbt | `schema.yml` + dicionário de dados |
| ARN Lambda, nome Glue job | Output Terraform + README Airflow |
| Evento fila/API | JSON Schema no repo produtor/consumidor |

**Breaking change** em contrato compartilhado: ADR + PRs nos repos afetados + comunicação aos times.

## Onde colocar código novo

| Entrega | Repositório |
|---------|-------------|
| Nova DAG | `{nome-projeto}-airflow` |
| Novo model dbt | `{nome-projeto}-dbt` |
| Nova Lambda | `{nome-projeto}-lambda-{funcao}` (novo repo se escopo distinto) |
| Novo job Glue | `{nome-projeto}-glue-{job}` |
| Nova API | `{nome-projeto}-api-{servico}` |
| Novo módulo IaC | `{nome-projeto}-infra` |

## Referências

- Exemplos mínimos: `examples/` (neste repo de padrões)
- ADR: `docs/adr/` (neste repo ou copiar para repo afetado se o time preferir ADR local)
