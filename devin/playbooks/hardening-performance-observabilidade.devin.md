# Playbook: Hardening de performance e observabilidade

## Objetivo

Melhorar componente existente em performance/custo e capacidade operacional de debug.

## Escopo

Otimizações mensuráveis + telemetria — mudanças incrementais, não rewrite.

## Contexto

- `docs/padroes/11-observabilidade.md`
- `docs/padroes/12-performance.md`
- Skills `melhorar-observabilidade`, `revisar-performance`

## O que procurar no repositório

- Métricas/baseline atuais
- Hot paths (loops I/O, scans, N+1)
- Dashboards e alertas existentes
- Runbooks

## Como planejar

1. Definir SLI/SLO ou métrica alvo (latência, custo, throughput).
2. Medir baseline.
3. Priorizar top 3 gargalos.
4. Planejar validação pós-mudança.

## Como implementar

**Performance:**
- Batch, paginação, filtro cedo, partition
- Timeouts, retry com jitter

**Observabilidade:**
- Log JSON + correlation_id
- Métricas sucesso/erro/duração/volume
- Alerta com runbook

## Como testar

- Testes de regressão comportamental
- Benchmark/volume test se mudança crítica
- Comparar métricas antes/depois em hml

## Como revisar

Checklists performance + observabilidade.

## Como reportar resultado

PR com baseline, mudança, impacto estimado, novos painéis/alertas.

## Critérios de aceite

- [ ] Melhoria mensurável ou custo documentado
- [ ] Sem PII em logs
- [ ] Cardinality de métricas controlada

## O que não fazer

- Otimizar sem medição
- Adicionar cache sem TTL
- Remover logs úteis para “performance”
