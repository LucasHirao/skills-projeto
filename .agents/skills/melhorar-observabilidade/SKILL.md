<!-- Sincronizado de .claude/skills/melhorar-observabilidade/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: melhorar-observabilidade
description: >-
  Adiciona ou corrige logs estruturados, métricas, traces e alertas no padrão
  projeto. Use quando faltar correlation_id, telemetria, runbook ou dashboard
  em componente existente.
---

# Melhorar observabilidade

**Referência:** `docs/padroes/11-observabilidade.md` | **Regra:** `.claude/rules/observabilidade.md`

## Quando usar

Componente difícil de debugar, alerta ausente, logs texto livre, falta métrica de negócio.

## Entradas esperadas

- Componente e fluxo crítico
- Ferramenta (CloudWatch, Datadog, etc.)
- Perguntas operacionais a responder

## Passo a passo

1. Mapear jornada e pontos de falha.
2. Adicionar log JSON com campos obrigatórios + correlation_id.
3. Métricas: sucesso, erro, duração, volume.
4. Propagar trace/correlation entre serviços.
5. Criar/atualizar alerta com link runbook.
6. Dashboard usando `template-dashboard.md` se fluxo crítico.
7. Validar ausência de PII em logs.

## Checklist de qualidade

- [ ] Campos obrigatórios presentes
- [ ] Operação nomeada consistentemente
- [ ] Runbook linkado em alerta

## Checklist de testes

- [ ] Teste que log/métrica é emitido em caminho feliz/erro (mock appender)

## Checklist de observabilidade

- [ ] Logs + métricas + traces alinhados
- [ ] Alertas com severidade

## Checklist de performance

- [ ] Log sampling se volume extremo
- [ ] Métricas cardinality controlada

## Armadilhas comuns

- Logar payload completo
- Alerta só em exception técnica
- Remover métrica legada sem migração

## Resultado esperado

Componente observável em prod com runbook e painéis úteis.

## Exemplo de prompt

```
Use melhorar-observabilidade. Adicione logs JSON e métricas em Lambda
processa-arquivo, correlation_id do evento, alerta se taxa erro >1%.
```

