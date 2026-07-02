# 00 — Como usar este handbook

> **Versão:** 1.1 · **Idioma:** português BR (identificadores internos em português; termos técnicos oficiais em inglês quando necessário) · **Modelo:** multi-repo · **Observabilidade:** Datadog

---

## Sumário

1. [Objetivo](#1-objetivo)
2. [Público-alvo](#2-público-alvo)
3. [Problemas que este handbook resolve](#3-problemas-que-este-handbook-resolve)
4. [Princípios de uso](#4-princípios-de-uso)
5. [Decisões de desenho do handbook](#5-decisões-de-desenho-do-handbook)
6. [Trade-offs](#6-trade-offs)
7. [Quando usar / quando não usar](#7-quando-usar--quando-não-usar)
8. [Estrutura do handbook (00–20)](#8-estrutura-do-handbook-0020)
9. [Trilhas de leitura](#9-trilhas-de-leitura)
10. [Convenções de nomenclatura](#10-convenções-de-nomenclatura)
11. [Práticas obrigatórias e recomendadas](#11-práticas-obrigatórias-e-recomendadas)
12. [Anti-padrões de uso](#12-anti-padrões-de-uso)
13. [Estrutura de pastas e artefatos](#13-estrutura-de-pastas-e-artefatos)
14. [Estratégias transversais](#14-estrégias-transversais)
15. [Checklists](#15-checklists)
16. [Critérios de aceite](#16-critérios-de-aceite)
17. [Definition of Done (DoD)](#17-definition-of-done-dod)
18. [FAQ](#18-faq)
19. [Guia para desenvolvedores júnior](#19-guia-para-desenvolvedores-júnior)
20. [Guia para desenvolvedores sênior](#20-guia-para-desenvolvedores-sênior)

---

## 1. Objetivo

Este documento é o **ponto de entrada** do Engineering Handbook. Ele explica **como navegar**, **quando consultar cada capítulo**, **como aplicar os padrões em repositórios de código separados** e **como manter o handbook vivo** sem transformá-lo em burocracia.

O handbook é a **fonte de verdade** para padrões técnicos de squads de dados e backend. Código de produção vive em repositórios dedicados (`{nome-projeto}-airflow`, `{nome-projeto}-dbt`, etc.); este repositório (`repositorio-de-padroes`) concentra a documentação versionada que todos os times devem seguir.

**Resultado esperado:** qualquer pessoa — interna, terceira ou assistente de IA — consegue, em menos de uma hora, entender o que ler, onde implementar e quais critérios de qualidade aplicar antes de abrir o primeiro PR.

---

## 2. Público-alvo

| Perfil | Como usar este capítulo |
|--------|-------------------------|
| **Desenvolvedor júnior** | Comece pela [trilha essencial](#91-trilha-essencial-primeira-semana) e pelo [20 — Onboarding técnico](20-onboarding-tecnico.md) |
| **Desenvolvedor pleno/sênior** | Use como referência por stack; consulte trade-offs e decisões antes de propor exceções |
| **Tech lead / arquiteto** | Valide aderência em reviews; proponha ADRs quando o handbook não cobrir o caso |
| **Revisor de código** | Trilha [revisores](#94-trilha-revisores-de-código); capítulos [16](16-code-review.md) e [18](18-definition-of-done.md) |
| **SRE / operação** | Trilha [operação](#95-trilha-operação-e-sre); capítulos [13](13-observabilidade.md), runbooks e [17](17-seguranca-conformidade-e-dados-sensiveis.md) |
| **Product / analytics** | Leia [01](01-contexto-principios-e-objetivos.md) e marts dbt [05](05-dbt.md) para entender SLAs e contratos de dados |
| **Usuário de IA** | Trilha [IA](#96-trilha-uso-com-ia); capítulo [19](19-padroes-para-uso-de-ia.md) — **não** substitua a leitura dos capítulos de stack |

---

## 3. Problemas que este handbook resolve

| Problema | Sintoma no dia a dia | Como o handbook ajuda |
|----------|----------------------|------------------------|
| **Divergência entre times** | Cada repo com estrutura, naming e testes diferentes | Padrões opinionados por stack + arquitetura transversal |
| **Onboarding lento** | Mesmas perguntas repetidas no Slack | Trilhas de leitura + [20-onboarding-tecnico.md](20-onboarding-tecnico.md) |
| **Código difícil de operar** | Incidentes sem runbook, logs inúteis | [13-observabilidade.md](13-observabilidade.md) (Datadog), templates de runbook |
| **PRs grandes e arriscados** | Mudanças sem teste, sem contrato, sem doc | DoD em [18](18-definition-of-done.md), TaaC em [11](11-taac-testes-integrados-na-pipeline.md) |
| **Dívida em pipelines** | DAGs god, SQL em handler, Terraform monolítico | Capítulos por stack com anti-padrões explícitos |
| **Multi-repo sem contrato** | Time A quebra time B ao mudar path S3 ou schema | [02-arquitetura-transversal.md](02-arquitetura-transversal.md) — contratos entre repos |
| **Uso caótico de IA** | Código gerado sem padrão, secrets no prompt | [19-padroes-para-uso-de-ia.md](19-padroes-para-uso-de-ia.md) |

---

## 4. Princípios de uso

1. **Handbook antes do hábito** — na dúvida, o padrão documentado prevalece sobre "como sempre fizemos".
2. **Um propósito por repositório** — multi-repo; não misturar Airflow, dbt e API no mesmo repo de produção.
3. **Exceção é documentada** — spike ou desvio exige justificativa no PR, issue de convergência ou ADR ([templates/adr.md](templates/adr.md)).
4. **Opinionado, não dogmático** — trade-offs estão explícitos; decisão local válida quando registrada.
5. **Operável por padrão** — se não tem log, métrica e alerta Datadog, não está pronto para produção crítica.
6. **Testável por padrão** — regra de negócio fora de DAG, handler e Terraform; cobertura ≥ 90%.
7. **Português na prosa e nos identificadores internos** — classes, funções, variáveis e testes em português; contratos externos, SDKs e tags técnicas permanecem conforme ferramenta.
8. **Evolução contínua** — feedback vira PR neste repositório; não acumular "padrão oral".

---

## 5. Decisões de desenho do handbook

| Decisão | Escolha | Alternativa rejeitada | Motivo |
|---------|---------|----------------------|--------|
| Organização | Capítulos numerados 00–20 | Wiki fragmentada | Ordem de leitura e links estáveis |
| Repositórios | Multi-repo por stack/componente | Monorepo único | Ownership claro, deploy independente, blast radius menor |
| Observabilidade | Datadog (logs, APM, métricas, SLO) | Ferramentas ad hoc por time | Correlação única, alertas padronizados |
| Placeholder de projeto | `{nome-projeto}` | Nome fixo de produto | Reutilizável entre squads sem acoplamento |
| Localização | `docs/engineering-handbook/` | `docs/padroes/` legado | Nome alinhado a "handbook" corporativo |
| Templates | `templates/` dentro do handbook | Templates espalhados | Copiar para `docs/` do repo de serviço |
| IA | Capítulo 19 + derivar artefatos depois | Rules/skills no mesmo repo como fonte | Handbook humano é fonte de verdade |
| Idioma | PT-BR | EN | Público principal brasileiro |

---

## 6. Trade-offs

### 6.1 Padronização vs. velocidade

**Padronizar desde o dia 1** reduz retrabalho em 3–6 meses quando múltiplos times tocam os mesmos fluxos (carga diária, marts, APIs).

| Abordagem | Vantagem | Custo |
|-----------|----------|-------|
| Padronização imediata | Menos incidentes, reviews mais rápidos | Curva inicial de leitura |
| "Correr e padronizar depois" | Entrega rápida no sprint 1 | Divergência cara de corrigir |

**Recomendação:** seguir handbook no primeiro componente. **Exceção:** spike ≤ 2 dias com DoD reduzida — registrar débito no PR.

### 6.2 Documentação extensa vs. descoberta

Capítulos longos cansam quem só quer um snippet. Por isso existem **trilhas de leitura** (seção 9) e **checklists** no fim de cada capítulo de stack.

### 6.3 Multi-repo vs. visibilidade

Repos separados exigem **contratos explícitos** (README, OpenAPI, `sources.yml`, outputs Terraform). O custo de coordenação é menor que o de um monorepo com fronteiras borradas.

---

## 7. Quando usar / quando não usar

### Use este handbook quando

- Iniciar um novo repositório `{nome-projeto}-*`
- Abrir PR em código de produção (dados, backend, infra)
- Revisar código de outro time ou terceiro
- Desenhar alerta, dashboard ou runbook no Datadog
- Onboarding de novo membro
- Escalar incidente e precisar de runbook padrão
- Configurar assistente de IA para gerar código alinhado

### Não use como substituto quando

- A decisão é **estratégica de produto** (priorização, roadmap) — use processo de produto
- O caso exige **ADR de arquitetura enterprise** não coberta — crie ADR no repo do serviço
- É **prototipação descartável** sem path para produção — documente que é throwaway
- A stack **não está no escopo** (ex.: frontend mobile) — não force padrões de backend

---

## 8. Estrutura do handbook (00–20)

| # | Documento | Conteúdo principal |
|---|-----------|-------------------|
| **00** | [Como usar este handbook](00-como-usar-este-handbook.md) | Navegação, trilhas, convenções |
| **01** | [Contexto, princípios e objetivos](01-contexto-principios-e-objetivos.md) | Por quê existimos, metas de qualidade |
| **02** | [Arquitetura transversal](02-arquitetura-transversal.md) | Camadas, contratos multi-repo, integração |
| **03** | [Padrões de código](03-padroes-de-codigo.md) | SOLID, estrutura, código testável |
| **04** | [Airflow](04-airflow.md) | DAGs, orquestração, callbacks Datadog |
| **05** | [dbt](05-dbt.md) | Modelagem, testes, incremental |
| **06** | [Terraform](06-terraform.md) | IaC AWS, módulos, ambientes |
| **07** | [Lambda Python](07-lambda-python.md) | Handlers finos, domain, cold start |
| **08** | [Java Spring Boot](08-java-spring-boot.md) | APIs, hexagonal, validação |
| **09** | [AWS Glue](09-aws-glue.md) | PySpark, jobs, particionamento |
| **10** | [Testes unitários](10-testes-unitarios.md) | pytest, JUnit, cobertura 90% |
| **11** | [TaaC — testes integrados na pipeline](11-taac-testes-integrados-na-pipeline.md) | Testes ponta a ponta em CI |
| **12** | [Testes de mutação](12-testes-de-mutacao.md) | Qualidade dos testes, 90% mutation |
| **13** | [Observabilidade (Datadog)](13-observabilidade.md) | Logs, métricas, traces, SLO |
| **14** | [Performance](14-performance.md) | Volume, custo, tuning |
| **15** | [Documentação](15-documentacao.md) | README, ADR, dicionário de dados |
| **16** | [Code review](16-code-review.md) | Processo, tom, checklist |
| **17** | [Segurança, conformidade e dados sensíveis](17-seguranca-conformidade-e-dados-sensiveis.md) | PII, secrets, LGPD |
| **18** | [Definition of Done](18-definition-of-done.md) | Critérios de entrega |
| **19** | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) | Prompts, revisão de código gerado |
| **20** | [Onboarding técnico](20-onboarding-tecnico.md) | Setup, primeiro PR, acessos |

### Templates reutilizáveis

| Template | Uso |
|----------|-----|
| [adr.md](templates/adr.md) | Architecture Decision Record |
| [decisao-tecnica.md](templates/decisao-tecnica.md) | Decisão local de menor escopo |
| [pr.md](templates/pr.md) | Corpo de pull request |
| [readme-componente.md](templates/readme-componente.md) | README de serviço/job |
| [runbook.md](templates/runbook.md) | Procedimento operacional |
| [dashboard.md](templates/dashboard.md) | Especificação dashboard Datadog |
| [teste-integrado.md](templates/teste-integrado.md) | Caso TaaC |
| [code-review.md](templates/code-review.md) | Registro formal de review |
| [plano-de-implementacao.md](templates/plano-de-implementacao.md) | Features médias/grandes |

---

## 9. Trilhas de leitura

### 9.1 Trilha essencial (primeira semana)

Ordem sugerida para **qualquer** novo membro técnico:

1. [00 — Como usar este handbook](00-como-usar-este-handbook.md) *(este documento)*
2. [01 — Contexto, princípios e objetivos](01-contexto-principios-e-objetivos.md)
3. [20 — Onboarding técnico](20-onboarding-tecnico.md) — ambiente, acessos, primeiro PR
4. [02 — Arquitetura transversal](02-arquitetura-transversal.md) — visão de camadas e multi-repo
5. [18 — Definition of Done](18-definition-of-done.md) — o que "pronto" significa
6. [16 — Code review](16-code-review.md) — como dar e receber feedback
7. [13 — Observabilidade (Datadog)](13-observabilidade.md) — logs e alertas mínimos
8. **Capítulo da sua stack** (seção 9.2)

**Tempo estimado:** 4–6 horas de leitura + 1–2 dias de exercício prático no repo do time.

### 9.2 Trilha por stack

Escolha **um** bloco conforme o repositório em que você trabalha:

#### Dados — orquestração

1. [04 — Airflow](04-airflow.md)
2. [13 — Observabilidade](13-observabilidade.md) — callbacks e métricas de DAG
3. [11 — TaaC](11-taac-testes-integrados-na-pipeline.md) — se a DAG integra Glue/Lambda/dbt
4. [14 — Performance](14-performance.md) — pools, concorrência, SLA

#### Dados — transformação

1. [05 — dbt](05-dbt.md)
2. [10 — Testes unitários](10-testes-unitarios.md) — testes SQL e macros
3. [15 — Documentação](15-documentacao.md) — schema, dicionário de dados
4. [04 — Airflow](04-airflow.md) — apenas integração (Cosmos, vars, schedule)

#### Infraestrutura

1. [06 — Terraform](06-terraform.md)
2. [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) — IAM, secrets
3. [13 — Observabilidade](13-observabilidade.md) — tags, custo, monitors

#### Backend — API

1. [08 — Java Spring Boot](08-java-spring-boot.md)
2. [03 — Padrões de código](03-padroes-de-codigo.md)
3. [10 — Testes unitários](10-testes-unitarios.md) + [12 — Mutação](12-testes-de-mutacao.md)
4. [13 — Observabilidade](13-observabilidade.md) — APM Datadog

#### Backend — serverless

1. [07 — Lambda Python](07-lambda-python.md)
2. [03 — Padrões de código](03-padroes-de-codigo.md)
3. [11 — TaaC](11-taac-testes-integrados-na-pipeline.md)

#### ETL distribuído

1. [09 — AWS Glue](09-aws-glue.md)
2. [14 — Performance](14-performance.md) — shuffle, particionamento
3. [04 — Airflow](04-airflow.md) — acionamento e sensors

### 9.3 Trilha transversal (tech lead)

Para quem define padrões ou arquitetura em `{nome-projeto}`:

1. [01 — Contexto](01-contexto-principios-e-objetivos.md)
2. [02 — Arquitetura transversal](02-arquitetura-transversal.md)
3. [15 — Documentação](15-documentacao.md) + [templates/adr.md](templates/adr.md)
4. [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md)
5. [18 — Definition of Done](18-definition-of-done.md)
6. Todos os capítulos de stack sob sua responsabilidade
7. [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md) — governança de código gerado

### 9.4 Trilha revisores de código

Leitura focada em **qualidade e consistência** em PRs:

1. [16 — Code review](16-code-review.md)
2. [18 — Definition of Done](18-definition-of-done.md)
3. [03 — Padrões de código](03-padroes-de-codigo.md)
4. Capítulo da stack do PR ([04](04-airflow.md)–[09](09-aws-glue.md))
5. [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) — secrets, PII
6. [templates/code-review.md](templates/code-review.md) — registro quando necessário

**Durante o review:** use o checklist do capítulo de stack + checklist transversal (seção 15).

### 9.5 Trilha operação e SRE

Para quem responde a alertas e mantém SLAs:

1. [13 — Observabilidade (Datadog)](13-observabilidade.md)
2. [04 — Airflow](04-airflow.md) — backfill, pools, falhas de task
3. [05 — dbt](05-dbt.md) — freshness, falhas de teste
4. [14 — Performance](14-performance.md) — custo AWS, scans
5. [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) — incidentes de dados
6. Runbooks em `docs/runbooks/` do repo de serviço (template: [runbook.md](templates/runbook.md))

**Prática:** todo monitor Datadog de severidade high+ deve linkar runbook.

### 9.6 Trilha uso com IA

Para quem usa assistentes de código no fluxo diário:

1. [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md)
2. [03 — Padrões de código](03-padroes-de-codigo.md) — o que a IA deve respeitar
3. Capítulo da tarefa ([04](04-airflow.md)–[09](09-aws-glue.md))
4. [16 — Code review](16-code-review.md) — revisar código gerado como humano
5. [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) — nunca colar secrets no prompt

**Regra:** a IA **implementa** padrões do handbook; o handbook **não** é substituído por resumo no chat.

---

## 10. Convenções de nomenclatura

### 10.1 Placeholder `{nome-projeto}`

Substitua pelo identificador curto do produto ou programa (ex.: `datalake`, `pagamentos`, `crm`).

| Contexto | Padrão | Exemplo |
|----------|--------|---------|
| Repositório Git | `{nome-projeto}-{componente}` | `datalake-dbt` |
| DAG Airflow | `{nome-projeto}_{dominio}_{fluxo}` | `datalake_vendas_carga_diaria` |
| Recurso AWS | `{nome-projeto}-{dominio}-{tipo}-{env}` | `datalake-vendas-bucket-prod` |
| Variable Airflow | `{nome-projeto}_{chave}` | `datalake_env` |
| Service Datadog | `{nome-projeto}-{componente}` | `datalake-lambda-valida-arquivo` |
| Tag dbt | `{nome-projeto}` + domínio | `datalake`, `vendas` |

### 10.2 Links entre capítulos

- Links relativos no mesmo diretório: `[dbt](05-dbt.md)`
- Âncoras em capítulos longos: `[DoD](18-definition-of-done.md#critérios-mínimos)`
- Templates: `[template PR](templates/pr.md)`

### 10.3 Versionamento do handbook

Mudanças breaking nos padrões devem:

1. Ser comunicadas em `#engenharia` (ou canal do time)
2. Incluir período de convivência quando possível
3. Atualizar [18-definition-of-done.md](18-definition-of-done.md) se critérios mudarem

### 10.4 Código interno em português

Identificadores criados pelo time (classes, funções, variáveis, testes, `task_id`, models dbt após prefixo) em **português**. Detalhes: [03 — Padrões de código](03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português).

---

## 11. Práticas obrigatórias e recomendadas

### Obrigatórias

| # | Prática | Referência |
|---|---------|------------|
| O1 | Ler trilha essencial antes do primeiro PR em produção | Seção 9.1 |
| O2 | Um PR por repositório de código (não misturar airflow + dbt) | [02](02-arquitetura-transversal.md) |
| O3 | Seguir DoD do [18](18-definition-of-done.md) | DoD |
| O4 | Logs estruturados JSON com `correlation_id` no Datadog | [13](13-observabilidade.md) |
| O5 | Sem secrets em código, Variables Airflow ou state Terraform | [17](17-seguranca-conformidade-e-dados-sensiveis.md) |
| O6 | Regra de negócio testável fora de framework | [03](03-padroes-de-codigo.md) |
| O7 | Template de PR preenchido | [templates/pr.md](templates/pr.md) |
| O8 | Exceção documentada (PR, ADR ou decisão técnica) | [templates/adr.md](templates/adr.md) |

### Recomendadas

| # | Prática | Benefício |
|---|---------|-----------|
| R1 | Marcar capítulo consultado no corpo do PR | Acelera review |
| R2 | Copiar README do [template](templates/readme-componente.md) em todo repo novo | Onboarding |
| R3 | Revisar handbook quando incidente revelou lacuna | Melhoria contínua |
| R4 | Pair review em mudanças de contrato cross-repo | Menos quebra downstream |
| R5 | Dashboard Datadog por fluxo crítico novo | [templates/dashboard.md](templates/dashboard.md) |

---

## 12. Anti-padrões de uso

| Anti-padrão | Por que é ruim | Correção |
|-------------|----------------|----------|
| "Não li, copiei do repo vizinho" | Propaga dívida antiga | Ler capítulo da stack |
| Handbook como PDF morto | Desatualiza em semanas | PR no repo `repositorio-de-padroes` |
| Padrão oral no Slack | Não escala, não audita | Documentar no capítulo certo |
| Monorepo disfarçado | Ownership confuso | Separar `{nome-projeto}-*` |
| Checklist só no último dia | Retrabalho caro | DoD desde o início do card |
| IA sem revisão humana | Bugs e secrets | [16](16-code-review.md) + [19](19-padroes-para-uso-de-ia.md) |
| Link quebrado entre capítulos | Perda de confiança | PR de doc junto com rename |
| Ignorar Datadog "porque depois vejo" | Incidente cego | Observabilidade no mesmo PR da feature |

---

## 13. Estrutura de pastas e artefatos

### 13.1 Este repositório (`repositorio-de-padroes`)

```
repositorio-de-padroes/
├── README.md
└── docs/
    └── engineering-handbook/       # Capítulos 00–20
        ├── 00-como-usar-este-handbook.md
        ├── ...
        ├── 20-onboarding-tecnico.md
        └── templates/              # Copiar para repos de serviço
```

### 13.2 Repositório de código típico (`{nome-projeto}-*`)

```
{nome-projeto}-dbt/
├── README.md                       # De templates/readme-componente.md
├── docs/
│   ├── adr/                        # Decisões locais
│   └── runbooks/                   # Operação
├── models/                         # (dbt) ou src/, dags/, etc.
├── tests/
└── .github/ ou pipeline CI
```

**Contratos cross-repo** documentados em README + outputs Terraform + `sources.yml` / OpenAPI — ver [02-arquitetura-transversal.md](02-arquitetura-transversal.md).

---

## 14. Estratégias transversais

Resumo de onde aprofundar; detalhes nos capítulos linkados.

| Dimensão | Meta | Capítulo |
|----------|------|----------|
| **Testes** | ≥ 90% cobertura; mutation onde aplicável; TaaC em integrações | [10](10-testes-unitarios.md), [11](11-taac-testes-integrados-na-pipeline.md), [12](12-testes-de-mutacao.md) |
| **Observabilidade** | Datadog: logs JSON, métricas, APM, alertas com runbook | [13](13-observabilidade.md) |
| **Performance** | Volume e custo antes de codificar; particionamento | [14](14-performance.md) |
| **Segurança** | Least privilege, sem PII em log, secrets em vault | [17](17-seguranca-conformidade-e-dados-sensiveis.md) |
| **Documentação** | README, ADR, dicionário para marts críticos | [15](15-documentacao.md) |

---

## 15. Checklists

### 15.1 Checklist — antes de abrir PR (autor)

- [ ] Li o capítulo da stack aplicável
- [ ] Trilha essencial concluída (se primeiro PR)
- [ ] Template [pr.md](templates/pr.md) preenchido
- [ ] DoD [18](18-definition-of-done.md) verificada
- [ ] Sem secrets ou PII em diff
- [ ] Testes verdes no CI
- [ ] Contrato cross-repo atualizado se aplicável
- [ ] Link para runbook/monitor se fluxo crítico novo

### 15.2 Checklist — review de documentação do handbook

- [ ] Links relativos funcionam (00–20, templates)
- [ ] Exemplos usam `{nome-projeto}`, não nome fixo de produto
- [ ] Sem referência a artefatos de IA como fonte de verdade
- [ ] Datadog citado como ferramenta padrão de observabilidade
- [ ] Trade-offs e anti-padrões presentes em capítulos de stack
- [ ] Checklists e DoD alinhados ao [18](18-definition-of-done.md)

### 15.3 Checklist — operação (handbook como referência)

- [ ] Runbook existe para monitors high/critical
- [ ] `correlation_id` rastreável do Airflow ao dbt/Lambda
- [ ] Playbook de backfill documentado no repo Airflow
- [ ] Contato do owner no README do componente

---

## 16. Critérios de aceite

Este capítulo (00) está sendo usado corretamente quando:

- [ ] Novo membro completa trilha essencial na primeira semana
- [ ] PRs referenciam capítulo(s) do handbook quando aplicável
- [ ] Exceções têm ADR ou seção no PR
- [ ] Índice do [README.md](../../README.md) reflete capítulos 00–20
- [ ] Times sabem qual repo `{nome-projeto}-*` usar para cada stack

---

## 17. Definition of Done (DoD)

O DoD **completo** está em [18-definition-of-done.md](18-definition-of-done.md).

Para **mudanças apenas na documentação** deste handbook:

- [ ] Links internos validados
- [ ] Revisão de par técnico (outro time se mudança transversal)
- [ ] Comunicação em canal de engenharia se mudança breaking
- [ ] Exemplos executáveis ou marcados como pseudocódigo
- [ ] Sem contradição com capítulos 01–20 da mesma versão

---

## 18. FAQ

**P: Preciso ler os 20 capítulos?**  
R: Não. Use a [trilha essencial](#91-trilha-essencial-primeira-semana) + stack + [18](18-definition-of-done.md).

**P: O handbook substitui documentação do meu serviço?**  
R: Não. O handbook é **genérico**; cada repo tem README, runbooks e ADRs locais ([15-documentacao.md](15-documentacao.md)).

**P: Somos multi-repo. Onde fica o código?**  
R: Um repo por componente: `{nome-projeto}-airflow`, `{nome-projeto}-dbt`, etc. Este repo é só orientação.

**P: Posso usar outra ferramenta que não Datadog?**  
R: Datadog é o padrão corporativo. Exceção exige ADR e plano de migração de alertas.

**P: E se o padrão estiver errado?**  
R: Abra PR neste repositório com proposta, trade-offs e impacto. Padrão vivo.

**P: Spike de 1 dia precisa de tudo?**  
R: DoD reduzida permitida; débito explícito no PR e issue de convergência.

**P: Como citar o handbook em PR de código?**  
R: Ex.: "Segue [04-airflow.md](../engineering-handbook/04-airflow.md) — seção idempotência".

**P: Terceiros precisam seguir?**  
R: Sim, para código entregue em repos `{nome-projeto}-*`. Contrato de fornecedor pode referenciar este repo.

**P: Onde ficam exemplos de código?**  
R: Nos capítulos de stack (04–09) e, quando existirem, em `examples/` do repo de padrões ou do serviço.

**P: IA pode ignorar capítulos longos?**  
R: Não. Use [19-padroes-para-uso-de-ia.md](19-padroes-para-uso-de-ia.md) para apontar capítulos relevantes por tarefa.

---

## 19. Guia para desenvolvedores júnior

### Primeiro dia

1. Clone o repo `repositorio-de-padroes` e marque favorito o [README](../../README.md).
2. Leia [01-contexto-principios-e-objetivos.md](01-contexto-principios-e-objetivos.md) — entenda o "por quê".
3. Siga [20-onboarding-tecnico.md](20-onboarding-tecnico.md) no repo do seu time.

### Primeira semana

| Dia | Foco | Capítulos |
|-----|------|-----------|
| 1–2 | Contexto + setup | 00, 01, 20 |
| 3 | Arquitetura | 02, 03 |
| 4 | Sua stack | 04 ou 05 ou 07 ou 08 |
| 5 | Qualidade | 10, 16, 18 |

### Dicas

- **Pergunte cedo** se o card não menciona qual repo editar — multi-repo confunde no início.
- **PR pequeno** > PR gigante; DoD é mais fácil de cumprir.
- **Copie templates**, não repos antigos sem revisar padrão.
- **Logs:** aprenda o formato JSON do [13](13-observabilidade.md) antes do primeiro deploy.
- **Não tenha medo do review** — [16](16-code-review.md) é aprendizado, não julgamento.

### Erros comuns de júnior

- Colocar SQL de negócio dentro da DAG
- `select *` em model dbt de produção
- Hardcodar bucket S3 "só para testar" e esquecer no merge
- Commitar `.env` ou credencial
- Ignorar teste quebrado "porque não foi eu"

---

## 20. Guia para desenvolvedores sênior

### Responsabilidades além do código

- **Guardião do contrato** entre `{nome-projeto}-*` repos
- **Revisor** que aplica [16](16-code-review.md) com consistência
- **Autor de ADR** quando o handbook não cobre o caso
- **Mentor** — apontar trilha certa em vez de responder no privado pela 10ª vez

### Quando propor mudança no handbook

- Incidente recorrente por lacuna documental
- Novo padrão de mercado adotado (ex.: Airflow Datasets, dbt unit tests)
- Ferramenta corporativa mudou (ex.: política Datadog)

### Quando **não** expandir o handbook

- Detalhe hiperespecífico de um único serviço → README local
- Política de RH ou gestão de pessoas
- Snippet que muda toda semana → repo de exemplos do serviço

### Review sênior em 5 minutos

1. Stack certa e repo certo?
2. Negócio fora de orquestração?
3. Testes + observabilidade presentes?
4. Contrato cross-repo quebrado?
5. Exceção documentada?

### Contribuir de volta

PRs neste repo são bem-vindos: correção de typo, novo anti-padrão vivido em produção, ou esclarecimento de trade-off. Sênior escreve o que gostaria de ter lido no mês 1.

---

## Histórico e manutenção

| Ação | Responsável | Frequência |
|------|-------------|------------|
| Revisar links 00–20 | Maintainers do handbook | A cada release major |
| Sincronizar com DoD | Tech leads | Quando DoD mudar |
| Retro pós-incidente → doc | Owner do serviço + SRE | Por incidente relevante |
| Comunicar mudança breaking | Autor do PR | Antes do merge |

---

*Próximo passo recomendado:* [01 — Contexto, princípios e objetivos](01-contexto-principios-e-objetivos.md)
