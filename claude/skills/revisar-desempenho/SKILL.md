---
name: revisar-desempenho
description: Analisar gargalos de desempenho e custo AWS em componentes {nome-projeto} com evidência e mudança mínima.
---

# Revisar desempenho

## Quando usar

- Latência ou custo acima do esperado
- Design review antes de implementação de alto volume
- Incidente relacionado a timeout, OOM ou scan caro

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [14 — Performance](../../../docs/engineering-handbook/14-performance.md)
- Capítulo da stack (04–09)
- [13 — Observabilidade](../../../docs/engineering-handbook/13-observabilidade.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md) §1.5

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Desempenho: preserve nomes de métricas técnicas Datadog; lógica interna em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Componente | Sim | `mart_vendas_diario`, job Glue X |
| Path | Sim | `models/marts/vendas/` |
| Volume | Sim | 10M linhas/dia, pico 3× |
| Evidência | Recomendado | Métrica Datadog, explain plan |
| Orçamento/custo | Se relevante | +20% AWS |

## Passos

1. Responder checklist mental do cap. 14 (volume, cardinalidade, I/O em loop, 10×).
2. Coletar baseline: métricas Datadog, tempo CI, custo AWS se disponível.
3. Identificar gargalos com evidência (código, query plan, trace).
4. Priorizar por impacto × esforço.
5. Propor mudança **mínima** com estimativa antes/depois.
6. Validar que não quebra contrato ou idempotência.
7. Documentar no PR ou plano de implementação.
8. Sugerir teste de carga ou TaaC se mudança crítica.

## Checklist de qualidade

- [ ] Diagnóstico baseado em evidência, não suposição
- [ ] Escopo limitado ao gargalo
- [ ] Trade-offs documentados

## Checklist de testes

- [ ] Testes existentes verdes após mudança
- [ ] Benchmark ou assert de tempo se padrão do repo
- [ ] Regressão de comportamento coberta

## Checklist de observabilidade

- [ ] Métricas para validar melhoria pós-deploy
- [ ] Dashboard com baseline marcado

## Checklist de desempenho

- [ ] Sem N+1, full scan evitável, collect massivo
- [ ] Partição/predicate pushdown (SQL/Spark)
- [ ] Batch/paginação/stream onde cabível
- [ ] Custo AWS estimado se > 20%

## Checklist de segurança

- [ ] Otimização não expõe dados adicionais
- [ ] Cache não vaza dados entre tenants

## Critérios de aceite

- Lista priorizada de gargalos com evidência
- Proposta com estimativa quantitativa ou qualitativa clara
- DoD performance §1.5 atendida na implementação

## O que não fazer

- Refatorar fora do escopo "já que estamos aqui"
- Micro-otimizar sem medição
- Trocar tecnologia sem ADR
- Ignorar impacto em backfill

## Como reportar

```markdown
## Baseline
- Volume: ...
- Métrica: ... (link Datadog)

## Gargalos (prioridade)
1. [alto] descrição — evidência — proposta

## Estimativa
- Antes: ...
- Depois: ...

## Fora de escopo
- ...
```

## Fonte de verdade

- [14 — Performance](../../../docs/engineering-handbook/14-performance.md)
