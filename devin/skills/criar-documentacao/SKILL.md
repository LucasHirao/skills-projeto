---
name: criar-documentacao
description: Criar ou atualizar documentação de componentes {nome-projeto} — README, runbook, ADR e corpo de PR.
---

# Criar documentação

## Quando usar

- Novo serviço, job, Lambda, módulo Terraform ou DAG
- Mudança de contrato, operação ou comportamento
- Pós-incidente (runbook) ou decisão arquitetural (ADR)

## Pré-leitura

- [15 — Documentação](../../docs/engineering-handbook/15-documentacao.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md) §1.3
- Capítulo da stack, se aplicável

## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Tipo de doc | Sim | README, runbook, ADR, PR |
| Componente | Sim | `processar_vendas_diario` |
| Repositório | Sim | `{nome-projeto}-airflow` |
| Mudança | Sim | Novo schedule e idempotência |
| Template | Sim | Ver tabela em cap. 15 |

## Passos

1. Escolher template correto (readme, runbook, adr, pr, etc.).
2. Responder as 7 perguntas do cap. 15: o quê, por quê, como roda, testa, opera, debuga, contratos.
3. Comandos copy-paste testáveis (local, CI, deploy).
4. Links para ADRs, dashboard Datadog, PRs irmãos.
5. Documentar idempotência, reprocessamento e rollback.
6. Para APIs: OpenAPI atualizado.
7. Para DAGs: `doc_md` + README se necessário.
8. Revisar prosa em português BR; identificadores técnicos conforme contrato.
9. Incluir no corpo do PR usando [template pr](../../docs/engineering-handbook/templates/pr.md).

## Checklist de qualidade

- [ ] Completo sem depender de conhecimento oral
- [ ] Atualizado na mesma PR da mudança de código
- [ ] Links relativos válidos

## Checklist de testes

- [ ] Seção "como testar" com comandos verificados
- [ ] TaaC/README de integração se aplicável

## Checklist de observabilidade

- [ ] Como debugar no Datadog (`correlation_id`, dashboard)
- [ ] Monitores e runbooks linkados

## Checklist de desempenho

- [ ] Volume esperado e limites documentados
- [ ] Timeout/retry descritos

## Checklist de segurança

- [ ] Sem segredos ou PII em exemplos
- [ ] Classificação de dados se relevante

## Critérios de aceite

- DoD §1.3 em [18](../../docs/engineering-handbook/18-definition-of-done.md)
- Outro dev opera o componente em 15 min só com a doc

## O que não fazer

- "Documentar depois do merge"
- README genérico sem comandos do projeto
- ADR para decisão trivial
- Duplicar handbook inteiro no README

## Como reportar

- Lista de arquivos de doc criados/alterados
- Checklist das 7 perguntas (preenchido/não aplicável)
- Links para templates usados

## Fonte de verdade

- [15 — Documentação](../../docs/engineering-handbook/15-documentacao.md)
- [Templates](../../docs/engineering-handbook/templates/)
