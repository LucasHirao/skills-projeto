# 20 — Onboarding técnico

Guia para integração em squads de **dados e backend** em ambiente **multi-repo**, com Datadog, DoD rigorosa e uso de IA assistida.

**Tempo estimado de leitura inicial:** 3–4 horas (leitura + exercício).

---

## 1. Antes de tudo

| Item | Ação |
|------|------|
| Acesso | Repositórios Git, AWS (via SSO), Datadog, CI, Slack do time |
| Repo de padrões | Clone `repositorio-de-padroes` — este handbook |
| Repo de código | Identificar o repo do seu primeiro ticket (ver §6) |
| IA | Cursor ou ferramenta aprovada pelo time — ler [19 — Padrões para IA](19-padroes-para-uso-de-ia.md) |

---

## 2. Ordem de leitura comum (todos os perfis)

1. [00 — Como usar este handbook](00-como-usar-este-handbook.md)
2. [01 — Contexto, princípios e objetivos](01-contexto-principios-e-objetivos.md)
3. [02 — Arquitetura transversal](02-arquitetura-transversal.md) — multi-repo, contratos
4. Capítulo(s) da **sua stack** (`04`–`09`)
5. [10 — Testes unitários](10-testes-unitarios.md) + [11 — TaaC](11-taac-testes-integrados-na-pipeline.md) + [12 — Mutação](12-testes-de-mutacao.md)
6. [13 — Observabilidade (Datadog)](13-observabilidade.md)
7. [18 — Definition of Done](18-definition-of-done.md)
8. [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md)
9. **Este capítulo** — trilha do seu perfil (§3)

---

## 3. Trilhas por perfil

### 3.1 Desenvolvedor júnior

**Objetivo:** primeiro PR pequeno com DoD completa em uma stack.

| Semana | Foco | Leitura | Entrega |
|--------|------|---------|---------|
| 1 | Setup + leitura | 00–02, stack, 18 | Ambiente local rodando; testes existentes passando |
| 2 | Observabilidade e testes | 10–13 | Explicar `correlation_id` e onde ver logs no Datadog |
| 3 | Primeiro PR | 16, 19 | Bugfix ou teste faltante; cov mantida ≥90% |
| 4 | Integração | 11, 15 | Acompanhar review; atualizar README se orientado |

**Primeiro PR sugerido:**

- Adicionar testes faltantes em módulo `domain/`
- Melhorar log estruturado sem mudar regra de negócio
- Corrigir documentação desatualizada com comando testado

**Mentoria:** pareamento no primeiro review; revisor explica cada 🔴.

**Checklist júnior — dia 1:**

- [ ] Acesso Git, AWS, Datadog, CI
- [ ] `repositorio-de-padroes` clonado; leu 00 e 18
- [ ] Repo de código clonado; build/test local OK
- [ ] Um fluxo rastreado no Datadog por `correlation_id` (exemplo do time)
- [ ] Canal Slack do time identificado
- [ ] Mentor designado

---

### 3.2 Desenvolvedor terceiro / consultor

**Objetivo:** produtividade rápida **sem** diluir padrões do cliente.

| Prioridade | Ação |
|------------|------|
| Contratos | Ler README dos repos que vai tocar; não assumir padrão de outro cliente |
| DoD | [18](18-definition-of-done.md) é não negociável salvo exceção aprovada por tech lead |
| Segurança | [17](17-seguranca-conformidade-e-dados-sensiveis.md) — sem PII em prompt ou log |
| IA | Usar templates do [19](19-padroes-para-uso-de-ia.md); review humano obrigatório |
| Multi-repo | Um PR por repo; referenciar PRs irmãos |

**Entregáveis esperados por sprint:**

- PRs com template [`templates/pr.md`](templates/pr.md) preenchido
- Evidência CI verde + cobertura
- Sem “TODO: documentar depois” em fluxo crítico

**Checklist terceiro — semana 1:**

- [ ] Leu 02 (multi-repo), 17 (segurança), 18 (DoD)
- [ ] Assinou/acordou política de dados do cliente
- [ ] Identificou tech lead e canal de escalação
- [ ] Executou ou simulou TaaC local (se aplicável)
- [ ] Primeiro PR aberto em até 5 dias úteis

---

### 3.3 Revisor (code reviewer)

**Objetivo:** gate de qualidade consistente entre squads.

| Responsabilidade | Referência |
|------------------|------------|
| Dimensões de review | [16 — Code review](16-code-review.md) |
| Checklist da stack | Seção 6 do capítulo 16 |
| Severidade | 🔴 bloqueio / 🟡 atenção / 🟢 sugestão |
| DoD | Não aprovar sem itens aplicáveis |
| IA | Código gerado por IA = atenção redobrada (§4 do 16) |

**Fluxo de review:**

