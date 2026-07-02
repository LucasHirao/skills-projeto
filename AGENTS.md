# AGENTS.md — Princípios compartilhados

Hub mínimo. Cada IA tem guia e artefatos próprios — **não misture pastas**.

| IA | Guia | Artefatos |
|----|------|-----------|
| **Claude Code** | [CLAUDE.md](CLAUDE.md) | `.claude/rules/`, `.claude/skills/` |
| **Devin** | [DEVIN.md](DEVIN.md) | `devin/skills/`, `devin/playbooks/` |
| **Referência técnica** (ambas) | `docs/padroes/` | profundidade por stack |
| **Review** | `checklists/` | por tecnologia |
| **Exemplos** | `examples/` | sob demanda |

## Modelo de repositórios

**Multi-repo.** Este repo = padrões. Código = um repo por stack (`{nome-projeto}-airflow`, `-dbt`, `-infra`, etc.). Ver [docs/padroes/18-estrutura-repositorios.md](docs/padroes/18-estrutura-repositorios.md).

## Princípios inegociáveis

1. Não inventar regra de negócio — perguntar ou hipótese explícita.
2. Ler `docs/padroes/` da stack **antes** de editar código no repo da stack.
3. Testes: 90% cobertura; 90% mutation onde aplicável.
4. Observabilidade e performance em toda entrega.
5. Contratos entre repos documentados; breaking change explícito.
6. ADR em decisão relevante (`docs/padroes/templates/template-adr.md`).
7. Idempotência e reprocessamento documentados.
8. Segredos fora do código; least privilege IAM.

## DoD

[docs/padroes/16-definition-of-done.md](docs/padroes/16-definition-of-done.md)

## Economia de contexto

- Carregue só o guia da IA em uso + rule/skill da tarefa + **um** `docs/padroes/XX.md` da stack.
- Não leia todos os padrões de uma vez.
- `docs/historico/` e `examples/` só quando necessário.
