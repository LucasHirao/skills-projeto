# Playbook — Extrair documentação funcional

Transforma conversa, notas ou transcrição em documentação funcional estruturada. **Não altera código.**

## Fonte de verdade

- [22 — Documentação funcional](../../docs/engineering-handbook/22-documentacao-funcional.md)
- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [17 — Segurança](../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Logging seguro](../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
- [Template documentação funcional](../../docs/engineering-handbook/templates/documentacao-funcional.md)

---

## Nomenclatura de código

- Prosa e exemplos em português; dados **sempre sintéticos**
- Não incluir CPF, CNPJ, nome, conta, e-mail, telefone ou payload real
- Se citar campos de log, usar allowlist — ver cap. 13
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).

---

## Prompt

```
Você extrai documentação funcional a partir de material informal.
Você NÃO altera código nem abre PR em repositório de aplicação.

## Material bruto
{colar transcrição, notas, bullets}

## Contexto
- Processo: {nome}
- Owner esperado: {time/pessoa ou desconhecido}
- Validador de negócio: {nome/time ou desconhecido}
- Público-alvo: {negócio | operação | engenharia | misto}

## Processo obrigatório
1. Classifique trechos: fato confirmado | assunção | dúvida | decisão.
2. Se confiança < 90% ou regra ambígua: liste perguntas objetivas ANTES do documento final.
3. Sanitize: substitua qualquer dado real por exemplo sintético (LOTE-0001, hash fictício).
4. Preencha o template documentacao-funcional.md.
5. Sugira glossário e fluxo funcional se aplicável.
6. Separe pontos para validação humana.

## Regras
- Não invente regra de negócio.
- Não promova assunção a fato sem validador.
- Linguagem acessível para pessoa nova.
- Owner e data de última revisão no documento.

## Formato de saída

# Documentação funcional — {processo}

## Resumo simples
## Fluxo principal
## Regras funcionais
## Exceções
## Glossário
## Dados sensíveis e cuidados
## Fatos confirmados
## Assunções
## Dúvidas abertas
## Pontos para validação humana
```

---

## Quando usar

- Após reunião com especialista de negócio
- Notas soltas que precisam virar doc permanente
- Antes de playbook `implementar-feature` quando regra não está escrita

## Próximo passo

Revisar com [revisar-documentacao-funcional.md](revisar-documentacao-funcional.md) antes de publicar.
