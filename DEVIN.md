# DEVIN.md — Como usar os padrões deste repositório no Devin

Guia prático para configurar o Devin e trabalhar com a base de padronização deste repositório.

**Documento central (todos os agentes):** [AGENTS.md](AGENTS.md)

## O que o Devin deve ler primeiro

1. [AGENTS.md](AGENTS.md) — princípios, DoD e comandos de qualidade
2. [docs/padroes/00-visao-geral.md](docs/padroes/00-visao-geral.md) — contexto do projeto
3. [docs/padroes/18-estrutura-repositorios.md](docs/padroes/18-estrutura-repositorios.md) — **multi-repo** (não monorepo)
4. Padrão da stack em `docs/padroes/` (ex.: `02-airflow.md`, `03-dbt.md`)
5. [docs/padroes/16-definition-of-done.md](docs/padroes/16-definition-of-done.md) — antes de encerrar a tarefa

## Multi-repo

- **Este repo** (ou equivalente): padrões, skills, playbooks.
- **Repos de código:** um por stack/componente — é **nesse** que o Devin edita código.
- Feature ponta a ponta = vários PRs coordenados; contratos documentados entre repos.

## Estrutura usada pelo Devin

| Recurso | Caminho | Quando usar |
|---------|---------|-------------|
| Skills | `.agents/skills/{nome}/SKILL.md` | Procedimentos repetíveis (criar DAG, dbt, Lambda…) |
| Playbooks | `devin-playbooks/*.devin.md` | Tarefas maiores com fluxo completo |
| Padrões detalhados | `docs/padroes/` | Referência técnica e exemplos |
| Checklists | `checklists/` | Review e validação pré-merge |
| Templates | `docs/padroes/templates/` | PR, ADR, runbook, TaaC |

> **Manutenção:** a fonte canônica das skills é `.claude/skills/`. Após alterações lá, rode `scripts/sync-skills.ps1` para atualizar `.agents/skills/`.

## Configuração recomendada

### 1. Conectar repositórios

- Repo de **padrões**: skills, playbooks, `docs/padroes/`.
- Repo de **código**: clone o da stack em que vai trabalhar (ex.: `{nome-projeto}-dbt`).
- Na sessão, deixe claro **qual repo** está sendo editado.

### 2. Contexto persistente (Knowledge / Instructions)

Inclua no contexto do projeto ou nas instruções da sessão:

```
Siga AGENTS.md e DEVIN.md na raiz.
Antes de implementar, leia o padrão da stack em docs/padroes/.
Use skills em .agents/skills/ para tarefas procedimentais.
Use playbooks em devin-playbooks/ para fluxos ponta a ponta.
Não invente regra de negócio. Sempre inclua testes (90% cov).
```

### 3. Skills disponíveis

| Skill | Pasta |
|-------|-------|
| Criar DAG Airflow | `.agents/skills/criar-dag-airflow/` |
| Criar model dbt | `.agents/skills/criar-modelo-dbt/` |
| Módulo Terraform | `.agents/skills/criar-modulo-terraform/` |
| Lambda Python | `.agents/skills/criar-lambda-python/` |
| API Spring Boot | `.agents/skills/criar-api-spring-boot/` |
| Job Glue | `.agents/skills/criar-job-glue/` |
| Testes unitários | `.agents/skills/criar-testes-unitarios/` |
| TaaC | `.agents/skills/criar-taac/` |
| Revisar PR | `.agents/skills/revisar-pr/` |
| Observabilidade | `.agents/skills/melhorar-observabilidade/` |
| Performance | `.agents/skills/revisar-performance/` |

## Playbooks — quando usar

Use **playbook** para tarefas amplas; use **skill** para uma entrega focada.

