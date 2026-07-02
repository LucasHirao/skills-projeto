# Code Review: {PR # / branch}

**Revisor:** {nome}  
**Data:** YYYY-MM-DD  
**Autor:** {nome}  
**Repositório:** `{org}/{repo}`  
**Stack:** {Airflow | dbt | Terraform | Lambda | Spring | Glue | multi}

## Resumo do PR

{1–2 frases — entendimento do que o PR faz.}

## CI

- [ ] Pipeline **verde**
- [ ] Cobertura **≥ 90%** (valor: {X%})
- [ ] Mutation **≥ 90%** (se aplicável — valor: {X%})
- [ ] TaaC passando (se integração)

## Checklist geral

- [ ] Correção funcional e casos de borda
- [ ] Clareza — entendível sem oral
- [ ] Testes adequados (comportamento, não só smoke)
- [ ] Segurança (IAM, secrets, PII, inputs)
- [ ] Observabilidade (logs JSON, `correlation_id`, métricas Datadog)
- [ ] Performance (volume, N+1, custo)
- [ ] Documentação (README, ADR, runbook)
- [ ] Contratos / breaking changes explícitos
- [ ] Multi-repo — PRs irmãos referenciados
- [ ] Código IA revisado com atenção redobrada

## Checklist da stack

### {Airflow | dbt | …}

- [ ] {item 1 do capítulo 16}
- [ ] {item 2}
- [ ] {item 3}

## Achados

| Sev | Arquivo | Linha | Comentário |
|-----|---------|-------|------------|
| 🔴 | | | |
| 🟡 | | | |
| 🟢 | | | |

### Detalhamento 🔴 (bloqueios)

1. 

### Detalhamento 🟡 (atenção)

1. 

## Dados e operação

| Pergunta | Resposta |
|----------|----------|
| Idempotência em reprocessamento? | |
| Backfill necessário? | |
| Impacto em downstream? | |
| Novo alerta/runbook? | |

## Veredito

- [ ] **Aprovado**
- [ ] **Aprovado com ressalvas** — {listar débitos com issue}
- [ ] **Mudanças necessárias** — re-review após correção

**Exceções de DoD aprovadas:** {nenhuma / descrever}

## Referências

- [16 — Code review](../16-code-review.md)
- [18 — Definition of Done](../18-definition-of-done.md)
