---
name: criar-modulo-terraform
description: >-
  Cria ou altera módulos e recursos Terraform AWS com IAM restritivo, tags,
  validação e plan de PR. Use no repo {nome-projeto}-infra para Lambda, S3, Glue,
  filas, roles e ambientes dev/hml/prod.
disable-model-invocation: true
---

# Criar módulo Terraform (Claude Code)

**Repo alvo:** `{nome-projeto}-infra` | **Rule:** `.claude/rules/terraform.md` | **Doc:** `docs/padroes/04-terraform.md`

## Pré-voo

1. Confirmar repo `-infra` (IaC separado do código de aplicação).
2. Ler módulo similar em `modules/` e uso em `environments/{env}/`.
3. Ler `04-terraform.md`: naming, IAM least privilege, state, testes `tftest`.
4. Plano: recurso, inputs/outputs, IAM, impacto em repos `-lambda-*`, `-glue-*`, `-airflow`.

## Entradas

- `{nome-projeto}`, `{componente}`, `{ambiente}` (dev/hml/prod)
- Recursos AWS (Lambda, S3, IAM, SQS, Glue, EventBridge, etc.)
- Consumidores downstream (ARN, bucket, fila)
- Tags obrigatórias, retenção, criptografia

## Procedimento

### 1. Estrutura de arquivos

```
modules/{componente}/
  main.tf
  variables.tf
  outputs.tf
  iam.tf              # se IAM não trivial
  versions.tf
environments/{env}/{componente}.tf
tests/{componente}_module.tftest.hcl
```

### 2. Módulo reutilizável

- Variáveis com `description`, `type`, `validation` quando possível.
- Outputs explícitos para contratos (ARN, nome, URL).
- Tags padrão via `locals` ou módulo `tags`.

```hcl
# IAM — escopo mínimo
{
  Effect   = "Allow"
  Action   = ["s3:GetObject", "s3:ListBucket"]
  Resource = [
    aws_s3_bucket.datalake.arn,
    "${aws_s3_bucket.datalake.arn}/raw/${var.dominio}/*"
  ]
}
```

### 3. Ambiente

- `environments/{env}/` referencia módulo; sem lógica duplicada.
- Secrets via SSM/Secrets Manager — nunca em `.tfvars` commitado.
- `lifecycle` e `prevent_destroy` apenas com ADR.

### 4. Contratos multi-repo

| Output TF | Consumidor | Documentar em |
|-----------|------------|---------------|
| Lambda ARN | `-lambda-*` README | output + README infra |
| Bucket name | Glue, dbt sources | README ambos repos |
| IAM role ARN | CI/CD, Airflow | runbook se crítico |
| SQS URL | Lambda trigger | contrato mensagem |

Liste breaking changes em outputs no corpo do PR.

### 5. Testes

```hcl
# tests/lambda_module.tftest.hcl
run "validates_required_tags" {
  command = plan
  assert {
    condition     = contains(keys(var.tags), "Environment")
    error_message = "Tag Environment obrigatória"
  }
}
```

```bash
terraform fmt -check -recursive
terraform validate
terraform test   # se configurado
```

### 6. Plan e documentação

- Incluir trecho do `terraform plan` no PR (sem secrets).
- README do módulo: inputs, outputs, exemplo de uso.
- Rollback: o que `destroy` afeta; dependências.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-terraform.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| `s3:*` / `resources = ["*"]` | Escopo mínimo por recurso |
| Lógica de negócio no TF | Só infra; app no repo da stack |
| Output renomeado sem aviso | Breaking change explícito |
| State local | Backend remoto por ambiente |
| Recurso órfão sem tag | Tags obrigatórias + `default_tags` |

## Reporte Claude

- Módulos/arquivos alterados
- Outputs novos ou alterados (breaking?)
- Comando `terraform plan` / `test` executado
- PRs irmãos nos repos que consomem ARN/bucket/fila

## Prompt

```
Repo datalake-infra. Skill criar-modulo-terraform. Plano primeiro.
Módulo lambda_processa_vendas: role IAM S3 read + DynamoDB write, outputs arn e role_name.
Ambiente dev. tftest para tags. terraform plan.
```
