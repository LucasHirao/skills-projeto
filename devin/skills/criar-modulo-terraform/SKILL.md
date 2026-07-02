---
name: criar-modulo-terraform
description: >-
  Procedimento Devin para criar ou alterar módulos Terraform AWS com IAM restritivo,
  tags e validação. Use no repositório {nome-projeto}-infra.
---

# Criar módulo Terraform (Devin)

**Playbook relacionado:** `devin/playbooks/criar-componente-aws.devin.md`

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-infra`** — IaC fica aqui, não no repo da aplicação.
2. Leitura de `docs/padroes/04-terraform.md` no repo de padrões.
3. Na sessão: componente, ambiente (dev/hml/prod), consumidores (Lambda ARN, bucket, fila).

## Busca obrigatória no repo infra

```text
modules/                     → módulos reutilizáveis
environments/{env}/          → composição por ambiente
tests/*.tftest.hcl           → testes de módulo
README.md                    → convenções de state e backend
```

Replique padrão de módulo **existente** no mesmo repo.

## Especificação do módulo

| Item | Valor |
|------|-------|
| Path | `modules/{componente}/` |
| IAM | least privilege — sem `*` em actions/resources sem ADR |
| Outputs | ARN, nome, URL — contrato para outros repos |
| Tags | Environment, Project, Owner (obrigatórias) |

## Passos de implementação

1. **variables.tf** — tipos, descriptions, `validation` onde couber.
2. **main.tf** — recursos; `lifecycle` só com justificativa.
3. **iam.tf** — políticas escopadas por bucket/fila/tabela.
4. **outputs.tf** — documentar breaking change se renomear.
5. **environments/{env}/** — wiring; secrets via SSM, não em git.
6. **tests/** — `tftest.hcl` para invariantes (tags, naming).
7. **README do módulo** — exemplo de uso e tabela de outputs.

## Coordenação multi-repo

| Se o TF cria... | Repo consumidor | Ação |
|-----------------|-----------------|------|
| Lambda + role | `-lambda-*` | README com env vars; aguardar ARN |
| Bucket curated | `-glue-*`, `-dbt` | README path + sources.yml |
| Fila SQS | `-lambda-*` | Contrato de mensagem |
| Glue job | `-glue-*` | Job name como variável |

Ordem típica: **infra primeiro**, depois código que consome outputs.

## Validação

```bash
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=environments/dev/terraform.tfvars   # ajustar path
terraform test                                                # se existir
```

Incluir trecho do plan no PR (sem valores sensíveis).

## Checklists

- `checklists/code-review-terraform.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-infra

## Módulo
modules/{componente}

## Recursos
Lambda, IAM, S3, ...

## Outputs novos/alterados
- lambda_arn (breaking? sim/não)

## Validação
terraform plan → resumo

## PRs irmãos
- [ ] datalake-lambda-x: usar ARN após merge
- [ ] datalake-glue-y: path bucket

## Rollback
o que destroy afeta
```

## Não fazer

- Editar `.claude/`
- `s3:*` ou `resources = ["*"]` sem ADR
- Lógica de negócio no Terraform
- State local ou secrets em `.tfvars` commitado
