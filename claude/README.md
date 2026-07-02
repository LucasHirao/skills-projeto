# Claude Code — Manual de Engenharia

Esta pasta contém **regras** e **skills** derivadas do [Manual de Engenharia](../docs/engineering-handbook/). Não substitui a fonte de verdade.

## Catálogo

Skills são descobertas por convenção em `claude/skills/*/SKILL.md`. Stacks e paths canônicos: [`manifest.yaml`](../docs/engineering-handbook/manifest.yaml).

Mapa resumido: [artefatos-ia.md](../docs/engineering-handbook/artefatos-ia.md).

## O que é esta pasta

- `regras/` — memória operacional curta (listadas no manifesto)
- `skills/` — procedimentos acionáveis por stack/tarefa
- `CLAUDE.md` — modelo para copiar à raiz de repos de código

## Instalar Skills

```bash
bash /caminho/repositorio-de-padroes/claude/sincronizar-claude.sh --check  # validar
bash /caminho/repositorio-de-padroes/claude/sincronizar-claude.sh           # copiar
```

## Quando usar `CLAUDE.md`

Copie [`CLAUDE.md`](CLAUDE.md) para a **raiz** do repositório de código alvo.

## Diferença: CLAUDE.md vs regras vs Skills

| Artefato | Escopo |
|----------|--------|
| `CLAUDE.md` | Comportamento global no repo de código |
| `regras/` | Constraints transversais |
| `skills/` | Workflow passo a passo por tarefa |

## Nomenclatura de código

Identificadores **internos** em português. Ver [03 — Padrões de código](../docs/engineering-handbook/03-padroes-de-codigo.md) e [regras/05-padroes-de-codigo.md](regras/05-padroes-de-codigo.md).

## Fluxos especiais

| Camada | Capítulo | Skills (exemplos) |
|--------|----------|-------------------|
| Agentes de prompt | [21](../docs/engineering-handbook/21-agentes-e-prompts.md) | `preparar-prompt-tecnico`, `revisar-prompt-tecnico` |
| Documentação funcional | [22](../docs/engineering-handbook/22-documentacao-funcional.md) | `extrair-documentacao-funcional`, `revisar-documentacao-funcional` |
| Stacks | `04`–`09` via manifesto | `criar-dag-airflow`, `criar-modelo-dbt`, … |

## Manutenção

1. Handbook primeiro
2. Atualizar `manifest.yaml` ao adicionar stack
3. `bash scripts/validar-handbook.sh`
4. Piloto em feature real

Ver [CONTRIBUTING.md](../CONTRIBUTING.md).

## Fonte de verdade

Derivado do Manual de Engenharia. Catálogo operacional: [`manifest.yaml`](../docs/engineering-handbook/manifest.yaml).
