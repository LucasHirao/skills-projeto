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

## 2. Perfis de maturidade

Use os níveis abaixo **além** do DoD universal (§1). Detalhes específicos de cada stack ficam no capítulo registrado em [`manifest.yaml`](manifest.yaml).

### Nível 1 — obrigatório desde o primeiro PR

- lint/format;
- testes unitários;
- cobertura mínima ou justificativa;
- security scan;
- documentação mínima;
- [logging seguro](13-observabilidade.md#checklist-de-logging-seguro).

### Nível 2 — integração real

- TaaC;
- contratos versionados;
- observabilidade com métricas/logs;
- runbook;
- validação de dados sensíveis.

### Nível 3 — fluxo crítico

- mutation testing;
- SLO/dashboard;
- teste de volume/performance;
- rollback validado;
- game day ou fire drill quando aplicável.

---

## 3. DoD por stack

Os detalhes específicos ficam no **capítulo da stack** registrado no [`manifest.yaml`](manifest.yaml).

A tabela abaixo é apenas um **resumo humano** das stacks principais atuais. O catálogo canônico de stacks e capítulos vive em [`manifest.yaml`](manifest.yaml). Ao adicionar nova stack, atualize o manifesto e o capítulo da stack; **não** transforme esta seção em lista exaustiva.

### Stacks principais atuais

| Stack | Capítulo | Perfil `dod_profile` |
|-------|----------|----------------------|
| Airflow | [04-airflow.md](04-airflow.md) | `airflow` |
| dbt | [05-dbt.md](05-dbt.md) | `dbt` |
| Terraform | [06-terraform.md](06-terraform.md) | `terraform` |
| Lambda Python | [07-lambda-python.md](07-lambda-python.md) | `lambda-python` |
| Java Spring Boot | [08-java-spring-boot.md](08-java-spring-boot.md) | `java-spring-boot` |
| AWS Glue | [09-aws-glue.md](09-aws-glue.md) | `aws-glue` |

### Recorte mínimo (referência rápida)

> Fonte exaustiva: capítulo da stack. Use apenas como lembrete no PR.

| Stack | Recorte |
|-------|---------|
| Airflow | parse test; callback Datadog; `correlation_id`; TaaC se integração externa |
| dbt | `dbt build` verde; `schema.yml`; testes em colunas críticas |
| Terraform | `fmt`/`validate`; plan na CI; tfsec/checkov; IAM least privilege |
| Lambda | handler fino; Powertools; DLQ se async; cobertura ≥ 90% |
| Spring Boot | OpenAPI; Security; MDC `correlation_id`; cobertura ≥ 90% |
| Glue | transformações testáveis; particionamento; log JSON com volume |

### Entregas transversais (não-stack)

| Tipo | Referência |
|------|------------|
| Documentação | [15 — Documentação](15-documentacao.md) |
| Observabilidade | [13 — Observabilidade](13-observabilidade.md) |
| Performance | [14 — Performance](14-performance.md) |
| Segurança | [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |

---

## 4. Metas de qualidade numéricas

| Métrica | Meta | Onde mede | Exceção |
|---------|------|-----------|---------|
| Cobertura unitária | **≥ 90%** | CI (coverage.xml) | DTO/bootstrap — justificar no PR |
| Mutation score | **≥ 90%** | CI (mutmut, Stryker, etc.) | UI/adapters finos — justificar |
| TaaC | Passando | CI estágio `integration` | Só unitário se sem integração real |
| CI | Verde | GitHub Actions / equivalente | Nunca merge com vermelho |

---

## 5. Pipeline CI mínima (recomendada)

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

## 6. Exceções temporárias

| Situação | Quem aprova | O que documentar |
|----------|-------------|------------------|
| Spike < 2 dias | Tech lead | Label `spike`; débito listado; issue de convergência |
| Cobertura < 90% | Reviewer | Justificativa; issue se débito real |
| Mutation < 90% | Tech lead | Escopo excluído e plano |
| Breaking change | Tech lead + consumidores | ADR + comunicação + migração |
| Sem TaaC inicial | Tech lead | Issue com prazo; integração mockada não conta |

Spike **não** vai para produção sem convergir para DoD completa.

---

## 7. DoD por tipo de entrega

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

## 8. Checklist rápido para o autor (copiar no PR)

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

## 9. Referências

- [10 — Testes unitários](10-testes-unitarios.md)
- [11 — TaaC](11-taac-testes-integrados-na-pipeline.md)
- [12 — Testes de mutação](12-testes-de-mutacao.md)
- [13 — Observabilidade](13-observabilidade.md)
- [14 — Performance](14-performance.md)
- [15 — Documentação](15-documentacao.md)
- [16 — Code review](16-code-review.md)
- [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md)