| Playbook | Arquivo | Cenário |
|----------|---------|---------|
| Feature ponta a ponta | `devin-playbooks/implementar-feature.devin.md` | Nova capacidade completa |
| Review de PR | `devin-playbooks/revisar-pull-request.devin.md` | Validar diff antes do merge |
| Pipeline Airflow + dbt | `devin-playbooks/criar-pipeline-airflow-dbt.devin.md` | Orquestração + transformação |
| Componente AWS | `devin-playbooks/criar-componente-aws.devin.md` | Terraform / infra |
| TaaC | `devin-playbooks/criar-taac.devin.md` | Teste integrado na CI |
| Investigar falha | `devin-playbooks/investigar-falha-pipeline.devin.md` | Incidente em pipeline |
| Hardening | `devin-playbooks/hardening-performance-observabilidade.devin.md` | Performance + observabilidade |

### Como acionar um playbook

**Opção A — Referência no prompt:**

```
Execute o playbook devin-playbooks/criar-pipeline-airflow-dbt.devin.md para o domínio vendas.
Leia AGENTS.md e docs/padroes/02-airflow.md e 03-dbt.md antes de editar.
```

**Opção B — Colar o conteúdo do playbook** na sessão como instrução inicial (útil em tarefas longas).

## Fluxos de trabalho recomendados

### Implementar algo novo

1. Leia `AGENTS.md` + padrão da stack.
2. Escolha playbook (se grande) ou skill (se focado).
3. Planeje: arquivos, testes, impacto em dados/ops.
4. Implemente seguindo código similar no repo.
5. Rode testes/lint; anexe evidência.
6. Preencha PR com `docs/padroes/templates/template-pr.md`.
7. Valide DoD em `docs/padroes/16-definition-of-done.md`.

### Revisar código

1. Abra `devin-playbooks/revisar-pull-request.devin.md` ou skill `revisar-pr`.
2. Use checklist da stack em `checklists/`.
3. Classifique achados: bloqueio / atenção / sugestão.

### Corrigir incidente

1. Playbook `investigar-falha-pipeline.devin.md`.
2. Runbook do componente (se existir).
3. Teste de regressão obrigatório antes do PR.

## Exemplos de prompts

### Lambda nova

```
Siga AGENTS.md e a skill .agents/skills/criar-lambda-python/SKILL.md.
Implemente Lambda que processa evento S3 JSON do domínio vendas.
Handler fino, domain testável, logs JSON, pytest 90%.
Leia docs/padroes/05-lambda-python.md. Não invente regra de negócio — liste dúvidas.
```

### Pipeline de dados

```
Use o playbook devin-playbooks/criar-pipeline-airflow-dbt.devin.md.
Domínio: vendas. DAG datalake_vendas_carga_diaria, models stg_ e fct_.
Idempotente por data_referencia. Inclua testes DAG + dbt build.
```

### Review

```
Use .agents/skills/revisar-pr/SKILL.md e checklists/code-review-dbt.md.
Revise o PR #{número}. Veredito com bloqueios explícitos.
```

## O que o Devin não deve fazer

- Inventar requisito de negócio ou dependência inexistente
- Ignorar `docs/padroes/` e implementar “do zero” com outro estilo
- Entregar sem testes ou com cobertura < 90% sem justificativa
- Remover observabilidade existente
- Editar `.agents/skills/` diretamente (alterar `.claude/skills/` e sincronizar)

## Para desenvolvedores humanos

| Ação | Onde |
|------|------|
| Onboarding rápido | `docs/padroes/00-visao-geral.md` |
| Abrir sessão Devin | Copiar prompt dos exemplos acima |
| Tarefa grande | Escolher playbook em `devin-playbooks/` |
| Validar entrega | `docs/padroes/16-definition-of-done.md` |
| Atualizar skills | `.claude/skills/` → `scripts/sync-skills.ps1` |

## Referência cruzada

- Cursor: [CURSOR.md](CURSOR.md)
- Claude Code: [CLAUDE.md](CLAUDE.md)
- Padrões para IA (prompts gerais): [docs/padroes/17-padroes-para-ia.md](docs/padroes/17-padroes-para-ia.md)
