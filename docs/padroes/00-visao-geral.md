# Visão geral dos padrões deste repositório

## Propósito

Base versionada de engenharia para alinhar desenvolvedores internos, terceiros e agentes de IA.

**Modelo de repositórios:** multi-repo — ver [18-estrutura-repositorios.md](18-estrutura-repositorios.md). Este conteúdo de padrões pode viver em repo dedicado; o código de produção fica em repos separados por stack/componente.

## Escopo técnico

| Stack | Uso típico |
|-------|------------|
| Airflow | Orquestração de pipelines |
| dbt | Transformação e modelagem analítica |
| Terraform | Infraestrutura AWS |
| Lambda (Python) | Processamento event-driven, integrações leves |
| Java Spring Boot | APIs e serviços transacionais |
| AWS Glue | ETL/ELT distribuído (PySpark) |

## Estrutura de documentação

```
docs/
├── padroes/          ← padrões 00–19 + templates
├── adr/              ← decisões arquiteturais
└── runbooks/         ← operação e incidentes
examples/             ← código mínimo de referência
```

## Princípios transversais

1. **Separação de responsabilidades** — negócio ≠ orquestração ≠ infra.
2. **Testabilidade** — 90% cobertura; 90% mutation onde aplicável.
3. **Observabilidade** — logs JSON, métricas, traces, alertas com runbook.
4. **Performance e custo** — pensar volume antes de codificar.
5. **Idempotência** — reprocessamento seguro é requisito, não opcional.
6. **Segurança** — least privilege, segredos externos, auditoria.

## Para humanos

1. Leia o padrão da sua stack antes do primeiro PR.
2. Use templates em `docs/padroes/templates/`.
3. Consulte checklists em `checklists/` no review.
4. Proponha melhorias via PR nos próprios padrões.

## Para agentes de IA

| Ferramenta | Comece por |
|------------|------------|
| Cursor | [`CURSOR.md`](../../CURSOR.md) na raiz |
| Claude Code | [`CLAUDE.md`](../../CLAUDE.md) na raiz |
| Devin | [`DEVIN.md`](../../DEVIN.md) na raiz |
| Qualquer agente | [`AGENTS.md`](../../AGENTS.md) na raiz |

Depois:

1. Consulte `docs/padroes/` da stack relevante.
2. Use skill em `.claude/skills/` (Claude) ou `.agents/skills/` (Devin).
3. Siga Definition of Done em `16-definition-of-done.md`.

## Trade-off: velocidade vs. padronização

**Recomendação:** padronizar desde o primeiro componente. O custo de divergência em 4 meses com múltiplos times supera o custo inicial de seguir templates e skills.

**Exceção:** spike técnico com prazo < 2 dias pode ter DoD reduzida — documentar débito no PR e criar issue de convergência.

## Próximos passos sugeridos

1. Tech leads ajustam naming `{nome-projeto}` e mapa de repositórios em `18-estrutura-repositorios.md`.
2. Onboarding: `19-onboarding.md`.
3. Piloto em uma feature ponta a ponta.
4. Feedback vira PR nos padrões/skills.
