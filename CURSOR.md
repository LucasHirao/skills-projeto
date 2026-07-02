# CURSOR.md — Como usar os padrões no Cursor

Guia para desenvolvedores e agentes Cursor neste repositório.

**Documento central:** [AGENTS.md](AGENTS.md)

## Carregamento automático

- `AGENTS.md` na raiz é o ponto de entrada interoperável.
- Regras do projeto: `.cursor/rules/` (espelham orientações de `.claude/rules/`).
- Para tarefas procedimentais, consulte `.claude/skills/` ou `.agents/skills/`.

## Antes de editar

1. Ler `AGENTS.md` e `docs/padroes/` da stack.
2. Ver `examples/` para padrão mínimo da stack.
3. Buscar implementação similar no repositório.
4. Planejar escopo, testes e riscos.

## Regras em `.cursor/rules/`

Regras curtas por stack — o Cursor aplica conforme arquivos editados. Detalhes em `docs/padroes/`.

## Skills

Mesmas skills do Claude Code em `.claude/skills/`. Exemplo de prompt:

```
Siga AGENTS.md e a skill criar-lambda-python.
Implemente Lambda para evento S3. Handler fino, testes 90%.
Leia docs/padroes/05-lambda-python.md e examples/lambda/.
```

## Documentação de referência

| Necessidade | Onde |
|-------------|------|
| Visão geral | `docs/padroes/00-visao-geral.md` |
| Layout do repo de código | `docs/padroes/18-estrutura-repositorios.md` |
| Onboarding | `docs/padroes/19-onboarding.md` |
| DoD | `docs/padroes/16-definition-of-done.md` |
| Prompts | `docs/padroes/17-padroes-para-ia.md` |

## Build e testes

Use o pipeline do repo de código em que você está trabalhando. Comandos locais: `18-estrutura-repositorios.md`.

## Nunca / Sempre

Igual a [CLAUDE.md](CLAUDE.md): não inventar negócio, não remover observabilidade, sempre testar e documentar impactos.

## Outros agentes

- Claude Code: [CLAUDE.md](CLAUDE.md)
- Devin: [DEVIN.md](DEVIN.md)
