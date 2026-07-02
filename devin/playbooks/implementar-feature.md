# Playbook — Implementar feature

Prompt reutilizável para implementação de features em um ou mais repositórios do ecossistema `{nome-projeto}`.

## Fonte de verdade

- [19 — Padrões para uso de IA](../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- Capítulo da stack aplicável em [`docs/engineering-handbook/`](../../docs/engineering-handbook/)
- [Template plano de implementação](../../docs/engineering-handbook/templates/plano-de-implementacao.md)

---

## Prompt

```
Você está implementando uma feature no ecossistema {nome-projeto} (multi-repo).

## Contexto
- Repositório(s): {org}/{repo-1}, {org}/{repo-2} (listar todos)
- Stack: {airflow | dbt | terraform | lambda | glue | spring-boot | misto}
- Path(s): {caminhos principais}
- Capítulo handbook: ../../docs/engineering-handbook/{NN}-{stack}.md
- Feature: {descrição objetiva do resultado observável}
- Restrições: {o que NÃO fazer; sem PII; sem breaking change silencioso}

## Antes de editar (obrigatório)
1. Leia o README de cada repo tocado.
2. Leia o capítulo da stack no handbook e o [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md).
3. Apresente um **plano em 5–10 bullets** com:
   - escopo e fora de escopo
   - ordem de implementação e deploy (ex.: TF → Glue → dbt → Airflow)
   - riscos em dados (idempotência, backfill, schema)
   - PRs necessários (um por repo)
   - dúvidas de negócio não documentadas (listar — não inventar)

Aguarde confirmação implícita do plano antes de alterar arquivos.

## Implementação
- Siga o estilo do módulo **vizinho** no mesmo diretório.
- Lógica de negócio fora de handler/DAG/Terraform.
- Um PR por repositório; referencie PRs irmãos no corpo.
- Correção mínima — sem refatoração fora do escopo.

## Entregáveis por repo
- Código + testes (cobertura ≥ 90%; mutation onde aplicável)
- TaaC se houver integração real ([11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md))
- Logs JSON com correlation_id + métricas Datadog
- README / OpenAPI / schema.yml se contrato mudou
- ADR se decisão arquitetural relevante

## Evidências finais (obrigatório no output)
- Comandos executados e resultado (testes, lint, dbt build, terraform validate)
- Cobertura ou link do relatório CI
- Resumo do que mudou por arquivo/repo
- Checklist DoD aplicável marcado
- Riscos residuais e rollback

## Critério de aceite
Feature atende [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md) e está pronta para **review humano** — você não aprova o PR.
```

---

## Variáveis

| Variável | Exemplo |
|----------|---------|
| `{org}` | `minha-org` |
| `{repo-1}` | `vendas-dbt` |
| `{nome-projeto}` | `vendas` |
| `{NN}-{stack}` | `05-dbt` |

## Quando usar

- Feature média/grande que cruza 1+ repos
- Nova capacidade com contrato, testes e observabilidade
- Spike convertido em implementação (com ADR prévio)
