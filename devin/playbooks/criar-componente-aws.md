# Playbook — Criar componente AWS

Prompt reutilizável para Lambda, Glue job ou infraestrutura AWS associada no `{nome-projeto}`.

## Fonte de verdade

- [06 — Terraform](../../docs/engineering-handbook/06-terraform.md)
- [07 — Lambda Python](../../docs/engineering-handbook/07-lambda-python.md)
- [09 — AWS Glue](../../docs/engineering-handbook/09-aws-glue.md)
- [13 — Observabilidade](../../docs/engineering-handbook/13-observabilidade.md)
- [18 — Definition of Done](../../docs/engineering-handbook/18-definition-of-done.md)

---

## Prompt

```
Crie ou altere um componente AWS no ecossistema {nome-projeto}.

## Contexto
- Tipo: {lambda-python | glue-job | ambos + terraform}
- Repositório de código: {org}/{nome-projeto}-{lambda|glue}
- Repositório IaC: {org}/{nome-projeto}-terraform
- Nome do componente: {nome}
- Trigger / entrada: {api gateway | sqs | s3 event | schedule | airflow operator}
- Saída / contrato: {s3 path | fila | tabela | api response}
- Volume esperado: {registros/dia ou RPS}
- Capítulo handbook: ../../docs/engineering-handbook/{07|09|06}-{stack}.md

## Antes de editar (obrigatório)
Plano em 5–10 bullets:
- Recursos AWS (IAM, filas, buckets, alarms)
- Timeout, memória, retry, DLQ
- Idempotência e poison message
- Ordem de deploy: Terraform antes do código (ou feature flag)
- Estimativa de custo mensal
- PRs necessários (IaC separado do código)

## Implementação
### IaC ({nome-projeto}-terraform)
Skill: criar-modulo-terraform
- Módulo reutilizável; outputs para o repo de código
- Alarmes Datadog em erro/latência/duração

### Código
- Lambda: skill criar-lambda-python
- Glue: skill criar-job-glue
- Handler/job fino; domain testável; logs JSON + métricas

### Testes
- Unitários ≥ 90%; TaaC se integração S3/fila
- Sem dados reais ou PII em fixtures

## Evidências finais
- terraform validate + plan resumido
- pytest / testes Glue verdes + coverage
- Exemplo de log JSON com correlation_id
- README do componente ([template](../../docs/engineering-handbook/templates/readme-componente.md))
- Checklist [18 — DoD](../../docs/engineering-handbook/18-definition-of-done.md)

Não invente permissões IAM além do necessário (least privilege).
```

---

## Quando usar

- Novo microserviço serverless ou job Glue
- Novo recurso AWS com IaC dedicado
- Componente acionado por Airflow ou evento S3/SQS
