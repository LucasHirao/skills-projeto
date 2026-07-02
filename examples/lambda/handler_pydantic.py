"""Handler fino com validação Pydantic na borda."""
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.parser import event_parser
from aws_lambda_powertools.utilities.parser.models import S3Model
from aws_lambda_powertools.utilities.typing import LambdaContext
from pydantic import BaseModel, Field

from app.application.processar import ProcessarArquivoUseCase

logger = Logger()
_use_case = ProcessarArquivoUseCase()


class ProcessamentoResult(BaseModel):
    status: str = "OK"
    processados: int = Field(ge=0)


@logger.inject_lambda_context
@event_parser(model=S3Model)
def handler(event: S3Model, context: LambdaContext) -> dict:
    record = event.Records[0]
    resultado = _use_case.execute(bucket=record.s3.bucket.name, key=record.s3.object.key)
    return ProcessamentoResult(processados=resultado.qtd).model_dump()
