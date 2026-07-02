# Checklist: Code Review Observabilidade

## Perguntas objetivas

- [ ] Logs estruturados JSON?
- [ ] `correlation_id` propagado?
- [ ] Campos obrigatórios presentes?
- [ ] Sem PII/secrets em log?
- [ ] Métricas sucesso/erro/duração?
- [ ] Trace em chamadas externas?
- [ ] Alerta/runbook se fluxo crítico novo?

## 🔴 Bloqueio

- Payload completo ou CPF em log
- Fluxo crítico sem métrica de erro
- Remoção de log/métrica existente

## 🟡 Atenção

- Só log de texto livre
- Alerta sem runbook linkado

## Exemplos de comentário

> 🔴 Log inclui `request.body` com dados do cliente — mascarar campos sensíveis.

> 🟡 Adicionar métrica `datalake_vendas_registros_rejeitados` para painel operacional.
