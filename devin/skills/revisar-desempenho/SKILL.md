---
name: revisar-desempenho
description: Analisa e propõe melhorias de desempenho e custo em componentes do {nome-projeto} com evidência de código ou métricas Datadog. Use para gargalos, volume alto, custo AWS ou latência.
allowed-tools: read, bash, grep, glob
argument-hint: "{org}/{repo} {componente} {volume — ex. 10M registros/dia}"
triggers:
  - revisar performance
  - otimizar custo aws
  - gargalo latência
  - full scan spark
---

# revisar-performance

## Fonte de verdade

- [14 — Performance](../../../docs/engineering-handbook/14-performance.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Componente lento ou caro em produção/staging
- Design review antes de volume 10×
- PR que altera particionamento, batch size, queries ou recursos AWS

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Desempenho: preserve nomes de métricas técnicas Datadog; lógica interna em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Passos

1. Estabelecer baseline: métricas Datadog, volume, p95/p99, custo.
2. **Plano** listando gargalos com evidência (código, query plan, métrica).
3. Propor mudança **mínima** com trade-off explícito.
4. Estimar impacto antes/depois (latência, custo, memória).
5. Não refatorar fora do escopo; um gargalo por PR quando possível.
6. Testes de regressão e benchmark se aplicável.

## Checklist DoD (recorte)

- [ ] Baseline documentado
- [ ] Mudança mensurável (não micro-otimização prematura)
- [ ] Timeout/retry/idempotência preservados
- [ ] Custo AWS estimado se impacto > 20%
- [ ] Sem regressão funcional (testes verdes)

## Templates

- [decisao-tecnica](../../../docs/engineering-handbook/templates/decisao-tecnica.md)
- [adr](../../../docs/engineering-handbook/templates/adr.md)

## Não fazer

Ver anti-padrões em [14 — Performance](../../../docs/engineering-handbook/14-performance.md).
