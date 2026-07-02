# 18 — Definition of Done (DoD)

Uma tarefa só está **pronta** quando todos os itens **aplicáveis** abaixo estão atendidos no(s) repositório(s) de código tocados.

**Multi-repo:** um PR por repositório. Entregas que cruzam repos exigem PRs coordenados, contratos atualizados e referências cruzadas no corpo de cada PR.

---

## 1. DoD universal (toda entrega de código)

### 1.1 Código e padrões

- [ ] Implementação segue o capítulo da stack no [Engineering Handbook](.)
- [ ] Lógica de negócio **fora** de handler/DAG/Terraform indevida
- [ ] Lint e format aplicados; estilo do módulo vizinho
- [ ] Nomes explícitos em **português** para código interno; exceções documentadas (contrato/SDK/legado)

### 1.2 Testes

- [ ] Testes unitários com **cobertura ≥ 90%** (exceções justificadas no PR)
- [ ] **Mutation score ≥ 90%** em `domain/` / `application/` onde aplicável
- [ ] **TaaC** quando há integração real (filas, DB, APIs, S3)
- [ ] Evidência de execução local ou CI anexada no PR
- [ ] Asserts de **comportamento**, não só execução sem erro

### 1.3 Documentação

- [ ] README do componente atualizado se comportamento ou contrato mudou
- [ ] **ADR** criado se decisão arquitetural relevante
- [ ] Runbook atualizado se impacto operacional ou novo incidente
- [ ] OpenAPI / `schema.yml` / exposures atualizados se contrato mudou
- [ ] Plano de implementação para features médias/grandes

### 1.4 Observabilidade

- [ ] Logs JSON com `correlation_id`, `service`, `env`, `status`
- [ ] Métricas de sucesso, erro, duração e volume (Datadog)
- [ ] Sem PII em log ou tags de alta cardinalidade
- [ ] Dashboard + monitor + runbook se fluxo **novo** ou **crítico**

### 1.5 Performance

- [ ] Volume esperado e pico considerados
- [ ] Sem N+1, full scan evitável ou collect massivo
- [ ] Timeout, retry e idempotência documentados
- [ ] Custo AWS estimado se impacto > 20%

### 1.6 Segurança

- [ ] Least privilege IAM; sem `*` sem ADR
- [ ] Sem segredos no código ou state
- [ ] Inputs validados na borda
- [ ] Scan de dependências e IaC sem bloqueio não justificado
- [ ] Dados sensíveis mascarados ou excluídos

### 1.7 Operação

- [ ] Idempotência e reprocessamento documentados
- [ ] Rollback ou plano de reversão considerado
- [ ] Feature flags com rollout e rollback (se aplicável)
- [ ] Pipeline CI **verde**

### 1.8 Review

- [ ] Code review aprovado por **humano**
- [ ] Checklist da stack (abaixo) consultado
- [ ] Breaking change explícito com migração e comunicação

---

## 2. DoD por stack

### 2.1 Airflow

- [ ] `airflow dags list` / parse test na CI
- [ ] Zero I/O no import da DAG
- [ ] `doc_md` com SLA, dono, idempotência
- [ ] `on_failure_callback` → log JSON + métrica Datadog
- [ ] `correlation_id` propagado via `dag_run.conf`
- [ ] `max_active_runs` definido conscientemente
- [ ] Sensors com `mode="reschedule"` quando longos
- [ ] TaaC se DAG integra com S3/fila/DB externo

### 2.2 dbt

- [ ] `schema.yml` com descriptions (model + colunas críticas)
- [ ] `dbt build` verde (run + test)
- [ ] Estratégia incremental com `unique_key` documentada
- [ ] Tests em colunas de negócio críticas
- [ ] `exposures` atualizados se consumidor externo
- [ ] Freshness configurado em sources críticos
- [ ] Métricas de build expostas à CI/Datadog

### 2.3 Terraform

- [ ] `terraform fmt` + `validate`
- [ ] `plan` na CI ou anexado ao PR
- [ ] tfsec/checkov sem HIGH/CRITICAL não justificado
- [ ] Tags obrigatórias: `env`, `service`, `team`
- [ ] IAM least privilege
- [ ] Alarmes Datadog/CloudWatch em recursos críticos
- [ ] README do módulo com inputs/outputs
- [ ] Sem segredo em plain text

### 2.4 Lambda Python

- [ ] Handler fino; domínio em módulo testável
- [ ] AWS Lambda Powertools: Logger, Tracer, Metrics
- [ ] Datadog Extension configurada (`DD_*`)
- [ ] DLQ se invocação assíncrona (SQS, EventBridge)
- [ ] Timeout e memória dimensionados
- [ ] Cobertura ≥ 90%; mutation em domain
- [ ] TaaC se integra com AWS real (LocalStack ou hml)

### 2.5 Java Spring Boot

- [ ] OpenAPI atualizado
- [ ] Spring Security em endpoints expostos
- [ ] MDC `correlation_id`; Micrometer → Datadog
- [ ] Paginação em listagens; sem N+1
- [ ] Testes unitários + slice/IT em endpoints novos
- [ ] Cobertura ≥ 90%; mutation em domain/application
- [ ] TaaC para fluxos integrados críticos

