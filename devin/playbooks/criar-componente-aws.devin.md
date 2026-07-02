# Playbook: Criar componente AWS com Terraform

## Objetivo

Provisionar recurso AWS (Lambda, S3, Glue, IAM, filas) com IaC revisável e segura.

## Escopo

Módulo Terraform, IAM, tags, alarmes básicos, documentação — sem secrets no código.

## Contexto

- `docs/padroes/04-terraform.md`
- Skill `criar-modulo-terraform`

## O que procurar no repositório

- Módulos em `infra/modules/`
- Padrão de ambientes `envs/{dev,hml,prod}`
- Outputs consumidos por outros módulos

## Como planejar

1. Recursos mínimos necessários.
2. IAM least privilege.
3. Contratos de output para apps.
4. Impacto de custo.

## Como implementar

1. Módulo com variáveis validadas.
2. Tags projeto.
3. README do módulo.
4. `fmt`, `validate`, `tflint`, `tfsec`.
5. Plan no PR.

## Como testar

```bash
terraform fmt -check -recursive
terraform validate
tflint --recursive
tfsec .
terraform plan -var-file=envs/dev/terraform.tfvars
```

## Como revisar

Checklist `checklists/code-review-terraform.md`.

## Como reportar resultado

PR com plan resumido, recursos criados, permissões IAM.

## Critérios de aceite

- [ ] Sem wildcard IAM sem ADR
- [ ] Tags completas
- [ ] Plan revisado

## O que não fazer

- State local commitado
- Recurso superdimensionado sem alarme
