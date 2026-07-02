# Regra Cursor

Espelha `.claude/rules/testes.md`. Detalhes em `docs/padroes/`.

---

# Regra: Testes

**Docs:** `08-testes-unitarios.md`, `09-taac-testes-integrados-pipeline.md`, `10-testes-de-mutacao.md`

## Metas

- Cobertura **90%** (line; branch se disponível)
- Mutation **90%** em lógica de negócio
- TaaC quando há integração real

## Faça

- Assert de comportamento observável
- Nomes: `deve_X_quando_Y`
- Fixtures determinísticas; cleanup
- Marcar `@pytest.mark.taac` / perfil Maven IT

## Não faça

- Teste só para cobertura
- E2E frágil que duplica TaaC
- BDD em todo teste técnico

## Exceções

DTO/bootstrap/gerado — justificar no PR
