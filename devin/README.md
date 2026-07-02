# Devin — Manual de Engenharia

Configuração do agente **Devin** derivada do [Manual de Engenharia](../docs/engineering-handbook/). Skills e playbooks **não** são fonte de verdade.

## Catálogo canônico

[`docs/engineering-handbook/manifest.yaml`](../docs/engineering-handbook/manifest.yaml) — stacks, paths e regras de validação.

Mapa resumido: [artefatos-ia.md](../docs/engineering-handbook/artefatos-ia.md).

## Fonte de verdade

| Artefato | Caminho |
|----------|---------|
| Handbook | [`docs/engineering-handbook/`](../docs/engineering-handbook/) |
| Manifesto | [`manifest.yaml`](../docs/engineering-handbook/manifest.yaml) |
| DoD | [18 — Definition of Done](../docs/engineering-handbook/18-definition-of-done.md) |
| Uso de IA | [19 — Padrões para uso de IA](../docs/engineering-handbook/19-padroes-para-uso-de-ia.md) |
| Agentes | [21 — Agentes e prompts](../docs/engineering-handbook/21-agentes-e-prompts.md) |
| Documentação funcional | [22 — Documentação funcional](../docs/engineering-handbook/22-documentacao-funcional.md) |
| Logging seguro | [13 — Observabilidade](../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis) |

## Estrutura

```
devin/
  AGENTS.md
  skills/*/SKILL.md      # descoberta por convenção
  playbooks/*.md           # descoberta por convenção
  sincronizar-devin.sh
```

## Skills vs Playbooks

| Tipo | Quando usar |
|------|-------------|
| **Skill** | Tarefa recorrente em um repo/stack |
| **Playbook** | Fluxo amplo ou cross-repo |

## Instalar Skills

```bash
bash /caminho/repositorio-de-padroes/devin/sincronizar-devin.sh --check
bash /caminho/repositorio-de-padroes/devin/sincronizar-devin.sh
```

## Convenções

- Prosa em português BR
- Identificadores internos em português ([03](../docs/engineering-handbook/03-padroes-de-codigo.md))
- Multi-repo: `{nome-projeto}-airflow`, `{nome-projeto}-dbt`, etc.
- Observabilidade: Datadog

## Manutenção

1. Handbook primeiro
2. `manifest.yaml` ao adicionar stack
3. `bash scripts/validar-handbook.sh`
4. Ver [CONTRIBUTING.md](../CONTRIBUTING.md)

## Fonte de verdade

Derivado do Manual de Engenharia. Catálogo: [`manifest.yaml`](../docs/engineering-handbook/manifest.yaml).
