<!-- Sincronizado de .claude/skills/criar-taac/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: criar-taac
description: >-
  Cria testes integrados autocontidos (TaaC) na pipeline projeto com Testcontainers,
  LocalStack ou WireMock. Use para validar integração AWS, DB, API ou pipeline
  entre componentes sem ambiente compartilhado.
---

# Criar TaaC

**Referência:** `docs/padroes/09-taac-testes-integrados-pipeline.md` | **Template:** `docs/padroes/templates/template-teste-integrado.md`

## Quando usar

Integração nova entre componentes; unitários não cobrem wiring real.

## Entradas esperadas

- Componentes sob teste e limites
- Dependências (DB, S3, API)
- Cenários e dados fixture
- Tempo máximo aceitável

## Passo a passo

1. Definir escopo (component, não E2E completo).
2. Escolher stack: Testcontainers / LocalStack / moto / WireMock.
3. Criar fixture determinística + cleanup.
4. Marcar `@pytest.mark.taac` ou perfil Maven `integration`.
5. Documentar em template-teste-integrado.md.
6. Adicionar estágio na CI (docker).
7. Garantir <5-10 min por suite.

## Checklist de qualidade

- [ ] Autocontido — sem depender de prod
- [ ] Isolamento entre testes
- [ ] Nomes de cenário claros

## Checklist de testes

- [ ] Happy path + erro de integração
- [ ] Contrato/schema validado se API
- [ ] Determinístico (sem sleep fixo)

## Checklist de observabilidade

- [ ] Logs de debug desligados em CI; habilitáveis local

## Checklist de performance

- [ ] Timeout explícito
- [ ] Não duplicar E2E lento

## Armadilhas comuns

- Testar ambiente compartilhado
- E2E de 30 min na PR
- BDD desnecessário em teste técnico

## Resultado esperado

TaaC na CI, documentado, reproduzível localmente com docker.

## Exemplo de prompt

```
Use criar-taac. Teste integração Lambda+DynamoDB com LocalStack, fixture
pedido.json, marker taac, cleanup após teste. Template preenchido.
```

