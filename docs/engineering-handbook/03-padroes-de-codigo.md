# 03 — Padrões de código

> **Versão:** 1.0 · **Aplica-se a:** todas as stacks · **Modelo:** multi-repo · **Observabilidade:** Datadog

---

## Sumário

1. [Objetivo](#1-objetivo)
2. [Público-alvo](#2-público-alvo)
3. [Problemas que resolvemos](#3-problemas-que-resolvemos)
4. [Princípios](#4-princípios)
5. [Decisões](#5-decisões)
6. [Trade-offs](#6-trade-offs)
7. [Quando aplicar / não aplicar](#7-quando-aplicar--não-aplicar)
8. [Estrutura e organização](#8-estrutura-e-organização)
9. [Convenções de código](#9-convenções-de-código)
10. [Práticas obrigatórias e recomendadas](#10-práticas-obrigatórias-e-recomendadas)
11. [Anti-padrões](#11-anti-padrões)
12. [Exemplos bom / ruim](#12-exemplos-bom--ruim)
13. [Por linguagem e stack](#13-por-linguagem-e-stack)
14. [Estratégias transversais](#14-estratégias-transversais)
15. [Checklists](#15-checklists)
16. [Critérios de aceite](#16-critérios-de-aceite)
17. [Definition of Done](#17-definition-of-done)
18. [FAQ](#18-faq)
19. [Guia júnior](#19-guia-júnior)
20. [Guia sênior](#20-guia-sênior)

---

## 1. Objetivo

Estabelecer padrões de código **legíveis, testáveis e seguros** para repositórios `{nome-projeto}-*`, independentemente da stack.

Código deve ser:

- Compreensível por humano em review e por operador via logs Datadog
- Testável sem ambiente cloud quando a regra é de negócio
- Coeso em arquivos e módulos pequenos
- Alinhado à [arquitetura de camadas](02-arquitetura-transversal.md)

---

## 2. Público-alvo

Todos os autores de código em Python, Java, SQL (dbt), HCL (Terraform) e PySpark. Revisores usam este capítulo como **lente transversal** além do capítulo de stack.

---

## 3. Problemas que resolvemos

| Problema | Exemplo | Consequência |
|----------|---------|--------------|
| Código opaco | `def process(x): ...` 200 linhas | Review lento, bugs |
| Teste inútil | `assert True` | Falsa confiança |
| Acoplamento framework | JUnit mockando 15 classes Spring no domain | Refactor caro |
| Estado mutável global | `CONFIG = load()` no import | Flaky tests |
| Log sem contexto | `print("erro")` | MTTR alto no Datadog |
| Nomes mentirosos | `getUser` que deleta | Manutenção perigosa |

---

## 4. Princípios

### C1 — Single Responsibility (SRP)

Uma função/classe, uma razão para mudar.

### C2 — Dependency Inversion (DIP)

Domínio define portas; infra implementa. Não o contrário.

### C3 — Fail fast

Validar entrada na borda; lançar exceção tipada; nunca engolir erro.

### C4 — Explicit over clever

Código chato e claro > one-liner inteligente.

### C5 — Immutability preferida

`frozen` dataclasses, records Java, evitar mutação compartilhada.

### C6 — Idempotência documentada

Funções que escrevem devem declarar chave de idempotência.

### C7 — Sem efeito colateral surpresa

Função `calculate_*` não deve gravar em S3.

### C8 — Lei de Demeter

Não encadear `a.getB().getC().save()`.

### C9 — Código amigável a operação

Logs estruturados com `operation`, `status`, `duration_ms`, `correlation_id`.

### C10 — Arquivos focados

Alvo < 300 linhas; extrair quando passar de 400.

---

## 5. Decisões

| ID | Decisão | Detalhe |
|----|---------|---------|
| COD-01 | Inglês em identificadores | PT-BR só em docs e comentários de negócio quando necessário |
| COD-02 | Type hints Python 3.11+ | Obrigatório em código novo |
| COD-03 | Formatter/linter no CI | black/ruff ou equivalente; Checkstyle/Spotless Java |
| COD-04 | Sem wildcard import | `from x import *` proibido |
| COD-05 | Exceções de domínio próprias | Não vazar `ClientError` boto3 para domain |
| COD-06 | Config por ambiente | Env vars / SSM; não constante `ENV=prod` no código |
| COD-07 | SQL em dbt, não em Python | Exceto dynamic SQL justificado em ADR |

---

## 6. Trade-offs

### 6.1 Abstração vs. YAGNI

| Muita abstração | Pouca abstração |
|-----------------|-----------------|
| Flexível | Direto |
| Indireção cognitiva | Duplicação se copiar 3x |

**Regra:** abstrair na **terceira** repetição real, não na primeira suposição.

### 6.2 DTO vs. entidade rica

APIs expõem DTOs; domínio usa tipos ricos. Mapeamento explícito evita vazamento de persistência.

### 6.3 Comentários

Comentar **por quê**, não **o quê**. Código autoexplicativo para o quê.

---

## 7. Quando aplicar / não aplicar

### Aplicar sempre em

- Código mergeado em `{nome-projeto}-*`
- Scripts com vida > 1 semana
- Terraform e dbt models em produção

### Relaxar em

- Notebook exploratório descartável (não commitar em prod repo)
- Spike com TTL < 48h com label `spike/` e issue de convergência

---

## 8. Estrutura e organização

### 8.1 Layout Python (Lambda, Airflow tasks, Glue)

```
src/
├── domain/           # Puro: sem boto3, airflow, pyspark
├── application/      # Casos de uso
├── infrastructure/   # Adapters AWS
└── handler.py|tasks.py|job.py  # Entrada fina
tests/
├── domain/
├── application/
└── integration/
```

### 8.2 Layout Java (Spring Boot)

```
domain/         # Entidades, value objects, domain services
application/    # Use cases, ports
adapter/in/     # Controllers
adapter/out/    # JPA, clients
config/
```

### 8.3 dbt

Ver [05-dbt.md](05-dbt.md) — staging / intermediate / marts.

### 8.4 Terraform

Ver [06-terraform.md](06-terraform.md) — módulos por capacidade.

---

## 9. Convenções de código

### 9.1 Naming

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Módulo Python | snake_case | `calculo_desconto.py` |
| Classe | PascalCase | `PedidoService` |
| Função | snake_case / camelCase Java | `calcular_total` |
| Constante | UPPER_SNAKE | `MAX_RETRY` |
| Boolean | prefixo is/has/can | `is_eligible` |
| Teste | `test_{comportamento}` | `test_rejeita_valor_negativo` |

### 9.2 Funções

- ≤ 40 linhas ideal; extrair se mais
- ≤ 4 parâmetros; usar objeto/dataclass se mais
- Retorno explícito; evitar `None` ambíguo sem Optional documentado

### 9.3 Erros

```python
# domain/errors.py
class PedidoInvalidoError(DomainError):
    def __init__(self, pedido_id: str, motivo: str):
        super().__init__(f"Pedido {pedido_id} inválido: {motivo}")
        self.pedido_id = pedido_id
        self.motivo = motivo
```

Mapear para HTTP 4xx/5xx na borda; log ERROR com `error_type` no Datadog.

### 9.4 Logging

```python
import logging
logger = logging.getLogger(__name__)

logger.info(
    "order_total_calculated",
    extra={
        "correlation_id": ctx.correlation_id,
        "operation": "calculate_order_total",
        "status": "SUCCESS",
        "order_id_hash": hash_id(order_id),
        "duration_ms": elapsed,
    },
)
```

**Nunca** logar PII em claro — [17-seguranca-conformidade-e-dados-sensiveis.md](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## 10. Práticas obrigatórias e recomendadas

### Obrigatórias

1. Type hints / tipos estáticos onde suportado
2. Linter e formatter no CI — build falha
3. Testes unitários para domain/application
4. Sem secrets no código ou logs
5. Validação de entrada na borda (Pydantic, Bean Validation)
6. `correlation_id` propagado em toda entrada HTTP/Lambda/task
7. Handler/DAG/controller finos — ver [02-arquitetura-transversal.md](02-arquitetura-transversal.md)

### Recomendadas

1. Property-based tests em regras financeiras críticas
2. Mutation testing em domain — [12-testes-de-mutacao.md](12-testes-de-mutacao.md)
3. Pre-commit hooks locais
4. Docstring em funções públicas de biblioteca interna
5. `__all__` explícito em pacotes Python publicados

---

## 11. Anti-padrões

| Anti-padrão | Stack | Correção |
|-------------|-------|----------|
| God function | Todas | Extrair funções nomeadas |
| God class | Java/Python | Split por responsabilidade |
| Primitive obsession | Todas | Value objects (`Money`, `CpfHash`) |
| Exception swallowing | Todas | Log + re-raise ou Result type |
| Magic number | Todas | Constante nomeada |
| Import no meio do arquivo | Python | Topo (exceto lazy load documentado) |
| Lógica em template SQL Jinja complexa | dbt | Intermediate model |
| `depends_on` circular | dbt/Terraform | Redesenhar grafo |
| Hardcoded bucket | Python/HCL | Var Terraform / Airflow Variable |

---

## 12. Exemplos bom / ruim

### 12.1 Lambda — handler

**Ruim:**

```python
def handler(event, context):
    s3 = boto3.client("s3")
    body = s3.get_object(Bucket=event["bucket"], Key=event["key"])["Body"].read()
    rows = json.loads(body)
    total = sum(r["valor"] for r in rows if r["status"] == "APROVADO")
    return {"total": total}
```

**Bom:**

```python
# domain/calculo.py
def totalizar_aprovados(registros: list[RegistroVenda]) -> Decimal:
    return sum((r.valor for r in registros if r.status == Status.APROVADO), Decimal("0"))

# application/processar_arquivo.py
class ProcessarArquivoUseCase:
    def __init__(self, reader: ArquivoReaderPort):
        self._reader = reader

    def execute(self, cmd: ProcessarArquivoCommand) -> ProcessarArquivoResult:
        registros = self._reader.read_vendas(cmd.bucket, cmd.key)
        total = totalizar_aprovados(registros)
        return ProcessarArquivoResult(total=total)

# handler.py
def handler(event, context):
    cmd = ProcessarArquivoCommand.from_event(event)
    correlation_id = event.get("correlation_id", context.aws_request_id)
    with log_context(correlation_id=correlation_id):
        result = use_case.execute(cmd)
    return result.to_response()
```

### 12.2 Spring — controller

**Ruim:** `@PostMapping` com 80 linhas de lógica e queries JPA.

**Bom:**

```java
@RestController
@RequestMapping("/v1/pedidos")
@RequiredArgsConstructor
public class PedidoController {
    private final CriarPedidoUseCase criarPedido;

    @PostMapping
    public ResponseEntity<PedidoResponse> criar(@Valid @RequestBody CriarPedidoRequest req) {
        var pedido = criarPedido.execute(req.toCommand());
        return ResponseEntity.status(HttpStatus.CREATED).body(PedidoResponse.from(pedido));
    }
}
```

### 12.3 Teste

**Ruim:**

```python
def test_process():
    assert process([]) is not None
```

**Bom:**

```python
def test_totalizar_aprovados_soma_apenas_aprovados():
    registros = [
        RegistroVenda(valor=Decimal("10"), status=Status.APROVADO),
        RegistroVenda(valor=Decimal("5"), status=Status.CANCELADO),
    ]
    assert totalizar_aprovados(registros) == Decimal("10")
```

---

## 13. Por linguagem e stack

### 13.1 Python

- `from __future__ import annotations` se necessário
- Dataclasses `frozen=True` para value objects
- Pydantic v2 na borda Lambda/API
- `pytest` + fixtures; não unittest legado
- Dependências pinadas (`requirements.txt` ou poetry.lock)

### 13.2 Java

- Java 17+ LTS
- Records para DTOs imutáveis
- Optional sem `.get()` nu
- MapStruct ou mapper explícito
- Arquitetura hexagonal — [08-java-spring-boot.md](08-java-spring-boot.md)

### 13.3 SQL / dbt

- Nomes explícitos de CTE
- Um conceito por model
- Comentário `-- Por quê:` no topo do model não óbvio

### 13.4 Terraform

- Um recurso por bloco lógico agrupado
- `description` em variables
- Sem `0.0.0.0/0` em security group sem ADR

### 13.5 PySpark (Glue)

- Transformações puras em funções testáveis com pandas local quando possível
- `job.py` só wiring

---

## 14. Estratégias transversais

### 14.1 Testes

| Camada | Meta |
|--------|------|
| domain | 95%+ cobertura, mutation |
| application | 90%+ cobertura |
| infrastructure | Integration / TaaC |
| handler | Smoke + contract |

[10-testes-unitarios.md](10-testes-unitarios.md)

### 14.2 Observabilidade

Padronizar `operation` names estáveis para dashboards Datadog. Métrica de negócio junto ao log de sucesso.

### 14.3 Performance

Evitar N+1; batch IO; não alocar listas gigantes em Lambda sem streaming.

[14-performance.md](14-performance.md)

### 14.4 Segurança

Sanitizar entrada; parameterized queries; sem `eval`/`exec`; dependabot.

### 14.5 Documentação

README com como rodar local; ADR para decisão COD-* divergente.

[15-documentacao.md](15-documentacao.md)

---

## 15. Checklists

### 15.1 Implementação

- [ ] Código na camada correta
- [ ] Nomes revelam intenção
- [ ] Sem magic numbers/secrets
- [ ] Erros tipados
- [ ] Logs JSON com correlation_id
- [ ] Testes de comportamento
- [ ] Linter verde

### 15.2 Code review

- [ ] Regra de negócio testável sem cloud?
- [ ] Função faz uma coisa?
- [ ] Tratamento de erro correto?
- [ ] PII segura?
- [ ] Alinhado [16-code-review.md](16-code-review.md)?

### 15.3 Operação

- [ ] `operation` estável para métricas
- [ ] Erros logados com `error_type`
- [ ] Timeouts configurados em clients HTTP

---

## 16. Critérios de aceite

- [ ] domain/ testável isoladamente
- [ ] Cobertura ≥ 90% no escopo do PR (ou exceção justificada)
- [ ] Nenhum anti-padrão seção 11
- [ ] CI: lint + test + security scan
- [ ] Logs compatíveis com Datadog parsing rules

---

## 17. Definition of Done

Ver [18-definition-of-done.md](18-definition-of-done.md). Específico de código:

- [ ] Formatter aplicado
- [ ] Sem código comentado "morto"
- [ ] Sem TODO sem issue linkada
- [ ] Dependências justificadas no PR se novas

---

## 18. FAQ

**P: Posso colocar validação simples no controller?**  
R: Validação de formato sim (Bean Validation); regra de negócio não.

**P: Arquivo com 500 linhas?**  
R: Dividir antes do merge salvo gerado (então gerador no CI).

**P: Log debug em prod?**  
R: Sampling via config; não flood indexing Datadog.

---

## 19. Guia júnior

Escreva o teste **antes** de mover lógica para domain. Se o teste precisa de boto3, a lógica está na camada errada. Use nomes longos e claros — ninguém penaliza `calculate_total_approved_orders`.

---

## 20. Guia sênior

Review de código é ensino: explique **qual princípio** foi violado, não só "mude isso". Bloqueie padrões que criam dívida sistêmica (god module, cross-repo import). Proponha extrair biblioteca interna só com caso de uso comprovado em ≥ 3 repos.

---

*Anterior:* [02 — Arquitetura transversal](02-arquitetura-transversal.md) · *Próximo:* [04 — Airflow](04-airflow.md)
