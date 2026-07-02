# 07 — Lambda Python

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Repositório:** `lambda-{dominio}` (um repositório por função ou grupo coeso)  
> **Escopo:** funções AWS Lambda em Python na plataforma `{nome-projeto}`

---

## Objetivo

Definir **como estruturamos, implementamos, testamos, observamos e operamos** Lambdas Python: handler fino, domínio testável, idempotência, tratamento de erros, integração AWS, **90% de cobertura**, mutation testing onde há lógica de negócio, **TaaC** para wiring real e instrumentação **Datadog**.

Lambda é **adaptador de evento** — regra de negócio vive fora do handler.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Desenvolvedor(a) Python** | Implementar e testar funções |
| **Engenheiro(a) de dados** | Lambdas de ingestão/transformação leve |
| **Revisor** | Critérios de handler, IAM, testes |
| **SRE** | DLQ, alarmes, runbooks |
| **Júnior** | Estrutura de pastas e padrão handler fino |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Solução neste capítulo |
|----------|---------|------------------------|
| Handler monolítico | 400 linhas, zero teste unitário | Camadas domain/application/infrastructure |
| Cold start ignorado | Timeout em pico | Clientes fora do handler, pacote enxuto |
| Retry infinito | Custo e DLQ lotada | Classificação de erros recuperável vs fatal |
| Logs texto livre | Impossível correlacionar no Datadog | JSON estruturado + correlation_id |
| Sem idempotência | Duplicata em reprocessamento | Chave de idempotência / conditional write |
| Cobertura baixa | Regressão silenciosa | 90% line + mutation em domínio |

---

## Princípios

1. **Handler fino** — parse, delega, formata resposta; sem regra de negócio.
2. **Domínio puro** — funções/classes testáveis sem boto3.
3. **Clientes AWS fora do handler** — reuso em warm start quando seguro.
4. **Config por env var** — secrets via Secrets Manager / Parameter Store.
5. **Falha explícita** — erros classificados; não engolir exceção genérica.
6. **Idempotência** — toda função que processa evento pode ser reinvocada.
7. **Observabilidade obrigatória** — logs JSON, métricas, traces no Datadog.
8. **90/90** — 90% cobertura de linha; 90% mutation score em módulos de domínio.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa | Motivo |
|---------|---------|-------------|--------|
| Estrutura | Hexagonal leve (domain/application/infrastructure) | Script único | Testabilidade |
| Validação de payload | Pydantic v2 | dict manual | Erros claros, tipagem |
| Observabilidade | AWS Lambda Powertools + Datadog | print() | Padrão corporativo |
| Empacotamento | Layer compartilhada para deps pesadas | Tudo no zip | Cold start |
| Runtime | Python 3.12+ (pinado no Terraform) | latest flutuante | Reprodutibilidade |
| Testes integrados | moto / LocalStack em TaaC | Apenas mock unitário | Wiring real |

---

## Trade-offs

| Trade-off | A | B | Escolha A quando | Escolha B quando |
|-----------|---|---|------------------|------------------|
| Sync vs async | Handler síncrono | SQS + worker | Latência baixa, poucos registros | Volume alto, backpressure |
| Pydantic no hot path | Validação completa | Validação mínima | Contrato externo instável | Evento interno já validado |
| Reserved concurrency | Limite fixo | Sem reserva | Proteger downstream | Custo e simplicidade |
| Lambda vs Glue | Lambda | Glue job | < 15 min, volume moderado | ETL pesado distribuído |

---

## Quando usar / quando não usar

### Use Lambda quando

- Processamento event-driven (S3, SQS, EventBridge, API Gateway).
- Tarefa < 15 min, memória até 10 GB, escala automática necessária.
- Transformação leve ou orquestração pontual.

### Não use Lambda quando

- Job Spark de horas — use [09 — AWS Glue](09-aws-glue.md).
- API complexa com muitos endpoints — considere [08 — Java Spring Boot](08-java-spring-boot.md).
- Processamento contínuo de alto volume sem backpressure — fila + workers dedicados.

---

## Estrutura de repositório e pastas

```
lambda-ingestao-arquivos/
├── src/
│   ├── handler.py
│   ├── domain/
│   │   ├── models.py
│   │   ├── validacao.py
│   │   └── transformacao.py
│   ├── application/
│   │   └── processar_arquivo.py
│   └── infrastructure/
│       ├── s3_client.py
│       ├── dynamodb_repo.py
│       └── config.py
├── tests/
│   ├── unit/
│   ├── integration/          # marcados @pytest.mark.taac
│   └── conftest.py
├── pyproject.toml
├── Dockerfile                # opcional, para parity local
├── .github/workflows/ci.yml
└── docs/
    ├── README.md
    └── runbooks/
```

**Multi-repo:** uma Lambda crítica pode ter repo próprio; grupo de funções pequenas e relacionadas pode compartilhar `lambda-{dominio}` com subpastas.

