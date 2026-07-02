"""Transformação pura — testável sem cluster."""
from __future__ import annotations


def normalizar_status(status: str | None) -> str:
    if not status or not status.strip():
        return "DESCONHECIDO"
    return status.strip().upper()
