---
name: criar-api-spring-boot
description: >-
  Cria ou altera endpoints e casos de uso Spring Boot com camadas hexagonais,
  validação, Problem Details e testes. Use no repo {nome-projeto}-api-* para REST,
  controllers, services, repositories e adapters Java.
disable-model-invocation: true
---

# Criar API Spring Boot (Claude Code)

**Repo alvo:** `{nome-projeto}-api-{dominio}` | **Rule:** `.claude/rules/java-spring-boot.md` | **Doc:** `docs/padroes/06-java-spring-boot.md`

## Pré-voo

1. Confirmar repo `-api-*` (API por domínio ou bounded context).
2. Ler endpoint similar: `adapter/in/rest`, `application`, `domain`, `adapter/out`.
3. Ler `06-java-spring-boot.md`: hexagonal, DTOs, erros RFC 7807, testes.
4. Plano: recurso REST, casos de uso, persistência, contratos com consumidores.

## Entradas

- `{nome-projeto}`, `{dominio}`, `{recurso}` (ex.: `pedidos`)
- Operações (GET/POST/PATCH/DELETE) e contrato OpenAPI
- Regras de validação e autorização
- Fonte de dados (JPA, JDBC, cliente HTTP, DynamoDB)

## Procedimento

### 1. Estrutura de arquivos

```
src/main/java/.../adapter/in/rest/{Recurso}Controller.java
src/main/java/.../application/{Acao}{Recurso}UseCase.java
src/main/java/.../domain/{Entidade}.java
src/main/java/.../adapter/out/persistence/{Entidade}RepositoryAdapter.java
src/test/java/.../application/{Acao}{Recurso}UseCaseTest.java
src/test/java/.../adapter/in/rest/{Recurso}ControllerTest.java
```

### 2. Camadas hexagonais

| Camada | Regra |
|--------|-------|
| `domain` | Entidades e regras sem Spring |
| `application` | Casos de uso; portas in/out |
| `adapter/in` | REST, validação `@Valid`, mapeamento DTO |
| `adapter/out` | JPA, HTTP client, mensageria |

```java
// Controller fino — delega ao use case
@PostMapping("/api/v1/pedidos")
public ResponseEntity<PedidoResponse> criar(@Valid @RequestBody CriarPedidoRequest req) {
    var pedido = criarPedidoUseCase.executar(req.toCommand());
    return ResponseEntity.status(HttpStatus.CREATED).body(PedidoResponse.from(pedido));
}
```

### 3. Erros e validação

- `ProblemDetail` (RFC 7807) para 4xx/5xx.
- Bean Validation na borda; regras de negócio no domain.
- `correlation_id` no MDC / header de resposta.

### 4. Contratos multi-repo

| Integração | Repo | Contrato |
|------------|------|----------|
| Infra (ECS, ALB, secrets) | `-infra` | outputs, env vars |
| Dados analíticos | `-dbt` exposures | não duplicar mart na API sem ADR |
| Eventos async | `-lambda-*` ou fila TF | schema da mensagem |

OpenAPI atualizado no PR se endpoint público.

### 5. Testes

```bash
./mvnw test -pl . -Dtest="*UseCaseTest,*ControllerTest"
./mvnw verify   # integração se existir
```

- Use case: mock das portas out; assert comportamento.
- Controller: `@WebMvcTest` ou MockMvc; status + body.
- Mutation (PIT) em domain/application se configurado.

### 6. Observabilidade

- Log estruturado com `correlation_id`, `user_id` (se aplicável, sem PII).
- Métricas Micrometer: latência, 4xx/5xx por endpoint.
- Tracing OpenTelemetry se stack do repo já usa.

### 7. Documentação

- README: como rodar local, perfis, endpoints novos.
- CHANGELOG ou nota de breaking change em path/versionamento.

## Checklists

- Transversal: `docs/padroes/checklist-transversal.md`
- Stack: `checklists/code-review-java-spring-boot.md`

## Armadilhas

| Sintoma | Correção |
|---------|----------|
| Lógica de negócio no Controller | Mover para use case/domain |
| Entity JPA vazando para REST | DTOs de entrada/saída |
| N+1 em listagem | Fetch join ou projeção |
| Exceção genérica 500 | ProblemDetail tipado |
| Endpoint sem teste de contrato | Controller + use case testados |

## Reporte Claude

- Endpoints e DTOs alterados
- Comando de teste executado
- Breaking changes em API
- PRs irmãos (infra, eventos)

## Prompt

```
Repo datalake-api-vendas. Skill criar-api-spring-boot. Plano primeiro.
POST /api/v1/pedidos com validação, CriarPedidoUseCase, ProblemDetail em erro.
Testes use case + WebMvcTest. OpenAPI atualizado.
```
