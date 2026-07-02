# Runbook: {Nome do incidente ou fluxo}

- **Owner:** {time/pessoa}
- **Última revisão:** YYYY-MM-DD
- **Dashboard:** {URL Datadog}
- **Monitors relacionados:** {nomes ou links}

## Sintoma

{O que o operador ou alerta Datadog observa — mensagem exata do monitor se possível.}

**Monitor exemplo:**

```
[PROD] {nome} — {condição}
```

## Severidade

| Nível | Critério |
|-------|----------|
| **P1** | {ex.: dados críticos parados > 1h} |
| **P2** | {ex.: degradação com workaround} |
| **P3** | {ex.: risco iminente} |

**Esta runbook:** {P1 | P2 | P3}

## Impacto

- **Negócio:** {relatórios, SLAs, consumidores}
- **Técnico:** {DAGs, models, APIs afetados}
- **Dados:** {marts, tabelas, partições}

## Diagnóstico rápido (≤ 15 min)

1. **Dashboard:** abrir {URL} — painéis {X, Y}
2. **Logs Datadog:**
   ```
   service:{serviço} status:FAILURE @correlation_id:{id}
   ```
3. **Última execução bem-sucedida:** {Airflow UI | Glue console | Lambda logs}
4. **Dependência upstream:** {S3 path, API, fila — como verificar}
5. **Métrica chave:** `{métrica}` — valor atual vs threshold

## Árvore de decisão

```
Alerta disparou?
├─ Não → verificar falso positivo / threshold
└─ Sim → upstream OK?
    ├─ Não → escalar origem / aguardar arquivo
    └─ Sim → qual componente falhou?
        ├─ Glue → seção Glue abaixo
        ├─ dbt → seção dbt abaixo
        └─ Lambda/API → seção X abaixo
```

## Causas comuns

| Causa | Como confirmar | Ação imediata |
|-------|----------------|---------------|
| {ex.: arquivo fonte atrasou} | {S3 empty, sensor timeout} | {contatar origem} |
| {ex.: job Glue falhou} | {CloudWatch / Datadog logs} | {corrigir + reprocessar} |
| {ex.: teste dbt falhou} | {logs task dbt} | {corrigir model} |
| {ex.: concorrência} | {2 runs ativas} | {pausar DAG} |

## Mitigação

### Imediata (conter)

1. 
2. 

### Definitiva (corrigir causa raiz)

1. 
2. 

## Reprocessamento

**Pré-condição:** {idempotência confirmada — ver ADR/README}

```bash
# Exemplo Airflow
airflow dags trigger {dag_id} \
  --conf '{"data_referencia": "YYYY-MM-DD", "correlation_id": "reprocess-manual-{uuid}"}'

# Exemplo dbt
dbt build --select {selector} --vars '{"data_referencia": "YYYY-MM-DD"}'

# Exemplo Glue / Lambda
{comando}
```

**Validação pós-reprocessamento:**

- [ ] Métrica `{métrica}` normalizada
- [ ] `dbt test` / testes de qualidade verdes
- [ ] Consumidores downstream atualizados

## Escalação

| Nível | Contato | Quando |
|-------|---------|--------|
| L1 | {plantão dados} | Após 30 min sem resolução |
| L2 | {tech lead} | Impacto P1 ou dados incorretos |
| L3 | {infra/AWS} | Capacidade, permissão, região |

## Comunicação

- Canal interno: {Slack}
- Status page / stakeholders: {se aplicável}

## Pós-incidente

- [ ] Atualizar este runbook (nova causa?)
- [ ] Ajustar threshold do monitor se falso positivo
- [ ] Criar ADR se decisão estrutural
- [ ] Postmortem se P1/P2 (blameless)
- [ ] Ticket de follow-up: {link}

## Referências

- README do componente: {link}
- ADR: {link}
- Handbook: [13 — Observabilidade](../13-observabilidade.md)
