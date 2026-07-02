"""Contrato de evento entre componentes — validar em TaaC."""
EVENTO_PROCESSAMENTO_SCHEMA = {
    "type": "object",
    "required": ["correlation_id", "data_referencia", "bucket", "key"],
    "properties": {
        "correlation_id": {"type": "string"},
        "data_referencia": {"type": "string", "format": "date"},
        "bucket": {"type": "string"},
        "key": {"type": "string"},
    },
    "additionalProperties": False,
}
