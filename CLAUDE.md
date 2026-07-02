# CLAUDE.md — Como usar os padrões deste repositório no Claude Code

Guia prático para configurar o Claude Code e trabalhar com a base de padronização deste repositório.

**Documento central (todos os agentes):** [AGENTS.md](AGENTS.md)

## O que o Claude deve ler primeiro

1. [AGENTS.md](AGENTS.md) — princípios, DoD e comandos de qualidade
2. [docs/padroes/00-visao-geral.md](docs/padroes/00-visao-geral.md) — contexto do projeto
3. Padrão da stack em `docs/padroes/` (ex.: `02-airflow.md`, `05-lambda-python.md`)
4. Regra operacional em `.claude/rules/{stack}.md` quando for editar código
5. [docs/padroes/16-definition-of-done.md](docs/padroes/16-definition-of-done.md) — antes de encerrar a tarefa

## Como o Claude Code carrega este repositório

- **Repo de padrões:** `CLAUDE.md` na raiz orienta uso de skills, rules e `docs/padroes/`.
- **Repo de código:** abra o repositório da stack (ex.: `{nome-projeto}-airflow`); leia também `AGENTS.md`/padrões via submodule, cópia ou link. Siga o README **daquele** repo.

**Não é monorepo** — detalhes em `docs/padroes/18-estrutura-repositorios.md`.

| Camada | Caminho | Papel |
|--------|---------|-------|
| Entrada | `CLAUDE.md` (este arquivo) | Como usar skills, rules e fluxos |
| Central | `AGENTS.md` | Princípios e regras para todos os agentes |
| Regras por stack | `.claude/rules/` | Lembretes operacionais (carregados pelo Claude Code) |
| Procedimentos | `.claude/skills/` | Workflows acionáveis por tarefa |
| Referência completa | `docs/padroes/` | Padrões, exemplos e trade-offs |
| Review | `checklists/` | Validação pré-merge |

## Regras operacionais (`.claude/rules/`)

O Claude Code aplica regras da pasta `.claude/rules/` conforme os arquivos editados:

| Arquivo | Stack |
|---------|-------|
| `arquitetura.md` | Camadas, domínio, contratos |
| `airflow.md` | DAGs, tasks, idempotência |
| `dbt.md` | Models, testes, materialização |
| `terraform.md` | IaC, IAM, tags |
| `lambda-python.md` | Handler fino, Powertools |
| `java-spring-boot.md` | API, use cases, testes |
| `glue.md` | PySpark, transforms |
| `testes.md` | Cobertura 90%, TaaC, mutation |
| `observabilidade.md` | Logs, métricas, alertas |
| `performance.md` | Volume, custo, N+1 |

**Dica:** ao pedir uma mudança, mencione a stack para o Claude priorizar a rule certa:

```
Altere a DAG datalake_vendas_carga_diaria seguindo .claude/rules/airflow.md
e docs/padroes/02-airflow.md.
```

## Skills — tarefas repetíveis

Invoque a skill pelo nome ou peça explicitamente para seguir o `SKILL.md`:

| Tarefa | Skill |
|--------|-------|
| Nova DAG | `.claude/skills/criar-dag-airflow/` |
| Novo model dbt | `.claude/skills/criar-modelo-dbt/` |
| Módulo Terraform | `.claude/skills/criar-modulo-terraform/` |
| Lambda Python | `.claude/skills/criar-lambda-python/` |
| API Spring Boot | `.claude/skills/criar-api-spring-boot/` |
| Job Glue | `.claude/skills/criar-job-glue/` |
| Testes unitários | `.claude/skills/criar-testes-unitarios/` |
| TaaC | `.claude/skills/criar-taac/` |
| Review de PR | `.claude/skills/revisar-pr/` |
| Observabilidade | `.claude/skills/melhorar-observabilidade/` |
| Performance | `.claude/skills/revisar-performance/` |

### Como invocar uma skill

```
Use a skill criar-lambda-python.
Implemente Lambda para processar evento S3 do domínio vendas.
Leia docs/padroes/05-lambda-python.md antes de editar.
```

Ou no Claude Code, se skills do projeto estiverem habilitadas, use `/` + nome da skill quando disponível.

## Fluxos de trabalho recomendados

### 1. Implementar componente focado

1. Planejar (escopo, arquivos, testes) **antes** de editar.
2. Ler padrão em `docs/padroes/` + rule em `.claude/rules/`.
3. Seguir skill correspondente.
4. Buscar implementação similar no repositório.
5. Rodar testes/lint; reportar resultado.
6. Verificar DoD.

### 2. Implementar feature grande

Quebre em etapas e use uma skill por entrega:

```
Etapa 1: Terraform (criar-modulo-terraform)
Etapa 2: Glue ou Lambda (criar-job-glue / criar-lambda-python)
Etapa 3: dbt (criar-modelo-dbt)
Etapa 4: Airflow (criar-dag-airflow)
Etapa 5: TaaC (criar-taac)
```

Playbooks equivalentes para sessões longas: pasta `devin-playbooks/` (úteis também como roteiro no Claude).

### 3. Revisar PR

```
Use a skill revisar-pr.
Revise este diff contra checklists/code-review-{stack}.md.
Classifique achados em bloqueio, atenção e sugestão.
```

### 4. Investigar bug

1. Reproduzir com fixture mínima.
2. Criar teste de regressão.
3. Corrigir causa raiz (não só sintoma).

## Exemplos de prompts

### DAG Airflow

```
Planeje antes de editar. Use criar-dag-airflow.
Crie datalake_vendas_carga_diaria: valida S3, aciona Glue.
max_active_runs=1, testes de parse, tasks.py testável.
```

### dbt

```
Use criar-modelo-dbt. stg_vendas__pedidos + fct_vendas_pedidos incremental.
schema.yml com testes. Rode dbt build.
```

### Review crítico (código de IA)

```
Revise como revisar-pr. Atenção especial: deps inventadas,
testes superficiais, regra de negócio não documentada.
```

## Nunca

- Alterar contrato público sem destacar **breaking change**
- Remover logs, métricas ou traces existentes
- Reduzir cobertura de testes sem justificativa explícita
- Inventar regra de negócio ou dependência inexistente
- Colocar lógica de negócio em DAG, handler ou controller

## Sempre

- Planejar antes de editar
- Rodar testes/lint quando possível e reportar resultado
- Explicar impactos (dados, custo, ops, segurança)
- Criar/atualizar testes junto com código
- Avaliar observabilidade e performance
- Registrar decisão relevante em ADR (`docs/padroes/templates/template-adr.md`)

## Manutenção das skills

- **Fonte canônica:** `.claude/skills/`
- **Cópia para Devin:** `.agents/skills/` via `scripts/sync-skills.ps1`
- Não editar `.agents/skills/` diretamente

## Para desenvolvedores humanos

| Ação | Onde |
|------|------|
| Abrir projeto | Claude Code detecta `CLAUDE.md` automaticamente |
| Onboarding | `docs/padroes/00-visao-geral.md` |
| Padrão da stack | `docs/padroes/02`–`07` |
| Template de PR | `docs/padroes/templates/template-pr.md` |
| Validar entrega | `docs/padroes/16-definition-of-done.md` |

## Referência cruzada

- Cursor: [CURSOR.md](CURSOR.md)
- Devin: [DEVIN.md](DEVIN.md)
- Prompts e anti-padrões: [docs/padroes/17-padroes-para-ia.md](docs/padroes/17-padroes-para-ia.md)
