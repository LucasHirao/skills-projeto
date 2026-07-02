# Definition of Done (DoD)

Uma tarefa só está **pronta** quando todos os itens aplicáveis abaixo estão atendidos **no(s) repositório(s) de código** tocados.

**Multi-repo:** um PR por repositório. Se a entrega cruzar repos, cada PR deve referenciar os demais e os contratos compartilhados.

## Código e padrões

- [ ] Implementação segue `docs/padroes/` da stack
- [ ] Sem lógica de negócio em handler/DAG/Terraform indevida
- [ ] Lint/format aplicado

## Testes

- [ ] Testes unitários com **cobertura ≥ 90%** (exceções justificadas)
- [ ] **Mutation score ≥ 90%** onde aplicável
- [ ] **TaaC** quando há integração relevante
- [ ] Evidência de execução local ou CI anexada no PR

## Qualidade transversal

- [ ] Segurança validada (least privilege, sem segredos)
- [ ] Observabilidade: logs JSON, métricas, correlation_id
- [ ] Performance avaliada para volume esperado
- [ ] Idempotência e reprocessamento documentados

## Documentação e decisões

- [ ] README/runbook atualizados se impacto operacional
- [ ] **ADR** criado se decisão arquitetural relevante
- [ ] Contratos públicos compatíveis ou **breaking change** explícito

## Operação

- [ ] Dashboard/alerta/runbook se fluxo novo ou crítico
- [ ] Feature flags consideradas (se aplicável) — rollout e rollback
- [ ] Pipeline CI **verde**

## Review

- [ ] Code review aprovado (humano obrigatório para merge)
- [ ] Checklists da stack consultados

## Exceções temporárias

Spike < 2 dias: DoD reduzida permitida com:

1. Label `spike` no PR
2. Débito técnico listado
3. Issue de convergência criada

## Por tipo de entrega

| Entrega | Itens extras |
|---------|--------------|
| DAG Airflow | parse test, doc_md, callback falha |
| Model dbt | schema.yml, dbt build |
| Terraform | plan no PR, tfsec |
| Lambda | handler fino, DLQ se async |
| API Spring | OpenAPI, testes slice/IT |
| Glue | transform testável, particionamento |
