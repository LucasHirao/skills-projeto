# Engineering Handbook / Manual de Engenharia

Repositório **multi-repo** de padrões técnicos para squads de dados e backend.

---

## Fonte principal da verdade

Todo padrão técnico vive em [`docs/engineering-handbook/`](docs/engineering-handbook/) (capítulos `00`–`22` + [templates](docs/engineering-handbook/templates/)).

Artefatos para agentes de IA são **derivados** — ver [artefatos-ia.md](docs/engineering-handbook/artefatos-ia.md) e [19 — Padrões para uso de IA](docs/engineering-handbook/19-padroes-para-uso-de-ia.md).

**Catálogo canônico:** [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml) — stacks, skills e playbooks registrados. Evite listas paralelas em README.

**Observabilidade:** [Datadog](docs/engineering-handbook/13-observabilidade.md) · **Logging seguro:** [allowlist](docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis).

**Nomenclatura:** identificadores internos em **português** — [03 — Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português).

**Documentação funcional:** [22 — Documentação funcional](docs/engineering-handbook/22-documentacao-funcional.md).

**Agentes de prompt:** [21 — Agentes e prompts](docs/engineering-handbook/21-agentes-e-prompts.md).

---

## Estrutura do repositório

```
docs/engineering-handbook/   # Manual de Engenharia + manifest.yaml
claude/                      # Skills e regras para Claude Code
devin/                       # Skills e playbooks para Devin
scripts/validar-handbook.sh  # Validação central
CONTRIBUTING.md              # Como adicionar stack/artefato
```

---

## Comece aqui

1. [00 — Como usar este handbook](docs/engineering-handbook/00-como-usar-este-handbook.md)
2. [20 — Onboarding técnico](docs/engineering-handbook/20-onboarding-tecnico.md)
3. [01 — Contexto, princípios e objetivos](docs/engineering-handbook/01-contexto-principios-e-objetivos.md)

Capítulos de stack (`04`–`09`) e demais capítulos: ver diretório [`docs/engineering-handbook/`](docs/engineering-handbook/) ou [`manifest.yaml`](docs/engineering-handbook/manifest.yaml).

---

## Catálogo de stacks e artefatos

O catálogo canônico vive em [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml).

Para adicionar nova stack:

1. Capítulo com [`templates/capitulo-stack.md`](docs/engineering-handbook/templates/capitulo-stack.md)
2. Skills/Playbooks derivados (se aplicável)
3. Entrada no `manifest.yaml`
4. `bash scripts/validar-handbook.sh`

Detalhes: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Artefatos Claude (`claude/`)

| Item | Uso |
|------|-----|
| [claude/README.md](claude/README.md) | Instalação e manutenção |
| [claude/CLAUDE.md](claude/CLAUDE.md) | Modelo para repos de código |
| [claude/skills/](claude/skills/) | Skills descobertas por `*/SKILL.md` |
| [claude/sincronizar-claude.sh](claude/sincronizar-claude.sh) | Valida e copia para `.claude/skills/` |

```bash
bash /caminho/repositorio-de-padroes/claude/sincronizar-claude.sh --check
```

---

## Artefatos Devin (`devin/`)

| Item | Uso |
|------|-----|
| [devin/README.md](devin/README.md) | Skills vs Playbooks |
| [devin/AGENTS.md](devin/AGENTS.md) | Modelo para repos de código |
| [devin/skills/](devin/skills/) | Skills por convenção |
| [devin/playbooks/](devin/playbooks/) | Prompts amplos multi-repo |
| [devin/sincronizar-devin.sh](devin/sincronizar-devin.sh) | Valida e copia para `.agents/skills/` |

```bash
bash /caminho/repositorio-de-padroes/devin/sincronizar-devin.sh --check
```

---

## Fluxo recomendado com agentes

1. Pedido informal → preparador (`preparar-prompt-tecnico` / playbook equivalente)
2. Confiança < 90% → perguntas objetivas
3. Revisor de prompt
4. Skill ou playbook de implementação com contexto mínimo
5. PR + DoD + review humano

---

## Uso no dia a dia

1. Ler capítulo do handbook (ou stack no manifesto)
2. Usar [templates](docs/engineering-handbook/templates/) em PRs e docs
3. Acionar skill/playbook quando automatizar tarefa repetida
4. Revisar com [DoD](docs/engineering-handbook/18-definition-of-done.md) e [code review](docs/engineering-handbook/16-code-review.md)

---

## Como contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md). Resumo: handbook primeiro → `manifest.yaml` → validar → PR.

---

## Princípios

- **Multi-repo** — contratos entre repositórios
- **Datadog** — logs, APM, métricas, alertas, SLO
- **Qualidade** — 90% cobertura; 90% mutation; TaaC
- **Português** — prosa do handbook e identificadores internos
- **Handbook canônico** — manifesto para catálogo; skills não inventam política
