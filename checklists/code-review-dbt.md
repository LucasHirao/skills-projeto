# Checklist: Code Review dbt

## Perguntas objetivas

- [ ] Prefixo correto (`stg_`, `int_`, `fct_`, `dim_`)?
- [ ] Camada adequada (staging vs mart)?
- [ ] `schema.yml` com descrição e testes?
- [ ] Incremental com `unique_key` e estratégia?
- [ ] Filtro cedo; sem `select *` desnecessário?
- [ ] `dbt build` verde?
- [ ] Impacto downstream avaliado?

## 🔴 Bloqueio

- Mart sem testes em colunas chave
- Incremental sem chave única documentada
- Lógica duplicada entre models sem macro

## 🟡 Atenção

- CTE muito grande — considerar `int_`
- Materialização inadequada (table em staging volátil)

## Exemplos de comentário

> 🔴 Coluna `pedido_id` sem `unique` + `not_null` no mart fato.

> 🟡 `merge` incremental sem tratar late arriving — adicionar janela lookback.
