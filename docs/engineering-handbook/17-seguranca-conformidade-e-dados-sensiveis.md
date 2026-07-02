# 17 — Segurança, conformidade e dados sensíveis

Segurança não é camada final — é requisito em **código, infra, dados, logs e uso de IA**.

---

## 1. Princípios

| # | Princípio | Aplicação |
|---|-----------|-----------|
| 1 | **Least privilege** | IAM, roles, scopes mínimos necessários |
| 2 | **Segredos fora do código** | Secrets Manager, SSM Parameter Store, CI secrets |
| 3 | **Dados sensíveis protegidos** | Mascarar em log; hash para rastreio; controle de acesso |
| 4 | **Criptografia** | TLS em trânsito; KMS em repouso (S3, RDS, DynamoDB) |
| 5 | **Auditoria** | Trilha de quem processou o quê, quando, com `correlation_id` |
| 6 | **Defesa em profundidade** | Validação na borda + autorização + monitoramento |
| 7 | **Fail secure** | Em dúvida, negar acesso; não expor stack trace ao cliente |

---

## 2. Classificação de dados

| Classificação | Exemplos | Em logs | Em dbt/export | Retenção |
|---------------|----------|---------|---------------|----------|
| **Público** | Dados agregados publicáveis | OK | OK | Política padrão |
| **Interno** | Métricas operacionais, IDs internos | OK sem payload completo | OK | Política padrão |
| **Confidencial** | PII, contratos, salários | Hash/mascarar | Colunas mascaradas ou excluídas | Mínima necessária |
| **Restrito** | Saúde, financeiro regulado, credenciais | **Não logar** | ADR + controle de acesso + criptografia | Legal/compliance |

**PII comum:** CPF, CNPJ, nome completo, e-mail, telefone, endereço, IP, biometria, dados de saúde.

---

## 3. Dados sensíveis em logs e telemetria

```python
# ❌ Proibido
logger.info(f"cpf={usuario.cpf}, email={usuario.email}")

# ✅ Correto
logger.info(
    "usuario_processado",
    extra={
        "user_id_hash": hash_sha256(usuario.id),
        "operation": "processar_cadastro",
        "status": "SUCCESS",
    },
)
```

| Dado | Em log | Em tag Datadog |
|------|--------|----------------|
| CPF/CNPJ | Hash ou máscara (`***.456.789-**`) | **Nunca** |
| E-mail | Hash ou domínio apenas | **Nunca** |
| S3 key com PII | Prefixo de bucket apenas | Baixa cardinalidade OK |
| Payload de API | **Nunca** completo | — |
| Token/senha | **Nunca** | **Nunca** |

**Datadog:** habilitar Sensitive Data Scanner nos pipelines de log.

---

## 4. Checklist de segurança no PR

- [ ] Inputs validados na borda (tipo, tamanho, formato, allowlist)
- [ ] Autenticação e autorização em endpoints expostos
- [ ] Sem `*` em IAM sem ADR de exceção
- [ ] Segredos em Secrets Manager / SSM — não em código ou TF plain text
- [ ] Dependências sem CVE **crítico/alto** não mitigado
- [ ] Infra com tfsec/checkov na CI
- [ ] Retenção de logs conforme política (prod vs dev)
- [ ] Arquivos/dados só em buckets e paths aprovados
- [ ] Criptografia KMS em buckets e databases sensíveis
- [ ] PII mascarada ou excluída em exports e logs

---

## 5. IAM e Terraform

```hcl
# ❌ Evitar
Action   = "*"
Resource = "*"

# ✅ Escopo mínimo
Action   = ["s3:GetObject", "s3:PutObject"]
Resource = "${aws_s3_bucket.datalake.arn}/vendas/incoming/*"
```

- Roles por serviço — não compartilhar role genérica entre Lambdas.
- Condições `aws:SourceArn`, `aws:PrincipalTag` quando aplicável.
- Revisar policy em todo PR Terraform que toca IAM.

Ver [06 — Terraform](06-terraform.md).

---

## 6. Aplicações (Lambda e Spring)

| Controle | Lambda | Spring |
|----------|--------|--------|
| Secrets | `DD_API_KEY` via Secrets Manager | Vault / SSM / Secrets Manager |
| Input | Pydantic / validação explícita | Bean Validation `@Valid` |
| Auth | API Gateway authorizer / IAM | Spring Security, OAuth2 |
| Erro ao cliente | Mensagem genérica; detalhe só em log | `@ControllerAdvice` sem stack leak |
| Dependências | `pip audit`, Dependabot | OWASP dependency-check, Dependabot |

---

## 7. Dados em pipelines (dbt, Glue, Airflow)

| Risco | Mitigação |
|-------|-----------|
| PII em mart público | Mascarar na camada `staging` ou `intermediate` |
| Bucket público | `block_public_acls = true` — sempre |
| Cross-account | ADR + bucket policy explícita |
| Reprocessamento | Não copiar PII para ambiente de dev sem anonimização |
| Lineage | Documentar colunas sensíveis no `schema.yml` |

---

## 8. Dependency e IaC scan

| Scan | Quando bloqueia merge |
|------|----------------------|
| Dependabot / Snyk | CVE crítico/alto sem patch ou ADR |
| `pip audit` / `npm audit` | Idem |
| tfsec / checkov | HIGH/CRITICAL sem exceção documentada |
| Secret scan (gitleaks) | Qualquer segredo detectado |

**Exceção temporária:** ADR com mitigação, prazo de remediação e owner.

---

## 9. Auditoria e rastreabilidade

Registrar em log estruturado ou tabela de auditoria:

| Campo | Descrição |
|-------|-----------|
| `correlation_id` / `run_id` | Rastreio ponta a ponta |
| `processed_at` | Timestamp UTC |
| `component` | Quem processou |
| `actor` | Usuário/sistema que disparou (se aplicável) |
| `record_count` | Volume processado |
| `data_referencia` | Partição de negócio |
| `business_key_hash` | Chave hasheada — nunca PII clara |

Retenção alinhada à política legal — não manter PII em log além do necessário.

---

## 10. Uso de IA e agentes

| Regra | Detalhe |
|-------|---------|
| Não colar dados reais/sensíveis em prompts | Usar fixtures anonimizadas |
| Agente não inventa regra regulatória | Escalar para humano / compliance |
| Código gerado = contribuição normal | Review + testes + DoD |
| Trilha de decisão | ADR, PR description, plano de implementação |
| Skills derivadas do handbook | Sem segredos embutidos em rules |

Ver [19 — Padrões para uso de IA](19-padroes-para-uso-de-ia.md).

---

## 11. Exceções e legado

Integração legada sem TLS, bucket sem KMS ou IAM amplo:

1. Documentar em **ADR** com justificativa de negócio.
2. Mitigação compensatória (private link, IP allowlist, VPC endpoint).
3. **Prazo** de remediação com issue rastreável.
4. Aprovação de tech lead + segurança/compliance quando restrito.

---

## 12. Resposta a incidente de dados

1. Conter (revogar credencial, bloquear acesso).
2. Avaliar escopo (quais dados, quantos registros, quem afetado).
3. Notificar conforme política interna e legal.
4. Postmortem com ações corretivas.
5. Atualizar runbook e controles.

---

## 13. Referências

- [13 — Observabilidade](13-observabilidade.md) — mascaramento em logs e tags
- [06 — Terraform](06-terraform.md) — IAM
- [07 — Lambda Python](07-lambda-python.md) — secrets
- [16 — Code review](16-code-review.md)
- [18 — Definition of Done](18-definition-of-done.md)
