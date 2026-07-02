---
name: revisar-documentacao-funcional
description: Revisar documentação funcional para clareza, completude, acessibilidade e ausência de dados sensíveis.
disable-model-invocation: true
---

# Revisar documentação funcional

## Quando usar

- Antes de publicar documentação funcional extraída por IA
- Revisão periódica de processo crítico
- Após incidente causado por mal-entendido de regra

**Não invocar automaticamente** — requer pedido explícito.

## Entradas esperadas

| Campo | Obrigatório |
|-------|-------------|
| Documento a revisar | Sim |
| Material fonte (se houver) | Recomendado |
| Validador esperado | Recomendado |

## Checklist de revisão

1. Está compreensível para pessoa nova?
2. Tem resumo simples?
3. Escopo e fora de escopo estão claros?
4. Fluxo principal está completo?
5. Regras funcionais estão testáveis (ou marcadas como não testáveis)?
6. Exceções estão documentadas?
7. Glossário cobre termos importantes?
8. Há dados reais ou sensíveis expostos?
9. Fatos, assunções e dúvidas estão separados?
10. Há owner e data de revisão?
11. Há pontos que precisam validação humana listados?
12. Dados sensíveis alinhados ao [logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)?

## Classificação de achados

| Severidade | Quando usar |
|------------|-------------|
| 🔴 **Bloqueio** | Dado real exposto; regra inventada apresentada como fato; lacuna crítica de escopo |
| 🟡 **Atenção** | Ambiguidade, glossário incompleto, assunção não marcada |
| 🟢 **Sugestão** | Melhoria de redação, FAQ, diagrama |

## Formato de saída

```markdown
# Revisão de documentação funcional

## Resumo
{aprovado | aprovado com ressalvas | bloqueado}

## Checklist
{itens com ✅ / ⚠️ / ❌}

## Achados

### 🔴 Bloqueios
### 🟡 Atenções
### 🟢 Sugestões

## Próximo passo
{publicar | voltar ao extrator | validar com especialista X}
```

## Nomenclatura de código

- Revisar se exemplos técnicos usam identificadores internos em português quando citam código
- Alertar se documentação incentiva log de payload ou PII
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)

## O que não fazer

- Aprovar documento com dado real
- Adicionar regra de negócio não presente no material fonte
- Substituir validação humana do especialista

## Fonte de verdade

- [22 — Documentação funcional](../../../docs/engineering-handbook/22-documentacao-funcional.md)
- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [17 — Segurança](../../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
