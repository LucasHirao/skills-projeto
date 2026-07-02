# Contribuindo

Obrigado por contribuir com o repositório de padrões técnicos.

## Princípios

1. **Handbook primeiro** — `docs/engineering-handbook/` é a fonte da verdade.
2. **Manifesto canônico** — stacks e paths vivem em [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml).
3. **Convenção sobre listas** — skills e playbooks são descobertos por pasta; não mantenha arrays paralelos em READMEs.
4. **Validação antes do merge** — rode `bash scripts/validar-handbook.sh`.

## Como adicionar uma nova stack

1. Criar capítulo usando [`docs/engineering-handbook/templates/capitulo-stack.md`](docs/engineering-handbook/templates/capitulo-stack.md).
2. Criar Skill Claude em `claude/skills/<nome>/SKILL.md` se houver tarefa recorrente.
3. Criar Skill Devin em `devin/skills/<nome>/SKILL.md` se houver automação por repo.
4. Criar Playbook Devin em `devin/playbooks/` se for fluxo amplo multi-repo.
5. Registrar a stack em [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml).
6. Rodar `bash scripts/validar-handbook.sh` ou `bash claude/sincronizar-claude.sh --check` e `bash devin/sincronizar-devin.sh --check`.
7. Abrir PR com exemplo mínimo e critérios de aceite.

**Não** adicione detalhes específicos da stack em [03 — Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md) — apenas regras transversais.

## Como alterar padrão existente

1. PR no capítulo do handbook.
2. Atualizar skills/playbooks derivados (se aplicável).
3. `manifest.yaml` só se mudar paths ou registrar nova stack.
4. Validar links e estrutura.

## Comandos de validação

```bash
bash scripts/validar-handbook.sh
bash claude/sincronizar-claude.sh --check
bash devin/sincronizar-devin.sh --check
```

## O que não fazer

- Duplicar capítulo inteiro dentro de skill/playbook
- Inventar regra de negócio não validada
- Manter contagem fixa de skills/playbooks no README
- Editar `artefatos-ia.md` com tabela gigante por capítulo — use o manifesto
