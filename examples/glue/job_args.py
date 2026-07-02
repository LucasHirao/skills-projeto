"""Argumentos Glue — wiring no job.py."""
from awsglue.utils import getResolvedOptions
import sys

REQUIRED = ["JOB_NAME", "input_path", "output_path", "data_referencia"]


def parse_args(argv=None):
    return getResolvedOptions(argv or sys.argv, REQUIRED)

# Job bookmarks (fonte append-only):
# --job-bookmark-option job-bookmark-enable
# Documentar reprocessamento: disable bookmark só com ADR + backfill controlado
