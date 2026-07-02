# ADR-{NNN}: {Título da decisão}

- **Status:** Proposta | Aceita | Depreciada | Substituída por [ADR-XXX](XXX-titulo.md)
- **Data:** YYYY-MM-DD
- **Autores:** {nomes}
- **Decisores:** {tech lead / arquitetura}
- **Repositórios afetados:** {org/repo-1, org/repo-2}

## Contexto

{Qual problema ou força motivou a decisão? Incluir volume, SLA, restrições regulatórias ou incidente que levou à discussão.}

## Decisão

{O que foi decidido, de forma clara e testável. Uma frase principal + bullets se necessário.}

## Alternativas consideradas

| Alternativa | Prós | Contras |
|-------------|------|---------|
| A — {nome} | | |
| B — {nome} | | |
| C — status quo | | |

## Consequências

### Positivas

- 

### Negativas / trade-offs

- 

## Impacto

| Área | Detalhe |
|------|---------|
| **Componentes** | {Lambdas, DAGs, models dbt, módulos TF} |
| **Contratos/dados** | {schema, paths S3, APIs} |
| **Operação** | {runbooks, alertas Datadog, reprocessamento} |
| **Custo AWS** | {estimativa ou ordem de grandeza} |
| **Segurança** | {IAM, PII, criptografia} |
| **Multi-repo** | {PRs necessários e ordem de deploy} |

## Plano de implementação

1. {Passo — repo, PR, dependência}
2. 
3. 

## Critérios de sucesso

- [ ] {Métrica ou comportamento verificável}
- [ ] {SLO ou teste TaaC passando}

## Referências

- Handbook: [docs/engineering-handbook/{capítulo}.md](../../{capítulo}.md)
- Incidente / ticket: {link}
- Documentação externa: {link}
