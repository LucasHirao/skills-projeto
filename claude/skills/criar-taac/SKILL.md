---
name: criar-taac
description: Criar testes integrados (TaaC) na pipeline CI de {nome-projeto} com ambiente autocontido e contratos validados.
---

# Criar TaaC

## Quando usar

- Integração nova com S3, fila, DB, API ou Catálogo
- Wiring que mock unitário não cobre
- Contract test entre produtor e consumidor

## Pré-leitura

- [11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [10 — Testes unitários](../../docs/engineering-handbook/10-testes-unitarios.md)
- Capítulo da stack (04–09)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `{nome-projeto}-glue` |
| Integração | Sim | Escrita S3 + leitura dbt source |
| Ferramenta | Sim | LocalStack, Testcontainers |
| Tempo CI aceitável | Sim | < 5 min |
| Contrato | Sim | Path, schema, headers |

## Passos

1. Plano: o que o TaaC prova que unitário não prova.
2. Ambiente autocontido — sem depender de hml compartilhado.
3. Fixture de dados sintéticos (sem PII).
4. Arrange: sobe container/stack mínima.
5. Act: executa componente real (handler, job, DAG task isolada).
6. Assert: estado externo (objeto S3, mensagem fila, row DB).
7. Teardown determinístico.
8. Documentar em [template teste-integrado](../../docs/engineering-handbook/templates/teste-integrado.md).
9. Integrar na CI com tag/markers (`integration`).
10. Manter poucos cenários de alto valor — não duplicar E2E.

## Checklist de qualidade

- [ ] Teste focado em integração, não re-testa toda unit
- [ ] Nome descreve cenário de negócio
- [ ] Flaky tratado (retry só com justificativa)

## Checklist de testes

- [ ] Roda na CI de forma isolada
- [ ] Falha clara quando contrato quebra
- [ ] Complementa (não substitui) unitários ≥ 90%

## Checklist de observabilidade

- [ ] Logs do teste permitem debug em falha
- [ ] `correlation_id` propagado no cenário, se aplicável

## Checklist de desempenho

- [ ] Tempo de pipeline aceitável
- [ ] Dados mínimos para provar wiring

## Checklist de segurança

- [ ] Sem credencial prod; credenciais de teste efêmeras
- [ ] Sem dump de dados reais

## Critérios de aceite

- TaaC verde na CI
- DoD §1.2 e capítulo 11 atendidos
- README atualizado com como rodar local

## O que não fazer

- E2E de jornada inteira no lugar de TaaC focado
- Ambiente compartilhado entre pipelines
- Dados de produção copiados
- TaaC que só asserta status HTTP 200

## Como reportar

- Cenário coberto e comandos (`pytest -m integration`)
- Tempo de execução na CI
- Dependências de container adicionadas

## Fonte de verdade

- [11 — TaaC](../../docs/engineering-handbook/11-taac-testes-integrados-na-pipeline.md)
- [Template — teste-integrado](../../docs/engineering-handbook/templates/teste-integrado.md)
