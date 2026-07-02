# Documentação

## Regra de ouro

Toda documentação deve responder:

1. **O que é**
2. **Por que existe**
3. **Como roda**
4. **Como testa**
5. **Como opera**
6. **Como debuga**
7. **Quais contratos não podem quebrar**

## Tipos de documento

| Tipo | Quando | Template |
|------|--------|----------|
| README componente | Todo serviço/job/lambda/módulo | `templates/template-readme-servico.md` |
| ADR | Decisão arquitetural relevante | `templates/template-adr.md` |
| Runbook | Operação e incidentes | `templates/template-runbook.md` |
| PR | Toda mudança | `templates/template-pr.md` |
| Dashboard | Novo fluxo crítico | `templates/template-dashboard.md` |
| TaaC | Teste integrado novo | `templates/template-teste-integrado.md` |
| C4 | Arquitetura de fluxo | `templates/template-c4.md` |
| Dicionário de dados | Mart crítico | `templates/template-dicionario-dados.md` |

## O que documentar por stack

### Endpoints (Spring)

- OpenAPI atualizado.
- Autenticação, rate limit, erros.
- Exemplos request/response.

### DAGs

- `doc_md` na DAG: SLA, idempotência, reprocessamento.
- Dependências externas e sensores.

### dbt models

- `description` no schema.yml.
- Colunas críticas e regras de negócio.
- Estratégia incremental.

### Glue jobs

- Parâmetros do job.
- Schema entrada/saída.
- Particionamento e modo write.

### Lambdas

- Formato do evento.
- Erros retornáveis vs DLQ.
- Variáveis de ambiente.

### Terraform modules

- Inputs/outputs.
- Recursos criados.
- Permissões IAM.

## Contratos e lineage

- Dicionário de dados para marts críticos.
- Lineage dbt (`exposures`) para consumidores.
- Versão de schema em eventos (Avro/JSON Schema quando aplicável).

## Estratégias operacionais

Documentar explicitamente:

- Idempotência (chave, comportamento em retry).
- Falhas (retry, DLQ, skip, alerta).
- Reprocessamento/backfill.
- Observabilidade (logs, métricas, dashboards).

## Documentação para IA

- Nomes de arquivos alinhados ao domínio.
- README com comandos copy-paste.
- Links para ADRs relacionados.
- Evitar conhecimento só oral.

## Manutenção

- PR que muda contrato **deve** atualizar doc.
- Runbook revisado após cada incidente relevante.
- ADR superseded quando decisão muda.
