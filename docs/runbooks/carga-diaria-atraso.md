# Runbook: Carga diária atrasada (exemplo sintético)

- **Owner:** squad-dados-exemplo
- **Última revisão:** 2025-07-02
- **Dashboard:** `https://app.datadoghq.com/dashboard/exemplo-carga-diaria`
- **Monitors relacionados:** `[PROD] carga-diaria-atraso`

## Sintoma

Monitor Datadog dispara quando a DAG `datalake_carga_diaria_arquivos` não conclui até 06:00 UTC.

## Severidade

**P2** — atraso com impacto em relatórios internos; sem perda de dados confirmada.

## Impacto

- **Negócio:** relatório diário de consolidação pode atrasar
- **Técnico:** DAG Airflow no repositório `{nome-projeto}-airflow`
- **Dados:** partição `data_referencia` do dia corrente

## Diagnóstico rápido

1. Localizar `correlation_id` da execução falha nos logs Datadog (`service:datalake-airflow status:FAILURE`).
2. Verificar task que falhou (geralmente `validar_arquivo_entrada` ou `executar_processamento_glue`).
3. Confirmar se arquivo de entrada chegou no prefixo S3 esperado (apenas prefixo — não logar conteúdo).

## Ações

1. Reprocessar com `data_referencia` correta se arquivo chegou após o schedule.
2. Escalar para owner da DAG se falha repetir em 2+ dias.

## Referências

- [13 — Observabilidade](../engineering-handbook/13-observabilidade.md)
- [04 — Airflow](../engineering-handbook/04-airflow.md)
- Template: [runbook.md](../engineering-handbook/templates/runbook.md)
