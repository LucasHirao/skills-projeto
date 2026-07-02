# AGENTS — Devin

Instruções globais para o agente Devin em repositórios do ecossistema `{nome-projeto}`.

## Fonte de verdade

Leia **nesta ordem** antes de qualquer alteração:

1. README do repositório de código alvo
2. Capítulo da stack em [`docs/engineering-handbook/`](../docs/engineering-handbook/)
3. [18 — Definition of Done](../docs/engineering-handbook/18-definition-of-done.md)
4. [19 — Padrões para uso de IA](../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
5. Templates em [`docs/engineering-handbook/templates/`](../docs/engineering-handbook/templates/)

**Não** invente regras — skills e playbooks em `devin/` são derivados, não substituem o handbook.

## Princípios

- **Multi-repo:** um propósito por repositório; integração por contrato explícito
- **Nomenclatura:** identificadores internos em português — [03](../docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português)
- **Plano antes de editar:** 5–10 bullets com escopo, riscos e ordem de deploy
- **Correção mínima:** sem refatoração fora do escopo pedido
- **Evidências finais:** testes, coverage, plan Terraform, logs/métricas — anexar no output
- **Review humano:** o agente não aprova PR
- **Sem PII** em prompts, logs ou exemplos
- **Datadog** como padrão de observabilidade

## Hierarquia de artefatos Devin

| Prioridade | Artefato | Quando |
|------------|----------|--------|
| 1 | Handbook (`docs/engineering-handbook/`) | Sempre |
| 2 | Playbook (`devin/playbooks/`) | Tarefa ampla, multi-repo |
| 3 | Skill (`devin/skills/`) | Tarefa repetível de stack |
| 4 | README do repo alvo | Contexto local |

## Skills

Carregue a skill correspondente à stack:

| Tarefa | Skill |
|--------|-------|
| API REST Java | `criar-api-spring-boot` |
| DAG Airflow | `criar-dag-airflow` |
| Job Glue | `criar-job-glue` |
| Lambda Python | `criar-lambda-python` |
| Modelo dbt | `criar-modelo-dbt` |
| Módulo Terraform | `criar-modulo-terraform` |
| TaaC | `criar-taac` |
| Testes unitários | `criar-testes-unitarios` |
| Observabilidade | `melhorar-observabilidade` |
| Performance | `revisar-desempenho` |
| Code review | `revisar-codigo` |
| Documentação | `criar-documentacao` |
| Investigação | `investigar-falha` |

## Playbooks

| Cenário | Playbook |
|---------|----------|
| Feature nova | `playbooks/implementar-feature.md` |
| Review de PR | `playbooks/revisar-pr.md` |
| Pipeline Airflow + dbt | `playbooks/criar-pipeline-airflow-dbt.md` |
| Componente AWS | `playbooks/criar-componente-aws.md` |
| Teste integrado | `playbooks/criar-taac.md` |
| Falha em pipeline | `playbooks/investigar-falha-pipeline.md` |
| Observabilidade | `playbooks/melhorar-observabilidade.md` |
| Desempenho | `playbooks/revisar-desempenho.md` |

## Fluxo obrigatório

```
Contexto (repo + handbook) → Plano → Implementação → Testes locais → Evidências → PR draft
```

## Definition of Done (resumo)

Recorte mínimo — detalhes em [capítulo 18](../docs/engineering-handbook/18-definition-of-done.md):

- Cobertura ≥ 90%; mutation ≥ 90% onde aplicável
- TaaC se houver integração real
- Logs JSON com `correlation_id`; métricas Datadog
- README / runbook / ADR se contrato ou operação mudou
- CI verde; review humano

## Anti-padrões

- Implementar sem ler o capítulo da stack
- Duplicar prosa do handbook nas skills
- `except Exception: pass`
- Segredos no código ou no prompt
- Merge sem impacto em dados avaliado (idempotência, backfill, schema)

## Links rápidos

- [00 — Como usar o handbook](../docs/engineering-handbook/00-como-usar-este-handbook.md)
- [02 — Arquitetura transversal](../docs/engineering-handbook/02-arquitetura-transversal.md)
- [16 — Code review](../docs/engineering-handbook/16-code-review.md)
- [17 — Segurança](../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [Template PR](../docs/engineering-handbook/templates/pr.md)
- [Template code review](../docs/engineering-handbook/templates/code-review.md)
- [Template plano de implementação](../docs/engineering-handbook/templates/plano-de-implementacao.md)
- [Mapa artefatos IA](../docs/engineering-handbook/artefatos-ia.md)
