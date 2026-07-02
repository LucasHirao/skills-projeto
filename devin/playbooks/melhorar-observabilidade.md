# Playbook — Melhorar observabilidade

Prompt reutilizável para hardening de logs, métricas, traces e alertas Datadog.

## Fonte de verdade

- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md) — [Logging seguro](../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
- [15 — Documentação](../../docs/engineering-handbook/15-documentacao.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [Template dashboard](../../docs/engineering-handbook/templates/dashboard.md)
- [Template runbook](../../docs/engineering-handbook/templates/runbook.md)

---

## Nomenclatura de código

Ao implementar ou revisar código:

- Use português para identificadores internos criados pelo time.
- Preserve nomes externos, SDKs, frameworks, contratos públicos, schemas, comandos e tags técnicas.
- Não renomeie contrato público existente sem versionamento/migração.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).


## Prompt

```
Melhore a observabilidade de um componente no ecossistema {nome-projeto}.

## Contexto
- Repositório: {org}/{repo}
- Componente: {DAG | Lambda | Glue | API Spring | dbt exposure}
- Path: {caminho}
- Sintoma atual: {MTTR alto | sem alerta | logs não estruturados | não rastreia correlation_id}
- Criticidade: {baixa | média | alta — define se monitor obrigatório}
- Capítulo: ../../docs/engineering-handbook/13-observabilidade.md

## Antes de editar (obrigatório)
Plano com:
1. Campos de log padronizados (correlation_id, service, env, status, duration_ms)
2. Métricas novas (sucesso, erro, latência, volume) — tags de baixa cardinalidade
3. Trace APM se aplicável
4. Monitors Datadog propostos (threshold, janela, destino)
5. Runbook para cada monitor crítico
6. O que **não** logar — política allowlist: sem payload, PII, credenciais; hash/máscara; tags Datadog sem alta cardinalidade ([checklist](../../docs/engineering-handbook/13-observabilidade.md#checklist-de-logging-seguro))

## Implementação
Skill: melhorar-observabilidade

- Logs JSON em pontos de entrada/saída e erros
- Propagação de correlation_id de/para Airflow, HTTP headers, mensagens SQS
- Métricas com nomes consistentes `{nome-projeto}.{componente}.{metrica}`
- Dashboard se novo domínio ou fluxo crítico

## Evidências finais
- Exemplo de log JSON (sanitizado)
- Lista de métricas com tags
- Definição de monitor(es) — query Datadog
- Link ou draft de runbook
- README atualizado (seção operação/debug)
- Checklist observabilidade do [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md)

Correção mínima — não refatorar lógica de negócio fora do necessário para instrumentar.
```

---

## Quando usar

- Componente novo sem instrumentação adequada
- Pós-incidente com diagnóstico difícil
- Preparação para fluxo crítico em produção
