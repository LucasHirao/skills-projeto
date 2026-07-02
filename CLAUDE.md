# CLAUDE.md — Claude Code

Guia operacional para Claude Code neste repositório de padrões e nos **repos de código** do time.

**Princípios:** [AGENTS.md](AGENTS.md) | **DoD:** [docs/padroes/16-definition-of-done.md](docs/padroes/16-definition-of-done.md)

---

## 1. O que o Claude carrega automaticamente

| Artefato | Função |
|----------|--------|
| `CLAUDE.md` (este arquivo) | Entrada e fluxos |
| `.claude/rules/*.md` | Regras por stack — aplicadas ao editar arquivos relacionados |
| `.claude/skills/*/SKILL.md` | Procedimentos — **somente quando invocados** (`disable-model-invocation`) |

**Não existe** pasta Devin aqui. Para Devin, use [DEVIN.md](DEVIN.md) e `devin/`.

---

## 2. Dois contextos de trabalho

### A) Repo de padrões (este)

- Explorar, melhorar documentação, rules e skills.
- Não implementar código de produção de negócio aqui.

### B) Repo de código (`{nome-projeto}-airflow`, `-dbt`, etc.)

1. Abrir o **repo da stack** no Claude Code.
2. Ter padrões acessíveis: submodule, clone lado a lado, ou cópia de `AGENTS.md` + `.claude/`.
3. Ler README do repo de código + rule em `.claude/rules/{stack}.md`.
4. Invocar skill: *"Use a skill criar-dag-airflow"* (ou caminho `.claude/skills/...`).
5. Aprofundar em **um** doc: `docs/padroes/02-airflow.md` (etc.) — não todos.

---

## 3. Mapa rules → stacks

| Rule | Quando carrega | Doc profundo |
|------|----------------|--------------|
| `arquitetura.md` | Qualquer código novo | `01-arquitetura-de-codigo.md` |
| `airflow.md` | `dags/`, `include/` | `02-airflow.md` |
| `dbt.md` | `models/`, `macros/` | `03-dbt.md` |
| `terraform.md` | `*.tf`, `modules/` | `04-terraform.md` |
| `lambda-python.md` | Lambda Python | `05-lambda-python.md` |
| `java-spring-boot.md` | Java API | `06-java-spring-boot.md` |
| `glue.md` | Glue/PySpark | `07-aws-glue.md` |
| `testes.md` | `tests/`, `*Test*` | `08`, `09`, `10` |
| `observabilidade.md` | logs, métricas, alertas | `11-observabilidade.md` |
| `performance.md` | hot paths, queries | `12-performance.md` |

---

## 4. Mapa skills → tarefas

| Skill | Invocar quando |
|-------|----------------|
| `criar-dag-airflow` | Nova/alteração DAG, sensor, dataset |
| `criar-modelo-dbt` | Model, incremental, schema.yml |
| `criar-modulo-terraform` | Recurso/módulo AWS |
| `criar-lambda-python` | Lambda + camadas |
| `criar-api-spring-boot` | Endpoint, use case, adapter |
| `criar-job-glue` | Job PySpark |
| `criar-testes-unitarios` | Cobertura, asserts |
| `criar-taac` | Integração autocontida |
| `revisar-pr` | Review estruturado |
| `melhorar-observabilidade` | Logs, métricas, alertas |
| `revisar-performance` | Gargalos, custo |

Todas em `.claude/skills/{nome}/SKILL.md`.

---

## 5. Fluxo obrigatório antes de editar

```
1. Resumir pedido e repo alvo
2. Listar arquivos/docs que vai consultar
3. Plano: escopo, testes, contratos, riscos (dados, custo, ops)
4. Implementar mudança mínima
5. Rodar testes do repo de código
6. Reportar: diff lógico, breaking changes, PRs irmãos em outros repos
```

**Nunca** pular o plano em mudança > 3 arquivos ou qualquer contrato de dados.

---

## 6. Decisões: implementar vs propor

| Situação | Ação |
|----------|------|
| Bug claro, padrão existe | Implementar |
| Decisão arquitetural | ADR + proposta |
| Schema/contrato público | Análise de impacto + proposta |
| Negócio ambíguo | Perguntar — não assumir |
| IaC destrutivo | Plano + rollback |

---

## 7. Multi-repo coordenado

Feature ponta a ponta = sequência de PRs:

1. `{nome-projeto}-infra` — recursos e IAM  
2. `{nome-projeto}-glue` ou `-lambda-*` — processamento  
3. `{nome-projeto}-dbt` — modelagem  
4. `{nome-projeto}-airflow` — orquestração  

Cada PR referencia os outros e os contratos (bucket, ARN, colunas, `data_referencia`).

---

## 8. Prompts que funcionam

**Implementação:**
```
Repo: {nome-projeto}-airflow. Use skill criar-dag-airflow.
Leia .claude/rules/airflow.md e docs/padroes/02-airflow.md.
DAG datalake_vendas_carga_diaria, max_active_runs=1, testes parse.
Plano antes de editar. Não inventar regra de negócio.
```

**Review:**
```
Use skill revisar-pr. Diff contra checklists/code-review-airflow.md.
Classifique bloqueio/atenção/sugestão. Verifique código gerado por IA.
```

---

## 9. Anti-padrões Claude

- Ler os 20 `docs/padroes/*.md` de uma vez
- Copiar `examples/` para produção sem adaptar naming
- God DAG / god handler / god module TF
- Teste sem assert; cobertura fake
- Remover telemetria existente
- Um PR alterando airflow + dbt + infra no mesmo repo (repos são separados)

---

## 10. Manutenção deste repo

- Rules: `.claude/rules/`
- Skills: `.claude/skills/`
- Conteúdo Devin: **não editar** em `.claude/` — ver `devin/`
