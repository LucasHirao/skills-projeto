---
name: revisar-codigo
description: Revisa pull requests contra o Manual de Engenharia do {nome-projeto}, classificando achados em bloqueio, atenção e sugestão, incluindo nomenclatura em português para código interno.
allowed-tools: read, grep, glob, bash
argument-hint: "{url ou diff do PR} {stack — ex. airflow, dbt, lambda}"
triggers:
  - revisar pr
  - code review
  - revisar pull request
  - revisar diff
  - revisar codigo
---

# revisar-codigo

## Fonte de verdade

- [16 — Code review](../../docs/engineering-handbook/16-code-review.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- Capítulo da stack: [04](../../docs/engineering-handbook/04-airflow.md)–[09](../../docs/engineering-handbook/09-aws-glue.md)

## Quando usar

- Pré-review antes do humano aprovar
- Auditoria de PR gerado por IA
- Review multi-repo com PRs irmãos

## Passos

1. Identificar stack e repos tocados; ler descrição do PR e PRs relacionados.
2. Verificar CI verde e escopo vs objetivo.
3. Avaliar dimensões: funcional, testes, segurança, dados, performance, observabilidade, contratos, ops.
4. Classificar **cada achado** com severidade:
   - 🔴 **Bloqueio** — bug, segurança, perda de dados, contrato quebrado
   - 🟡 **Atenção** — fortemente recomendado; débito só com justificativa
   - 🟢 **Sugestão** — melhoria opcional, estilo, naming
5. Usar template de code review; não aprovar — humano decide merge.
6. Checar código gerado por IA (deps reais, regra não inventada, estilo vizinho).

## Checklist DoD (recorte)

- [ ] Cobertura e testes adequados à mudança
- [ ] Impacto em dados (idempotência, backfill, schema)
- [ ] Logs/métricas sem PII
- [ ] Breaking change explícito se houver
- [ ] Multi-repo: PRs irmãos referenciados

## Templates

- [code-review](../../docs/engineering-handbook/templates/code-review.md)
- [pr](../../docs/engineering-handbook/templates/pr.md)

## Não fazer

- Aprovar ou fazer merge
- Inventar regra de negócio não documentada
- Duplicar checklist completo do handbook — apontar links
