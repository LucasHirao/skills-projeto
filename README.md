7﻿# Engineering Handbook / Manual de Engenharia

Repositório **multi-repo** de padrões técnicos para squads de dados e backend.

---

## Fonte principal da verdade

Todo padrão técnico vive em [`docs/engineering-handbook/`](docs/engineering-handbook/) (capítulos `00`–`22` + [templates](docs/engineering-handbook/templates/)).

Artefatos para agentes de IA são **derivados** — ver [artefatos-ia.md](docs/engineering-handbook/artefatos-ia.md) e [19 — Padrões para uso de IA](docs/engineering-handbook/19-padroes-para-uso-de-ia.md).

**Catálogo canônico:** [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml) — stacks registradas, capítulos transversais, Skills associadas a stacks, regras de descoberta de Skills/Playbooks e templates obrigatórios. Evite listas paralelas em README.

**Observabilidade:** [Datadog](docs/engineering-handbook/13-observabilidade.md) · **Logging seguro:** [allowlist](docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis).

**Nomenclatura:** identificadores internos em **português** — [03 — Padrões de código](docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português).

**Documentação funcional:** [22 — Documentação funcional](docs/engineering-handbook/22-documentacao-funcional.md).

**Agentes de prompt:** [21 — Agentes e prompts](docs/engineering-handbook/21-agentes-e-prompts.md).

---

## Estrutura do repositório

```
docs/engineering-handbook/   # Manual de Engenharia + manifest.yaml
claude/                      # Skills e regras para Claude Code
devin/                       # Skills e playbooks para Devin
scripts/validar-handbook.sh  # Validação central
CONTRIBUTING.md              # Como adicionar stack/artefato
```

---

## Comece aqui

1. [00 — Como usar este handbook](docs/engineering-handbook/00-como-usar-este-handbook.md)
2. [20 — Onboarding técnico](docs/engineering-handbook/20-onboarding-tecnico.md)
3. [01 — Contexto, princípios e objetivos](docs/engineering-handbook/01-contexto-principios-e-objetivos.md)

Capítulos de stack (`04`–`09`) e demais capítulos: ver diretório [`docs/engineering-handbook/`](docs/engineering-handbook/) ou [`manifest.yaml`](docs/engineering-handbook/manifest.yaml).

---

## Catálogo de stacks e artefatos

O catálogo canônico vive em [`docs/engineering-handbook/manifest.yaml`](docs/engineering-handbook/manifest.yaml) (stacks, capítulos transversais, Skills de stack, regras de descoberta e templates). Skills e Playbooks adicionais são encontrados por convenção de pastas — não precisam estar listados nominalmente no manifesto.

Para adicionar nova stack:

1. Capítulo com [`templates/capitulo-stack.md`](docs/engineering-handbook/templates/capitulo-stack.md)
2. Skills/Playbooks derivados (se aplicável)
3. Entrada no `manifest.yaml`
4. `bash scripts/validar-handbook.sh`

Detalhes: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Artefatos Claude (`claude/`)

| Item | Uso |
|------|-----|
| [claude/README.md](claude/README.md) | Instalação e manutenção |
| [claude/CLAUDE.md](claude/CLAUDE.md) | Modelo para repos de código |
| [claude/skills/](claude/skills/) | Skills descobertas por `*/SKILL.md` |
| [claude/sincronizar-claude.sh](claude/sincronizar-claude.sh) | Valida e copia para `.claude/skills/` |

```bash
bash /caminho/repositorio-de-padroes/claude/sincronizar-claude.sh --check
```

---

## Artefatos Devin (`devin/`)

| Item | Uso |
|------|-----|
| [devin/README.md](devin/README.md) | Skills vs Playbooks |
| [devin/AGENTS.md](devin/AGENTS.md) | Modelo para repos de código |
| [devin/skills/](devin/skills/) | Skills por convenção |
| [devin/playbooks/](devin/playbooks/) | Prompts amplos multi-repo |
| [devin/sincronizar-devin.sh](devin/sincronizar-devin.sh) | Valida e copia para `.agents/skills/` |

```bash
bash /caminho/repositorio-de-padroes/devin/sincronizar-devin.sh --check
```

---

## Fluxo recomendado com agentes

1. Pedido informal → preparador (`preparar-prompt-tecnico` / playbook equivalente)
2. Confiança < 90% → perguntas objetivas
3. Revisor de prompt
4. Skill ou playbook de implementação com contexto mínimo
5. PR + DoD + review humano

---

## Uso no dia a dia

1. Ler capítulo do handbook (ou stack no manifesto)
2. Usar [templates](docs/engineering-handbook/templates/) em PRs e docs
3. Acionar skill/playbook quando automatizar tarefa repetida
4. Revisar com [DoD](docs/engineering-handbook/18-definition-of-done.md) e [code review](docs/engineering-handbook/16-code-review.md)

---

## Como contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md). Resumo: handbook primeiro → `manifest.yaml` → validar → PR.

