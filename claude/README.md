# Claude Code — Manual de Engenharia

Esta pasta contém **regras** e **skills** derivadas do [Manual de Engenharia](../docs/engineering-handbook/). Não substitui a fonte de verdade.

## O que é esta pasta

- `regras/` — memória operacional curta para o agente
- `skills/` — procedimentos acionáveis por stack/tarefa (fonte versionada)
- `CLAUDE.md` — modelo de instrução para copiar à raiz de repos de código

## Relação com o handbook

Leia o capítulo aplicável em `docs/engineering-handbook/` **antes** de editar código. Skills linkam capítulos — não duplicam conteúdo longo.

Mapa completo: [artefatos-ia.md](../docs/engineering-handbook/artefatos-ia.md).

## Instalar Skills no Claude Code

```bash
# Na raiz do repo de código (cria .claude/skills/)
bash /caminho/repositorio-de-padroes/claude/sincronizar-claude.sh
```

Ou copie manualmente `claude/skills/*` → `.claude/skills/`.

## Quando usar `CLAUDE.md`

Copie [`CLAUDE.md`](CLAUDE.md) para a **raiz** do repositório de código alvo. Orienta o agente a ler README local, handbook, DoD e nomenclatura em português.

## Diferença: CLAUDE.md vs regras vs Skills

| Artefato | Escopo |
|----------|--------|
| `CLAUDE.md` | Comportamento global no repo de código |
| `regras/` | Constraints transversais (arquitetura, testes, segurança) |
| `skills/` | Workflow passo a passo para uma tarefa |

## Nomenclatura de código

Identificadores **internos** em português. Exceções: contratos externos, SDKs, tags Datadog. Ver [03 — Padrões de código](../docs/engineering-handbook/03-padroes-de-codigo.md#92-nomenclatura-de-código-em-português) e [regras/05-padroes-de-codigo.md](regras/05-padroes-de-codigo.md).

## Manutenção

1. **Handbook primeiro** — PR em `docs/engineering-handbook/`
2. **Skill depois** — PR em `claude/`
3. **Nunca** criar skill com padrão novo sem atualizar handbook
4. **Revisar** skill em PR com humano
5. **Testar** em feature piloto antes de considerar estável

## Skills (17)

**Agentes (prompt):** `preparar-prompt-tecnico` · `revisar-prompt-tecnico`

**Documentação funcional:** `extrair-documentacao-funcional` · `revisar-documentacao-funcional`

**Implementação e operação:** `criar-dag-airflow` · `criar-modelo-dbt` · `criar-modulo-terraform` · `criar-lambda-python` · `criar-api-spring-boot` · `criar-job-glue` · `criar-testes-unitarios` · `criar-taac` · `revisar-codigo` · `revisar-desempenho` · `melhorar-observabilidade` · `criar-documentacao` · `investigar-falha`

Guia de agentes: [21 — Agentes e prompts](../docs/engineering-handbook/21-agentes-e-prompts.md). Documentação funcional: [22](../docs/engineering-handbook/22-documentacao-funcional.md). Logging seguro: [13](../docs/engineering-handbook/13-observabilidade.md#logging-seguro-e-dados-sensíveis).

## Fluxo preparador → revisor → implementação

1. Pedido vago → Skill `preparar-prompt-tecnico` → briefing técnico
2. Confiança < 90% → perguntas antes do prompt final
3. Skill `revisar-prompt-tecnico` → sem bloqueios 🔴
4. Skill de stack com contexto mínimo do briefing

Não use agentes preparador/revisor para implementar código diretamente.

## Fonte de verdade

Este artefato é derivado do Manual de Engenharia.

Antes de alterar um padrão:

1. Atualize o capítulo correspondente em `docs/engineering-handbook/`.
2. Abra PR de revisão do handbook.
3. Depois atualize este artefato derivado.
