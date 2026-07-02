---
name: criar-modulo-terraform
description: Cria ou altera módulos Terraform/IaC no {nome-projeto} com IAM least privilege, tags padronizadas e alarmes Datadog. Use ao provisionar Lambda, Glue, S3, IAM, filas ou alarmes.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{nome-projeto}-terraform modules/{nome_modulo}/ {recursos}"
triggers:
  - criar módulo terraform
  - provisionar aws
  - iac terraform
  - iam least privilege
---

# criar-modulo-terraform

## Fonte de verdade

- [06 — Terraform](../../docs/engineering-handbook/06-terraform.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Novo módulo ou recurso em `{nome-projeto}-terraform`
- Alteração de IAM, buckets, filas, Lambdas, Glue jobs
- Alarmes e integrações Datadog via Terraform

## Passos

1. Ler módulo vizinho; seguir padrão de `variables`, `outputs`, `versions`.
2. **Plano** com `terraform plan` esperado e blast radius.
3. IAM least privilege; sem `*` sem ADR.
4. Tags obrigatórias: `env`, `service`, `team`, `managed_by`.
5. README do módulo com inputs/outputs e exemplo de uso.
6. tfsec/checkov na CI; state remoto; sem segredo no código.

## Checklist DoD (recorte)

- [ ] `terraform validate` / plan limpo
- [ ] Outputs documentados para repos consumidores
- [ ] Alarmes em recursos críticos
- [ ] Breaking change em output comunicado nos PRs irmãos
- [ ] Scan IaC sem bloqueio não justificado

## Templates

- [readme-componente](../../docs/engineering-handbook/templates/readme-componente.md)
- [adr](../../docs/engineering-handbook/templates/adr.md)

## Não fazer

Ver anti-padrões em [06 — Terraform](../../docs/engineering-handbook/06-terraform.md).
