# Uso de IA

## Escopo

Como agentes (Claude Code, Cursor, etc.) devem pedir, executar, validar e reportar trabalho em `{nome-projeto}`.

## Hierarquia de contexto

1. README do repo alvo
2. Capítulo da stack no handbook
3. [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md)
4. Esta rule + skill em `claude/skills/`

## Prompt eficaz

```
Contexto: [repo, path, capítulo handbook]
Objetivo: [resultado observável]
Restrições: [não fazer X, sem PII]
Entregáveis: [código, testes, doc, observabilidade]
Critério de aceite: [DoD específica]
```

## Quebrar tarefas grandes

Um PR por etapa: ADR → Terraform → job → dbt → DAG → TaaC → dashboard.

## Validação obrigatória (antes do merge)

1. Testes e lint locais (mesmos da CI)
2. Imports e deps no manifesto
3. Aderência ao módulo vizinho
4. Impacto em dados (idempotência, backfill)
5. Logs sem PII
6. **Review humano**

## O que a IA não decide

- Regra de negócio não documentada
- Exceção de segurança ou SLA de negócio
- Breaking change em contrato público
- Aprovar próprio PR

## Skills com `disable-model-invocation`

`revisar-codigo` e `investigar-falha` — só quando o usuário invocar explicitamente.

## Fonte de verdade

- [19 — Padrões para uso de IA](../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
- [16 — Code review](../../docs/engineering-handbook/16-code-review.md)
