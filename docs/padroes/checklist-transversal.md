# Checklist transversal (skills)

Use em **toda** entrega de código, além do checklist da stack em `checklists/`.

## Qualidade

- [ ] Aderência a `docs/padroes/` e rule da stack
- [ ] Lógica de negócio fora de handler/DAG/Terraform
- [ ] Nomes explícitos; arquivos coesos

## Testes

- [ ] Cobertura ≥ 90% (exceções justificadas no PR)
- [ ] Assert de comportamento, não só execução
- [ ] Mutation ≥ 90% em domain/application quando aplicável
- [ ] TaaC se há integração real

## Observabilidade

- [ ] Log JSON + `correlation_id`
- [ ] Métricas sucesso/erro/duração/volume
- [ ] Sem PII em log
- [ ] Runbook/alerta se fluxo crítico novo

## Performance

- [ ] Volume esperado considerado
- [ ] Sem I/O em loop / N+1 / full scan evitável
- [ ] Batch, paginação ou partition quando couber

## Multi-repo

- [ ] PR em um repo de código por vez
- [ ] Contratos cross-repo atualizados (README, outputs TF, schema)
