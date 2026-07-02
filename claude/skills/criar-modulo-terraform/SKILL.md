---
name: criar-modulo-terraform
description: Criar ou alterar módulos Terraform para infraestrutura AWS de {nome-projeto} com IAM least privilege, tags e validação CI.
---

# Criar módulo Terraform

## Quando usar

- Novo módulo reutilizável (Lambda, bucket, fila, IAM)
- Alteração de ambiente (`dev`, `hml`, `prod`)
- Outputs consumidos por outros repos

## Pré-leitura

- [06 — Terraform](../../docs/engineering-handbook/06-terraform.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `terraform-{nome-projeto}` |
| Módulo / path | Sim | `modules/lambda-processa-arquivo` |
| Recursos | Sim | Lambda, IAM role, alarmes |
| Ambiente | Sim | `hml` |
| Consumidores | Se houver | repo `{nome-projeto}-glue` |

## Passos

1. Plano: recursos, blast radius, dependências e outputs.
2. Módulo pequeno por capacidade; variáveis com descrição.
3. IAM least privilege — sem `*` sem ADR.
4. Tags obrigatórias: `env`, `service`, `team`.
5. Secrets via Secrets Manager; `sensitive` em outputs.
6. Alarmes Datadog/métricas para recursos críticos.
7. README do módulo com inputs/outputs e exemplo.
8. `terraform fmt`, `validate`, plan na CI.
9. tfsec/checkov sem HIGH/CRITICAL não justificado.
10. Resumir plan no output do PR.

## Checklist de qualidade

- [ ] Módulo reutilizável e documentado
- [ ] State remoto com lock
- [ ] Ambientes isolados

## Checklist de testes

- [ ] `terraform validate` na CI
- [ ] Plan anexado ou na pipeline
- [ ] Testes de módulo (terratest) se padrão do repo

## Checklist de observabilidade

- [ ] Alarmes em recursos críticos
- [ ] Integração Datadog desde o módulo, se aplicável

## Checklist de desempenho

- [ ] Lifecycle e retenção conscientes (S3, logs)
- [ ] Custo estimado se impacto > 20%

## Checklist de segurança

- [ ] Least privilege IAM
- [ ] Sem segredo em state plain text
- [ ] Encryption at rest onde obrigatório

## Critérios de aceite

- DoD Terraform em [18](../../docs/engineering-handbook/18-definition-of-done.md) §2.3
- Plan revisado por humano

## O que não fazer

- Monólito Terraform com todos os recursos
- State local
- Permissão ampla temporária sem ticket/ADR
- Output de secret sem `sensitive`

## Como reportar

- Resumo do plan (criar/alterar/destruir)
- Outputs novos e repos consumidores
- Findings de tfsec/checkov resolvidos

## Fonte de verdade

- [06 — Terraform](../../docs/engineering-handbook/06-terraform.md)
- [Template — readme-componente](../../docs/engineering-handbook/templates/readme-componente.md)
