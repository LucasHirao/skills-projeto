---
name: criar-testes-unitarios
description: Cria ou amplia testes unitários e de mutação no {nome-projeto} com cobertura ≥90% e asserts de comportamento. Use ao testar domain, application, transforms ou módulos sem integração real.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{repo} {caminho_modulo} {comportamentos a cobrir}"
triggers:
  - criar testes unitários
  - aumentar cobertura
  - testes de mutação
  - pytest junit
---

# criar-testes-unitarios

## Fonte de verdade

- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- [12 — Testes de mutação](../../docs/engineering-handbook/12-testes-de-mutacao.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Novo módulo sem testes ou cobertura abaixo de 90%
- Refatoração que exige rede de segurança
- Mutation score insuficiente em `domain/` / `application/`

## Passos

1. Mapear comportamentos públicos do módulo (não implementação).
2. **Plano** com casos limite, erros e happy path.
3. Testes com nomes descritivos; arrange-act-assert.
4. Mocks só na borda (I/O); domain sem mock excessivo.
5. Rodar coverage e mutation localmente; anexar evidência.
6. Não testar getter/setter trivial ou framework.

## Checklist DoD (recorte)

- [ ] Cobertura ≥ 90% no escopo do PR
- [ ] Mutation ≥ 90% em domain/application (onde aplicável)
- [ ] Asserts de comportamento, não `assert True`
- [ ] CI verde com mesmos comandos locais
- [ ] Sem flake (tempo, ordem, rede)

## Templates

- [pr](../../docs/engineering-handbook/templates/pr.md)

## Não fazer

Ver anti-padrões em [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md).
