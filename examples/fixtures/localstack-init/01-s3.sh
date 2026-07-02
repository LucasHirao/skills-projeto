#!/bin/bash
# Init LocalStack para TaaC — bucket de exemplo
awslocal s3 mb s3://datalake-vendas-raw-dev || true
