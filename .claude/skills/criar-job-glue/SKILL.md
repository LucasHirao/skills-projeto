---
name: criar-job-glue
description: >-
  Cria ou altera jobs AWS Glue projeto com PySpark, transforms testáveis e escrita
  particionada. Use para ETL/ELT Glue, scripts PySpark, bookmarks ou integração
  com data lake S3.
---

# Criar job Glue

**Referência:** `docs/padroes/07-aws-glue.md` | **Regra:** `.claude/rules/glue.md`

## Quando usar

Novo job ETL, transformação PySpark, leitura/escrita S3, incremental com bookmarks.

## Entradas esperadas

- Paths entrada/saída
- Schema esperado
- Particionamento
- Estratégia idempotente de write

## Passo a passo

1. Estrutura: `job.py`, `io/`, `transforms/`, `tests/`.
2. Funções puras em `transforms/` com pytest.
3. Spark nativo antes de UDF.
4. Leitura com pushdown; escrita particionada Parquet.
5. Métricas de registros processados/rejeitados.
6. Teste Spark local com fixture pequena.
7. Documentar parâmetros e reprocessamento.

## Checklist de qualidade

- [ ] Separação read/transform/write
- [ ] Schema validado
- [ ] Write mode documentado

## Checklist de testes

- [ ] pytest em transforms puras
- [ ] Spark local para DataFrame
- [ ] Casos limite (null, duplicata)

## Checklist de observabilidade

- [ ] Logs estruturados por etapa
- [ ] Métricas CloudWatch custom

## Checklist de performance

- [ ] Sem collect em volume grande
- [ ] Partition/filter cedo
- [ ] Broadcast join se dimensão pequena

## Armadilhas comuns

- Script único de 500 linhas
- pandas em milhões de linhas
- overwrite sem critério

## Resultado esperado

Job modular, testado, com particionamento e doc operacional.

## Exemplo de prompt

```
Use criar-job-glue. Job lê Parquet vendas/, normaliza status em transforms/
testável, escreve particionado por data_referencia. Testes pytest + spark local.
```