1. CI verde
2. Ler descrição do PR ([`templates/pr.md`](templates/pr.md))
3. Checar testes, observabilidade, segurança, dados
4. Comentários com severidade
5. Registrar review formal se time exigir ([`templates/code-review.md`](templates/code-review.md))

**SLA sugerido:** resposta em 1–2 dias úteis; 🔴 em menos de 1 dia se bloqueante.

**Checklist revisor:**

- [ ] Leu 16 completo + capítulo stack do PR
- [ ] Sabe aprovar exceção de DoD (quando e quem)
- [ ] Conhece dashboards Datadog do domínio
- [ ] Skill `revisar-codigo` testada (opcional)

---

### 3.4 Tech lead

**Objetivo:** coerência arquitetural, exceções, multi-repo e evolução do handbook.

| Responsabilidade | Ação |
|------------------|------|
| ADRs | Aprovar decisões com trade-off; garantir registro |
| DoD exceções | Spike, breaking change, cov < 90% |
| Multi-repo | Ordem de deploy; contratos entre times |
| Incidentes | Postmortem; runbook; SLO |
| Handbook | Propor PRs em `repositorio-de-padroes`; derivar skills ([19 §7](19-padroes-para-uso-de-ia.md#7-como-extrair-skills-playbooks-e-rules-a-partir-deste-handbook)) |
| Onboarding | Atribuir mentor; validar trilha júnior/terceiro |

**Rituais sugeridos:**

- Revisão trimestral de SLOs e dashboards
- Débito técnico de spikes com prazo
- Piloto de skill nova antes de rollout no time

---

## 4. Multi-repo — mapa mental

```
repositorio-de-padroes          → padrões (handbook 00–20, templates)
org/terraform-*      → infra, IAM, alarmes
org/airflow-*        → DAGs
org/dbt-*            → models, tests, exposures
org/glue-* / lambda  → ingestão e processamento
org/api-*            → Spring Boot APIs
```

**Regras:**

1. Um propósito por repositório
2. Integração por **contrato** (schema, path S3, OpenAPI, TF output)
3. PR coordenado quando contrato muda
4. Padrões transversais só em `repositorio-de-padroes`

---

## 5. Primeiro PR — passo a passo

1. Identificar **repositório de código** correto (ticket / tech lead).
2. Ler código **similar** no mesmo repo — copiar estilo, não outro cliente.
3. Branch: `{ticket}-{descricao-curta}`.
4. Implementar com DoD ([18](18-definition-of-done.md)).
5. Preencher [`templates/pr.md`](templates/pr.md).
6. CI verde; anexar evidência de cov.
7. Se cruzar contrato: mencionar PRs irmãos e ordem de merge.
8. Solicitar review; responder comentários em 1 dia útil.

---

## 6. Exceções à Definition of Done

| Situação | Quem aprova | O que documentar |
|----------|-------------|------------------|
| Cobertura < 90% em DTO/bootstrap | Reviewer | Justificativa no PR; issue se débito |
| Spike < 2 dias | Tech lead | Label `spike` + débito + issue |
| Breaking change | Tech lead + consumidores | ADR + comunicação |
| Sem TaaC na v1 | Tech lead | Issue com prazo; mock não substitui integração real |
| Mutation < 90% | Tech lead | Escopo excluído documentado |

---

## 7. Ferramentas do dia a dia

| Ferramenta | Uso no onboarding |
|------------|-------------------|
| **Datadog** | Logs (`correlation_id`), APM, dashboards, monitors |
| **CI** | Status de build, coverage, mutation, TaaC |
| **GitHub** | PR, review, `gh pr checks` |
| **IA (Cursor)** | [19 — Templates de prompt](19-padroes-para-uso-de-ia.md#3-templates-de-prompt) |
| **Handbook** | Fonte de verdade — `docs/engineering-handbook/` |

---

## 8. Contatos do time (preencher)

| Domínio | Responsável | Canal |
|---------|-------------|-------|
| Dados / dbt | _a definir_ | |
| Orquestração / Airflow | _a definir_ | |
| Infra / Terraform | _a definir_ | |
| APIs / Spring | _a definir_ | |
| Observabilidade / Datadog | _a definir_ | |
| Plantão / incidentes | _a definir_ | |

---

## 9. Anti-padrões no onboarding

| Evitar | Consequência |
|--------|--------------|
| Implementar sem ler padrão da stack | PR bloqueado, retrabalho |
| Copiar de outro projeto/cliente | Contrato errado, incidente |
| PR grande sem testes | Review lento, regressão |
| Ignorar impacto em dados/reprocessamento | Duplicata, perda |
| PII em log ou prompt | Compliance |
| Merge sem CI verde | Main quebrada |

---

## 10. Referências

- [18 — Definition of Done](18-definition-of-done.md)
- [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md)
- [16 — Code review](16-code-review.md)
- Templates: [`templates/`](templates/)
- Runbook exemplo: [`../runbooks/carga-diaria-atraso.md`](../runbooks/carga-diaria-atraso.md)
