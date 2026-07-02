---
name: criar-testes-unitarios
description: Criar ou ampliar testes unitários e mutation em {nome-projeto} com cobertura ≥90% e asserts de comportamento.
---

# Criar testes unitários

## Quando usar

- Novo módulo de domínio ou caso de uso
- Cobertura abaixo de 90% ou mutation insuficiente
- Regressão após bugfix

## Pré-leitura

- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- [12 — Testes de mutação](../../docs/engineering-handbook/12-testes-de-mutacao.md)
- [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `lambda-processa-arquivo` |
| Módulo alvo | Sim | `domain/servicos/validar_arquivo.py` |
| Comportamentos | Sim | Rejeitar extensão inválida |
| Stack de teste | Sim | pytest, JUnit, etc. |
| Meta mutation | Se domain/app | ≥ 90% |

## Passos

1. Listar comportamentos esperados (feliz, borda, erro).
2. Nomear testes em português: `deve_rejeitar_quando_extensao_invalida`.
3. Arrange-Act-Assert; um conceito por teste.
4. Mock só na fronteira (repositório, cliente HTTP) — não o SUT.
5. Cobrir branches e exceções de domínio.
6. Rodar coverage; fechar gaps com testes de comportamento.
7. Rodar mutation em `domain/`/`application/`; fortalecer asserts fracos.
8. Evidência no PR (comando + %).

## Checklist de qualidade

- [ ] Testes legíveis sem comentário óbvio
- [ ] Sem duplicação excessiva de setup (fixtures)
- [ ] Testes independentes e determinísticos

## Checklist de testes

- [ ] Cobertura de linha ≥ 90%
- [ ] Mutation ≥ 90% em domain/application
- [ ] Casos de borda e erro cobertos
- [ ] Sem `assert True` ou teste vazio

## Checklist de observabilidade

- [ ] N/A para unitários puros (validar em TaaC se log crítico)

## Checklist de desempenho

- [ ] Suite rápida (< few min); pesado vai para TaaC
- [ ] Sem sleep arbitrário

## Checklist de segurança

- [ ] Fixtures sem PII real
- [ ] Sem credenciais em arquivos de teste

## Critérios de aceite

- Gates de coverage/mutation da CI verdes
- DoD §1.2 em [18](../../docs/engineering-handbook/18-definition-of-done.md)

## O que não fazer

- Testar implementação interna frágil
- Mock em excesso mascarando wiring
- Teste que só verifica que mock foi chamado
- Pular mutation "por tempo"

## Como reportar

- Comando executado e % coverage/mutation
- Comportamentos novos cobertos (lista)
- Gaps conhecidos justificados no PR

## Fonte de verdade

- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- [12 — Testes de mutação](../../docs/engineering-handbook/12-testes-de-mutacao.md)
