# Engineering Handbook

Repositório **multi-repo** de padrões técnicos humanos para squads de dados e backend (Airflow, dbt, Terraform, Lambda Python, Java Spring Boot, AWS Glue).

**Fonte de verdade:** documentação versionada em [`docs/engineering-handbook/`](docs/engineering-handbook/). Skills, playbooks e rules para IA são **derivados depois** do handbook — ver [§7 — Como extrair skills](docs/engineering-handbook/19-padroes-para-uso-de-ia.md#7-como-extrair-skills-playbooks-e-rules-a-partir-deste-handbook).

**Observabilidade:** [Datadog](docs/engineering-handbook/13-observabilidade.md) como ferramenta padrão.

---

## Comece aqui

1. [00 — Como usar este handbook](docs/engineering-handbook/00-como-usar-este-handbook.md)
2. [20 — Onboarding técnico](docs/engineering-handbook/20-onboarding-tecnico.md) — setup e primeiro PR
3. [01 — Contexto, princípios e objetivos](docs/engineering-handbook/01-contexto-principios-e-objetivos.md)

---

## Índice completo (00–20)

| # | Documento |
|---|-----------|
| 00 | [Como usar este handbook](docs/engineering-handbook/00-como-usar-este-handbook.md) |
| 01 | [Contexto, princípios e objetivos](docs/engineering-handbook/01-contexto-principios-e-objetivos.md) |
| 02 | [Arquitetura transversal](docs/engineering-handbook/02-arquitetura-transversal.md) |
| 03 | [Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md) |
| 04 | [Airflow](docs/engineering-handbook/04-airflow.md) |
| 05 | [dbt](docs/engineering-handbook/05-dbt.md) |
| 06 | [Terraform](docs/engineering-handbook/06-terraform.md) |
| 07 | [Lambda Python](docs/engineering-handbook/07-lambda-python.md) |
| 08 | [Java Spring Boot](docs/engineering-handbook/08-java-spring-boot.md) |
| 09 | [AWS Glue](docs/engineering-handbook/09-aws-glue.md) |
| 10 | [Testes unitários](docs/engineering-handbook/10-testes-unitarios.md) |
| 11 | [TaaC — testes integrados na pipeline](docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md) |
| 12 | [Testes de mutação](docs/engineering-handbook/12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](docs/engineering-handbook/13-observabilidade.md) |
| 14 | [Performance](docs/engineering-handbook/14-performance.md) |
| 15 | [Documentação](docs/engineering-handbook/15-documentacao.md) |
| 16 | [Code review](docs/engineering-handbook/16-code-review.md) |
| 17 | [Segurança, conformidade e dados sensíveis](docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](docs/engineering-handbook/18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](docs/engineering-handbook/19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](docs/engineering-handbook/20-onboarding-tecnico.md) |

---

## Templates

Copiar para `docs/` do repositório do serviço ou usar como corpo de PR.

| Template | Uso |
|----------|-----|
| [adr.md](docs/engineering-handbook/templates/adr.md) | Architecture Decision Record |
| [decisao-tecnica.md](docs/engineering-handbook/templates/decisao-tecnica.md) | Decisão local |
| [pr.md](docs/engineering-handbook/templates/pr.md) | Pull request |
| [readme-componente.md](docs/engineering-handbook/templates/readme-componente.md) | README de serviço/job |
| [runbook.md](docs/engineering-handbook/templates/runbook.md) | Procedimento operacional |
| [dashboard.md](docs/engineering-handbook/templates/dashboard.md) | Dashboard Datadog |
| [teste-integrado.md](docs/engineering-handbook/templates/teste-integrado.md) | TaaC |
| [code-review.md](docs/engineering-handbook/templates/code-review.md) | Registro de review |
| [plano-de-implementacao.md](docs/engineering-handbook/templates/plano-de-implementacao.md) | Features médias/grandes |

---

## Princípios

- **Multi-repo** — um propósito por repositório; integração por contrato
- **Datadog** — logs, APM, métricas, alertas, SLO
- **Qualidade** — 90% cobertura; 90% mutation onde aplicável; TaaC para integrações
- **Opinionado** — exceções documentadas em ADR ou PR
- **Português BR** — prosa do handbook; código e identificadores em inglês

---

## Estrutura

```
docs/
  engineering-handbook/     # Capítulos 00–20
    templates/              # Templates reutilizáveis
```

---

## Contribuir

1. PR neste repositório (`orientacoes`)
2. Mudanças transversais: avisar em `#engenharia`
3. Seguir [Definition of Done](docs/engineering-handbook/18-definition-of-done.md)
