"""Domínio testável — sem boto3."""
from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True)
class RegistroVenda:
    pedido_id: str
    valor: Decimal
    status: str


def totalizar_aprovados(registros: list[RegistroVenda]) -> Decimal:
    return sum((r.valor for r in registros if r.status == "APROVADO"), Decimal("0"))
