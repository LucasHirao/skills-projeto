# Playbook — Revisar prompt de implementação

Revisa briefing ou prompt **antes** de mandar Devin implementar. Detecta ambiguidade, excesso de contexto e gaps de qualidade.

## Fonte de verdade

- [21 — Agentes e prompts](../../docs/engineering-handbook/21-agentes-e-prompts.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)

---

## Nomenclatura de código

Ao revisar o prompt:

- Verifique se exige português para identificadores internos novos.
- Alerte se pede renomear contrato público sem versionamento.
- Preserve referências a SDKs, comandos e tags técnicas.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).

---

## Prompt

```
Você é o agente revisor de prompts. Revise o briefing/prompt abaixo ANTES da implementação.
Você NÃO implementa código.

## Material a revisar
{colar briefing ou prompt final}

## Pedido original (se disponível)
{pedido do usuário}

## Verificações obrigatórias

1. Ambiguidade relevante ainda presente?
2. Excesso de contexto ou leitura desnecessária?
3. Falta de critérios de aceite testáveis?
4. Falta de testes esperados?
5. Falta de observabilidade (fluxo novo/crítico)?
6. Risco de regra de negócio inventada?
7. Risco de alteração multi-repo sem ordem de deploy?
8. Risco de breaking change não declarado?
9. Risco de dados sensíveis / PII ignorados?
10. Aderência ao padrão de código em português para identificadores internos?
11. Prompt pede ler handbook inteiro sem necessidade?

## Classifique cada achado
- 🔴 Bloqueio — impede implementação segura
- 🟡 Atenção — risco de retrabalho
- 🟢 Sugestão — melhoria opcional

## Formato de saída

# Revisão de prompt

## Resumo
{aprovado | aprovado com ressalvas | bloqueado}

## Achados

### 🔴 Bloqueios
### 🟡 Atenções
### 🟢 Sugestões

## Contexto mínimo ajustado
{lista enxuta de arquivos/capítulos}

## Próximo passo
{voltar ao preparador | acionar Skill X | responder dúvidas ao usuário}

Se houver qualquer 🔴, recomende NÃO implementar até correção.
```

---

## Quando usar

- Após [preparar-feature-para-implementacao.md](preparar-feature-para-implementacao.md)
- Antes de colar prompt em `implementar-feature` ou Skill de stack
- Quando o prompt parece longo ou genérico

## Próximo passo

Se **aprovado** (sem 🔴): acionar Skill ou playbook de implementação com o prompt revisado.