---

## Princípios

- **Multi-repo** — contratos entre repositórios
- **Datadog** — logs, APM, métricas, alertas, SLO
- **Qualidade** — 90% cobertura; 90% mutation; TaaC
- **Português** — prosa do handbook e identificadores internos
- **Handbook canônico** — manifesto para catálogo; skills não inventam política












Atue como Principal Engineer especializado em DynamoDB, modelagem single-table, sistemas distribuídos, DDD, workflows assíncronos e processamento ETL.

Preciso que você modele criticamente uma solução em DynamoDB para o cenário abaixo. O objetivo não é defender DynamoDB de forma automática, mas explorar até onde ele consegue atender ao problema com segurança, consistência, clareza de ownership e custo aceitável.

Não proponha PostgreSQL ou outro banco como solução principal neste momento. Caso identifique limitações relevantes do DynamoDB, registre-as explicitamente, mas ainda apresente a melhor modelagem possível usando DynamoDB.

## 1. Contexto do sistema

O sistema processa pedidos relacionados à obtenção e geração de dados bancários para atendimento da IN 636, no contexto do Simba.

Existe um fluxo com características transacionais e de ETL:

- recebimento de atendimentos e pedidos;
- identificação de envolvidos e contas;
- descoberta das informações necessárias;
- obtenção dos dados em diferentes sistemas de origem;
- processamento por Lambda, ECS, Glue e Airflow;
- armazenamento de resultados intermediários e finais no S3;
- acompanhamento do estado do atendimento;
- geração, validação e transmissão de arquivos.

O volume inicial estimado é de aproximadamente 10 mil atendimentos por mês, mas a modelagem deve permitir crescimento.

Os dados bancários volumosos não precisam ficar no DynamoDB. O DynamoDB deve armazenar principalmente:

- estado operacional;
- metadados;
- dependências;
- referências para resultados no S3;
- progresso;
- auditoria mínima;
- controle de idempotência e concorrência.

## 2. Conceitos principais

Considere inicialmente os seguintes conceitos:

### Atendimento

É o agrupamento maior do processo. Um atendimento pode possuir vários pedidos.

### Pedido

Representa uma solicitação de negócio. Um pedido pode envolver:

- vários envolvidos;
- várias contas;
- diferentes tipos de informação;
- diferentes períodos;
- diferentes sistemas de origem.

Um pedido só pode ser considerado concluído quando todas as suas necessidades obrigatórias estiverem concluídas.

### Necessidade do pedido

Representa algo de que um pedido precisa, por exemplo:

- extrato da conta A no mês de janeiro;
- dados de origem e destino da conta A no mês de janeiro;
- dados cadastrais;
- determinado agrupamento ou seção da IN 636.

A necessidade pertence exclusivamente a um pedido.

### Unidade de trabalho compartilhável

Representa uma obtenção ou processamento que pode ser reaproveitado por vários pedidos.

Uma mesma unidade de trabalho pode satisfazer necessidades de diferentes pedidos.

Exemplo:

Pedido P1 precisa do extrato da conta A entre janeiro e junho.

Pedido P2 precisa do extrato da mesma conta A entre março e agosto.

Os resultados de março, abril, maio e junho devem ser reaproveitados entre os dois pedidos.

A identidade de uma unidade de trabalho não deve considerar somente a conta. Deve considerar, conforme necessário:

- identificador tokenizado da conta;
- tipo de dado;
- sistema de origem;
- período ou partição temporal;
- versão da regra de extração;
- versão do schema;
- parâmetros que alterem semanticamente o resultado.

### Resultado

O resultado volumoso deve ficar no S3. O DynamoDB deve manter referências como:

- URI do S3;
- checksum;
- schema version;
- data de geração;
- validade;
- status;
- origem;
- versão do processamento.

## 3. Característica estrutural

Inicialmente o fluxo parece uma árvore:

Atendimento
  → Pedidos
    → Necessidades
      → Processamentos

Entretanto, devido ao reaproveitamento, a estrutura real é um grafo direcionado:

Pedido P1
  → Necessidade N1
    → Unidade de trabalho W1

Pedido P2
  → Necessidade N2
    → Unidade de trabalho W1

A unidade W1 é compartilhada, mas cada pedido deve manter seu próprio estado e progresso.

O status de uma unidade compartilhada não pode substituir o status particular da necessidade de cada pedido.

## 4. Regras obrigatórias

Considere as seguintes regras:

1. Um atendimento só pode concluir quando todos os pedidos obrigatórios estiverem concluídos.

2. Um pedido só pode concluir quando todas as suas necessidades obrigatórias estiverem concluídas.

3. Uma necessidade pode ser satisfeita por uma unidade de trabalho já existente.

4. Uma unidade de trabalho pode satisfazer necessidades de muitos pedidos.

5. A conclusão de uma unidade de trabalho deve ser propagada para todas as necessidades dependentes.

