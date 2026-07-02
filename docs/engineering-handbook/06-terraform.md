# 06 — Terraform

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Repositório:** `terraform-{nome-projeto}` ou `infra-{dominio}`  
> **Escopo:** infraestrutura como código na AWS para a plataforma `{nome-projeto}`

---

## Objetivo

Definir **como projetamos, versionamos, testamos, revisamos e operamos** infraestrutura com Terraform em ambiente **multi-repo**: módulos reutilizáveis, ambientes isolados, IAM least privilege, state remoto seguro, validação em CI e integração com observabilidade (**Datadog**) e custo.

Terraform é o **contrato executável** entre engenharia e cloud — não um bloco de notas de recursos soltos.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Engenheiro(a) de plataforma / DevOps** | Criar e manter módulos e ambientes |
| **Desenvolvedor(a) de aplicação** | Consumir outputs e entender dependências de infra |
| **SRE / operações** | Entender blast radius, rollback e alertas |
| **Revisor de PR** | Critérios objetivos além de `terraform plan` |
| **Júnior** | Estrutura mínima e erros comuns a evitar |

---

## Problemas que estes padrões resolvem

| Problema recorrente | Sintoma | Como este capítulo ajuda |
|---------------------|---------|--------------------------|
| State local ou compartilhado sem lock | Corrupção de state, deploy concorrente | Backend S3 + DynamoDB lock |
| IAM `*` sem justificativa | Brecha de segurança, auditoria reprovada | Least privilege + ADR para exceções |
| Módulo monolítico | Reuso impossível, plan de 30 min | Módulos pequenos por capacidade |
| Drift não detectado | Produção diverge do código | Plan obrigatório, scheduled drift (opcional) |
| Secrets no state | Vazamento em backup de state | `sensitive`, Secrets Manager, sem plain text |
| Ambientes acoplados | Mudança em dev quebra prod | Diretórios/workspaces por ambiente |
| Infra sem observabilidade | Incidente sem métrica/alerta | Integração Datadog desde o módulo |

---

## Princípios

1. **Infra como código versionada** — toda mudança via PR com `plan` anexado ou linkado.
2. **Módulos pequenos e compostos** — um módulo = uma capacidade (Lambda + IAM, bucket data lake, fila DLQ).
3. **Ambientes explícitos** — `dev`, `hml`, `prod` nunca compartilham state.
4. **Least privilege IAM** — escopo mínimo por recurso; wildcard só com ADR.
5. **Tags obrigatórias** — custo, ownership e rastreabilidade em todo recurso taggável.
6. **Providers pinados** — versões fixas em `versions.tf`; upgrade é PR dedicado.
7. **Não commitar state** — backend remoto sempre; `.tfstate` no `.gitignore`.
8. **Observabilidade by design** — log groups com retenção, métricas exportáveis, integração Datadog quando aplicável.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa descartada | Motivo |
|---------|---------|----------------------|--------|
| Organização multi-repo | Um repo `terraform-{dominio}` por domínio/capacidade | Monorepo único de infra | Ciclo de vida e ownership independentes |
| Separação de ambientes | Diretórios `envs/{dev,hml,prod}` | Workspace único com `count` | Blast radius e permissões de apply distintas |
| Backend | S3 + DynamoDB lock | Terraform Cloud (se não adotado) | Controle na conta AWS corporativa |
| Módulos compartilhados | Repo `terraform-modules-{nome-projeto}` ou path `modules/` local | Copy-paste entre repos | DRY com versionamento semver |
| Scan de segurança | `tflint` + `tfsec`/`checkov` em CI | Apenas `validate` | Falha cedo em misconfig |
| Testes | `terraform test` nativo + contract de outputs | Apenas plan manual | Regressão automatizada |

---

## Trade-offs

| Trade-off | Opção A | Opção B | Quando escolher A | Quando escolher B |
|-----------|---------|---------|-------------------|-------------------|
| Módulo genérico vs específico | Módulo parametrizado | Módulo por caso de uso | 3+ consumidores iguais | Comportamento único, baixo reuso |
| `for_each` vs recursos explícitos | `for_each` em mapas | Recursos nomeados | N instâncias homogêneas | Poucos recursos, nomes estáveis críticos |
| Remote state data source | Ler output de outro stack | Duplicar variável | Contrato estável entre domínios | Protótipo / desacoplamento temporário |
| Terratest | Teste Go de deploy real | `terraform test` + plan | Módulo crítico, alta complexidade | Maioria dos módulos — mais rápido |

