# Code Review

## Objetivo

Garantir correção, segurança, operabilidade e aderência aos padrões deste repositório antes do merge.

## Dimensões do review

| Dimensão | Pergunta central |
|----------|------------------|
| Funcional | Faz o que deveria nos casos limite? |
| Clareza | Outro dev entende em 15 min? |
| Testes | 90% cov + casos relevantes? |
| Segurança | Least privilege, sem segredo, input validado? |
| Performance | Aguenta volume esperado? |
| Observabilidade | Dá para debugar em prod? |
| Dados | Impacto em schema, backfill, qualidade? |
| Ops | Rollback, alerta, runbook? |
| Contratos | Breaking change explícito? |
| Feature flags | Rollout, default e rollback documentados? |

## Código gerado por IA — atenção redobrada

- [ ] Dependências existem no projeto?
- [ ] Regra de negócio não foi inventada?
- [ ] Testes assertam comportamento real?
- [ ] Erros não são `except Exception: pass`?
- [ ] Segue padrões do módulo mais próximo?

## Severidade de comentários

| Nível | Significado |
|-------|-------------|
| 🔴 Bloqueio | Deve corrigir antes do merge |
| 🟡 Atenção | Fortemente recomendado |
| 🟢 Sugestão | Opcional |

## Exemplos de comentários

**Bloqueio:**
> Regra de cálculo no handler Lambda impede teste unitário. Extrair para `domain/` conforme `05-lambda-python.md`.

**Atenção:**
> Incremental sem `unique_key` documentado — risco de duplicata em reprocessamento.

**Sugestão:**
> Considerar renomear `process_data` para `normalizar_pedidos_vendas`.

## Checklists por tecnologia

| Stack | Arquivo |
|-------|---------|
| Airflow | `checklists/code-review-airflow.md` |
| dbt | `checklists/code-review-dbt.md` |
| Terraform | `checklists/code-review-terraform.md` |
| Lambda Python | `checklists/code-review-lambda-python.md` |
| Java Spring Boot | `checklists/code-review-java-spring-boot.md` |
| Glue | `checklists/code-review-glue.md` |
| Testes | `checklists/code-review-testes.md` |
| Observabilidade | `checklists/code-review-observabilidade.md` |
| Performance | `checklists/code-review-performance.md` |

Template de review: `docs/padroes/templates/template-code-review.md`.

## Skill

Use `.claude/skills/revisar-pr/` para workflow estruturado.
