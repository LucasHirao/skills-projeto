# Engineering Handbook / Manual de Engenharia

Repositório **multi-repo** de padrões técnicos para squads de dados e backend (Airflow, dbt, Terraform, Lambda Python, Java Spring Boot, AWS Glue).

---

## Fonte principal da verdade

Todo padrão técnico vive em [`docs/engineering-handbook/`](docs/engineering-handbook/) (capítulos `00`–`20` + [templates](docs/engineering-handbook/templates/)).

Artefatos para agentes de IA são **derivados** — ver [artefatos-ia.md](docs/engineering-handbook/artefatos-ia.md) e [19 — Padrões para uso de IA](docs/engineering-handbook/19-padroes-para-uso-de-ia.md).

**Observabilidade:** [Datadog](docs/engineering-handbook/13-observabilidade.md).

**Nomenclatura de código:** identificadores internos criados pelo time em **português** (classes, funções, variáveis, testes, DAGs, models dbt). Exceções: contratos externos, SDKs, frameworks, tags técnicas (`service`, `env`, `correlation_id`). Detalhes em [03 — Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português).

---

## Estrutura do repositório

```
docs/engineering-handbook/   # Manual de Engenharia (fonte da verdade)
claude/                      # Skills e regras para Claude Code
devin/                       # Skills e playbooks para Devin
README.md                    # Este arquivo
```

---

## Comece aqui

1. [00 — Como usar este handbook](docs/engineering-handbook/00-como-usar-este-handbook.md)
2. [20 — Onboarding técnico](docs/engineering-handbook/20-onboarding-tecnico.md)
3. [01 — Contexto, princípios e objetivos](docs/engineering-handbook/01-contexto-principios-e-objetivos.md)

---

## Índice do handbook (00–20)

| # | Documento |
|---|-----------|
| 00 | [Como usar](docs/engineering-handbook/00-como-usar-este-handbook.md) |
| 01 | [Contexto e princípios](docs/engineering-handbook/01-contexto-principios-e-objetivos.md) |
| 02 | [Arquitetura transversal](docs/engineering-handbook/02-arquitetura-transversal.md) |
| 03 | [Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md) |
| 04–09 | [Airflow](docs/engineering-handbook/04-airflow.md) · [dbt](docs/engineering-handbook/05-dbt.md) · [Terraform](docs/engineering-handbook/06-terraform.md) · [Lambda](docs/engineering-handbook/07-lambda-python.md) · [Java](docs/engineering-handbook/08-java-spring-boot.md) · [Glue](docs/engineering-handbook/09-aws-glue.md) |
| 10–12 | [Testes unitários](docs/engineering-handbook/10-testes-unitarios.md) · [TaaC](docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md) · [Mutação](docs/engineering-handbook/12-testes-de-mutacao.md) |
| 13–14 | [Observabilidade](docs/engineering-handbook/13-observabilidade.md) · [Performance](docs/engineering-handbook/14-performance.md) |
| 15–20 | [Documentação](docs/engineering-handbook/15-documentacao.md) · [Code review](docs/engineering-handbook/16-code-review.md) · [Segurança](docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md) · [DoD](docs/engineering-handbook/18-definition-of-done.md) · [IA](docs/engineering-handbook/19-padroes-para-uso-de-ia.md) · [Onboarding](docs/engineering-handbook/20-onboarding-tecnico.md) |
| — | [Mapa artefatos IA](docs/engineering-handbook/artefatos-ia.md) |

---

## Artefatos Claude (`claude/`)

| Item | Uso |
|------|-----|
| [claude/README.md](claude/README.md) | Instalação e manutenção |
| [claude/CLAUDE.md](claude/CLAUDE.md) | Modelo para copiar à raiz de repos de código |
| [claude/regras/](claude/regras/) | Regras curtas operacionais |
| [claude/skills/](claude/skills/) | 13 skills versionadas |
| [claude/sincronizar-claude.sh](claude/sincronizar-claude.sh) | Copia skills para `.claude/skills/` |

```bash
# No repo de código (após clonar orientacoes ou submodule)
bash /caminho/orientacoes/claude/sincronizar-claude.sh
```

---

## Artefatos Devin (`devin/`)

| Item | Uso |
|------|-----|
| [devin/README.md](devin/README.md) | Instalação, Skills vs Playbooks |
| [devin/AGENTS.md](devin/AGENTS.md) | Modelo de instrução para repos de código |
| [devin/skills/](devin/skills/) | 13 skills versionadas |
| [devin/playbooks/](devin/playbooks/) | 8 prompts amplos multi-repo |
| [devin/sincronizar-devin.sh](devin/sincronizar-devin.sh) | Copia skills para `.agents/skills/` |

```bash
bash /caminho/orientacoes/devin/sincronizar-devin.sh
```

**Skills** — tarefas recorrentes por stack no repositório. **Playbooks** — fluxos amplos/cross-repo (feature, pipeline, incidente).

---

## Uso no dia a dia

1. Ler capítulo do handbook aplicável
2. Usar [template](docs/engineering-handbook/templates/) em PRs e docs
3. Acionar skill/playbook de IA quando automatizar tarefa repetida
4. Revisar com [DoD](docs/engineering-handbook/18-definition-of-done.md) e [code review](docs/engineering-handbook/16-code-review.md)

---

## Como contribuir

1. **Handbook primeiro** — PR em `docs/engineering-handbook/`
2. Depois atualizar `claude/` e/ou `devin/` + [artefatos-ia.md](docs/engineering-handbook/artefatos-ia.md)
3. Piloto em uma feature real antes de considerar skill estável
4. Avisar em `#engenharia` se mudança for transversal

---

## Princípios

- **Multi-repo** — contratos entre repositórios
- **Datadog** — logs, APM, métricas, alertas, SLO
- **Qualidade** — 90% cobertura; 90% mutation; TaaC
- **Português** — prosa do handbook e identificadores internos de código
- **Handbook canônico** — skills/playbooks não inventam política
