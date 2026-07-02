---
name: investigar-falha
description: Diagnosticar incidentes, bugs e falhas de pipeline em {nome-projeto} com hipóteses ordenadas e correção mínima.
disable-model-invocation: true
---

# Investigar falha

## Quando usar

- Usuário pede explicitamente investigação de incidente ou bug
- Pipeline falhou em prod/hml/CI
- Regressão após deploy

**Não invocar automaticamente** — requer pedido explícito (`disable-model-invocation`).

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [13 — Observabilidade](../../../docs/engineering-handbook/13-observabilidade.md)
- [16 — Code review](../../../docs/engineering-handbook/16-code-review.md) (dimensão dados/ops)
- Capítulo da stack afetada
- [11 — TaaC](../../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md) (reprodução)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Investigação: preserve `correlation_id` e campos de ferramenta; relatório em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Sintoma | Sim | DAG falhou às 06:15 UTC |
| Ambiente | Sim | `prod` |
| Evidência | Sim | `correlation_id`, stack trace, task_id |
| Escopo | Sim | Último deploy ou data_referencia |
| Impacto | Recomendado | Atraso SLA, dados duplicados |

## Passos

1. **Congelar escopo** — não expandir refatoração.
2. Coletar evidência: logs Datadog (`correlation_id`), métricas, histórico de deploy.
3. Listar hipóteses ordenadas por probabilidade.
4. Testar hipótese mais provável com menor custo (query, replay, teste local).
5. Ao coletar evidência: **não** reproduzir PII ou payload completo no relatório — usar `correlation_id` e campos allowlist.
6. Reproduzir com teste unitário ou TaaC **antes** de corrigir.
7. Aplicar correção mínima; evitar mudança colateral.
8. Adicionar teste de regressão.
9. Atualizar runbook se lacuna operacional.
10. Post-mortem leve no PR se incidente prod.

## Checklist de qualidade

- [ ] Causa raiz identificada ou incerteza explícita
- [ ] Timeline do incidente documentada
- [ ] Correção alinhada ao handbook

## Checklist de testes

- [ ] Teste de regressão adicionado
- [ ] Suite existente verde
- [ ] TaaC atualizado se wiring quebrou

## Checklist de observabilidade

- [ ] Log/métrica que facilitaria detecção mais cedo (follow-up)
- [ ] `correlation_id` usado na investigação

## Checklist de desempenho

- [ ] Verificar se falha é timeout/volume (não só bug lógico)
- [ ] Backfill/reprocessamento dimensionado

## Checklist de segurança

- [ ] Evidência sem expor PII na resposta
- [ ] Sem workaround inseguro (bypass auth, IAM `*`)

## Critérios de aceite

- Reprodução documentada
- Correção mínima com teste
- Runbook atualizado se aplicável
- Impacto em dados avaliado (duplicata, perda, atraso)

## O que não fazer

- Corrigir sem entender causa
- Refatorar amplo no mesmo PR
- Reprocessar prod sem plano de idempotência
- Colar dados reais de cliente no chat

## Como reportar

```markdown
## Sintoma
...

## Evidência
- correlation_id: ...
- Link/query Datadog: ...

## Hipóteses testadas
1. [descartada/confirmada] ...

## Causa raiz
...

## Correção
- Arquivo: ...
- Teste de regressão: ...

## Impacto em dados
...

## Follow-ups
- [ ] métrica/alerta
- [ ] runbook
```

## Fonte de verdade

- [13 — Observabilidade](../../../docs/engineering-handbook/13-observabilidade.md)
- [Template — runbook](../../../docs/engineering-handbook/templates/runbook.md)
- [19 — Padrões para uso de IA](../../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md) (§3.7)
