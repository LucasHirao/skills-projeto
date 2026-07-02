# 19 — Padrões para uso de IA

Este capítulo define como **pedir**, **validar** e **manter** trabalho feito com agentes de IA (Cursor, Claude Code, Copilot, etc.) em times multi-repo.

**Princípio:** IA acelera execução; **humano** responde por merge, dados e produção.

---

## 1. Hierarquia de contexto

O agente deve ler, nesta ordem:

1. README do **repositório de código** alvo
2. Capítulo da stack no handbook (`04-airflow.md` … `09-aws-glue.md`)
3. [18 — Definition of Done](18-definition-of-done.md)
4. Este capítulo (19)
5. Templates em [`templates/`](templates/)

**Não** pedir para “implementar tudo” sem apontar repo, path e capítulo.

---

## 2. Como pedir tarefas eficazes

### 2.1 Estrutura de prompt recomendada

```
Contexto: [repo, módulo, stack, link capítulo handbook]
Objetivo: [resultado observável em prod ou CI]
Restrições: [padrões, não fazer X, sem PII real]
Entregáveis: [código + testes + doc + observabilidade]
Critério de aceite: [DoD específica — cov 90%, TaaC, runbook, etc.]
```

### 2.2 Quebrar tarefas grandes

| Em vez de | Peça (um PR cada) |
|-----------|-------------------|
| “Implemente o pipeline completo” | 1) ADR → 2) Terraform → 3) Glue → 4) dbt → 5) DAG → 6) TaaC → 7) Dashboard |
| “Refatore tudo” | Um módulo por PR com testes verdes |
| “Adicione observabilidade” | Um serviço por PR com monitors |

### 2.3 Contexto multi-repo

```
Repos envolvidos:
- org/terraform-datalake (IAM + buckets)
- org/glue-vendas (job)
- org/dbt-vendas (models)
- org/airflow-datalake (DAG)

Contrato: data_referencia, correlation_id, path s3://...

Ordem de deploy: TF → Glue → dbt → Airflow
PRs devem referenciar uns aos outros.
```

---

## 3. Templates de prompt

### 3.1 Implementar feature

```
Leia docs/engineering-handbook/{capítulo-da-stack}.md e
docs/engineering-handbook/18-definition-of-done.md.

Repo: {org}/{repo}
Implemente {feature} em {path}.

Antes de editar: plano em 5–10 bullets.
Inclua: testes (cov ≥90%), logs JSON com correlation_id, métricas Datadog.
Não invente regra de negócio — liste dúvidas como bullet.
Siga estilo do módulo vizinho.
```

### 3.2 Revisar PR

```
Revise este diff contra:
- docs/engineering-handbook/16-code-review.md
- docs/engineering-handbook/18-definition-of-done.md
- capítulo da stack: {04-airflow | 05-dbt | ...}

Classifique achados: 🔴 bloqueio | 🟡 atenção | 🟢 sugestão.
Verifique: testes, segurança, observabilidade, performance, contratos, multi-repo.
Use template docs/engineering-handbook/templates/code-review.md.
```

### 3.3 Criar testes

```
Para {módulo} em {path}:
- Testes unitários, cobertura ≥90%
- Mutation ≥90% em domain/application
- TaaC se houver integração (S3, fila, DB, API)

Siga docs/engineering-handbook/10-testes-unitarios.md,
11-taac-testes-integrados-na-pipeline.md e 12-testes-de-mutacao.md.
Nomes descritivos; asserts de comportamento, não mock excessivo.
```

### 3.4 Melhorar performance

```
Analise {componente} em {path} para volume {N} registros/dia.
Liste gargalos com evidência (código ou métrica Datadog).
Proponha mudança mínima com baseline antes/depois.
Siga docs/engineering-handbook/14-performance.md.
Não refatore fora do escopo.
```

### 3.5 Melhorar observabilidade

```
Adicione em {componente}:
- Logs JSON (correlation_id, service, env, status)
- Métricas Datadog (sucesso, erro, duração, volume)
- Trace APM se aplicável

Siga docs/engineering-handbook/13-observabilidade.md.
Sem PII em log. Tags de baixa cardinalidade.
Se fluxo crítico: sugira monitor + runbook.
```

### 3.6 Criar documentação

```
Atualize/crie documentação para {componente} usando
docs/engineering-handbook/templates/readme-componente.md.

Deve responder: o que é, por que, como roda, testa, opera, debuga, contratos.
Comandos copy-paste testáveis. Links para ADRs.
Siga docs/engineering-handbook/15-documentacao.md.
```

### 3.7 Investigar bug

```
Sintoma: {o que quebrou, quando, ambiente}
Evidência: logs Datadog (correlation_id: {id}), métricas, stack trace
Hipóteses ordenadas por probabilidade.
Reproduza com teste (unit ou TaaC) antes de corrigir.
Correção mínima + teste de regressão.
Não expandir escopo.
```

### 3.8 Criar infra Terraform

