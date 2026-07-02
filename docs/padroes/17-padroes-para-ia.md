# Padrões para IA

## Como pedir tarefas eficazes

### Estrutura de prompt recomendada

```
Contexto: [módulo, stack, link doc]
Objetivo: [resultado observável]
Restrições: [padrões, não fazer X]
Entregáveis: [código + testes + doc]
Critério de aceite: [DoD específica]
```

### Quebrar tarefas grandes

| Em vez de | Peça |
|-----------|------|
| "Implemente o pipeline completo" | 1) ADR estratégia 2) Terraform 3) Glue 4) dbt 5) DAG 6) TaaC |
| "Refatore tudo" | Um módulo por PR com testes |

## Templates de prompt

### Implementar feature

```
Leia AGENTS.md e docs/padroes/{stack}.md.
Implemente {feature} em {path}.
Plano antes de editar. Inclua testes (90% cov), logs estruturados.
Não invente regra de negócio — liste dúvidas.
```

### Revisar PR

```
Revise este diff contra checklists/{stack}.md e docs/padroes/14-code-review.md.
Classifique achados em bloqueio/atenção/sugestão.
```

### Criar testes

```
Para {módulo}, crie testes unitários (90% cov) e TaaC se houver integração.
Siga docs/padroes/08 e 09. Nomes descritivos, asserts de comportamento.
```

### Melhorar performance

```
Analise {componente} para volume {N}.
Liste gargalos com evidência. Proponha mudança mínima com baseline.
```

### Melhorar observabilidade

```
Adicione logs JSON, métricas e correlation_id em {componente}.
Siga docs/padroes/11-observabilidade.md. Sem dados sensíveis.
```

### Investigar bug

```
Sintoma: {X}. Logs/métricas: {Y}.
Hipóteses ordenadas. Não corrigir sem reproduzir com teste.
```

## Anti-padrões

| Evitar | Por quê |
|--------|---------|
| "Implemente tudo" sem contexto | Código inventado |
| Aceitar sem teste | Regressão |
| Aceitar dependência não listada no projeto | Build quebrado |
| Overengineering | Manutenção cara |
| Merge sem entender impacto em dados | Incidente prod |

## Validar saída da IA

1. Rodar testes e lint localmente.
2. Verificar imports e deps no `pyproject.toml`/`pom.xml`.
3. Conferir aderência ao padrão do diretório vizinho.
4. Review humano obrigatório.

## Ferramentas

| IA | Guia | Skills / playbooks |
|----|------|-------------------|
| Claude Code | [CLAUDE.md](../../CLAUDE.md) | `.claude/skills/` |
| Devin | [DEVIN.md](../../DEVIN.md) | `devin/skills/`, `devin/playbooks/` |
