# Playbook — Revisar documentação funcional

Revisa documentação funcional para clareza, completude, acessibilidade e segurança. **Não altera código.**

## Fonte de verdade

- [22 — Documentação funcional](../../docs/engineering-handbook/22-documentacao-funcional.md)
- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Logging seguro](../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)

---

## Nomenclatura de código

- Verificar ausência de dados reais e sensíveis no texto
- Alertar se doc incentiva log de payload ou PII
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).

---

## Prompt

```
Você revisa documentação funcional ANTES de publicação.
Você NÃO altera código.

## Documento a revisar
{colar markdown}

## Material fonte (opcional)
{transcrição ou notas originais}

## Verificações obrigatórias
1. Compreensível para pessoa nova?
2. Resumo simples presente?
3. Escopo e fora de escopo claros?
4. Fluxo principal completo?
5. Regras funcionais testáveis ou marcadas?
6. Exceções documentadas?
7. Glossário adequado?
8. Dados reais ou sensíveis expostos? (CPF, CNPJ, nome, conta, e-mail, telefone, payload)
9. Fatos, assunções e dúvidas separados?
10. Owner e data de revisão?
11. Pontos para validação humana listados?
12. Alinhamento com logging seguro (sem incentivar payload/PII em log)?

## Classifique achados
- 🔴 Bloqueio
- 🟡 Atenção
- 🟢 Sugestão

## Formato de saída

# Revisão de documentação funcional

## Resumo
## Checklist
## Achados (🔴 / 🟡 / 🟢)
## Próximo passo

Se houver 🔴, recomende NÃO publicar até correção e validação humana.
```

---

## Quando usar

- Após [extrair-documentacao-funcional.md](extrair-documentacao-funcional.md)
- Revisão trimestral de processo crítico
- Antes de vincular doc em PR de implementação

## Próximo passo

Publicar em `docs/` do repositório adequado após aprovação do validador humano.
