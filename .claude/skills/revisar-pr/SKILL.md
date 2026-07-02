---
name: revisar-pr
description: >-
  Revisa pull requests contra padrões, checklists por stack e riscos de dados,
  ops e segurança. Use ao revisar PR, diff, branch ou código gerado por IA antes do merge.
disable-model-invocation: true
---

# Revisar PR (Claude Code)

**Repo alvo:** repo do PR | **Rule:** `.claude/rules/arquitetura.md` + rule da stack | **Doc:** `docs/padroes/14-code-review.md`

## Pré-voo

1. Ler descrição do PR, plano de teste e issues vinculadas.
2. Identificar stack(s) e repos afetados (multi-repo).
3. Abrir checklist(s) em `checklists/code-review-{stack}.md`.
4. Ler `16-definition-of-done.md` e `checklist-transversal.md`.

## Entradas

- Diff, link do PR ou branch
- Stack(s): airflow, dbt, terraform, lambda, java, glue, testes
- Contexto: feature, bugfix, refactor, código IA
- Ambiente alvo (dev/hml/prod)

## Procedimento

### 1. Classificação de achados

| Nível | Critério | Ação |
|-------|----------|------|
| 🔴 Bloqueio | Segurança, perda de dados, contrato quebrado, sem teste em lógica crítica | Exigir correção |
| 🟡 Atenção | Débito, observabilidade fraca, performance em escala | Corrigir ou ticket |
| 🟢 Sugestão | Estilo, naming, simplificação | Opcional |

### 2. Checklist por dimensão

**Arquitetura** (`01-arquitetura-de-codigo.md`)
- Lógica de negócio fora de handler/DAG/TF?
- Camadas respeitadas?
- Um PR por repo?

**Dados**
- Schema/coluna removida ou renomeada? Breaking change documentado?
- Idempotência e reprocessamento?
- Impacto em backfill?

**Segurança**
- IAM least privilege; sem secrets no código.
- PII em logs?

**Testes**
- ≥ 90% cobertura; mutation onde aplicável.
- Asserts substantivos; TaaC se integração.

**Ops**
- Observabilidade mantida ou melhorada.
- Runbook/alerta se fluxo crítico.

**Código IA**
- Dependências existem no repo?
- Regra de negócio inventada?
- Código morto ou over-engineering?

### 3. Multi-repo

Verificar PR descreve PRs irmãos:

```
infra (IAM/bucket) → glue/lambda → dbt → airflow
```

Contratos: ARN, path S3, colunas, `data_referencia`, tag dbt.

### 4. Template de saída

Usar estrutura de `docs/padroes/templates/template-code-review.md`:

```markdown
## Veredito
Aprovado | Aprovado com ressalvas | Mudanças necessárias

## Bloqueios
- ...

## Atenção
- ...

## Sugestões
- ...

## Multi-repo
- [ ] PR irmão em ...

## Testes
CI: verde/vermelho — gaps: ...
```

### 5. Playbook Devin (referência)

Reviews amplos multi-repo: `devin/playbooks/revisar-pull-request.devin.md`.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-{stack}.md` (uma ou mais)
- DoD: `docs/padroes/16-definition-of-done.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Aprovar só porque CI verde | Ler diff e contratos |
| Nit como bloqueio | Separar severidade |
| Ignorar backfill | Perguntar impacto dados |
| Review só de estilo | Checar dados/segurança/ops |
| Um PR com airflow+dbt+infra | Pedir split por repo |

## Reporte Claude

- Veredito claro
- Achados por severidade com arquivo/linha quando possível
- PRs irmãos faltantes
- Perguntas ao autor se negócio ambíguo

## Prompt

```
Use revisar-pr. Diff no repo datalake-dbt, branch feature/fct-pedidos.
Checklists dbt + transversal. Classifique achados. Código gerado por IA — validar negócio.
Veredito e PRs irmãos necessários.
```
