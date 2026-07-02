# Playbook — Revisar desempenho

Prompt reutilizável para análise de performance, custo AWS e otimização com evidências.

## Fonte de verdade

- [14 — Performance](../../docs/engineering-handbook/14-performance.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md)
- Capítulo da stack: [`docs/engineering-handbook/`](../../docs/engineering-handbook/)

---

## Prompt

```
Analise e proponha melhorias de desempenho no ecossistema {nome-projeto}.

## Contexto
- Repositório: {org}/{repo}
- Componente: {Glue job | Lambda | dbt model | DAG task | API endpoint | query SQL}
- Path: {caminho}
- Volume atual: {registros/dia | RPS | tamanho médio batch}
- Volume alvo (10×): {se aplicável}
- Sintoma: {latência p95 | custo AWS | OOM | timeout | full table scan}
- Métricas Datadog disponíveis: {queries ou período analisado}
- Capítulo: ../../docs/engineering-handbook/14-performance.md

## Antes de alterar (obrigatório)
1. **Baseline** documentado: p50/p95/p99, custo, CPU/memória, DPU, slot time dbt.
2. Liste gargalos com **evidência** (trecho de código, explain plan, métrica).
3. Priorize por impacto × esforço.
4. Plano de mudança mínima — um gargalo principal por PR quando possível.
5. Trade-offs explícitos (consistência, custo, complexidade).
6. Riscos de regressão funcional e como testar.

## Análise por stack
- **Glue/Spark:** particionamento, shuffle, broadcast, bookmark, DPU
- **Lambda:** memória, cold start, batch size, timeout, concurrency
- **dbt:** materialização, incremental strategy, indexes, warehouse size
- **Airflow:** pool, parallelism, sensor mode, custo de schedule
- **Spring/API:** N+1, cache, connection pool, payload size

## Implementação (se solicitado)
Skill: revisar-desempenho
- Mudança mínima com benchmark antes/depois
- Testes de regressão verdes
- Documentar limites (timeout, retry, idempotência)

## Evidências finais
- Tabela antes/depois (latência, custo, throughput)
- Comandos de benchmark executados
- PR ou proposta de PR com escopo fechado
- ADR se mudança arquitetural ([template](../../docs/engineering-handbook/templates/adr.md))
- Itens **não** endereçados (fora de escopo) listados explicitamente

Não micro-otimizar sem medição. Não refatorar amplo “porque estava aqui”.
```

---

## Quando usar

- Custo AWS crescente em job/pipeline
- Timeout ou OOM em produção
- Design review antes de escalar volume
- PR que altera query, particionamento ou recursos