---

## Convenções e naming

| Item | Convenção |
|------|-----------|
| Função AWS | `{nome-projeto}-{acao}-{env}` |
| Handler | `handler.handler` |
| Use case | `{Verbo}{Entidade}UseCase` |
| Testes | `test_deve_{resultado}_quando_{condicao}` |
| Métricas Datadog | `{nome-projeto}.lambda.{metrica}` |
| Log `operation` | snake_case estável (`processar_arquivo`) |

---

## Práticas obrigatórias

- [ ] Handler com no máximo ~30 linhas (delegação)
- [ ] Type hints em todo código de produção
- [ ] Logs JSON com `correlation_id`, `operation`, sem PII
- [ ] Métricas: sucesso, erro, duração, volume processado
- [ ] DLQ ou on-failure destination para async
- [ ] Timeout configurado (< tempo máximo do evento upstream)
- [ ] IAM least privilege (provisionado via [06 — Terraform](06-terraform.md))
- [ ] `pytest --cov-fail-under=90` em CI
- [ ] Mutation testing (`mutmut`) em `domain/` com score ≥ 90%
- [ ] TaaC para pelo menos um fluxo feliz + erro de integração
- [ ] README com evento de exemplo e como testar local

---

## Práticas recomendadas

- AWS Lambda Powertools (Logger, Tracer, Metrics)
- Datadog Lambda Extension ou Forwarder
- Partial batch response em SQS
- Paginação boto3 em listagens
- `tenacity` para retry em erros recuperáveis (com limite)
- SnapStart (Java) não aplica — em Python, minimize imports no cold path
- X-Ray ou Datadog APM habilitado

---

## Anti-padrões

```python
# ❌ Lógica de negócio no handler
def handler(event, context):
    for record in event["Records"]:
        if record["valor"] < 0:
            raise ValueError("...")
        # 200 linhas...

# ❌ Cliente boto3 dentro do handler a cada invoke
def handler(event, context):
    s3 = boto3.client("s3")

# ❌ Catch genérico sem re-raise classificado
try:
    processar()
except Exception:
    pass

# ❌ Secret hardcoded
API_KEY = "sk-live-xxx"

# ❌ Teste sem assert
def test_handler():
    handler(event, context)
```

---

## Exemplos (bom vs ruim)

### Handler fino — bom

```python
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from application.processar_arquivo import ProcessarArquivoUseCase

logger = Logger()
tracer = Tracer()
metrics = Metrics()
_use_case = ProcessarArquivoUseCase()

@logger.inject_lambda_context
@tracer.capture_lambda_handler
@metrics.log_metrics
def handler(event: dict, context: LambdaContext) -> dict:
    correlation_id = event.get("correlation_id") or context.aws_request_id
    logger.append_keys(correlation_id=correlation_id)
    resultado = _use_case.execute(event)
    metrics.add_metric(name="RegistrosProcessados", unit="Count", value=resultado.qtd)
    return {"status": "OK", "processados": resultado.qtd}
```

### Domínio testável — bom

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class RegistroVenda:
    pedido_id: str
    valor: float
    status: str

def filtrar_aprovados(registros: list[RegistroVenda]) -> list[RegistroVenda]:
    return [r for r in registros if r.status == "APROVADO"]
```

### Classificação de erro — bom

```python
class ErroRecuperavel(Exception):
    """Retry permitido."""

class ErroContrato(Exception):
    """Payload inválido — não retry."""

def execute(self, event: dict) -> Resultado:
    try:
        payload = EventoEntrada.model_validate(event)
    except ValidationError as e:
        raise ErroContrato(str(e)) from e
    ...
```

### Teste unitário — bom

```python
def test_filtrar_aprovados_remove_cancelados():
    registros = [
        RegistroVenda("1", 10.0, "APROVADO"),
        RegistroVenda("2", 5.0, "CANCELADO"),
    ]
    assert [r.pedido_id for r in filtrar_aprovados(registros)] == ["1"]
