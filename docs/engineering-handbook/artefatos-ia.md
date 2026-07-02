# Mapa de artefatos de IA

Este documento rastreia a relação entre capítulos do **Manual de Engenharia** (`docs/engineering-handbook/`) e artefatos derivados para **Claude Code** (`claude/`) e **Devin** (`devin/`).

**Regra:** handbook primeiro; artefatos depois. Não duplicar capítulos inteiros nas skills.

---

## Como usar este mapa

1. Ao alterar um padrão no handbook, localize a linha do capítulo.
2. Atualize os artefatos listados na mesma sprint (ou PR subsequente).
3. Rode piloto em uma feature real antes de considerar skill “estável”.

---

## Mapa por capítulo

| Capítulo do handbook | Artefatos Claude | Artefatos Devin |
|----------------------|------------------|-----------------|
| [00 — Como usar](00-como-usar-este-handbook.md) | [claude/README.md](../../claude/README.md) | [devin/README.md](../../devin/README.md) |
| [01 — Contexto e princípios](01-contexto-principios-e-objetivos.md) | [claude/regras/00-regras-gerais.md](../../claude/regras/00-regras-gerais.md) | [devin/AGENTS.md](../../devin/AGENTS.md) |
| [02 — Arquitetura transversal](02-arquitetura-transversal.md) | [claude/regras/01-arquitetura.md](../../claude/regras/01-arquitetura.md) | [devin/AGENTS.md](../../devin/AGENTS.md), [implementar-feature.md](../../devin/playbooks/implementar-feature.md) |
| [03 — Padrões de código](03-padroes-de-codigo.md) | [claude/regras/05-padroes-de-codigo.md](../../claude/regras/05-padroes-de-codigo.md), todas as skills | [devin/AGENTS.md](../../devin/AGENTS.md), todas as skills |
| [04 — Airflow](04-airflow.md) | [criar-dag-airflow](../../claude/skills/criar-dag-airflow/SKILL.md) | [criar-dag-airflow](../../devin/skills/criar-dag-airflow/SKILL.md), [criar-pipeline-airflow-dbt.md](../../devin/playbooks/criar-pipeline-airflow-dbt.md) |
| [05 — dbt](05-dbt.md) | [criar-modelo-dbt](../../claude/skills/criar-modelo-dbt/SKILL.md) | [criar-modelo-dbt](../../devin/skills/criar-modelo-dbt/SKILL.md), [criar-pipeline-airflow-dbt.md](../../devin/playbooks/criar-pipeline-airflow-dbt.md) |
| [06 — Terraform](06-terraform.md) | [criar-modulo-terraform](../../claude/skills/criar-modulo-terraform/SKILL.md) | [criar-modulo-terraform](../../devin/skills/criar-modulo-terraform/SKILL.md), [criar-componente-aws.md](../../devin/playbooks/criar-componente-aws.md) |
| [07 — Lambda Python](07-lambda-python.md) | [criar-lambda-python](../../claude/skills/criar-lambda-python/SKILL.md) | [criar-lambda-python](../../devin/skills/criar-lambda-python/SKILL.md), [criar-componente-aws.md](../../devin/playbooks/criar-componente-aws.md) |
| [08 — Java Spring Boot](08-java-spring-boot.md) | [criar-api-spring-boot](../../claude/skills/criar-api-spring-boot/SKILL.md) | [criar-api-spring-boot](../../devin/skills/criar-api-spring-boot/SKILL.md) |
| [09 — AWS Glue](09-aws-glue.md) | [criar-job-glue](../../claude/skills/criar-job-glue/SKILL.md) | [criar-job-glue](../../devin/skills/criar-job-glue/SKILL.md), [criar-componente-aws.md](../../devin/playbooks/criar-componente-aws.md) |
| [10 — Testes unitários](10-testes-unitarios.md) | [claude/regras/02-testes.md](../../claude/regras/02-testes.md), [criar-testes-unitarios](../../claude/skills/criar-testes-unitarios/SKILL.md) | [criar-testes-unitarios](../../devin/skills/criar-testes-unitarios/SKILL.md) |
| [11 — TaaC](11-taac-testes-integrados-na-pipeline.md) | [criar-taac](../../claude/skills/criar-taac/SKILL.md) | [criar-taac](../../devin/skills/criar-taac/SKILL.md), [criar-taac.md](../../devin/playbooks/criar-taac.md) |
| [12 — Testes de mutação](12-testes-de-mutacao.md) | [claude/regras/02-testes.md](../../claude/regras/02-testes.md), [criar-testes-unitarios](../../claude/skills/criar-testes-unitarios/SKILL.md) | [criar-testes-unitarios](../../devin/skills/criar-testes-unitarios/SKILL.md) |
| [13 — Observabilidade](13-observabilidade.md) | [claude/regras/03-observabilidade.md](../../claude/regras/03-observabilidade.md), [melhorar-observabilidade](../../claude/skills/melhorar-observabilidade/SKILL.md), [investigar-falha](../../claude/skills/investigar-falha/SKILL.md) | [melhorar-observabilidade](../../devin/skills/melhorar-observabilidade/SKILL.md), [investigar-falha](../../devin/skills/investigar-falha/SKILL.md), playbooks de observabilidade e pipeline |
| [14 — Performance](14-performance.md) | [revisar-desempenho](../../claude/skills/revisar-desempenho/SKILL.md) | [revisar-desempenho](../../devin/skills/revisar-desempenho/SKILL.md), [revisar-desempenho.md](../../devin/playbooks/revisar-desempenho.md) |
| [15 — Documentação](15-documentacao.md) | [criar-documentacao](../../claude/skills/criar-documentacao/SKILL.md) | [criar-documentacao](../../devin/skills/criar-documentacao/SKILL.md) |
| [16 — Code review](16-code-review.md) | [revisar-codigo](../../claude/skills/revisar-codigo/SKILL.md) | [revisar-codigo](../../devin/skills/revisar-codigo/SKILL.md), [revisar-pr.md](../../devin/playbooks/revisar-pr.md) |
| [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) | [claude/regras/04-seguranca.md](../../claude/regras/04-seguranca.md) | [devin/AGENTS.md](../../devin/AGENTS.md) |
| [18 — Definition of Done](18-definition-of-done.md) | Todas as skills (checklist DoD) | Todas as skills e playbooks |
| [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md) | [claude/regras/06-uso-de-ia.md](../../claude/regras/06-uso-de-ia.md), [claude/CLAUDE.md](../../claude/CLAUDE.md) | [devin/AGENTS.md](../../devin/AGENTS.md) |
| [20 — Onboarding técnico](20-onboarding-tecnico.md) | [claude/README.md](../../claude/README.md) | [devin/README.md](../../devin/README.md) |
| Templates | [criar-documentacao](../../claude/skills/criar-documentacao/SKILL.md) | [criar-documentacao](../../devin/skills/criar-documentacao/SKILL.md), playbooks |

