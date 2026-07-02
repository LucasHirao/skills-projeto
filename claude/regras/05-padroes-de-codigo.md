# Padrões de código

## Objetivo

Reforçar estilo e nomenclatura transversal para agentes Claude em repositórios `{nome-projeto}-*`.

## Regras obrigatórias

- Identificadores **internos** em português: classes, funções, variáveis, testes, tasks, models dbt (após prefixo técnico)
- Comentários e docstrings em português quando existirem
- Seguir estilo do **módulo vizinho**
- Regra de negócio testável sem cloud quando possível
- Tags técnicas Datadog inalteradas: `service`, `env`, `version`, `correlation_id`

## Exceções (não traduzir)

- Contratos públicos (OpenAPI, schema externo, payload de integração)
- SDKs, frameworks, palavras reservadas, comandos CLI
- Recursos AWS quando padrão corporativo exige inglês
- Repositório legado com inglês consolidado — documentar exceção no PR

### Bom vs ruim

| Bom | Ruim (código novo interno) |
|-----|----------------------------|
| `ProcessarArquivoUseCase` | `ProcessFileUseCase` |
| `validar_arquivo_entrada` | `validate_input_file` |
| `test_deve_rejeitar_lote_quando_schema_invalido` | `test_should_reject_batch_when_schema_invalid` |
| `stg_{nome-projeto}__arquivos_recebidos` | `stg_files_received` |

## Anti-padrões

- Handler/DAG com centenas de linhas de negócio
- Identificadores internos em inglês sem justificativa
- `select *` em produção
- `except Exception: pass`

## Links

- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)

## Fonte de verdade

Este artefato é derivado do Manual de Engenharia.

Antes de alterar um padrão:

1. Atualize o capítulo correspondente em `docs/engineering-handbook/`.
2. Abra PR de revisão do handbook.
3. Depois atualize este artefato derivado.
