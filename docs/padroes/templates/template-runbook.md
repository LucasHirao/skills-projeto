# Runbook: {Nome do incidente/fluxo}

## Sintoma

{O que o operador ou alerta observa.}

## Severidade

{Baixa | Média | Alta | Crítica}

## Impacto

{O que deixa de funcionar; quem é afetado.}

## Diagnóstico rápido

1. Verificar dashboard: {link}
2. Buscar logs: `{query}`
3. Checar última execução: {Airflow/Glue/Lambda}

## Causas comuns

| Causa | Como confirmar | Ação |
|-------|----------------|------|
| | | |

## Mitigação

### Imediata
1. 

### Definitiva
1. 

## Reprocessamento

```bash
{comandos de backfill/replay}
```

## Escalação

- **Time:** 
- **Contato:** 

## Pós-incidente

- [ ] Atualizar este runbook
- [ ] Criar ADR se decisão estrutural
- [ ] Ajustar alerta se falso positivo
