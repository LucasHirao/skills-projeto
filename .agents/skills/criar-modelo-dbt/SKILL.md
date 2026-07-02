<!-- Sincronizado de .claude/skills/criar-modelo-dbt/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: criar-modelo-dbt
description: >-
  Cria ou altera models dbt projeto (staging, intermediate, marts) com testes,
  documentação e materialização adequada. Use para novos models SQL, incrementais,
  schema.yml ou refatoração de camadas dbt.
---

# Criar modelo dbt

**Referência:** `docs/padroes/03-dbt.md` | **Regra:** `.claude/rules/dbt.md`

## Quando usar

Novo model, incremental, testes em schema.yml, macro ou ajuste de camada.

## Entradas esperadas

- Camada (stg/int/fct/dim)
- Fontes/refs upstream
- Chave única e regra incremental
- Testes de negócio necessários

## Passo a passo

1. Identificar camada e prefixo correto.
2. Criar SQL com filtro cedo; evitar `select *`.
3. Adicionar entrada em `schema.yml` (descrição + testes).
4. Escolher materialização (view/table/incremental).
5. Se incremental: `unique_key`, estratégia, late arriving documentado.
6. Rodar `dbt build --select {model}+`.
7. Avaliar lineage downstream.

## Checklist de qualidade

- [ ] Prefixo e pasta corretos
- [ ] SQL legível e modular
- [ ] Sem duplicação evitável

## Checklist de testes

- [ ] `not_null`/`unique` em chaves
- [ ] `relationships` se FK
- [ ] `accepted_values` se enum
- [ ] `dbt build` verde

## Checklist de observabilidade

- [ ] Freshness na source se SLA
- [ ] Exposures para consumidores críticos

## Checklist de performance

- [ ] Filtro na staging
- [ ] Incremental para volume alto
- [ ] Particionamento/cluster se aplicável

## Armadilhas comuns

- Mart na staging
- Incremental sem unique_key
- CTE gigante sem `int_`

## Resultado esperado

Model documentado, testado, com materialização adequada e CI verde.

## Exemplo de prompt

```
Use criar-modelo-dbt. Crie stg_vendas__pedidos e fct_vendas_pedidos incremental
com unique_key pedido_id. schema.yml com testes. Rodar dbt build.
```

