# Lambda Python

## Estrutura

```
lambdas/nome-funcao/
├── handler.py
├── domain/
├── application/
├── infrastructure/
├── pyproject.toml
└── tests/
    ├── unit/
    └── integration/
```

## Handler fino

```python
"""Handler: processa evento S3 de arquivo de vendas."""
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.utilities.typing import LambdaContext
from application.processar_arquivo import ProcessarArquivoUseCase

logger = Logger()
tracer = Tracer()
metrics = Metrics()
_use_case = ProcessarArquivoUseCase()  # wiring fora do handler quando seguro

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

## Domínio testável

```python
# domain/validacao.py
from dataclasses import dataclass

@dataclass(frozen=True)
class RegistroVenda:
    pedido_id: str
    valor: float
    status: str

def filtrar_aprovados(registros: list[RegistroVenda]) -> list[RegistroVenda]:
    return [r for r in registros if r.status == "APROVADO"]
```

## Configuração e segredos

- Env vars para config não sensível.
- Secrets Manager / Parameter Store para credenciais.
- Clientes boto3 **fora** do handler (reuso em warm start).

## Tratamento de erros

| Tipo | Ação |
|------|------|
| Recuperável (throttle, timeout rede) | Retry + DLQ se esgotar |
| Não recuperável (payload inválido) | Log + métrica; não retry infinito |
| Contrato | Erro 4xx equivalente; documentar |
| Dependência | Circuit breaker quando aplicável |

## Logs estruturados

```python
logger.info("processamento_iniciado", extra={
    "operation": "processar_arquivo",
    "bucket": bucket,
    "key": key,  # sem dados sensíveis no path se PII
    "record_count": len(registros),
})
```

## Teste unitário

```python
def test_filtrar_aprovados():
    registros = [
        RegistroVenda("1", 10.0, "APROVADO"),
        RegistroVenda("2", 5.0, "CANCELADO"),
    ]
    assert len(filtrar_aprovados(registros)) == 1
```

## Teste integrado (LocalStack/moto)

```python
@pytest.mark.integration
def test_handler_processa_s3(localstack_s3, sample_event):
    # fixture sobe bucket e objeto
    response = handler(sample_event, LambdaContextStub())
    assert response["status"] == "OK"
```

## Mutation testing

```toml
# pyproject.toml / .mutmut-config
[tool.mutmut]
paths_to_mutate = ["domain/", "application/"]
```

## Performance

- Memória adequada (CPU proporcional na Lambda).
- Package enxuto (layers para deps pesadas).
- Paginação em listagens S3/DynamoDB.
- Batch operations quando possível.

## Exemplos adicionais

- `examples/lambda/handler_pydantic.py` — Pydantic + Powertools parser
- `examples/lambda/domain_calculo.py` — domínio testável
- `examples/terraform/modulo_lambda_minimo.tf` — DLQ, IAM, outputs

## Reserved concurrency

Documentar no Terraform quando limitar blast radius ou proteger downstream.

## Code review

Ver `checklists/code-review-lambda-python.md`.
