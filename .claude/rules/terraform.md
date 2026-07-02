# Regra: Terraform

**Doc:** `docs/padroes/04-terraform.md` | **Checklist:** `checklists/code-review-terraform.md`

## Escopo

Repo `{nome-projeto}-infra` — `modules/`, `envs/{dev,hml,prod}/`.

## Faça

- Tags: `Project`, `Environment`, `ManagedBy`, `Owner`, `CostCenter`.
- Variáveis com `type`, `description`, `validation`.
- IAM least privilege — resource ARN específico.
- Outputs documentados para contratos (Lambda ARN, bucket name).
- `sensitive = true` em outputs secretos.
- Backend remoto S3 + lock DynamoDB.
- DLQ/on-failure em Lambda; KMS em buckets sensíveis.
- `lifecycle` e retenção de logs definidos.

## Não faça

```hcl
# ❌
actions = ["s3:*"]
resources = ["*"]
```

## Critérios de aceite

- [ ] `fmt` + `validate` + tfsec/checkov
- [ ] Plan revisado no PR
- [ ] Sem secret em plain text no state