---

## Playbooks Devin (transversais)

| Playbook | Capítulos principais |
|----------|---------------------|
| [implementar-feature.md](../../devin/playbooks/implementar-feature.md) | 02, 03, 18, 15 |
| [revisar-pr.md](../../devin/playbooks/revisar-pr.md) | 16, 18, 03 |
| [criar-pipeline-airflow-dbt.md](../../devin/playbooks/criar-pipeline-airflow-dbt.md) | 04, 05, 11, 13 |
| [criar-componente-aws.md](../../devin/playbooks/criar-componente-aws.md) | 06, 07, 09, 17 |
| [criar-taac.md](../../devin/playbooks/criar-taac.md) | 11, 10, 18 |
| [investigar-falha-pipeline.md](../../devin/playbooks/investigar-falha-pipeline.md) | 13, 14, 16 |
| [melhorar-observabilidade.md](../../devin/playbooks/melhorar-observabilidade.md) | 13, 15 |
| [revisar-desempenho.md](../../devin/playbooks/revisar-desempenho.md) | 14, 03 |

---

## Sincronização

| Destino local | Origem versionada | Script |
|---------------|-------------------|--------|
| `.claude/skills/` | `claude/skills/` | `claude/sincronizar-claude.sh` |
| `.agents/skills/` | `devin/skills/` | `devin/sincronizar-devin.sh` |

Copie `claude/CLAUDE.md` ou `devin/AGENTS.md` para a raiz do **repositório de código** alvo quando necessário.

---

## Fonte de verdade

Este artefato é derivado do Manual de Engenharia.

Antes de alterar um padrão:

1. Atualize o capítulo correspondente em `docs/engineering-handbook/`.
2. Abra PR de revisão do handbook.
3. Depois atualize este mapa e os artefatos listados.
