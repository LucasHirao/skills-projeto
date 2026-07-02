---
name: criar-modulo-terraform
description: >-
  Cria ou altera módulos e recursos Terraform projeto com IAM restritivo, tags,
  validação e plan de PR. Use para infra AWS, IAM, Lambda, S3, Glue, filas ou
  ambientes dev/hml/prod.
---

# Criar módulo Terraform

**Referência:** `docs/padroes/04-terraform.md` | **Regra:** `.claude/rules/terraform.md`

## Quando usar

Novo recurso AWS, módulo reutilizável, IAM, variáveis ou ambiente.

## Entradas esperadas

- Recursos necessários
- Ambiente (dev/hml/prod)
- Contratos de input/output
- Permissões mínimas

## Passo a passo

1. Verificar módulo existente em `infra/modules/`.
2. Criar/estender módulo com `variables.tf` (validação), `main.tf`, `outputs.tf`.
3. Aplicar `local.default_tags` projeto.
4. IAM least privilege — sem wildcard sem ADR.
5. README do módulo com inputs/outputs.
6. Rodar `fmt`, `validate`, `tflint`, `tfsec`.
7. Gerar `plan` para anexar ao PR.

## Checklist de qualidade

- [ ] Tags obrigatórias
- [ ] Variáveis tipadas e validadas
- [ ] Outputs com description
- [ ] Sem secret em plain text

## Checklist de testes

- [ ] `terraform validate`
- [ ] `tflint` / `tfsec`
- [ ] Teste de módulo se outputs críticos

## Checklist de observabilidade

- [ ] Alarmes em recurso crítico
- [ ] Logs com retenção definida

## Checklist de performance

- [ ] Dimensionamento justificado
- [ ] Lifecycle em recursos efêmeros

## Armadilhas comuns

- Módulo god com 20+ recursos não relacionados
- State sem backend remoto
- Policy `*/*`

## Resultado esperado

Módulo revisável, plan no PR, IAM restritivo, documentado.

## Exemplo de prompt

```
Use criar-modulo-terraform. Módulo lambda-processa-arquivo com IAM leitura
bucket projeto-input-{env}, DLQ e tags projeto. Incluir validate e tfsec.
```
