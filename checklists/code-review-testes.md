# Checklist: Code Review Testes

## Perguntas objetivas

- [ ] Cobertura ≥ 90% (exceções justificadas)?
- [ ] Mutation ≥ 90% onde aplicável?
- [ ] Testes assertam comportamento?
- [ ] Nomes descrevem cenário?
- [ ] TaaC para integrações novas?
- [ ] Fixtures determinísticas?
- [ ] Sem dependência de ambiente compartilhado?

## 🔴 Bloqueio

- Teste sem assert relevante
- Queda de cobertura sem justificativa
- Integração crítica só com mock

## 🟡 Atenção

- Mock excessivo em domínio
- Teste flaky (timing, ordem)

## Exemplos de comentário

> 🔴 `test_handler` não verifica resposta — adicionar assert em `processados`.

> 🟡 Flaky: sleep(5) — usar awaitility/polling com timeout.
