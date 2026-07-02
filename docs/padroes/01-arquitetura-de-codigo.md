# Arquitetura de código

## Objetivo

Código previsível, testável e fácil de modificar por humanos e agentes de IA, com fronteiras claras entre domínio, aplicação, infraestrutura e orquestração.

## Camadas e responsabilidades

| Camada | Responsabilidade | Onde vive |
|--------|------------------|-----------|
| Domínio | Regras de negócio puras | `domain/`, pacotes `*.domain` |
| Aplicação | Casos de uso, orquestração local | `application/`, `service/` |
| Infraestrutura | AWS, DB, filas, HTTP clients | `infrastructure/`, `adapter/` |
| Orquestração | Agendamento, dependências entre jobs | DAG Airflow, Step Functions |
| Integração | Contratos na borda | DTOs, schemas, OpenAPI |

**Regra:** lógica de negócio pesada **não** fica em DAG, handler Lambda, controller Spring, script Glue monolítico ou módulo Terraform.

## Princípios

- **SOLID** quando aplicável; priorizar SRP e DIP.
- **Alta coesão, baixo acoplamento** — módulos pequenos com contrato explícito.
- **Lei de Demeter** — não encadear `a.getB().getC().doX()`.
- **Ask, Don't Tell** — objetos perguntam comportamento, não expõem estado para manipulação externa.
- **Fail fast** — validar na borda; erros explícitos, não silenciosos.
- **Idempotência** — mesma entrada + mesmo contexto = mesmo efeito observável.
- **Imutabilidade** — preferir estruturas imutáveis em domínio (dataclasses frozen, records Java).

## Organização por stack (um repositório por componente)

Cada bloco abaixo é a **raiz de um repo de código**, não uma pasta dentro de um monorepo.

```
# repo: {nome-projeto}-api-usuario
src/main/java/.../domain|application|adapter/
src/test/

# repo: {nome-projeto}-lambda-processa-arquivo
handler.py, domain/, application/, tests/

# repo: {nome-projeto}-airflow
dags/{nome-projeto}_carga_diaria.py
include/app/{dag}/tasks.py

# repo: {nome-projeto}-dbt
models/staging|intermediate|marts/

# repo: {nome-projeto}-glue-carga-vendas
job.py, transforms/, tests/
```

## Contratos entre camadas

- DTOs/schemas na fronteira (Pydantic, Bean Validation, JSON Schema).
- Domínio não importa boto3, Spring, Airflow, Spark.
- Versão de contrato documentada; breaking change exige ADR + comunicação.

## Evitar "god" components

| Anti-padrão | Sintoma | Correção |
|-------------|---------|----------|
| God DAG | 500+ linhas, SQL e HTTP na DAG | Extrair para módulos; DAG só orquestra |
| God Lambda | Handler com toda regra | Handler fino + domain |
| God Glue job | Um arquivo faz tudo | `read` / `transform` / `write` separados |
| God Terraform module | 30+ recursos não relacionados | Submódulos por capacidade |

## Exemplo ruim — Lambda

```python
# ❌ Regra de negócio, I/O e parsing no handler
def handler(event, context):
    s3 = boto3.client("s3")
    obj = s3.get_object(Bucket=event["bucket"], Key=event["key"])
    rows = json.loads(obj["Body"].read())
    total = sum(r["valor"] for r in rows if r["status"] == "APROVADO")
    return {"total": total}
```

**Por que é ruim:** impossível testar regra sem mockar S3; handler acoplado a formato do evento.

## Exemplo bom — Lambda

```python
# domain/calculo.py — testável sem AWS
def totalizar_aprovados(registros: list[dict]) -> Decimal:
    return sum(Decimal(str(r["valor"])) for r in registros if r["status"] == "APROVADO")

# handler.py — fino
def handler(event, context):
    payload = EventParser.parse(event)
    registros = s3_reader.read_json_array(payload.bucket, payload.key)
    return {"total": str(totalizar_aprovados(registros))}
```

**Ganho:** domínio testável com pytest; handler substituível em TaaC.

## Código amigável para IA

- Nomes explícitos (`calcular_saldo_pendente`, não `process`).
- Arquivos < 300 linhas quando possível.
- Testes próximos do comportamento (`tests/domain/test_calculo.py`).
- README local por componente.
- Baixa surpresa — sem metaprogramação obscura.

## Critérios de aceite

- [ ] Regra de negócio em módulo testável sem framework
- [ ] Handler/DAG/controller finos
- [ ] Validação na borda
- [ ] Erros tipados e tratados
- [ ] Idempotência documentada
