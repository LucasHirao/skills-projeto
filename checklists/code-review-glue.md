# Checklist: Code Review Glue

## Perguntas objetivas

- [ ] Separação read/transform/write?
- [ ] Transforms testáveis (pytest)?
- [ ] UDF evitada quando função nativa resolve?
- [ ] Particionamento na escrita?
- [ ] Idempotência do write documentada?
- [ ] Sem `collect()` em volume grande?
- [ ] Schema validado?

## 🔴 Bloqueio

- Script monolítico sem testes
- `overwrite` sem critério em dados compartilhados
- UDF Python em hot path sem justificativa

## 🟡 Atenção

- Join sem filtro prévio
- Job sem métrica de registros processados

## Exemplos de comentário

> 🔴 `df.collect()` para validar milhões de linhas — usar agregação ou amostra.

> 🟡 Extrair `normalizar_status` para `transforms/` com teste unitário.
