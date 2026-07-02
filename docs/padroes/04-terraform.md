# Terraform

## Princípios

- Infra como código versionada, revisável e com plan obrigatório em PR.
- Módulos pequenos e reutilizáveis; ambientes por workspace ou diretório.
- Least privilege IAM; sem wildcard sem justificativa documentada.

## Estrutura

```
infra/
├── modules/
│   ├── lambda-processa/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── s3-data-lake/
├── envs/
│   ├── dev/
│   ├── hml/
│   └── prod/
└── versions.tf
```

## Tags obrigatórias

```hcl
locals {
  default_tags = {
    Project = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner_team
    CostCenter  = var.cost_center
  }
}
```

## Variável com validação

```hcl
variable "environment" {
  description = "Ambiente de deploy (dev, hml, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "environment deve ser dev, hml ou prod."
  }
}
```

## IAM restritiva — exemplo

```hcl
# ✅ Escopo mínimo para Lambda ler bucket específico
data "aws_iam_policy_document" "lambda_s3_read" {
  statement {
    sid       = "ReadInputBucket"
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.input.arn,
      "${aws_s3_bucket.input.arn}/*"
    ]
  }
}

# ❌ Evitar sem ADR
# actions = ["s3:*"]
# resources = ["*"]
```

## Backend e state

Ver `examples/terraform/backend.tf.example` — S3 + DynamoDB lock.

- State é sensível — sem secrets em plain text; usar `sensitive = true` em outputs.
- Nunca commitar `terraform.tfstate`.

## Módulo completo de referência

`examples/terraform/modulo_lambda_minimo.tf` — Lambda + S3 + IAM + DLQ + outputs.

## Naming AWS

Ver `docs/padroes/18-estrutura-repositorios.md` — `{nome-projeto}-{dominio}-{tipo}-{env}`.

## KMS e criptografia

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "input" {
  bucket = aws_s3_bucket.input.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
  }
}
```

## Lifecycle e custo

```hcl
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = 30
}
```

## terraform test (nativo)

```hcl
# tests/lambda_module.tftest.hcl
run "valida_output_bucket" {
  command = plan
  assert {
    condition     = output.input_bucket != ""
    error_message = "input_bucket deve ser exposto"
  }
}
```

## Scan de segurança

```bash
terraform fmt -check -recursive && terraform validate
tflint --recursive
tfsec .
checkov -d infra/    # complementar tfsec
```

## Code review

Ver `checklists/code-review-terraform.md`.