---

## Quando usar / quando não usar

### Use Terraform quando

- Recurso AWS de longa duração (Lambda, S3, RDS, IAM, Glue job, filas).
- Configuração precisa ser reproduzível entre ambientes.
- Mudança precisa de revisão, auditoria e rollback planejado.

### Não use Terraform quando

- Script one-off de migração de dados (use job Glue/Lambda com ciclo próprio).
- Configuração puramente runtime da aplicação (use Parameter Store + app).
- Recurso efêmero de debug local.

**Exceção:** bootstrap do backend Terraform pode ser script documentado + ADR — depois tudo via Terraform.

---

## Estrutura de repositório e pastas

```
terraform-{dominio}/
├── modules/
│   ├── lambda-processa/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── iam.tf
│   │   ├── monitoring.tf      # log group, alarmes, forward Datadog
│   │   ├── README.md
│   │   └── tests/
│   │       └── lambda_module.tftest.hcl
│   └── s3-data-lake/
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── hml/
│   └── prod/
├── versions.tf
├── .tflint.hcl
├── .github/workflows/terraform-ci.yml
└── docs/
    ├── adr/
    └── runbooks/
```

**Multi-repo:** módulos compartilhados entre domínios vivem em `terraform-modules-{nome-projeto}` consumidos via `source = "git::https://...?ref=v1.2.0"`.

---

## Padrões de código da stack

Índice rápido — detalhes neste capítulo:

