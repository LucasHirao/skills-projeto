# Estrutura de repositórios (multi-repo)

**Não usamos monorepo.** Este repositório é o **repo de padrões** (Claude + Devin). Código vive em repos separados.

## Este repositório (padrões)

```
/
├── AGENTS.md, CLAUDE.md, DEVIN.md
├── .claude/          → exclusivo Claude Code
├── devin/            → exclusivo Devin
├── docs/padroes/     → referência técnica compartilhada
├── checklists/
└── examples/
```

## Repositórios de código (um por stack)

| Repositório | Conteúdo |
|-------------|----------|
| `{nome-projeto}-airflow` | DAGs, plugins, testes |
| `{nome-projeto}-dbt` | models, macros |
| `{nome-projeto}-infra` | Terraform |
| `{nome-projeto}-lambda-{funcao}` | Lambda Python |
| `{nome-projeto}-glue-{job}` | Glue PySpark |
| `{nome-projeto}-api-{servico}` | Spring Boot |

## Artefatos por IA (não misturar)

| IA | Onde editar |
|----|-------------|
| Claude Code | `.claude/rules/`, `.claude/skills/`, [CLAUDE.md](../../CLAUDE.md) |
| Devin | `devin/skills/`, `devin/playbooks/`, [DEVIN.md](../../DEVIN.md) |

## Contratos entre repos

Documentar em README + ADR: paths S3, schemas, ARNs, `data_referencia`.

## Comandos locais

Na **raiz do repo de código** da stack — ver pipeline do ambiente.

## Naming AWS

`{nome-projeto}-{dominio}-{tipo}-{env}` — detalhes nas tabelas em versões anteriores deste doc.
