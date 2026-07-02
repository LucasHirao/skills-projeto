# CLAUDE.md — orientações para agentes

Você trabalha no ecossistema **multi-repo** `{nome-projeto}`. Siga os padrões do Engineering Handbook antes de inventar convenções.

## Leitura obrigatória (nesta ordem)

1. README do repositório de código alvo
2. [`docs/engineering-handbook/`](../docs/engineering-handbook/) — capítulo da stack (04–09) ou transversal (02–03)
3. [`18-definition-of-done.md`](../docs/engineering-handbook/18-definition-of-done.md)
4. Rules em [`claude/regras/`](regras/) e skill aplicável em [`claude/skills/`](skills/)

## Rules ativas

| Arquivo | Escopo |
|---------|--------|
| [00-regras-gerais.md](regras/00-regras-gerais.md) | Princípios, multi-repo, DoD, nomenclatura |
| [01-arquitetura.md](regras/01-arquitetura.md) | Camadas, contratos entre repos |
| [02-testes.md](regras/02-testes.md) | Unitários, mutation, TaaC |
| [03-observabilidade.md](regras/03-observabilidade.md) | Datadog: logs, métricas, traces |
| [04-seguranca.md](regras/04-seguranca.md) | IAM, segredos, PII, compliance |
| [05-padroes-de-codigo.md](regras/05-padroes-de-codigo.md) | Estilo, nomenclatura PT, anti-padrões |
| [06-uso-de-ia.md](regras/06-uso-de-ia.md) | Como pedir, validar e reportar |

## Skills por tarefa

Consulte `claude/skills/{nome}/SKILL.md` quando o usuário pedir implementação, review, documentação ou investigação. Skills com `disable-model-invocation` são acionadas explicitamente pelo usuário.

## Convenções

- **Prosa:** português BR
- **Identificadores internos de domínio:** português (`calcular_total_vendas`, `ProcessarArquivoUseCase`)
- **Exceções em inglês:** contratos públicos (OpenAPI, schema S3, filas), SDKs AWS, tags técnicas Datadog (`service`, `env`, `correlation_id`)
- **Observabilidade:** Datadog como ferramenta padrão
- **Qualidade:** cobertura ≥ 90%; mutation ≥ 90% em `domain/`/`application/`; TaaC para integrações reais

## O que você não pode decidir

- Regra de negócio não documentada → listar dúvidas e escalar
- Exceção de segurança ou breaking change em contrato → ADR + humano
- Aprovar PR → review humano obrigatório

## Anti-padrões

- Implementar sem apontar repo, path e capítulo do handbook
- Duplicar prosa longa do handbook nas respostas
- Colar PII ou dados reais no contexto
- Overengineering ou abstração prematura
- Mencionar clientes específicos — use `{nome-projeto}`

## Fonte de verdade

[`docs/engineering-handbook/`](../docs/engineering-handbook/)
