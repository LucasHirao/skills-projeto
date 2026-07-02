# Devin — Manual de Engenharia

Configuração do agente **Devin** derivada do [Manual de Engenharia](../docs/engineering-handbook/). Skills e playbooks **não** são fonte de verdade — apenas atalhos acionáveis.

## Fonte de verdade

| Artefato | Caminho |
|----------|---------|
| Handbook | [`docs/engineering-handbook/`](../docs/engineering-handbook/) |
| Mapa IA | [artefatos-ia.md](../docs/engineering-handbook/artefatos-ia.md) |
| DoD | [18 — Definition of Done](../docs/engineering-handbook/18-definition-of-done.md) |
| Uso de IA | [19 — Padrões para uso de IA](../docs/engineering-handbook/19-padroes-para-uso-de-ia.md) |
| Agentes | [21 — Agentes e prompts](../docs/engineering-handbook/21-agentes-e-prompts.md) |
| Documentação funcional | [22 — Documentação funcional](../docs/engineering-handbook/22-documentacao-funcional.md) |
| Logging seguro | [13 — Observabilidade](../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis) |

**Regra:** mudança de padrão → PR no handbook primeiro; `devin/` atualizado depois.

## Estrutura

```
devin/
  AGENTS.md              # Modelo para repos de código
  skills/                # 13 skills (fonte versionada)
  playbooks/             # 12 prompts (agentes, doc funcional, implementação)
  sincronizar-devin.sh   # Copia skills → .agents/skills/
```

## Skills vs Playbooks

| Tipo | Quando usar |
|------|-------------|
| **Skill** | Tarefa recorrente em um repo/stack (DAG, model dbt, Lambda) |
| **Playbook** | Fluxo amplo ou cross-repo (feature, pipeline, incidente) |

Playbooks são **prompts reutilizáveis** — Devin não os descobre automaticamente; cole ou referencie no chat.

## Convenções

- **Prosa:** português BR
- **Identificadores internos:** português ([03 — Padrões de código](../docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português))
- **Exceções:** contratos externos, SDKs, tags `service`/`env`/`correlation_id`
- **Multi-repo:** `{nome-projeto}-airflow`, `{nome-projeto}-dbt`, etc.
- **Observabilidade:** Datadog

## Instalar Skills no Devin

```bash
# Na raiz do repo de código
bash /caminho/repositorio-de-padroes/devin/sincronizar-devin.sh
```

Copia `devin/skills/*` → `.agents/skills/`. Copie [`AGENTS.md`](AGENTS.md) para a raiz do repo alvo se necessário.

## Skills (13)

`criar-dag-airflow` · `criar-modelo-dbt` · `criar-modulo-terraform` · `criar-lambda-python` · `criar-api-spring-boot` · `criar-job-glue` · `criar-testes-unitarios` · `criar-taac` · `revisar-codigo` · `revisar-desempenho` · `melhorar-observabilidade` · `criar-documentacao` · `investigar-falha`

## Playbooks (12)

**Agentes:** [`preparar-feature-para-implementacao.md`](playbooks/preparar-feature-para-implementacao.md) · [`revisar-prompt-de-implementacao.md`](playbooks/revisar-prompt-de-implementacao.md)

**Documentação funcional:** [`extrair-documentacao-funcional.md`](playbooks/extrair-documentacao-funcional.md) · [`revisar-documentacao-funcional.md`](playbooks/revisar-documentacao-funcional.md)

**Implementação e operação:** [`implementar-feature.md`](playbooks/implementar-feature.md) · [`revisar-pr.md`](playbooks/revisar-pr.md) · [`criar-pipeline-airflow-dbt.md`](playbooks/criar-pipeline-airflow-dbt.md) · [`criar-componente-aws.md`](playbooks/criar-componente-aws.md) · [`criar-taac.md`](playbooks/criar-taac.md) · [`investigar-falha-pipeline.md`](playbooks/investigar-falha-pipeline.md) · [`melhorar-observabilidade.md`](playbooks/melhorar-observabilidade.md) · [`revisar-desempenho.md`](playbooks/revisar-desempenho.md)

## Fluxo preparador → revisor → implementação

1. Pedido informal → playbook `preparar-feature-para-implementacao`
2. Confiança < 90% → perguntas objetivas (não gerar prompt de implementação)
3. Playbook `revisar-prompt-de-implementacao` → sem bloqueios 🔴
4. Skill de stack ou `implementar-feature` com contexto mínimo do briefing

## Manutenção

1. Handbook primeiro
2. Skill/playbook depois
3. Piloto em feature real
4. PR neste repo (`repositorio-de-padroes`)

## Fonte de verdade

Este artefato é derivado do Manual de Engenharia.

Antes de alterar um padrão:

1. Atualize o capítulo correspondente em `docs/engineering-handbook/`.
2. Abra PR de revisão do handbook.
3. Depois atualize este artefato derivado.