### 2.6 AWS Glue

- [ ] Transformações testáveis (funções puras extraídas)
- [ ] Particionamento de saída documentado
- [ ] Job args: `data_referencia`, `correlation_id`
- [ ] Bookmark ou estratégia incremental
- [ ] Log JSON no driver com volume e duração
- [ ] Métricas custom no Datadog
- [ ] TaaC com subset representativo de dados

### 2.7 Documentação (entrega doc-only)

- [ ] Responde às 7 perguntas do [15 — Documentação](15-documentacao.md)
- [ ] Links válidos; comandos testados
- [ ] Revisão de par técnico
- [ ] Sem informação sensível ou desatualizada

### 2.8 Observabilidade (entrega obs-only)

- [ ] Monitors com runbook linkado
- [ ] Dashboard com owner e filtros `env`/`service`
- [ ] SLO definido se fluxo crítico
- [ ] Cardinalidade de tags revisada
- [ ] Teste de alerta em hml (fire drill)

### 2.9 Performance (entrega perf-only)

- [ ] Baseline documentado (métrica Datadog antes/depois)
- [ ] Teste de volume representativo
- [ ] ADR se trade-off de custo vs latência

### 2.10 Segurança (entrega seg-only)

- [ ] Threat model leve ou checklist [17](17-seguranca-conformidade-e-dados-sensiveis.md)
- [ ] Evidência de scan limpo ou ADR de exceção
- [ ] Rotação de segredo se exposto

---

## 3. Metas de qualidade numéricas

| Métrica | Meta | Onde mede | Exceção |
|---------|------|-----------|---------|
| Cobertura unitária | **≥ 90%** | CI (coverage.xml) | DTO/bootstrap — justificar no PR |
| Mutation score | **≥ 90%** | CI (mutmut, Stryker, etc.) | UI/adapters finos — justificar |
| TaaC | Passando | CI estágio `integration` | Só unitário se sem integração real |
| CI | Verde | GitHub Actions / equivalente | Nunca merge com vermelho |

---

## 4. Pipeline CI mínima (recomendada)

```yaml
# Conceito — ajustar ao projeto
stages:
  - lint          # ruff, eslint, terraform fmt
  - unit          # pytest / mvn test
  - coverage      # --cov-fail-under=90
  - mutation      # mutmut / stryker (domain)
  - integration   # pytest -m taac
  - security      # pip audit, tfsec, gitleaks
  - dbt           # dbt build (se repo dbt)
  - airflow       # dags list (se repo airflow)
```

Bloqueios mínimos para merge: lint + unit + coverage + security. Mutation e TaaC conforme maturidade do repo.

---

## 5. Exceções temporárias

| Situação | Quem aprova | O que documentar |
|----------|-------------|------------------|
| Spike < 2 dias | Tech lead | Label `spike`; débito listado; issue de convergência |
| Cobertura < 90% | Reviewer | Justificativa; issue se débito real |
| Mutation < 90% | Tech lead | Escopo excluído e plano |
| Breaking change | Tech lead + consumidores | ADR + comunicação + migração |
| Sem TaaC inicial | Tech lead | Issue com prazo; integração mockada não conta |

Spike **não** vai para produção sem convergir para DoD completa.

---

## 6. DoD por tipo de entrega

| Entrega | Itens além da DoD universal |
|---------|----------------------------|
| Nova DAG | parse test, callbacks, doc_md, TaaC se integra |
| Novo model dbt | schema.yml, exposures, freshness |
| Novo módulo TF | plan, alarmes, README módulo |
| Nova Lambda | Powertools, DLQ, Extension Datadog |
| Novo endpoint API | OpenAPI, auth, testes IT |
| Novo job Glue | particionamento, bookmark, métricas |
| Hotfix prod | Postmortem se SEV1/2; runbook atualizado |
| Só documentação | §2.7 |
| Só observabilidade | §2.8 |

---

## 7. Checklist rápido para o autor (copiar no PR)

```markdown
## DoD
- [ ] Código + lint
- [ ] Testes ≥90% + mutation (se aplicável) + TaaC (se integração)
- [ ] Documentação (README/ADR/runbook)
- [ ] Observabilidade (logs, métricas, correlation_id)
- [ ] Performance avaliada
- [ ] Segurança (IAM, secrets, PII)
- [ ] CI verde
- [ ] Review humano
```

Template completo: [`templates/pr.md`](templates/pr.md).

---

## 8. Referências

- [10 — Testes unitários](10-testes-unitarios.md)
- [11 — TaaC](11-taac-testes-integrados-na-pipeline.md)
- [12 — Testes de mutação](12-testes-de-mutacao.md)
- [13 — Observabilidade](13-observabilidade.md)
- [14 — Performance](14-performance.md)
- [15 — Documentação](15-documentacao.md)
- [16 — Code review](16-code-review.md)
- [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md)
