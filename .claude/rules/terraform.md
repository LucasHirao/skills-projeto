# Regra: Terraform

**Doc:** `docs/padroes/04-terraform.md` | **Checklist:** `checklists/code-review-terraform.md`

## Faça

- Tags obrigatórias do projeto
- Variáveis com validação
- IAM least privilege
- `fmt`, `validate`, `tflint`, `tfsec` no CI
- Plan no PR

## Não faça

- Wildcard IAM sem ADR
- Secret em plain text
- Commitar state local

## Módulos

- Um módulo = uma capacidade coesa
- Outputs documentados para contratos
