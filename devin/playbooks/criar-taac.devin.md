# Playbook: Criar TaaC (teste integrado autocontido)

## Objetivo

Teste de integração na CI, ambiente autocontido, validando wiring real entre componentes.

## Escopo

Teste integrado — não E2E completo de produção.

## Contexto

- `docs/padroes/09-taac-testes-integrados-pipeline.md`
- Skill `criar-taac`
- Template `docs/padroes/templates/template-teste-integrado.md`

## O que procurar no repositório

- Testes integrados existentes (padrão de fixtures)
- docker-compose.test.yml
- Marcadores pytest / perfil Maven IT

## Como planejar

1. Delimitar componentes (in/out).
2. Escolher Testcontainers / LocalStack / WireMock.
3. Cenários: happy path + falha integração.
4. Tempo máximo < 10 min.

## Como implementar

1. Fixture + cleanup.
2. Teste com marker `taac`.
3. Documentar no template.
4. Estágio CI com docker.

## Como testar

```bash
docker compose -f docker-compose.test.yml up -d
pytest -m taac -v --timeout=300
```

## Como revisar

Checklist `checklists/code-review-testes.md`.

## Como reportar resultado

PR indicando o que integra, como rodar local, tempo de execução.

## Critérios de aceite

- [ ] Determinístico
- [ ] Sem dep de ambiente compartilhado
- [ ] Documentado

## O que não fazer

- Dados reais de produção
- Sleep fixo para sincronização
- BDD em teste puramente técnico
