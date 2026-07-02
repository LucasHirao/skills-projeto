---
name: preparar-prompt-tecnico
description: Transformar pedido bruto em briefing técnico claro, com contexto mínimo e prompt de implementação. Não implementa código.
---

# Preparar prompt técnico

## Quando usar

- Pedido inicial vago ou incompleto
- Tarefa pode afetar múltiplos repositórios
- Risco de o agente implementar algo errado
- Necessidade de economizar tokens na execução
- Direcionar Claude/Devin para a Skill ou playbook correto

**Não usar** para implementar código — use a Skill de stack após o briefing.

## Entradas esperadas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Pedido bruto | Sim | “Preciso de uma DAG que processe arquivos diários” |
| Repositório alvo | Se conhecido | `{nome-projeto}-airflow` |
| Stack provável | Se conhecida | Airflow, dbt, misto |
| Paths relevantes | Se conhecidos | `dags/carga/`, `models/staging/` |
| Restrições | Recomendado | Sem PII; sem breaking change |
| Prazo/objetivo | Recomendado | Entregar até sexta; reduzir falhas noturnas |

## Processo obrigatório

### 1. Classificar a tarefa

Uma categoria principal: implementação · revisão · investigação · documentação · refatoração · teste · observabilidade · performance.

### 2. Identificar stack principal

Airflow · dbt · Terraform · Lambda Python · Java Spring Boot · AWS Glue · misto · desconhecido.

### 3. Selecionar contexto mínimo

Incluir **apenas**:

- Skill específica da stack (ou playbook Devin se feature ampla)
- Capítulo da stack (`04`–`09`)
- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)
- Capítulos adicionais **somente se necessário** (13 observabilidade, 17 segurança, 11 TaaC, etc.)

### 4. Avaliar ambiguidade

Marcar presença de: regra de negócio ausente · contrato desconhecido · repositório indefinido · entrada/saída indefinida · critério de aceite ausente · risco breaking change · risco dados sensíveis.

### 5. Definir confiança

| Nível | Faixa | Ação |
|-------|-------|------|
| Alta | ≥ 90% | Gerar prompt final de implementação |
| Média | 70–89% | Briefing com assunções explícitas |
| Baixa | < 70% | Perguntar antes de implementar |

Use a heurística do [21 — Agentes e prompts](../../../docs/engineering-handbook/21-agentes-e-prompts.md#8-como-calcular-confiança).

### 6. Se confiança < 90%

Listar **perguntas objetivas** em `## Dúvidas bloqueantes`. Não gerar `## Prompt final para implementação` até resolvidas ou assumidas explicitamente (média).

### 7. Se confiança ≥ 90%

Preencher o formato de saída completo, incluindo `## Prompt final para implementação` enxuto.

## Formato de saída obrigatório

```markdown
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

## Prompt final para implementação
```

## Regras de economia de tokens

- Não incluir capítulos inteiros no prompt
- Não colar conteúdo longo do handbook
- Referenciar caminhos relativos (handbook, skill, arquivos do repo alvo)
- Incluir apenas trecho funcional necessário (ex.: assinatura de função vizinha)
- Não pedir leitura de arquivos sem relação com a tarefa
- Não acionar múltiplas Skills se uma específica bastar
- Nunca pedir “ler todo o handbook” para tarefa de uma stack

## Mapeamento stack → Skill

| Stack | Skill | Capítulo |
|-------|-------|----------|
| Airflow | `criar-dag-airflow` | `04-airflow.md` |
| dbt | `criar-modelo-dbt` | `05-dbt.md` |
| Terraform | `criar-modulo-terraform` | `06-terraform.md` |
| Lambda | `criar-lambda-python` | `07-lambda-python.md` |
| Spring Boot | `criar-api-spring-boot` | `08-java-spring-boot.md` |
| Glue | `criar-job-glue` | `09-aws-glue.md` |
| Testes | `criar-testes-unitarios` | `10-testes-unitarios.md` |
| TaaC | `criar-taac` | `11-taac-testes-integrados-na-pipeline.md` |
| Review | `revisar-codigo` | `16-code-review.md` |
| Performance | `revisar-desempenho` | `14-performance.md` |
| Observabilidade | `melhorar-observabilidade` | `13-observabilidade.md` |
| Incidente | `investigar-falha` | `13-observabilidade.md` |
| Feature ampla (Devin) | playbook `implementar-feature` | `02`, `18` + stacks |

## Nomenclatura de código

- Briefing e prompt final devem exigir identificadores internos em português
- Preservar nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos e tags técnicas
- Não inventar nomes de API/contrato — referenciar documentação existente
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)

## Fonte de verdade

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)
- [19 — Padrões para uso de IA](../../../docs/engineering-handbook/19-padroes-para-uso-de-ia.md)
- [21 — Agentes e prompts](../../../docs/engineering-handbook/21-agentes-e-prompts.md)