6. Cada necessidade só pode ser contabilizada uma vez no progresso do pedido, mesmo com retries ou eventos duplicados.

7. O conjunto de filhos ou necessidades deve possuir um conceito equivalente a `sealed`, `discovery_completed` ou `requirements_closed`, para evitar que um pedido seja concluído antes que todas as necessidades tenham sido descobertas.

8. Dois processos concorrentes não podem criar duas unidades de trabalho equivalentes.

9. Um novo pedido pode ser criado depois que uma unidade de trabalho já estiver concluída. Nesse caso, sua necessidade deve ser satisfeita imediatamente.

10. Deve ser tratado o caso de corrida em que uma dependência é criada exatamente enquanto a unidade de trabalho é concluída.

11. Reprocessamentos não podem sobrescrever silenciosamente resultados mais recentes ou produzidos por uma versão diferente da regra.

12. O cancelamento de um pedido não deve cancelar uma unidade compartilhada que ainda seja necessária por outros pedidos.

13. Glue, ECS e Lambda podem executar processamentos, mas deve existir ownership claro sobre quem altera os estados de negócio.

14. Evite que vários processadores alterem diretamente contadores, status de pedidos e status de atendimentos sem uma regra centralizada.

15. Não armazene listas potencialmente ilimitadas de pedidos dentro do item da unidade de trabalho.

16. Dados sensíveis, como conta, agência, CPF e conteúdo do extrato, não devem aparecer diretamente em PKs, SKs, logs ou métricas.

## 5. Access patterns obrigatórios

Modele o DynamoDB a partir dos seguintes padrões de acesso:

1. Criar um atendimento.

2. Criar pedidos pertencentes ao atendimento.

3. Consultar todos os pedidos de um atendimento.

4. Consultar o estado completo de um atendimento.

5. Criar as necessidades de um pedido.

6. Marcar que a descoberta das necessidades do pedido terminou.

7. Consultar todas as necessidades de um pedido.

8. Consultar somente as necessidades pendentes ou com erro.

9. Buscar uma unidade de trabalho existente por sua chave de reaproveitamento.

10. Criar uma unidade de trabalho somente se ainda não existir outra equivalente.

11. Associar uma necessidade de pedido a uma unidade de trabalho.

12. Descobrir todos os pedidos ou necessidades que aguardam uma determinada unidade de trabalho.

13. Marcar uma unidade de trabalho como concluída.

14. Propagar a conclusão da unidade de trabalho para todas as dependências.

15. Atualizar o progresso de cada pedido afetado de forma idempotente.

16. Atualizar o atendimento quando um pedido for concluído.

17. Consultar unidades de trabalho pendentes, falhas, expiradas ou paradas.

18. Consultar pedidos parados ou próximos do SLA.

19. Consultar unidades de trabalho por conta tokenizada, tipo de dado e período.

20. Consultar histórico de transições relevantes.

21. Reprocessar uma unidade usando uma nova versão da regra ou do schema.

22. Identificar quais pedidos utilizaram um determinado resultado.

23. Invalidar um resultado sem corromper pedidos que já foram concluídos anteriormente.

24. Permitir auditoria sobre qual versão do resultado satisfez cada necessidade.

## 6. Cenário concreto que deve ser modelado

Apresente exemplos concretos de itens para este cenário:

Atendimento: A1

Pedido P1:
- conta tokenizada C1;
- extrato;
- período de janeiro a junho de 2026.

Pedido P2:
- mesma conta tokenizada C1;
- extrato;
- período de março a agosto de 2026.

Considere unidades de trabalho mensais:

- C1 + extrato + janeiro/2026;
- C1 + extrato + fevereiro/2026;
- C1 + extrato + março/2026;
- C1 + extrato + abril/2026;
- C1 + extrato + maio/2026;
- C1 + extrato + junho/2026;
- C1 + extrato + julho/2026;
- C1 + extrato + agosto/2026.

Março, abril, maio e junho devem ser compartilhados pelos dois pedidos.

Mostre:

- itens de atendimento;
- itens de pedido;
- itens de necessidade;
- itens de unidade de trabalho;
- itens de associação entre necessidade e unidade de trabalho;
- referências para o S3;
- itens ou registros usados para idempotência;
- itens de auditoria, caso recomendados;
- projeções ou itens duplicados necessários para os padrões de acesso.

Use exemplos concretos de:

- PK;
- SK;
- GSI1PK;
- GSI1SK;
- demais GSIs;
- atributos;
- status;
- versionamento;
- timestamps;
- chaves de idempotência.

Não use identificadores bancários reais.

## 7. Decisões que devem ser avaliadas

Compare e justifique as seguintes alternativas dentro do DynamoDB:

### Particionamento por atendimento

Exemplo:

PK = ATENDIMENTO#A1

Com pedidos e necessidades dentro da mesma item collection.

Avalie:

- facilidade de consultar o atendimento completo;
- risco de hot partition;
- tamanho da item collection;
- concorrência;
- impacto do reaproveitamento
