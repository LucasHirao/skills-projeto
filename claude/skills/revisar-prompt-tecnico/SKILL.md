---
name: revisar-prompt-tecnico
description: Revisar briefing ou prompt de implementação antes da execução. Detecta ambiguidade, excesso de contexto e gaps de DoD.
disable-model-invocation: true
---

# Revisar prompt técnico

## Quando usar

- Antes de acionar Skill de implementação
- Briefing gerado pelo preparador precisa de segunda opinião
- Prompt parece longo, genérico ou arriscado
- Multi-repo sem ordem clara de deploy

**Não implementa código** — apenas revisa o prompt/briefing.

## Entradas esperadas

| Campo | Obrigatório |
|-------|-------------|
| Briefing ou prompt a revisar | Sim |
| Pedido original do usuário | Recomendado |
| Stack declarada | Sim |

## Checklist de revisão

Responder sim/não/parcial para cada item:

1. O objetivo está claro?
2. O escopo está delimitado?
3. O fora de escopo está explícito?
4. A stack está identificada?
5. O contexto mínimo está correto (sem capítulos extras)?
6. Há leitura excessiva de arquivos?
7. O prompt pede ler o handbook inteiro sem necessidade?
8. Existem regras de negócio inventadas?
9. Existem assunções não declaradas?
10. Existem dúvidas bloqueantes não resolvidas?
11. Os critérios de aceite são testáveis?
12. Os testes esperados foram definidos?
13. Observabilidade foi considerada (se fluxo novo/crítico)?
14. Segurança/dados sensíveis foram considerados?
15. O padrão de identificadores internos em português foi considerado?

## Classificação de achados

| Severidade | Quando usar |
|------------|-------------|
| 🔴 **Bloqueio** | Impede implementação segura (ambiguidade crítica, contrato inventado, escopo aberto, dados sensíveis ignorados) |
| 🟡 **Atenção** | Pode causar retrabalho (contexto excessivo, DoD incompleto, assunção frágil) |
| 🟢 **Sugestão** | Melhoria opcional (reduzir tokens, clarificar redação) |

## Formato de saída

```markdown
# Revisão de prompt

## Resumo
{aprovado | aprovado com ressalvas | bloqueado}

## Checklist
{tabela ou lista com ✅ / ⚠️ / ❌}

## Achados

### 🔴 Bloqueios
- ...

### 🟡 Atenções
- ...

### 🟢 Sugestões
- ...

## Contexto mínimo recomendado
{lista ajustada se necessário}

## Próximo passo
{voltar ao preparador | acionar Skill X | responder dúvidas}
```

## Regras

- Se houver 🔴, **não** recomendar implementação até correção
- Sugerir remoção de leituras desnecessárias com caminhos concretos
- Verificar aderência ao [21 — Agentes e prompts](../../../docs/engineering-handbook/21-agentes-e-prompts.md)
- Não adicionar requisitos de negócio não presentes no pedido original

## Nomenclatura de código

- Prompt deve exigir português para identificadores internos novos
- Alertar se o prompt pede renomear contrato público sem versionamento
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)

## Fonte de verdade

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)
- [19 — Padrões para uso de IA](../../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
- [21 — Agentes e prompts](../../../docs/engineering-handbook/21-agentes-e-prompts.md)
