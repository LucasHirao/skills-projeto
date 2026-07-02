# 22 — Documentação funcional

Este capítulo define como **extrair conhecimento tácito** de pessoas (conversas, reuniões, notas, transcrições) e transformá-lo em **documentação funcional** acessível — sem expor dados reais.

**Princípio:** documentação funcional explica **o que o negócio faz e por quê**; documentação técnica explica **como o sistema implementa**.

Relacionado: [15 — Documentação](15-documentacao.md), [Logging seguro e dados sensíveis](13-observabilidade.md#logging-seguro-e-dados-sensíveis), [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## 1. O que é documentação funcional

Documentação que descreve **processos, regras, fluxos e conceitos de negócio** de forma compreensível para:

- pessoa nova no time;
- operação e suporte;
- engenharia que precisa implementar ou manter;
- auditoria e conformidade (sem expor dados reais).

**Não é:** código, diagrama de infra, ADR de tecnologia ou runbook operacional — embora possa referenciá-los.

---

## 2. Tipos de documento — quando usar cada um

| Tipo | Foco | Público | Template |
|------|------|---------|----------|
| **Documentação funcional** | Processo e regras de negócio | Negócio, ops, engenharia | [`documentacao-funcional.md`](templates/documentacao-funcional.md) |
| **Documentação técnica** | Como implementar/operar componente | Engenharia | [`readme-componente.md`](templates/readme-componente.md) |
| **ADR** | Decisão arquitetural com trade-off | Engenharia | [`adr.md`](templates/adr.md) |
| **Runbook** | Incidente, reprocessamento, alerta | Operação/SRE | [`runbook.md`](templates/runbook.md) |
| **Glossário funcional** | Vocabulário do domínio | Todos | [`glossario-funcional.md`](templates/glossario-funcional.md) |
| **Fluxo funcional** | Passo a passo e estados | Negócio, ops | [`fluxo-funcional.md`](templates/fluxo-funcional.md) |

---

## 3. Quando usar documentação funcional

- Onboarding de pessoa nova em um domínio
- Processo existe só na cabeça de especialistas
- Regra de negócio ambígua causou bug ou retrabalho
- Preparação para implementação (antes do código)
- Alinhamento entre squads (dados, backend, operação)
- Auditoria ou conformidade que exige rastreabilidade de regras

**Não substitui** validação humana — especialista deve confirmar fatos.

---

## 4. Como entrevistar especialistas

### Preparação

1. Definir **escopo** do processo (início e fim)
2. Listar **perguntas abertas** conhecidas
3. Identificar **validador** (owner de negócio)
4. Avisar que a sessão **não** deve usar dados reais — apenas exemplos sintéticos

### Roteiro de perguntas

| Área | Perguntas |
|------|-----------|
| Objetivo | O que este processo entrega? Quem consome? |
| Entradas/saídas | O que entra? O que sai? Em que formato? |
| Fluxo | Qual o caminho feliz? O que pode dar errado? |
| Regras | Quais regras são obrigatórias? Há exceções? |
| Dados | Quais dados são sensíveis? O que nunca pode vazar? |
| Dependências | De quais sistemas/pessoas depende? |
| Histórico | O que mudou recentemente? O que está obsoleto? |

### Boas práticas

- Gravar/transcrever **com consentimento**; revisar antes de publicar
- Repetir em voz alta o entendimento — “então, se X, acontece Y?”
- Marcar na hora: **fato** vs **suposição** vs **dúvida**

---

## 5. Separar fato, suposição e dúvida

| Categoria | Definição | Onde registrar |
|-----------|-----------|----------------|
| **Fato confirmado** | Validado por especialista ou documento oficial | `## Fatos confirmados` |
| **Assunção** | Parece verdade, não validado | `## Assunções` |
| **Dúvida aberta** | Ninguém confirmou | `## Dúvidas abertas` |
| **Decisão tomada** | Acordo explícito na reunião | `## Decisões tomadas` |
| **Ponto a validar** | Precisa confirmação antes de implementar | `## Pontos para validação humana` (skills) |

**Regra:** IA **não promove** assunção a fato sem validador humano.

---

## 6. Documentar fluxo de processo

1. Nomear o fluxo e o **owner**
2. Descrever visão geral em linguagem simples
3. Tabela passo a passo (ator, entrada, ação, saída)
4. Estados e transições se houver máquina de estados
5. Fluxos alternativos e exceções
6. Pontos de auditoria — o que registrar **sem** dados sensíveis ([logging seguro](13-observabilidade.md#logging-seguro-e-dados-sensíveis))

Template: [`fluxo-funcional.md`](templates/fluxo-funcional.md).

---

## 7. Documentar regras de negócio

- Uma regra por linha, ID estável (`RF-01`, `RF-02`)
- Linguagem testável quando possível (“deve rejeitar quando…”)
- Se não testável, marcar e explicar por quê
- Não inventar regra — se não foi dito, vai para **dúvidas abertas**

---

## 8. Documentar glossário

- Termo → significado simples → exemplo **sintético** → fonte/validador
- Evitar jargão técnico quando público for negócio
- Atualizar quando surgir termo novo em entrevista

Template: [`glossario-funcional.md`](templates/glossario-funcional.md).

---

## 9. Exceções e casos alternativos

Documentar para cada exceção:

- **quando** ocorre;
- **o que** o processo faz;
- **o que** o operador/sistema deve fazer;
- **o que** não fazer (ex.: não reprocessar sem idempotência).

---

## 10. Dados sensíveis na documentação funcional

**Proibido** em exemplos e anexos:

- CPF, CNPJ, nome, conta, agência, e-mail, telefone reais
- Payload de produção, dumps de banco, screenshots com PII

**Permitido:**

- IDs fictícios (`LOTE-0001`, `CLIENTE-SINTETICO-01`)
- Hashes de exemplo (`sha256:abc123...`)
- Volumes agregados (`150 registros`)
- Classificação de dados (“campo X é confidencial”) sem valor

Alinhar com [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) e logging por allowlist.

---

## 11. Validar com humanos

Checklist antes de considerar “publicável”:

- [ ] Especialista de negócio revisou fatos e regras
- [ ] Engenharia confirmou viabilidade técnica (se aplicável)
- [ ] Sem dados reais no texto
- [ ] Dúvidas abertas têm owner
- [ ] Owner e data de última revisão preenchidos
- [ ] Glossário cobre termos usados no fluxo

---

## 12. Manter documentação viva

| Gatilho | Ação |
|---------|------|
| Mudança de regra de negócio | Atualizar doc funcional **no mesmo PR** ou sprint |
| Incidente por mal-entendido | Revisar seção de regras/exceções |
| Novo integrante com mesmas dúvidas | Melhorar resumo e FAQ |
| Processo descontinuado | Marcar obsoleto + data + substituto |

**Revisão periódica:** pelo menos trimestral para processos críticos.

---

## 13. Uso de IA na documentação funcional

| Etapa | Artefato Claude | Artefato Devin |
|-------|----------------|----------------|
| Extrair de conversa/notas | Skill `extrair-documentacao-funcional` | Playbook `extrair-documentacao-funcional.md` |
| Revisar antes de publicar | Skill `revisar-documentacao-funcional` | Playbook `revisar-documentacao-funcional.md` |

**Regras para IA:**

- Não alterar código na extração
- Perguntar se confiança < 90% (regra ambígua, owner ausente, risco de dado sensível)
- Usar templates oficiais
- Separar fatos, assunções e dúvidas

Ver [21 — Agentes e prompts](21-agentes-e-prompts.md) para preparação de contexto mínimo.

---

## 14. Critérios de aceite da documentação funcional

- [ ] Resumo compreensível para pessoa nova
- [ ] Escopo e fora de escopo explícitos
- [ ] Fluxo principal completo
- [ ] Regras e exceções documentadas
- [ ] Glossário ou conceitos importantes
- [ ] Sem dados reais
- [ ] Fatos / assunções / dúvidas separados
- [ ] Owner e última revisão
- [ ] Validador humano indicado

---

## Fonte de verdade

Este capítulo é parte do Manual de Engenharia. Templates e skills são derivados.
