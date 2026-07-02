# AGENTS.md — Instruções para agentes de IA

Documento central interoperável para Cursor, Claude Code, Devin e outros agentes que trabalham neste repositório.

## Contexto

Repositório de engenharia de dados e integrações na AWS: orquestração (Airflow), transformação (dbt), infraestrutura (Terraform), processamento (Glue, Lambda Python) e APIs (Java Spring Boot). Pode envolver equipe interna e terceiros em paralelo.

**Risco principal:** implementações divergentes sem identidade comum em DAGs, jobs, models, Terraform, testes e documentação.

**Objetivo destes padrões:** garantir que humanos e agentes sigam a mesma base versionada de qualidade, observabilidade, performance e arquitetura.

## Princípios inegociáveis

1. **Não inventar regra de negócio** — se o requisito não está documentado, perguntar ou propor explicitamente como hipótese.
2. **Consultar documentação antes de implementar** — ler `docs/padroes/`, ADRs, README do componente e código existente.
3. **Sempre criar ou atualizar testes** — cobertura mínima 90%; mutation score 90% onde aplicável.
4. **Sempre avaliar observabilidade e performance** — logs estruturados, métricas, traces e impacto de volume/custo.
5. **Preservar compatibilidade** — não quebrar contratos públicos sem destacar breaking change.
6. **Registrar decisões relevantes em ADR** — usar `docs/padroes/templates/template-adr.md` e `docs/adr/`.
7. **Idempotência e reprocessamento** — todo pipeline/job deve ser pensado para reexecução segura.
8. **Segurança por padrão** — least privilege, segredos fora do código, dados sensíveis mascarados.
9. **Código pequeno e explícito** — nomes claros, arquivos menores, lógica de negócio fora de handlers/DAGs/Terraform.

## Onde encontrar padrões

| Tipo | Local |
|------|-------|
| **Como usar no Cursor** | [`CURSOR.md`](CURSOR.md) |
| **Como usar no Claude Code** | [`CLAUDE.md`](CLAUDE.md) |
| **Como usar no Devin** | [`DEVIN.md`](DEVIN.md) |
| Documentação humana completa | `docs/padroes/` |
| Exemplos mínimos executáveis | `examples/` |
| ADRs | `docs/adr/` |
| Runbooks | `docs/runbooks/` |
| Regras operacionais (Claude Code) | `.claude/rules/` |
| Regras operacionais (Cursor) | `.cursor/rules/` |
| Skills procedimentais (Claude Code) | `.claude/skills/` |
| Skills (Devin/outros) | `.agents/skills/` |
| Playbooks Devin | `devin-playbooks/` |
| Checklists de review | `checklists/` |
| Templates | `docs/padroes/templates/` |
| Onboarding | `docs/padroes/19-onboarding.md` |
| Estrutura multi-repo | `docs/padroes/18-estrutura-repositorios.md` |
| Definition of Done | `docs/padroes/16-definition-of-done.md` |

## Início rápido por ferramenta

| Ferramenta | Arquivo na raiz | O que fazer |
|------------|-----------------|-------------|
| Cursor | `CURSOR.md` + `AGENTS.md` | Rules em `.cursor/rules/` |
| Claude Code | `CLAUDE.md` | Rules e skills em `.claude/` |
| Devin | `DEVIN.md` | Playbooks e `.agents/skills/` |

## Build, test e lint

Use o **pipeline e comandos já configurados no ambiente** do repositório. Antes de merge, garantir que os gates locais equivalentes passam (testes, lint, fmt, validate).

Referência de comandos por stack (na raiz de **cada** repo de código): `docs/padroes/18-estrutura-repositorios.md`.

**Não é monorepo** — um PR = um repositório de código; padrões vivem neste repo de orientações.

## Padrão de resposta esperado dos agentes

1. **Entender** — resumir o pedido e listar arquivos/docs consultados.
2. **Planejar** — plano curto antes de editar (escopo, riscos, testes).
3. **Implementar** — mudança mínima necessária, seguindo padrões existentes.
4. **Testar** — rodar testes/lint quando possível; reportar resultado.
5. **Reportar** — o que mudou, por quê, impactos (contrato, dados, custo, ops), breaking changes e próximos passos.

## Quando alterar código vs. apenas propor

| Situação | Ação |
|----------|------|
| Tarefa clara, padrões definidos, escopo pequeno | Implementar |
| Decisão arquitetural relevante | Propor + ADR antes de implementar |
| Contrato público ou schema de dados | Propor com análise de impacto |
| Requisito de negócio ambíguo | Perguntar; não assumir |
| Mudança de infra destrutiva | Propor plan + rollback |

## Como lidar com dúvidas

1. Buscar em `docs/padroes/`, `examples/`, ADRs e código similar existente.
2. Se ainda houver dúvida, listar opções com trade-offs e recomendação.
3. Não bloquear em detalhe cosmético — seguir convenção do módulo mais próximo.
4. Em dúvida de negócio, **parar e perguntar**.

## Skills — quando usar

- `criar-dag-airflow`, `criar-modelo-dbt`, `criar-modulo-terraform`
- `criar-lambda-python`, `criar-api-spring-boot`, `criar-job-glue`
- `criar-testes-unitarios`, `criar-taac`
- `revisar-pr`, `melhorar-observabilidade`, `revisar-performance`

## Pirâmide de qualidade (resumo)

```
        E2E / smoke (poucos)
      TaaC / integração (focados)
    Testes unitários (muitos, 90% cov)
  Lint / fmt / validate / security scan
```

## Exceções documentadas

- DTO puro, bootstrap e código gerado podem ter cobertura reduzida — **justificar no PR**.
- Mutation testing não é obrigatório em Terraform, SQL literal dbt ou DAG declarativa — aplicar em lógica de negócio/transformação.
- BDD só quando Gherkin ajuda alinhamento negócio/QA — não é padrão para todo teste técnico.

## Manutenção

- Padrões vivem no repositório; PRs que introduzem nova convenção devem atualizar docs correspondentes.
- Skills canônicas em `.claude/skills/`; sincronizar com `.agents/skills/` via `scripts/sync-skills.ps1`.
