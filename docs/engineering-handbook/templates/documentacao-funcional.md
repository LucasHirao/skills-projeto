# Documentação funcional — {nome do processo}

- **Owner:** {time/pessoa}
- **Última revisão:** YYYY-MM-DD
- **Validador(es):** {quem confirma regras de negócio}

## Resumo em linguagem simples

{2–4 frases que uma pessoa nova entende sem conhecer o sistema.}

## Objetivo do processo

{Por que este processo existe e qual resultado de negócio entrega.}

## Público-alvo

{Operação, negócio, engenharia, auditoria, etc.}

## Escopo

{O que este documento cobre.}

## Fora de escopo

{O que não está documentado aqui e onde procurar.}

## Conceitos importantes

| Conceito | Significado simples |
|----------|---------------------|
| {termo} | {definição acessível} |

## Atores envolvidos

| Ator | Papel |
|------|-------|
| {sistema ou time} | {o que faz no fluxo} |

## Entradas

| Entrada | Origem | Formato | Obrigatória? |
|---------|--------|---------|--------------|
| {ex.: arquivo de lote} | {origem sintética} | {CSV, API, fila} | Sim/Não |

## Saídas

| Saída | Destino | Formato |
|-------|---------|---------|
| {ex.: relatório consolidado} | {destino sintético} | {formato} |

## Fluxo principal

1. {passo 1}
2. {passo 2}
3. {passo N}

## Fluxos alternativos

| Cenário | Quando ocorre | O que muda |
|---------|---------------|------------|
| {ex.: reprocessamento} | {condição} | {diferença no fluxo} |

## Regras funcionais

| ID | Regra | Testável? |
|----|-------|-----------|
| RF-01 | {regra em linguagem clara} | Sim/Não |

## Exceções

| Exceção | Tratamento esperado |
|---------|---------------------|
| {ex.: arquivo vazio} | {ação} |

## Dados envolvidos

| Dado | Classificação | Observação |
|------|---------------|------------|
| {ex.: identificador de lote} | Interno | Exemplo sintético: `LOTE-0001` |

## Dados sensíveis e cuidados

- {quais dados são sensíveis no processo}
- {como documentar sem expor valores reais}
- {o que não pode aparecer em exemplos nem em logs}

## Dependências externas

| Dependência | Tipo | Impacto se indisponível |
|-------------|------|-------------------------|
| {sistema X} | API/fila/arquivo | {impacto} |

## Perguntas frequentes

### {pergunta}

{resposta curta}

## Fatos confirmados

- {fato validado por especialista ou documento oficial}

## Assunções

- {o que foi assumido e ainda não validado formalmente}

## Dúvidas abertas

- {pergunta pendente — owner para resolver}

## Decisões tomadas

| Data | Decisão | Responsável |
|------|---------|-------------|
| YYYY-MM-DD | {decisão} | {nome/time} |

## Exemplos sintéticos

```
Entrada exemplo: arquivo "lote_vendas_20250702.csv" com 150 registros fictícios.
Identificador de negócio exemplo: hash "sha256:abc123..." (nunca valor real).
```

## Critérios de aceite da documentação

- [ ] Pessoa nova entende o fluxo principal sem oralidade
- [ ] Escopo e fora de escopo explícitos
- [ ] Regras funcionais testáveis ou marcadas como não testáveis
- [ ] Exceções documentadas
- [ ] Sem dados reais (CPF, CNPJ, nome, conta, e-mail, telefone, payload)
- [ ] Fatos, assunções e dúvidas separados
- [ ] Owner e data de revisão preenchidos
- [ ] Validador humano indicado

## Owner

{time/pessoa}

## Última revisão

YYYY-MM-DD
