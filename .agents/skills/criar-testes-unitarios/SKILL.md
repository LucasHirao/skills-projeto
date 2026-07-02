<!-- Sincronizado de .claude/skills/criar-testes-unitarios/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: criar-testes-unitarios
description: >-
  Cria ou melhora testes unitários projeto com cobertura 90% e asserts de comportamento.
  Use para pytest, JUnit, testes de DAG parse, transforms ou domínio sem integração.
---

# Criar testes unitários

**Referência:** `docs/padroes/08-testes-unitarios.md` | **Regra:** `.claude/rules/testes.md`

## Quando usar

Código novo sem testes, cobertura abaixo de 90%, testes frágeis ou superficiais.

## Entradas esperadas

- Módulo/classe alvo
- Comportamentos críticos e casos limite
- Stack (Python/Java/Airflow/dbt)

## Passo a passo

1. Mapear comportamentos observáveis (não implementação).
2. Nomear `deve_{resultado}_quando_{condição}`.
3. Given/When/Then em estrutura ou comentários.
4. Mock só na borda (I/O, AWS, DB).
5. Rodar cobertura; fechar gaps em lógica de negócio.
6. Justificar exceções (DTO, bootstrap) no PR.

## Checklist de qualidade

- [ ] Assert em resultado observável
- [ ] Independente e determinístico
- [ ] Sem duplicação excessiva

## Checklist de testes

- [ ] Line coverage ≥90%
- [ ] Branch coverage se disponível
- [ ] Casos limite e erro

## Checklist de observabilidade

- N/A para unitários puros (validar em TaaC)

## Checklist de performance

- [ ] Testes rápidos (<1s cada quando possível)

## Armadilhas comuns

- `assert_called_once` como único assert
- Testar getter/setter trivial
- Fixture gigante compartilhada com efeito colateral

## Resultado esperado

Suite rápida, ≥90% cov, prova comportamento crítico.

## Exemplo de prompt

```
Use criar-testes-unitarios. Cobrir domain/calculo.py com pytest, 90% cov,
casos valor negativo e lista vazia. Sem mock no domínio.
```

