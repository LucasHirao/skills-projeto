---
name: melhorar-observabilidade
description: >-
  Procedimento Devin para adicionar ou corrigir logs, métricas, traces e alertas
  em componente existente. Use no repositório de código do componente afetado.
---

# Melhorar observabilidade (Devin)

**Playbook relacionado:** `devin/playbooks/hardening-performance-observabilidade.devin.md` (hardening amplo)

## Configuração da sessão Devin

1. Clone/checkout o repo do componente (`-lambda-*`, `-api-*`, `-airflow`, `-glue-*`).
2. Leitura de `docs/padroes/11-observabilidade.md`.
3. Na sessão: gap reportado (sem correlation_id, sem alerta, logs texto livre), fluxo crítico?

## Busca obrigatória no repo

```text
handler.py / Controller / tasks.py / job script
config de logging existente
métricas CloudWatch/Datadog/Micrometer já emitidas
README ou runbooks/
.github/ ou infra/           → alarmes se no mesmo repo
```

**Não remover** telemetria existente sem ADR documentado.

## Gaps típicos a corrigir

| Gap | Ação |
|-----|------|
| Log texto livre | JSON com `correlation_id`, `componente` |
| Sem métricas sucesso/erro | contadores + latência |
| Falha silenciosa | ERROR estruturado + alerta |
| Fluxo crítico novo | runbook + alarme |

## Passos de implementação

1. Propagar `correlation_id` do trigger (SQS, API header, `dag_run.conf`).
2. Padronizar campos de log (sem PII).
3. Emitir métricas com cardinalidade baixa (`ambiente`, `dominio`).
4. Tracing em chamadas externas se stack suporta (OTel, X-Ray, Powertools).
5. Se crítico: alarme + runbook (sintoma → diagnóstico → mitigação).
6. Teste: `caplog` ou assert métrica mockada onde o repo já faz.
7. README: novos campos e link runbook.

## Coordenação multi-repo

| Artefato | Repo |
|----------|------|
| CloudWatch alarm TF | `-infra` |
| Dashboard compartilhado | documentar no README do time |
| Callback falha DAG | `-airflow` |
| Métricas job Glue | `-glue-*` + opcional TF |

Liste PR infra se alarme novo.

## Validação

- Testes unitários continuam verdes.
- Em dev/staging: evidência de log JSON (trecho sanitizado no reporte).

## Checklists

- `checklists/code-review-observabilidade.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-lambda-x

## Gaps corrigidos
- correlation_id no handler
- métricas registros_ok/erro

## Arquivos
src/handler.py, ...

## Alertas/runbooks
- alarme X → runbook path

## PRs irmãos
- [ ] datalake-infra: alarm TF

## Como validar
disparar evento teste → log esperado
```

## Não fazer

- Editar `.claude/`
- PII em log
- Remover métricas legadas sem transição
- Alerta sem runbook em fluxo crítico
