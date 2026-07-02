---
name: revisar-codigo
description: Pré-revisar diff de PR contra handbook, DoD e checklist da stack. Não substitui aprovação humana.
disable-model-invocation: true
---

# Revisar código

## Quando usar

- Usuário pede explicitamente review de PR ou diff
- Pré-análise antes do review humano
- Auditoria de aderência ao handbook

**Não invocar automaticamente** — requer pedido explícito (`disable-model-invocation`).

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [16 — Code review](../../../docs/engineering-handbook/16-code-review.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)
- Capítulo da stack (04–09)
- [17 — Segurança](../../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Revisão: verificar se código novo segue identificadores internos em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Diff ou link PR | Sim | `gh pr diff 42` |
| Stack | Sim | Airflow, dbt, Lambda… |
| Repositório | Sim | `{nome-projeto}-airflow` |
| PRs irmãos | Se multi-repo | `terraform-#15`, `dbt-#8` |
| Contexto de negócio | Recomendado | Spec, ADR |

## Passos

1. Confirmar CI verde (ou listar falhas).
2. Classificar stack e carregar checklist DoD §2 correspondente.
3. Avaliar dimensões: funcional, clareza, testes, segurança, performance, observabilidade, dados, ops, contratos.
4. Verificar código gerado por IA (deps, regra inventada, mocks vazios).
5. Checar multi-repo: referências cruzadas e contratos alinhados.
6. Classificar cada achado: 🔴 bloqueio | 🟡 atenção | 🟢 sugestão.
7. Preencher [template code-review](../../../docs/engineering-handbook/templates/code-review.md).
8. **Não aprovar** — recomendar ação ao autor e revisor humano.

## Checklist de qualidade

- [ ] Aderência ao capítulo da stack
- [ ] Estilo do módulo vizinho
- [ ] Lógica de negócio fora de handler/DAG/Terraform indevido
- [ ] Documentação atualizada se contrato mudou

## Checklist de testes

- [ ] Cobertura ≥ 90% evidenciada
- [ ] Mutation/TaaC onde aplicável
- [ ] Asserts de comportamento

## Checklist de observabilidade

- [ ] Logs JSON, métricas Datadog
- [ ] Sem PII em log/tags
- [ ] Runbook/monitor se fluxo crítico novo

## Checklist de desempenho

- [ ] Volume e pico considerados
- [ ] Sem N+1 ou full scan evitável

## Checklist de segurança

- [ ] Least privilege IAM
- [ ] Sem segredo no diff
- [ ] Inputs validados

## Critérios de aceite

- Relatório estruturado com severidades
- Bloqueios justificados com link ao handbook
- Revisor humano ainda necessário para merge

## O que não fazer

- Aprovar ou "LGTM" como gate final
- Comentários vagos ("melhorar isso")
- Inventar requisito não documentado
- Ignorar impacto em dados/backfill

## Como reportar

Usar estrutura:

```markdown
## Resumo
[1–3 frases]

## 🔴 Bloqueios
- [arquivo:linha] descrição → [link handbook]

## 🟡 Atenção
- ...

## 🟢 Sugestões
- ...

## DoD
- [ ] item pendente

## Próximos passos
- Autor: ...
- Revisor humano: ...
```

## Fonte de verdade

- [16 — Code review](../../../docs/engineering-handbook/16-code-review.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)
- [Template — code-review](../../../docs/engineering-handbook/templates/code-review.md)
