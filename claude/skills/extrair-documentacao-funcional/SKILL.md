---
name: extrair-documentacao-funcional
description: Transformar conversa, notas ou transcrição em documentação funcional estruturada. Não altera código.
---

# Extrair documentação funcional

## Quando usar

- Especialista explicou processo em reunião, chat ou notas soltas
- Conhecimento tácito precisa virar documentação acessível
- Antes de implementar feature que depende de regra de negócio
- Onboarding de domínio novo

**Não usar** para implementar código ou alterar repositórios de aplicação.

## Entradas esperadas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Material bruto | Sim | Transcrição, bullets, áudio transcrito |
| Nome do processo | Sim | `Carga diária de arquivos de vendas` |
| Owner/validador | Recomendado | Squad negócio-vendas |
| Público-alvo | Recomendado | Operação + engenharia |
| Repositório de docs | Se conhecido | `{nome-projeto}-docs` |

## Perguntas que a IA deve fazer

Quando informação estiver ausente ou ambígua:

1. Qual o **início e fim** do processo (escopo)?
2. Quais **entradas** e **saídas** (formato, origem, destino)?
3. Qual o **fluxo feliz** passo a passo?
4. Quais **regras funcionais** são obrigatórias?
5. Quais **exceções** existem?
6. Quais **dados são sensíveis** e como tratar em exemplos?
7. Quem **valida** fatos de negócio (nome/time)?
8. Há **conflito** entre versões contadas por pessoas diferentes?

## Quando perguntar antes de gerar documento

- Regra funcional ambígua ou contraditória
- Entrada/saída não clara
- Termos desconhecidos sem definição
- Risco de incluir dado sensível no texto
- Conflito entre versões do processo
- Owner ou validador não definido
- Confiança < 90% (ver [21 — Agentes e prompts](../../../docs/engineering-handbook/21-agentes-e-prompts.md))

## Processo

1. Ler material bruto **uma vez** — não inventar regra.
2. Classificar trechos: fato · assunção · dúvida · decisão.
3. Sanitizar: remover ou substituir qualquer dado real por exemplo sintético.
4. Preencher [template documentação funcional](../../../docs/engineering-handbook/templates/documentacao-funcional.md).
5. Gerar ou sugerir [glossário](../../../docs/engineering-handbook/templates/glossario-funcional.md) e [fluxo](../../../docs/engineering-handbook/templates/fluxo-funcional.md) se aplicável.
6. Listar **pontos para validação humana** explicitamente.

## Como evitar dados sensíveis

- Nunca copiar CPF, CNPJ, nome, conta, agência, e-mail, telefone ou payload real
- Usar `LOTE-0001`, `CLIENTE-SINTETICO-01`, `hash:sha256:...`
- Em “dados envolvidos”, classificar sem valor real
- Alinhar auditoria com [logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)

## Formato de saída

```markdown
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

Incluir **Owner** e **Última revisão** (data atual como rascunho).

## Nomenclatura de código

- Documentação funcional: prosa em português; exemplos sintéticos
- Se mencionar campos técnicos de log, usar allowlist (`correlation_id`, `operation`, `status`) — nunca payload
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)

## O que não fazer

- Inventar regra de negócio
- Promover assunção a fato sem validador
- Incluir dados reais “para ilustrar”
- Alterar código ou abrir PR em repo de aplicação sem pedido explícito

## Fonte de verdade

- [22 — Documentação funcional](../../../docs/engineering-handbook/22-documentacao-funcional.md)
- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [17 — Segurança](../../../docs/engineering-handbook/17-seguranca-conformidade-e-dados-sensiveis.md)
- [13 — Logging seguro](../../../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis)
- [Template — documentação funcional](../../../docs/engineering-handbook/templates/documentacao-funcional.md)
