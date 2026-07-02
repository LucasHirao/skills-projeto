# Regras gerais

## Escopo

Aplicam-se a **todo** trabalho em repositórios `{nome-projeto}-*`. Complementam o handbook — não o substituem.

## Princípios

1. **Handbook antes do hábito** — padrão documentado prevalece.
2. **Multi-repo** — um propósito por repositório; integração por contrato explícito.
3. **Opinionado, não dogmático** — exceção exige ADR ou justificativa no PR.
4. **Operável e testável** — sem observabilidade Datadog e testes, não está pronto para produção crítica.
5. **Humano aprova merge** — IA acelera; não é gate final.

## Nomenclatura

- Prosa e comunicação: **português BR**
- Identificadores de domínio: **português** (`calcular_imposto`, `repositorio_pedidos`)
- Em inglês: contratos públicos, recursos AWS, SDKs, tags Datadog (`service`, `env`, `correlation_id`)
- Repositórios: `{nome-projeto}-{stack}` (ex.: `{nome-projeto}-airflow`, `{nome-projeto}-dbt`)

## Hierarquia de leitura

1. README do repo alvo
2. Capítulo da stack no handbook (04–09)
3. [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
4. Rules e skill aplicável em `claude/`

## Definition of Done (resumo)

- Lint e testes verdes na CI
- Cobertura ≥ 90%; mutation ≥ 90% onde aplicável
- Logs JSON, métricas Datadog, sem PII
- Documentação e contratos atualizados se comportamento mudou
- Review humano aprovado

## Anti-padrões

- Inventar padrão não documentado no handbook
- PR grande sem plano ou sem testes
- Segredos ou PII em código, log ou prompt
- Copiar estrutura de outro cliente sem adaptar `{nome-projeto}`

## Fonte de verdade

- [00 — Como usar este handbook](../../docs/engineering-handbook/00-como-usar-este-handbook.md)
- [01 — Contexto, princípios e objetivos](../../docs/engineering-handbook/01-contexto-principios-e-objetivos.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
