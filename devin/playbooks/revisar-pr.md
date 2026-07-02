# Playbook — Revisar PR

Prompt reutilizável para code review de pull requests contra o Engineering Handbook.

## Fonte de verdade

- [16 — Code review](../../docs/engineering-handbook/16-code-review.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Logging seguro](../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
- [Template code review](../../docs/engineering-handbook/templates/code-review.md)

---

## Nomenclatura de código

Ao implementar ou revisar código:

- Use português para identificadores internos criados pelo time.
- Preserve nomes externos, SDKs, frameworks, contratos públicos, schemas, comandos e tags técnicas.
- Não renomeie contrato público existente sem versionamento/migração.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).


## Prompt

```
Revise este pull request no ecossistema {nome-projeto}.

## Contexto
- PR: {URL ou diff}
- Repositório: {org}/{repo}
- Stack: {airflow | dbt | terraform | lambda | glue | spring-boot}
- Capítulo handbook: ../../docs/engineering-handbook/{NN}-{stack}.md
- PRs irmãos (multi-repo): {URLs ou "nenhum"}
- Objetivo declarado do autor: {copiar do PR}

## Instruções
1. Confirme se a CI está verde e se o escopo do diff corresponde ao objetivo.
2. Avalie as dimensões do [16 — Code review](../../docs/engineering-handbook/16-code-review.md):
   funcional, clareza, testes, segurança, performance, observabilidade, dados, ops, contratos, multi-repo.
3. Para código gerado por IA: deps reais, regra não inventada, estilo do vizinho, sem `except: pass`.
4. Verifique aderência ao [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md).
5. Revise logs no diff: [checklist de logging seguro](../../docs/engineering-handbook/13-observabilidade.md#checklist-de-logging-seguro) — sem payload, PII, credenciais; tags Datadog válidas.

## Classificação de severidade (obrigatória em cada achado)
- 🔴 **Bloqueio** — bug, segurança, perda de dados, contrato quebrado, CI vermelho ignorado
- 🟡 **Atenção** — fortemente recomendado; débito aceitável só com justificativa no PR
- 🟢 **Sugestão** — melhoria opcional, estilo, naming, refatoração não bloqueante

## Formato de saída
Use o template [code-review](../../docs/engineering-handbook/templates/code-review.md) com:

### Resumo
{1–3 frases: aprovável com ressalvas? / bloqueado?}

### Achados
| Severidade | Arquivo | Comentário |
|------------|---------|------------|
| 🔴 | ... | ... |
| 🟡 | ... | ... |
| 🟢 | ... | ... |

### Checklist DoD
- [ ] itens aplicáveis verificados

### Veredito
- [ ] Pronto para review humano (sem 🔴)
- [ ] Bloqueado — corrigir 🔴 antes do merge

**Você não aprova nem faz merge** — apenas pré-revisa para o revisor humano.
```

---

## Variáveis

| Variável | Exemplo |
|----------|---------|
| `{NN}-{stack}` | `04-airflow`, `07-lambda-python` |

## Quando usar

- Pré-review automatizado antes do humano
- PRs grandes ou multi-repo
- PRs com código gerado por IA