```
Módulo {nome} em {path}.
Siga docs/engineering-handbook/06-terraform.md.
IAM least privilege, tags env/service/team, alarmes críticos.
Inclua README do módulo. tfsec/checkov limpo.
Plan resumido no output.
```

### 3.9 Spike / exploração

```
Spike de até 2 dias: {pergunta a responder}
Entregável: ADR ou decisão técnica com recomendação — não código em prod.
Label spike. Listar débitos se código throwaway.
```

---

## 4. Anti-padrões

| Evitar | Por quê |
|--------|---------|
| “Implemente tudo” sem contexto | Regras inventadas, código errado |
| Aceitar sem rodar testes | Regressão silenciosa |
| Aceitar dependência não listada no projeto | Build quebrado |
| Overengineering (abstração prematura) | Manutenção cara |
| Merge sem impacto em dados | Incidente, duplicata, perda |
| Colar PII/dados reais no prompt | Vazamento, compliance |
| IA como aprovador final | Sem accountability humana |
| Copiar de outro cliente sem adaptar | Naming e contrato errados |

---

## 5. Validar saída da IA (obrigatório antes do merge)

1. Rodar testes e lint **localmente** (mesmos comandos da CI).
2. Verificar imports e deps no manifesto do projeto.
3. Conferir aderência ao padrão do diretório vizinho.
4. Revisar impacto em **dados** (idempotência, backfill, schema).
5. Checar logs/métricas sem PII.
6. **Review humano** — IA não aprova PR.

---

## 6. O que a IA pode e não pode decidir

| Pode | Não pode (escalar humano) |
|------|----------------------------|
| Estrutura de código dentro dos padrões | Regra de negócio não documentada |
| Nomes dentro das convenções | Exceção de segurança/compliance |
| Testes derivados do comportamento spec | SLA/SLO de negócio |
| Refactor mecânico com testes verdes | Breaking change em contrato público |
| Draft de ADR/runbook | Aprovar próprio PR |

---

## 7. Como extrair skills, playbooks e rules a partir deste handbook

Skills e rules para agentes são **derivados** do handbook — não a fonte de verdade.

### 7.1 Quando criar uma skill

| Gatilho | Skill sugerida |
|---------|----------------|
| Tarefa repetida com checklist longo | `criar-dag-airflow`, `criar-lambda-python`, etc. |
| Review especializado | `revisar-codigo`, `revisar-desempenho` |
| Capítulo 00–20 estável | Extrair resumo acionável |

### 7.1 Estrutura de skill (Claude / Devin)

Artefatos versionados neste repositório:

```
claude/skills/{nome-skill}/SKILL.md    # Claude Code — copiar para .claude/skills/
devin/skills/{nome-skill}/SKILL.md     # Devin — copiar para .agents/skills/
devin/playbooks/{nome}.md              # Prompts amplos multi-repo
claude/regras/*.md                     # Regras curtas operacionais
```

Mapa completo: [artefatos-ia.md](artefatos-ia.md).

Conteúdo mínimo do `SKILL.md`:

1. **Quando usar** — gatilho em linguagem natural
2. **Pré-leitura** — links para capítulos 00–20 relevantes
3. **Passos** — sequência verificável
4. **Checklist DoD** — recorte do capítulo 18
5. **Anti-padrões** — do capítulo da stack
6. **Templates** — links para `docs/engineering-handbook/templates/`

### 7.3 Processo de extração (checklist)

- [ ] Capítulo do handbook revisado por tech lead
- [ ] Skill referencia handbook por link — não duplica prosa longa
- [ ] Checklist DoD recortado e testado em 1 PR piloto
- [ ] Skill versionada em `claude/skills/` ou `devin/skills/` neste repo
- [ ] Feedback do piloto vira PR no handbook primeiro; skill atualizada depois

### 7.4 Rules (`.cursor/rules/` ou equivalente)

- Uma rule **curta** por stack apontando para o capítulo.
- Rule transversal: DoD, observabilidade Datadog, sem PII em log.
- **Não** embutir segredos, URLs internas ou dados de cliente.

### 7.5 Manutenção viva

```
Handbook (fonte) → PR review → Skill/Rule (derivado) → Piloto em feature → Feedback → Handbook
```

Mudança de padrão: **sempre** handbook primeiro; skills seguem em PR separado.

---

## 8. Ferramentas e entrypoints

| Ferramenta | Comece por |
|------------|------------|
| Cursor Agent | README do repo + capítulo stack + este doc |
| Claude Code | `claude/CLAUDE.md` + `claude/skills/` (sincronizar com `.claude/skills/`) |
| Devin | `devin/AGENTS.md` + `devin/skills/` e `devin/playbooks/` |
| CI | Mesma DoD — IA não bypassa coverage/security |

## 9. Referências

- [15 — Documentação](15-documentacao.md)
- [16 — Code review](16-code-review.md)
- [18 — Definition of Done](18-definition-of-done.md)
- [20 — Onboarding técnico](20-onboarding-tecnico.md)
- [Mapa artefatos IA](artefatos-ia.md) — sincronização handbook ↔ Claude/Devin
