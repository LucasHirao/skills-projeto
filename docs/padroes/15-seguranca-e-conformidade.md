# Segurança e conformidade

## Princípios

1. **Least privilege** — IAM, roles, scopes mínimos.
2. **Segredos fora do código** — Secrets Manager, Parameter Store, CI secrets.
3. **Dados sensíveis** — mascarar em log, hash quando necessário para rastreio.
4. **Criptografia** — em trânsito (TLS) e repouso (KMS) por padrão.
5. **Auditoria** — trilha de quem processou o quê e quando.

## Checklist

- [ ] Inputs validados na borda
- [ ] Endpoints com autenticação/autorização
- [ ] Sem `*` em IAM sem ADR
- [ ] Dependências com scan (Dependabot, Snyk, etc.)
- [ ] Infra com tfsec/checkov
- [ ] Retenção de logs conforme política
- [ ] Arquivos/dados só em buckets/paths aprovados

## Logs

```python
# ❌
logger.info(f"cpf={usuario.cpf}")

# ✅
logger.info("usuario_processado", extra={"user_id_hash": hash_id(usuario.id)})
```

## Uso de IA

- Não colar dados sensíveis/reais em prompts.
- Agente **não inventa** regra regulatória — escalar para humano.
- Revisar código gerado como qualquer contribuição.
- Manter trilha (ADR, PR description) de decisões.

## Exceções

Integração legada sem TLS: documentar em ADR com mitigação (private link, IP allowlist) e prazo de remediação.

## Auditoria e rastreabilidade

Registrar em log ou tabela de auditoria (quando aplicável):

- `correlation_id` / `run_id`
- `processed_at`, `component`, `record_count`
- `data_referencia` ou chave de negócio hasheada

## Classificação de dados / PII

| Classificação | Em logs | Em dbt/export |
|---------------|---------|---------------|
| Público | OK | OK |
| Interno | OK sem payload completo | OK |
| Confidencial | Hash/mascarar | Colunas mascaradas ou excluídas |
| Restrito | Não logar | ADR + controle de acesso |

## Dependency scan

- Habilitar Dependabot/Snyk no repositório.
- CVE crítico/alto: bloquear merge até patch ou ADR de mitigação.

## Referências

- `04-terraform.md` — IAM
- `05-lambda-python.md` — secrets
- `11-observabilidade.md` — mascaramento em logs
