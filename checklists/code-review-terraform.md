# Checklist: Code Review Terraform

## Perguntas objetivas

- [ ] `terraform fmt` e `validate` ok?
- [ ] Variáveis com tipo, descrição e validação?
- [ ] Tags obrigatórias projeto?
- [ ] IAM least privilege?
- [ ] Sem secret em plain text no state?
- [ ] Plan anexado/revisado no PR?
- [ ] tfsec/tflint executados?

## 🔴 Bloqueio

- `Action = "*"` / `Resource = "*"` sem ADR
- State local commitado
- Recurso destrutivo sem lifecycle/plano rollback

## 🟡 Atenção

- Módulo monolítico — considerar split
- Sem alarmes em recurso crítico novo

## Exemplos de comentário

> 🔴 Policy S3 com `s3:*` — restringir ao bucket `projeto-vendas-{env}`.

> 🟡 Adicionar `description` no output `lambda_arn` para consumidores.
