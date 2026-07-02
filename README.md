# skills-projeto

Padrões de engenharia para **Claude Code** e **Devin** — repositórios separados, conteúdo por IA.

## Estrutura

```
├── AGENTS.md              # princípios compartilhados (hub)
├── CLAUDE.md              # guia Claude Code
├── DEVIN.md               # guia Devin
│
├── .claude/               # somente Claude Code
│   ├── rules/             # 10 regras por stack (com exemplos)
│   └── skills/            # 11 procedimentos
│
├── devin/                 # somente Devin
│   ├── skills/            # 11 procedimentos
│   └── playbooks/         # 7 fluxos longos
│
├── docs/padroes/          # referência técnica profunda (ambas IAs)
├── checklists/
└── examples/
```

**Não há duplicata** entre `.claude/` e `devin/`. Consulte só a pasta da IA em uso.

## Comece por

| IA | Leia |
|----|------|
| Claude Code | [CLAUDE.md](CLAUDE.md) → `.claude/rules/` + skill da tarefa |
| Devin | [DEVIN.md](DEVIN.md) → `devin/skills/` ou `devin/playbooks/` |
| Ambas | [AGENTS.md](AGENTS.md) + `docs/padroes/` da stack |

## Multi-repo

Código de produção fica em repos separados (`{nome-projeto}-airflow`, `-dbt`, `-infra`, …). Este repo contém **padrões**. Ver [docs/padroes/18-estrutura-repositorios.md](docs/padroes/18-estrutura-repositorios.md).

## Como usar nos repos de código

- **Submodule** ou clone deste repo como referência.
- Copiar `AGENTS.md` + `.claude/` para consumo Claude (se desejado).
- Devin: apontar sessão para este repo + repo de código da stack.

## Manutenção

- Claude: editar `.claude/rules/` e `.claude/skills/`
- Devin: editar `devin/skills/` e `devin/playbooks/`
- Padrões técnicos: `docs/padroes/`