| Tópico | Seção |
|--------|-------|
| Estrutura de pastas | [Estrutura de repositório](#estrutura-de-repositório-e-pastas) |
| Convenções e naming | [Convenções e naming](#convenções-e-naming) |
| Práticas / anti-padrões | [Práticas obrigatórias](#práticas-obrigatórias) · [Anti-padrões](#anti-padrões) |
| Exemplos | [Exemplos](#exemplos-bom-vs-ruim) |
| Testes | [Estratégia de testes](#estratégia-de-testes) |
| Observabilidade / segurança | [Observabilidade](#observabilidade-datadog) · [Segurança](#segurança) |
| Checklists | [Checklist de implementação](#checklist-de-implementação) |

Transversal: [03 — Padrões de código](03-padroes-de-codigo.md) · [18 — DoD](18-definition-of-done.md)

---

## Convenções e naming

### Recursos AWS

Padrão: `{nome-projeto}-{dominio}-{tipo}-{env}` (kebab-case).

| Recurso | Exemplo |
|---------|---------|
| Lambda | `{nome-projeto}-ingestao-arquivos-dev` |
| S3 bucket | `{nome-projeto}-datalake-bronze-prod` |
| IAM role | `{nome-projeto}-glue-etl-vendas-prod` |

### Arquivos Terraform

| Arquivo | Conteúdo |
|---------|----------|
| `main.tf` | Recursos principais |
| `variables.tf` | Inputs com `description` e `validation` |
| `outputs.tf` | Contratos para outros stacks |
| `iam.tf` | Políticas e roles |
| `monitoring.tf` | CloudWatch, integração Datadog |
| `locals.tf` | Composição e tags |

### Tags obrigatórias

```hcl
locals {
  default_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner_team
    CostCenter  = var.cost_center
    Repository  = "terraform-vendas"
  }
}
```

---

## Práticas obrigatórias

- [ ] `terraform fmt -check -recursive` em CI
- [ ] `terraform validate` em CI
- [ ] `terraform plan` em todo PR que altera `.tf`
- [ ] Variáveis com `type`, `description` e `validation` quando enum
- [ ] Outputs com `description`; `sensitive = true` quando necessário
- [ ] IAM sem `Action = "*"` / `Resource = "*"` sem ADR
- [ ] Backend remoto com lock
- [ ] Tags `default_tags` em provider AWS
- [ ] `tflint` e scan de segurança (`tfsec` ou `checkov`) em CI
- [ ] README no módulo: inputs, outputs, exemplo de uso
- [ ] Retenção de log group definida (não infinito por padrão)
- [ ] Criptografia em repouso (S3 SSE-KMS, RDS encryption)

---

## Práticas recomendadas

- `terraform test` para outputs e invariantes críticos
- `moved` blocks em refactors para evitar destroy/recreate
- `lifecycle { prevent_destroy = true }` em recursos críticos de prod (com cuidado)
- Data sources para ler recursos existentes em vez de duplicar IDs
- `depends_on` explícito apenas quando necessário (grafo implícito primeiro)
- Documentar dependência entre repos (stack A consome output de stack B)
- Alarmes CloudWatch encaminhados ao Datadog via integração AWS

---

## Anti-padrões

```hcl
# ❌ Wildcard sem ADR
resource "aws_iam_role_policy" "bad" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "*"
    }]
  })
}

# ❌ Secret em variável default ou output sem sensitive
output "db_password" {
  value = aws_db_instance.main.password
}

# ❌ Ambiente hardcoded no módulo
resource "aws_lambda_function" "x" {
  function_name = "minha-lambda-prod"  # quebra dev/hml
}

# ❌ State local commitado
# terraform.tfstate no repositório

# ❌ Provider sem version pin
terraform {
  required_providers {
    aws = {}  # versão flutuante
  }
}
```

---

## Exemplos (bom vs ruim)

### Variável com validação — bom

```hcl
variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  validation {
    condition     = contains(["dev", "hml", "prod"], var.environment)
    error_message = "environment deve ser dev, hml ou prod."
  }
}
```

### IAM restritiva — bom

```hcl
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
```

### Backend — bom

```hcl
terraform {
  backend "s3" {
    bucket         = "{nome-projeto}-terraform-state"
    key            = "vendas/dev/terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "{nome-projeto}-terraform-lock"
    encrypt        = true
  }
}
```

### terraform test — bom

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

---

## Estratégia de testes

| Camada | Ferramenta | O que valida | Onde roda |
|--------|------------|--------------|-----------|
| Estática | `fmt`, `validate`, `tflint` | Sintaxe, lint | CI em todo PR |
| Segurança | `tfsec`, `checkov` | Misconfig (bucket público, SG aberto) | CI |
| Contrato | `terraform test` | Outputs, count de recursos | CI |
| Integração | Terratest (opcional) | Deploy em conta efêmera | Pipeline noturno / release |

**Cobertura:** Terraform não usa line coverage — use **contract tests** de outputs e políticas IAM esperadas.

**Relação com outros capítulos:**

- Testes de **lógica de aplicação**: [10 — Testes unitários](10-testes-unitarios.md)
- Testes de **wiring real** (Lambda invocada, bucket criado): [11 — TaaC](11-taac-testes-integrados-na-pipeline.md)

---

## Observabilidade (Datadog)

Toda stack Terraform que provisiona compute ou pipelines deve incluir hooks de observabilidade:

| Recurso | O que provisionar | Datadog |
|---------|-------------------|---------|
| Lambda | `aws_cloudwatch_log_group` + retenção | Forwarder ou Lambda extension |
| API Gateway / ALB | Access logs | Log pipeline JSON |
| Glue job | Continuous logging | Métrica custom `glue.job.duration` |
| SQS DLQ | Alarme em `ApproximateNumberOfMessagesVisible` | Monitor Datadog |

```hcl
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days
  tags              = local.default_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda errors — ver runbook e Datadog"
  dimensions = {
    FunctionName = aws_lambda_function.main.function_name
  }
}
```

Detalhes: [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Área | Prática |
|------|---------|
| S3 | Lifecycle para Glacier/expire em bronze; Intelligent-Tiering quando volume alto |
| Lambda | Memory right-sizing; evitar over-provision em Terraform |
| Glue | `max_capacity` / worker type explícitos; alarme de DPU-hours |
| Logs | Retenção 7–30 dias dev; 30–90 prod conforme compliance |
| NAT Gateway | Avaliar VPC endpoints para S3/DynamoDB e reduzir tráfego NAT |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Least privilege IAM por recurso
- KMS customer-managed para dados sensíveis
- Block Public Access em buckets
- `aws_s3_bucket_public_access_block` sempre
- Secrets via Secrets Manager — referência por ARN, não valor
- State bucket com encryption e policy restritiva
- Sem credenciais AWS em variáveis de CI — OIDC ou role assumível

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

Por módulo (`README.md`):

- Propósito e diagrama simples
- Tabela de variáveis e outputs
- Exemplo de consumo em `envs/dev`
- Dependências de outros stacks
- Runbook linkado se recurso crítico

Por mudança destrutiva: ADR ou seção no PR. Template: [templates/readme-componente.md](templates/readme-componente.md).

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Módulo segue estrutura padrão (`main`, `variables`, `outputs`, `iam`, `monitoring`)
- [ ] Naming `{nome-projeto}-{dominio}-{tipo}-{env}`
- [ ] Tags obrigatórias aplicadas
- [ ] Backend e provider versionados
- [ ] IAM revisada (sem wildcard injustificado)
- [ ] Log group + alarme mínimo
- [ ] `terraform test` ou plan documentado
- [ ] README do módulo atualizado
- [ ] `terraform plan` anexado ao PR (dev/hml)

---

## Checklist de code review

- [ ] Plan mostra apenas mudanças esperadas (sem destroy surpresa)
- [ ] Novos recursos taggados
- [ ] IAM mínima necessária
- [ ] Sem secret em plain text
- [ ] Outputs necessários para consumidores downstream
- [ ] Retenção de logs e custo considerados
- [ ] Breaking change em output documentada
- [ ] Scan de segurança CI verde

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Runbook para falha de apply (lock preso, state corrupt)
- [ ] Monitor Datadog para alarmes provisionados
- [ ] Drift detection agendado (opcional, recomendado em prod)
- [ ] Backup de state habilitado no bucket
- [ ] Procedimento de rollback: `terraform apply` versão anterior ou revert PR

---

## Critérios de aceite

1. `terraform plan` em dev/hml sem erro e com diff explicado no PR.
2. CI: fmt, validate, lint, security scan verdes.
3. Módulo documentado com inputs/outputs.
4. IAM aprovada por revisor com contexto de segurança quando sensível.
5. Observabilidade mínima provisionada (logs + alarme).
6. Apply em prod somente após merge + pipeline de promoção.

---

## Definition of Done (tema Terraform)

- [ ] Código em `main` com apply bem-sucedido em hml
- [ ] Plan de prod revisado (se aplicável)
- [ ] Documentação e runbook atualizados
- [ ] Monitores Datadog validados em ambiente não-prod
- [ ] Consumidores de outputs notificados se contrato mudou
- [ ] DoD universal: [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**Posso usar `terraform apply` local em prod?**  
Não. Apply em prod via pipeline com aprovação manual e role restrita.

**Como versiono módulo compartilhado?**  
Git tags semver (`v1.2.0`); consumidores pinam `ref=v1.2.0`.

**E se precisar de `s3:*` temporariamente?**  
ADR com escopo, prazo de remediação e aprovação de segurança.

**Terratest é obrigatório?**  
Não. Obrigatório: validate + lint + security + plan. Terratest para módulos críticos e compartilhados.

**Como integro com outro repo de app?**  
Outputs deste stack → variáveis/Parameter Store do app; contrato documentado.

---

## Guia de uso para júnior

1. Clone o repo `terraform-{dominio}` e leia o README.
2. Configure AWS SSO: `aws sso login --profile dev`.
3. Em `envs/dev`: `terraform init && terraform plan`.
4. Alterações pequenas: comece pelo módulo, depois wire em `envs/dev`.
5. Rode localmente: `terraform fmt -recursive && terraform validate`.
6. Abra PR com plan colado; peça review de alguém que já aplicou naquele domínio.
7. Nunca aplique em prod no primeiro mês — observe o pipeline.

Onboarding completo: [20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Blast radius da mudança (destroy/recreate de stateful?)
- Acoplamento entre stacks e ordem de apply
- IAM: permissões que sobrevivem a escala (novos objetos no bucket?)
- Custo marginal (NAT, DPU, log ingestion Datadog)
- Idempotência e imports (`import` block) em migrações
- Compatibilidade com políticas de backup e DR
- Se a mudança exige TaaC no repo consumidor

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 02 | [Arquitetura transversal](02-arquitetura-transversal.md) |
| 03 | [Padrões de código](03-padroes-de-codigo.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 11 | [TaaC — testes integrados na pipeline](11-taac-testes-integrados-na-pipeline.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança, conformidade e dados sensíveis](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