```

---

## Estratégia de testes

| Camada | Escopo | Meta | Ferramenta |
|--------|--------|------|------------|
| Unitário | domain/, application/ | 90% line, 90% mutation | pytest, mutmut |
| Componente | infrastructure com mock | Casos de adaptador | pytest + moto |
| TaaC | handler + LocalStack/moto | Fluxo feliz + DLQ | [11 — TaaC](11-taac-testes-integrados-na-pipeline.md) |
| Contrato | Schema evento/resposta | Breaking change detectado | jsonschema / Pydantic |

```bash
# CI
pytest tests/unit --cov=src --cov-fail-under=90
mutmut run --paths-to-mutate=src/domain
mutmut results  # verificar score >= 90%
pytest tests/integration -m taac
```

Detalhes mutation: [12 — Testes de mutação](12-testes-de-mutacao.md).

---

## Observabilidade (Datadog)

| Sinal | Implementação |
|-------|---------------|
| Logs | JSON via Powertools; `service`, `env`, `version`, `correlation_id` |
| Métricas | `aws.lambda.enhanced.*` + custom `registros_processados` |
| Traces | `@tracer.capture_method` em use cases críticos |
| Alertas | Error rate, duration p99, DLQ depth, throttles |

```python
logger.info(
    "processamento_concluido",
    extra={
        "operation": "processar_arquivo",
        "bucket": bucket,
        "record_count": len(registros),
        "duration_ms": elapsed_ms,
    },
)
```

- Dashboard por função: template [templates/dashboard.md](templates/dashboard.md)
- Monitor exemplo: taxa de erro > 1% por 5 min → PagerDuty

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Fator | Ação |
|-------|------|
| Cold start | Minimize imports; layer para pandas se inevitável |
| Memória | Ajuste por power tuning (custo vs duração) |
| Pacote | Exclua testes, boto3 desnecessário (runtime já inclui) |
| Boto3 | Cliente global com `config=Config(retries=...)` |
| Batch | Processe SQS em lote com partial failure |
| Concorrência | Reserved concurrency só para proteger downstream |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Secrets Manager / SSM Parameter Store (SecureString)
- Sem PII em logs; mascarar campos sensíveis no Pydantic
- Validar tamanho e tipo de payload (anti-DoS)
- IAM via Terraform — sem credenciais no código
- Dependências pinadas; scan `pip-audit` / Dependabot

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

README do repo deve responder:

- O que dispara a Lambda (evento, fila, schedule)
- Formato do evento (exemplo JSON)
- Idempotência e semântica de retry
- Variáveis de ambiente
- Como rodar testes e TaaC local
- Link dashboard Datadog e runbook

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Estrutura domain/application/infrastructure
- [ ] Handler fino com Powertools
- [ ] Pydantic para entrada
- [ ] Erros classificados
- [ ] Idempotência documentada e testada
- [ ] Cobertura ≥ 90%
- [ ] Mutation ≥ 90% em domain
- [ ] TaaC com moto/LocalStack
- [ ] DLQ configurada (async)
- [ ] Alarmes Datadog

---

## Checklist de code review

- [ ] Sem lógica de negócio no handler
- [ ] Sem secret hardcoded
- [ ] Logs sem PII
- [ ] Testes cobrem caminhos de erro
- [ ] Mutation score aceitável
- [ ] Timeout e memory justificados
- [ ] IAM mínima no PR de Terraform associado

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Runbook: DLQ com mensagens, throttle, timeout
- [ ] Dashboard Datadog com golden signals
- [ ] Procedimento de reprocessamento (replay SQS / re-upload S3)
- [ ] Versão deployada rastreável (`DD_VERSION` / tag Git)

---

## Critérios de aceite

1. CI verde com cobertura e mutation.
2. TaaC valida integração mínima.
3. Deploy em dev/hml com invocação de teste documentada.
4. Observabilidade visível no Datadog em 15 min após deploy.
5. Runbook linkado no README.

---

## Definition of Done (tema Lambda)

- [ ] Código mergeado, Terraform aplicado em hml
- [ ] Testes unitários + TaaC + mutation verdes
- [ ] Documentação e runbook atualizados
- [ ] Monitores Datadog ativos
- [ ] DoD universal: [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**Posso usar `pandas` na Lambda?**  
Só se inevitável — prefira Glue. Se usar, layer compartilhada e teste de cold start.

**Como testar localmente?**  
`pytest` unitário; TaaC com Docker (LocalStack); `sam local invoke` opcional.

**O que vai na DLQ?**  
Erros não recuperáveis após retries; monitorar e ter runbook de triagem.

**Preciso de mutation em `handler.py`?**  
Foco em `domain/` e `application/` — handler é wiring fino.

---

## Guia de uso para júnior

1. Leia o evento de exemplo no README.
2. Implemente regra em `domain/` com teste primeiro.
3. Wire em `application/` e `handler.py`.
4. Rode `pytest tests/unit --cov=src`.
5. Adicione um TaaC feliz com fixture do `conftest.py`.
6. Abra PR com template [templates/pr.md](templates/pr.md).

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Semântica de idempotência sob retry S3/SQS
- Blast radius de IAM e acesso a dados
- Comportamento em partial batch failure
- Custo projetado (invocações × duração × memória)
- Contrato downstream quebrável
- Adequação Lambda vs Glue vs API

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 06 | [Terraform](06-terraform.md) |
| 08 | [Java Spring Boot](08-java-spring-boot.md) |
| 09 | [AWS Glue](09-aws-glue.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 11 | [TaaC](11-taac-testes-integrados-na-pipeline.md) |
| 12 | [Testes de mutação](12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
