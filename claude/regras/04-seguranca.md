# Segurança

## Escopo

IAM, segredos, dados sensíveis e conformidade em `{nome-projeto}-*`.

## Princípios

- **Least privilege** — IAM sem `*` sem ADR
- Segredos em Secrets Manager/SSM — nunca em código, state ou Variable do Airflow
- Validar inputs na borda (API, Lambda, eventos)
- Scan de dependências e IaC sem bloqueio não justificado

## Dados sensíveis

- Não logar PII; mascarar em métricas e traces
- Não colar dados reais em prompts de IA
- Classificar dados conforme política do time

## Infraestrutura

- `sensitive` no Terraform para outputs secretos
- tfsec/checkov sem HIGH/CRITICAL não justificado
- State remoto com lock e criptografia

## Anti-padrões

- Credencial em repositório ou `terraform.tfvars` commitado
- Permissão ampla "para funcionar"
- Bypass de scan na CI sem justificativa
- Expor endpoint interno sem autenticação documentada

## Fonte de verdade

- [17 — Segurança, conformidade e dados sensíveis](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [06 — Terraform](../../docs/engineering-handbook/06-terraform.md) (IAM)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md) (§1.6)
