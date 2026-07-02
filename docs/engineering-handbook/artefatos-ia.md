# Mapa de artefatos de IA

Este documento explica como o **Manual de Engenharia** se relaciona com artefatos derivados para **Claude Code** (`claude/`) e **Devin** (`devin/`).

**Regra:** handbook primeiro; artefatos depois. Não duplicar capítulos inteiros nas skills.

**Catálogo canônico:** [`manifest.yaml`](manifest.yaml) — stacks, capítulos transversais, paths de skills e playbooks. **Evite** manter listas paralelas em outros arquivos; atualize o manifesto ao adicionar stack ou artefato.

**Transversal:** [03 — Padrões de código](03-padroes-de-codigo.md) em todas as skills; [13 — Logging seguro](13-observabilidade.md#logging-seguro-e-dados-sensíveis) em observabilidade/revisão; [21 — Agentes](21-agentes-e-prompts.md) e [22 — Documentação funcional](22-documentacao-funcional.md) nas camadas correspondentes.

---

## Como usar

1. Altere o padrão no capítulo do handbook.
2. Atualize skills/playbooks derivados na mesma sprint (ou PR subsequente).
3. Registre nova stack em `manifest.yaml`.
4. Rode `bash scripts/validar-handbook.sh` ou `sincronizar-*.sh --check`.
5. Pilote em feature real antes de considerar skill estável.

---

## Capítulos transversais

| Tema | Capítulo | Artefatos típicos |
|------|----------|-------------------|
| Código | [03](03-padroes-de-codigo.md) | Todas as skills; `claude/regras/05-padroes-de-codigo.md` |
| DoD | [18](18-definition-of-done.md) | Todas as skills e playbooks de implementação |
| Observabilidade | [13](13-observabilidade.md) | `melhorar-observabilidade`, `investigar-falha`, playbooks relacionados |
| Segurança | [17](17-seguranca-conformidade-e-dados-sensiveis.md) | `claude/regras/04-seguranca.md`, `devin/AGENTS.md` |
| Agentes de prompt | [21](21-agentes-e-prompts.md) | Skills/playbooks com `prompt` no nome |
| Documentação funcional | [22](22-documentacao-funcional.md) | Skills/playbooks com `documentacao-funcional` no nome |
| Uso de IA | [19](19-padroes-para-uso-de-ia.md) | `CLAUDE.md`, `AGENTS.md`, `claude/regras/06-uso-de-ia.md` |

---

## Stacks (visão resumida)

Detalhes completos em `manifest.yaml`. Cada stack tem capítulo handbook + skills Claude/Devin quando aplicável.

| Stack | Capítulo |
|-------|----------|
| Airflow | [04-airflow.md](04-airflow.md) |
| dbt | [05-dbt.md](05-dbt.md) |
| Terraform | [06-terraform.md](06-terraform.md) |
| Lambda Python | [07-lambda-python.md](07-lambda-python.md) |
| Java Spring Boot | [08-java-spring-boot.md](08-java-spring-boot.md) |
| AWS Glue | [09-aws-glue.md](09-aws-glue.md) |

---

## Descoberta por convenção

| Artefato | Onde | Convenção |
|----------|------|-----------|
| Skills Claude | `claude/skills/*/SKILL.md` | Uma pasta por skill |
| Skills Devin | `devin/skills/*/SKILL.md` | Espelha Claude quando por stack |
| Playbooks Devin | `devin/playbooks/*.md` | Prompts reutilizáveis amplos |
| Regras Claude | `claude/regras/*.md` | Listadas em `manifest.yaml` |

Validação por categoria (nome do artefato):

- `*prompt*` → deve referenciar cap. 21
- `*documentacao-funcional*` → deve referenciar cap. 22
- `*observabilidade*` / `*investigar-falha*` → deve referenciar cap. 13
- Skill de stack no manifesto → deve referenciar capítulo da stack

---

## Sincronização

| Destino local | Origem | Validação / cópia |
|---------------|--------|-------------------|
| `.claude/skills/` | `claude/skills/` | `claude/sincronizar-claude.sh` |
| `.agents/skills/` | `devin/skills/` | `devin/sincronizar-devin.sh` |
| — | handbook + manifesto | `scripts/validar-handbook.sh` |

Copie `claude/CLAUDE.md` ou `devin/AGENTS.md` para a raiz do **repositório de código** alvo quando necessário.

---

## Fonte de verdade

Este artefato é **visão humana resumida**. O catálogo operacional é [`manifest.yaml`](manifest.yaml).

Antes de alterar um padrão:

1. Atualize o capítulo em `docs/engineering-handbook/`.
2. Abra PR de revisão do handbook.
3. Atualize `manifest.yaml` e artefatos derivados.
4. Rode validação (`scripts/validar-handbook.sh`).
