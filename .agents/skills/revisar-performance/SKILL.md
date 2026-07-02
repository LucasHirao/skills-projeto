<!-- Sincronizado de .claude/skills/revisar-performance/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: revisar-performance
description: >-
  Analisa e propõe melhorias de performance e custo AWS em código projeto. Use para
  gargalos, N+1, scans, cold start Lambda, jobs Spark lentos ou queries dbt caras.
---

# Revisar performance

**Referência:** `docs/padroes/12-performance.md` | **Checklist:** `checklists/code-review-performance.md`

## Quando usar

PR com risco de performance, job lento, custo AWS alto, endpoint sem paginação.

## Entradas esperadas

- Componente e path crítico
- Volume esperado (registros, RPS, GB)
- Métricas/baseline se disponíveis

## Passo a passo

1. Identificar operações O(n), I/O em loop, full scans.
2. Classificar por impacto (latência, custo, throughput).
3. Propor mudança mínima com trade-off explícito.
4. Sugerir batch/paginação/cache/partition conforme stack.
5. Recomendar teste de volume ou baseline antes/depois.
6. Documentar no PR impacto estimado.

## Checklist de qualidade

- [ ] Mudança não compromete idempotência
- [ ] Simplicidade preservada

## Checklist de testes

- [ ] Teste de regressão comportamental
- [ ] Benchmark/microbench só se justificado

## Checklist de observabilidade

- [ ] Métricas para validar melhoria pós-deploy

## Checklist de performance

- [ ] N+1 eliminado
- [ ] Filtro cedo aplicado
- [ ] Timeouts e retry com jitter
- [ ] Custo AWS considerado

## Armadilhas comuns

- Otimizar prematuramente sem medição
- Cache sem invalidação
- microbench em código não hot

## Resultado esperado

Lista priorizada de gargalos + patches recomendados com impacto estimado.

## Exemplo de prompt

```
Use revisar-performance. Analise repository que lista pedidos com N+1,
volume 100k/dia. Proponha paginação e fetch join com impacto estimado.
```

