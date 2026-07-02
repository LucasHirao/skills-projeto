# Playbook — Preparar feature para implementação

Transforma solicitação vaga em **briefing técnico** e, se confiança ≥ 90%, em prompt de implementação. **Não implementa código** nesta etapa.

## Fonte de verdade

- [21 — Agentes e prompts](../../docs/engineering-handbook/21-agentes-e-prompts.md)
- [19 — Padrões para uso de IA](../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)

---

## Nomenclatura de código

Ao montar o briefing e o prompt final:

- Use português para identificadores internos criados pelo time.
- Preserve nomes externos, SDKs, frameworks, contratos públicos, schemas, comandos e tags técnicas.
- Não invente nomes de contrato ou regra de negócio.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).

---

## Prompt

```
Você é o agente preparador. Sua função é transformar um pedido informal em briefing técnico implementável.
Você NÃO implementa código nesta etapa.

## Pedido bruto
{colar pedido do usuário}

## Informações conhecidas (preencher o que houver)
- Repositório(s): {org}/{repo} ou desconhecido
- Stack provável: {airflow | dbt | terraform | lambda | glue | spring-boot | misto | desconhecido}
- Paths: {caminhos ou desconhecido}
- Restrições: {sem PII, sem breaking change, etc.}
- Prazo/objetivo: {opcional}

## Processo obrigatório

1. Leia APENAS o README do repositório alvo (se URL/path fornecido). Não leia o handbook inteiro.
2. Classifique a tarefa: implementação | revisão | investigação | documentação | refatoração | teste | observabilidade | performance.
3. Identifique stack principal.
4. Selecione contexto mínimo:
   - Skill Devin correspondente (ex.: criar-dag-airflow) OU playbook implementar-feature se multi-repo amplo
   - Capítulo da stack (04–09) — UM capítulo se stack única
   - ../../docs/engineering-handbook/03-padroes-de-codigo.md
   - ../../docs/engineering-handbook/18-definition-of-done.md
   - Capítulos extras SOMENTE se necessário (13, 17, 11)
5. Avalie ambiguidade: negócio, contrato, repo, I/O, aceite, breaking change, dados sensíveis.
6. Calcule confiança (heurística cap. 21). Se < 90%, liste perguntas objetivas e PARE antes do prompt de implementação.
7. Se ≥ 90%, gere briefing completo + prompt final enxuto.

## Regras
- Nunca peça para ler todo o handbook se a tarefa é de uma stack.
- Referencie caminhos; não cole capítulos inteiros.
- Não invente regra de negócio.
- Separe: escopo | fora de escopo | assunções | dúvidas | critérios de aceite.
- Identificadores internos novos em português (cap. 03).

## Formato de saída

# Briefing técnico

## Classificação da tarefa
## Stack principal
## Objetivo
## Escopo
## Fora de escopo
## Contexto mínimo que o agente deve ler
## Repositórios/arquivos envolvidos
## Regras conhecidas
## Assunções
## Dúvidas bloqueantes
## Critérios de aceite
## Testes esperados
## Observabilidade esperada
## Riscos
## Skill ou playbook recomendado para implementação
## Prompt final para implementação
(somente se confiança ≥ 90%; caso contrário, omitir e aguardar respostas)
```

---

## Variáveis

| Variável | Exemplo |
|----------|---------|
| `{org}` | `minha-org` |
| `{repo}` | `vendas-airflow` |
| `{nome-projeto}` | `vendas` |

## Quando usar

- Pedido informal antes de acionar `implementar-feature` ou Skill de stack
- Feature nova com escopo ainda não fechado
- Economizar tokens na fase de implementação

## Próximo passo

1. Revisar com [revisar-prompt-de-implementacao.md](revisar-prompt-de-implementacao.md)
2. Se aprovado, acionar Skill ou [implementar-feature.md](implementar-feature.md)
