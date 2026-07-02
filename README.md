# skills-projeto

Base versionada de padrões de engenharia para humanos e agentes de IA (Cursor, Claude Code, Devin).

## Comece por

| Público | Arquivo |
|---------|---------|
| Qualquer agente | [AGENTS.md](AGENTS.md) |
| Cursor | [CURSOR.md](CURSOR.md) |
| Claude Code | [CLAUDE.md](CLAUDE.md) |
| Devin | [DEVIN.md](DEVIN.md) |
| Desenvolvedores | [docs/padroes/00-visao-geral.md](docs/padroes/00-visao-geral.md) |

## Modelo de repositórios

**Multi-repo** — este repositório contém padrões, skills e exemplos. O código de produção fica em repos separados por stack. Ver [docs/padroes/18-estrutura-repositorios.md](docs/padroes/18-estrutura-repositorios.md).

## Estrutura

```
docs/padroes/     Padrões técnicos e templates
.claude/          Rules e skills (Claude Code)
.agents/          Skills (Devin)
.cursor/          Rules (Cursor)
checklists/       Code review por stack
devin-playbooks/  Playbooks reutilizáveis
examples/         Referências mínimas por stack
```

## Manutenção das skills

Fonte canônica: `.claude/skills/`. Sincronizar com `.agents/skills/`:

```powershell
.\scripts\sync-skills.ps1
```
