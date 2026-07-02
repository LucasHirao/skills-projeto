# 15 — Documentação

Documentação é **contrato operacional** — não é opcional nem “depois do merge”.

---

## 1. Regra de ouro

Toda documentação de componente deve responder:

1. **O que é**
2. **Por que existe**
3. **Como roda** (local e deploy)
4. **Como testa**
5. **Como opera** (idempotência, reprocessamento, falhas)
6. **Como debuga** (logs, métricas, dashboard Datadog)
7. **Quais contratos não podem quebrar**

Se alguma resposta estiver só na cabeça de alguém, a documentação está incompleta.

---

## 2. Tipos de documento

| Tipo | Quando | Onde vive | Template |
|------|--------|-----------|----------|
| README do componente | Todo serviço/job/Lambda/módulo | Raiz do repo ou `docs/` | [`templates/readme-componente.md`](templates/readme-componente.md) |
| ADR | Decisão arquitetural com trade-off | `docs/adr/` | [`templates/adr.md`](templates/adr.md) |
| Decisão técnica local | Escolha menor, sem impacto transversal | `docs/decisoes/` | [`templates/decisao-tecnica.md`](templates/decisao-tecnica.md) |
| Runbook | Operação, incidentes, reprocessamento | `docs/runbooks/` | [`templates/runbook.md`](templates/runbook.md) |
| PR | Toda mudança | Corpo do PR | [`templates/pr.md`](templates/pr.md) |
| Dashboard | Fluxo novo ou criticidade alterada | Datadog + doc | [`templates/dashboard.md`](templates/dashboard.md) |
| TaaC | Teste integrado novo | `tests/integration/` | [`templates/teste-integrado.md`](templates/teste-integrado.md) |
| Plano de implementação | Feature média/grande, multi-repo | `docs/planos/` ou PR | [`templates/plano-de-implementacao.md`](templates/plano-de-implementacao.md) |
| Documentação funcional | Processo, regras e fluxos de negócio | `docs/funcional/` ou wiki | [`templates/documentacao-funcional.md`](templates/documentacao-funcional.md) |
| Glossário funcional | Vocabulário do domínio | Junto à doc funcional | [`templates/glossario-funcional.md`](templates/glossario-funcional.md) |
| Fluxo funcional | Passo a passo de processo | Junto à doc funcional | [`templates/fluxo-funcional.md`](templates/fluxo-funcional.md) |
| Code review | Review formal ou auditoria | PR / wiki | [`templates/code-review.md`](templates/code-review.md) |

---

## 3. O que documentar por stack

### 3.1 Endpoints (Spring Boot)

- OpenAPI (`springdoc`) atualizado e publicado.
- Autenticação, autorização, rate limit.
- Códigos de erro e formato de resposta.
- Exemplos request/response (curl ou Swagger).
- SLAs e dependências downstream.

### 3.2 DAGs (Airflow)

- `doc_md` na DAG: propósito, SLA, dono.
- Schedule, `max_active_runs`, pools.
- Idempotência e chave de reprocessamento.
- Dependências externas (sensors, datasets).
- Variáveis `conf` aceitas (`data_referencia`, `correlation_id`).
- Link para runbook e dashboard Datadog.

### 3.3 Models (dbt)

- `description` no `schema.yml` (model e colunas críticas).
- Regras de negócio não óbvias.
- Estratégia incremental, `unique_key`, lookback.
- Dependências (`ref`, `source`) e consumidores (`exposures`).
- Testes customizados e o que validam.

### 3.4 Jobs (Glue)

- Parâmetros do job (`--data_referencia`, `--correlation_id`).
- Schema entrada/saída e evolução.
- Particionamento e modo de escrita (overwrite/append/merge).
- Bookmark e comportamento em retry.
- Métricas custom enviadas ao Datadog.

### 3.5 Lambdas

- Formato do evento (exemplo JSON).
- Erros retornáveis vs envio para DLQ.
- Variáveis de ambiente e secrets.
- Timeout, memória, concorrência reservada.
- Idempotência por `correlation_id` ou chave de negócio.

### 3.6 Módulos Terraform

- Inputs/outputs com descrição e default.
- Recursos criados e dependências.
- Permissões IAM (link para policy).
- Alarmes Datadog/CloudWatch provisionados.
- Como rodar `plan` em hml e prod.

---

## 4. Contratos e lineage

| Artefato | Quando |
|----------|--------|
| Dicionário de dados | Marts críticos consumidos por negócio |
| dbt `exposures` | Todo mart com consumidor externo |
| Schema versionado | Eventos Avro/JSON Schema em filas e APIs |
| OpenAPI versionado | APIs públicas ou entre times |
| README cross-repo | Quando contrato cruza repositórios |

**Breaking change:** sempre explícito no PR, com plano de migração e comunicação aos consumidores.

---

## 5. Estratégias operacionais (obrigatório em README)

Documentar explicitamente:

| Tópico | Conteúdo |
|--------|----------|
| **Idempotência** | Chave, comportamento em retry |
| **Falhas** | Retry, DLQ, skip, alerta |
| **Reprocessamento** | Comando de backfill, escopo seguro |
| **Observabilidade** | Logs (`correlation_id`), métricas, dashboard, runbook |
| **SLA** | Janela esperada e impacto de atraso |
| **Rollback** | Como reverter deploy ou dados |

---

## 6. Documentação em ambiente multi-repo

1. **Um README por repositório** — não assumir que o leitor conhece o monorepo vizinho.
2. **Links entre repos** — URL do contrato (OpenAPI, schema dbt, output Terraform).
3. **PR coordenado** — referenciar PRs irmãos no corpo (`Depends on org/repo#123`).
4. **Handbook central** (`repositorio-de-padroes`) — padrões transversais; detalhe operacional fica no repo do serviço.

---

## 7. Documentação para uso com IA

Facilitar que agentes encontrem contexto sem inventar regras:

- Nomes de arquivos alinhados ao domínio (`processar_pedidos_vendas.py`, não `utils2.py`).
- README com comandos **copy-paste** testados.
- Links para ADRs e capítulos do handbook (`04-airflow.md`, etc.).
- Comentários só onde a regra de negócio não é óbvia no código.
- Evitar conhecimento **só oral** — se foi decidido em reunião, virar ADR ou decisão técnica.

Ver [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md).

---

## 8. Manutenção e Definition of Done

| Evento | Ação de documentação |
|--------|---------------------|
| PR muda contrato | Atualizar README, OpenAPI, schema.yml |
| Incidente relevante | Atualizar runbook em até 48h |
| Decisão superada | ADR marcada `Substituída por ADR-XXX` |
| Fluxo novo crítico | Dashboard + runbook + README |
| Deprecação | Aviso com prazo; ADR se impacto amplo |

Documentação desatualizada é tratada como **bug** — pode bloquear merge em fluxos críticos.

---

## 9. Checklist no PR

- [ ] README atualizado se comportamento, contrato ou operação mudou
- [ ] ADR criado se decisão arquitetural relevante
- [ ] Runbook/dashboard se impacto operacional novo
- [ ] OpenAPI / schema.yml / exposures atualizados
- [ ] Comandos de teste e execução reproduzíveis
- [ ] Links cross-repo se entrega multi-repo

---

## 10. Referências

- [13 — Observabilidade](13-observabilidade.md)
- [16 — Code review](16-code-review.md)
- [18 — Definition of Done](18-definition-of-done.md)
- Templates: [`templates/`](templates/)
