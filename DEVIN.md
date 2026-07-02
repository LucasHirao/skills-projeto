# DEVIN.md — Devin

Guia operacional para Devin. Artefatos **exclusivos** em `devin/` — não usar `.claude/` (é do Claude Code).

**Princípios:** [AGENTS.md](AGENTS.md) | **DoD:** [docs/padroes/16-definition-of-done.md](docs/padroes/16-definition-of-done.md)

---

## 1. Estrutura Devin neste repo

```
devin/
├── skills/           # procedimentos (espelham capacidades do Claude, conteúdo Devin)
└── playbooks/        # sessões longas, ponta a ponta, investigação
```

| Tipo | Quando usar |
|------|-------------|
| **Skill** | Tarefa focada (uma DAG, um model dbt, uma Lambda) |
| **Playbook** | Feature multi-repo, incidente, hardening, review amplo |

**Referência técnica profunda:** `docs/padroes/` — consultar **um** arquivo por stack por sessão.

---

## 2. Configuração da sessão Devin

### Repositórios

1. **Repo de padrões** — este (skills, playbooks, docs).
2. **Repo de código** — clone o da stack em que vai trabalhar.

Deixe explícito na sessão: *"Estou editando `{nome-projeto}-dbt`"*.

### Instructions sugeridas (Knowledge)

```
Siga DEVIN.md e AGENTS.md.
Multi-repo: um PR por repositório de código.
Antes de editar: leia docs/padroes/{stack}.md e devin/skills/{tarefa}/SKILL.md.
Não inventar regra de negócio. Plano antes de código. Testes 90%.
Propagar correlation_id. Documentar contratos entre repos.
```

### O que NÃO carregar

- Pasta `.claude/` (outra IA)
- `docs/historico/`
- Todos os playbooks de uma vez

---

## 3. Skills Devin (`devin/skills/`)

| Skill | Tarefa |
|-------|--------|
| `criar-dag-airflow` | DAG, sensor, dataset, integração |
| `criar-modelo-dbt` | Models, tests, incremental |
| `criar-modulo-terraform` | IaC AWS |
| `criar-lambda-python` | Lambda em camadas |
| `criar-api-spring-boot` | API Java |
| `criar-job-glue` | ETL PySpark |
| `criar-testes-unitarios` | Unitários 90% |
| `criar-taac` | Integração na pipeline |
| `revisar-pr` | Code review |
| `melhorar-observabilidade` | Logs, métricas, alertas |
| `revisar-performance` | Latência, custo, volume |

Cada `SKILL.md` inclui: objetivo Devin, busca no repo, passos, validação, reporte.

---

## 4. Playbooks Devin (`devin/playbooks/`)

| Playbook | Cenário |
|----------|---------|
| `implementar-feature.devin.md` | Feature multi-repo completa |
| `revisar-pull-request.devin.md` | Review pré-merge |
| `criar-pipeline-airflow-dbt.devin.md` | Orquestração + transformação |
| `criar-componente-aws.devin.md` | Terraform |
| `criar-taac.devin.md` | Teste integrado |
| `investigar-falha-pipeline.devin.md` | Incidente produção |
| `hardening-performance-observabilidade.devin.md` | Hardening |

**Como acionar:** cole o playbook na sessão ou referencie o path + variáveis (`{nome-projeto}`, `{dominio}`).

---

## 5. Fluxo de sessão Devin

```
1. Escopo + repo de código alvo
2. Ler skill OU playbook
3. Buscar código similar no repo de código (não só no repo de padrões)
4. Plano com lista de arquivos e PRs irmãos
5. Implementar com commits pequenos
6. Testes locais / pipeline do ambiente
7. Reporte: PRs necessários, contratos, riscos, o que falta em outro repo
```

---

## 6. Multi-repo (crítico para Devin)

Devin tende a assumir monorepo — **corrija explicitamente**:

- Infra, Glue, dbt, Airflow = **repos diferentes**
- Contrato S3: documentado no README do produtor e consumidor
- Um PR por repo; linkar issues/PRs relacionados
- ADR no repo de padrões ou no repo mais afetado (acordar no time)

---

## 7. Validação antes de encerrar

- [ ] DoD `16-definition-of-done.md`
- [ ] Checklist da stack em `checklists/`
- [ ] `docs/padroes/checklist-transversal.md`
- [ ] Nenhuma dependência inventada
- [ ] Evidência de testes

---

## 8. Prompts modelo

**Skill:**
```
Sessão no repo {nome-projeto}-lambda-processa-arquivo.
Siga devin/skills/criar-lambda-python/SKILL.md e docs/padroes/05-lambda-python.md.
Plano primeiro. Handler fino, Pydantic, pytest 90%.
```

**Playbook:**
```
Execute devin/playbooks/implementar-feature.devin.md.
Domínio vendas. Repos: infra, glue-vendas, dbt, airflow.
data_referencia como chave de idempotência.
```

---

## 9. Anti-padrões Devin

- Editar `.claude/` pensando que é para Devin
- Um PR gigante cross-stack em um único repo
- Playbook + todas as skills carregadas sem necessidade
- Ignorar pipeline existente do ambiente
- Fechar sessão sem listar PRs pendentes em outros repos

---

## 10. Claude Code

Artefatos separados: [CLAUDE.md](CLAUDE.md) e `.claude/`.
