# Playbook — Criar TaaC

Prompt reutilizável para testes integrados na pipeline (TaaC) no ecossistema `{nome-projeto}`.

## Fonte de verdade

- [11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- [02 — Arquitetura transversal](../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [Template teste integrado](../../docs/engineering-handbook/templates/teste-integrado.md)

---

## Nomenclatura de código

Ao implementar ou revisar código:

- Use português para identificadores internos criados pelo time.
- Preserve nomes externos, SDKs, frameworks, contratos públicos, schemas, comandos e tags técnicas.
- Não renomeie contrato público existente sem versionamento/migração.
- Consulte [03 — Padrões de código](../../docs/engineering-handbook/03-padroes-de-codigo.md).


## Prompt

```
Crie um teste integrado na pipeline (TaaC) para o ecossistema {nome-projeto}.

## Contexto
- Repositório: {org}/{repo}
- Fluxo sob teste: {ex. DAG X → Glue Y → S3 path Z → dbt model W}
- Contrato:
  - Entrada: {schema, formato, path}
  - Saída: {schema, grain, path, row count esperado}
  - correlation_id: {como injetar e rastrear}
- Ambiente CI: {LocalStack | conta ephemeral | container}
- Componentes externos simulados: {lista}

## Antes de editar (obrigatório)
Plano com:
1. Cenário happy path e pelo menos 1 caso de falha
2. Dados sintéticos (sem PII)
3. Setup/teardown de recursos
4. Tempo máximo aceitável na CI
5. Onde o teste vive (path) e como é disparado na pipeline
6. Relação com testes unitários existentes (não duplicar)

## Implementação
Skill: criar-taac

- Arquivo de teste determinístico
- Asserts de comportamento observável (não estado interno)
- Mensagens de falha acionáveis para o operador
- Documentação com [template teste-integrado](../../docs/engineering-handbook/templates/teste-integrado.md)
- Tag/stage `taac` na CI

## Evidências finais
- Comando de execução local e output
- Tempo de execução
- Link para contrato documentado no README do componente
- Checklist DoD seção TaaC em [18](../../docs/engineering-handbook/18-definition-of-done.md)

Se o contrato entre repos mudar, atualize TaaC **no mesmo PR** ou PR irmão referenciado.
```

---

## Quando usar

- Nova integração entre componentes
- Regressão após incidente de dados
- Validação de contrato S3/fila antes de deploy em produção
