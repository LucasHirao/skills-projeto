# Qualidade e testes

## Escopo

Testes unitários, mutation e TaaC para repositórios `{nome-projeto}-*`.

## Metas

| Tipo | Meta | Onde |
|------|------|------|
| Cobertura de linha | ≥ 90% | Todo código com lógica |
| Mutation score | ≥ 90% | `domain/`, `application/` |
| TaaC | Obrigatório | Integração real (S3, fila, DB, API) |

## Princípios

- Asserts de **comportamento**, não só "não levantou exceção"
- Mock mínimo em unitário; integração real no TaaC
- Nomes descritivos em português (`deve_rejeitar_pedido_sem_itens`)
- Teste de regressão antes de corrigir bug

## CI

- Mesmos comandos localmente e na pipeline
- Coverage e mutation como gate (exceção justificada no PR)
- TaaC com ambiente autocontido (Testcontainers/LocalStack)

## Anti-padrões

- `assert True` ou teste que só instancia objeto
- Mock de tudo — wiring quebrado passa verde
- Pular TaaC em integração nova "por tempo"
- Dados reais ou PII em fixtures

## Fonte de verdade

- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- [11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [12 — Testes de mutação](../../docs/engineering-handbook/12-testes-de-mutacao.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)
