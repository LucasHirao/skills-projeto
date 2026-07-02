# 08 — Java Spring Boot

> **Versão:** 1.0  
> **Última atualização:** julho/2026  
> **Repositório:** `{dominio}-api` ou `api-{nome-projeto}-{contexto}`  
> **Escopo:** serviços HTTP e workers Spring Boot na plataforma `{nome-projeto}`

---

## Objetivo

Estabelecer **como projetamos APIs e serviços Java/Spring Boot** em arquitetura em camadas ou hexagonal: controller fino, casos de uso testáveis, adapters isolados, observabilidade **Datadog**, **90% cobertura**, **90% mutation** (PIT) em domínio e **TaaC** com Testcontainers.

Spring Boot é **framework de entrega** — domínio não deve depender dele.

---

## Para quem serve

| Público | Uso |
|---------|-----|
| **Desenvolvedor(a) Java** | Implementar endpoints e casos de uso |
| **Arquiteto(a)** | Decidir limites de bounded context |
| **Revisor** | Critérios de camadas, transações, testes |
| **SRE** | SLO, health checks, runbooks |
| **Júnior** | Estrutura de pacotes e testes sem `@SpringBootTest` desnecessário |

---

## Problemas que estes padrões resolvem

| Problema | Sintoma | Solução |
|----------|---------|---------|
| Lógica no controller | `@RestController` com 150 linhas | Use case dedicado |
| `@SpringBootTest` em tudo | Suite de 10 min | Slices + testes de domínio puros |
| N+1 e pool esgotado | Latência p99 alta | Fetch join, paginação, métricas JDBC |
| Erro HTTP inconsistente | Cliente não trata resposta | RFC 7807 Problem Details |
| Entity exposta na API | Acoplamento JPA ↔ contrato | DTOs na borda |
| Baixa mutation score | Testes frágeis | PIT em domain/service |

---

## Princípios

1. **Controller fino** — validação de entrada, delega, mapeia resposta.
2. **Caso de uso explícito** — uma classe por operação de negócio significativa.
3. **Domínio sem Spring** — regras testáveis sem contexto.
4. **DTO na borda** — nunca expor entidade JPA.
5. **Transação no application layer** — `@Transactional` no use case, não no controller.
6. **Erros padronizados** — Problem Details com `type`, `title`, `detail`.
7. **Observabilidade** — Micrometer + Datadog APM; correlation ID em MDC.
8. **90/90** — cobertura JaCoCo ≥ 90%; PIT ≥ 90% em pacotes de domínio.

---

## Decisões arquiteturais

| Decisão | Escolha | Alternativa | Motivo |
|---------|---------|-------------|--------|
| Estilo | Hexagonal / clean em serviços novos | MVC clássico em legado | Testabilidade e evolução |
| Persistência | Spring Data JPA + adapters | JDBC template direto | Produtividade com ports |
| API docs | OpenAPI 3 (springdoc) | Wiki manual | Contrato e TaaC |
| Mensageria | SQS/SNS via adapters | Acoplamento direto SDK | Testabilidade |
| Build | Maven wrapper | Gradle | Padronizar por org (ajustar se Gradle) |
| Java | 21 LTS | 17 | Suporte longo, virtual threads quando útil |

---

## Trade-offs

| Trade-off | A | B | A quando | B quando |
|-----------|---|---|----------|----------|
| `@WebMvcTest` vs `@SpringBootTest` | Slice MVC | Contexto completo | Teste de controller | Fluxo E2E único |
| Virtual threads | `spring.threads.virtual.enabled=true` | Pool tradicional | I/O bound alto | CPU bound |
| Cache | Caffeine/Redis | Sem cache | Leitura repetida, SLA | Dados sempre frescos |
| Sync API vs evento | REST | SQS outbox | Consulta imediata | Desacoplamento |

---

## Quando usar / quando não usar

### Use Spring Boot quando

- API REST/HTTP com múltiplos endpoints e autenticação.
- Serviço com persistência relacional e transações.
- Integrações síncronas com sistemas externos (com resiliência).

### Não use Spring Boot quando

- Função pontual event-driven simples — [07 — Lambda Python](07-lambda-python.md).
- ETL batch pesado — [09 — AWS Glue](09-aws-glue.md).
- Script de transformação SQL — dbt no warehouse.

---

## Estrutura de repositório e pastas

```
pedidos-api/
├── src/main/java/com/{org}/{dominio}/
│   ├── PedidosApiApplication.java
│   ├── adapter/in/web/
│   │   ├── PedidoController.java
│   │   ├── dto/
│   │   └── ProblemDetailsHandler.java
│   ├── application/
│   │   └── CriarPedidoUseCase.java
│   ├── domain/
│   │   ├── Pedido.java
│   │   └── PedidoRepository.java      # port
│   └── adapter/out/persistence/
│       └── PedidoJpaAdapter.java
├── src/main/resources/
│   ├── application.yml
│   └── db/migration/                  # Flyway
├── src/test/java/
│   ├── unit/domain/
│   ├── unit/application/
│   └── integration/
├── pom.xml
└── docs/
    ├── openapi.yaml
    └── runbooks/
```

---

## Convenções e naming

| Item | Convenção |
|------|-----------|
| Pacote base | `com.{org}.{dominio}` |
| Use case | `{Verbo}{Entidade}UseCase` |
| Controller | `{Entidade}Controller` |
| DTO request/response | `CriarPedidoRequest`, `PedidoResponse` |
| Testes | `deve_{resultado}_quando_{condicao}` |
| Métricas | `{dominio}.{operacao}.{resultado}` |
| Profiles | `local`, `dev`, `hml`, `prod` |

---

## Práticas obrigatórias

- [ ] Bean Validation (`@Valid`) em requests
- [ ] Problem Details para 4xx/5xx
- [ ] Correlation ID (`X-Correlation-Id`) propagado no MDC
- [ ] Paginação em listagens (`Pageable`)
- [ ] Timeouts em clients HTTP (RestClient/WebClient)
- [ ] JaCoCo `minimum 0.90` em CI
- [ ] PIT mutation score ≥ 90% em `domain` e `application`
- [ ] TaaC com Testcontainers (Postgres, LocalStack, WireMock)
- [ ] OpenAPI publicado e versionado
- [ ] Health: `actuator/health` + readiness customizado se necessário
- [ ] Sem secrets em `application.yml` commitado

---

## Práticas recomendadas

- Testes de domínio sem Spring (`@ExtendWith(MockitoExtension.class)`)
- `@DataJpaTest` para repositories
- `@WebMvcTest` para controllers
- Resilience4j (retry, circuit breaker) em adapters externos
- Flyway para schema; nunca `ddl-auto=update` em prod
- Structured logging (Logstash encoder) → Datadog
- `dd-trace-java` para APM

---

## Anti-padrões

```java
// ❌ Lógica de negócio no controller
@PostMapping("/pedidos")
public ResponseEntity<?> criar(@RequestBody Map<String, Object> body) {
    if ((Integer) body.get("qtd") < 0) { ... }
}

// ❌ Entity JPA como response
@GetMapping("/{id}")
public PedidoEntity buscar(@PathVariable Long id) { ... }

// ❌ @SpringBootTest para testar regra pura
@SpringBootTest
class CalculadoraDescontoTest { ... }

// ❌ Catch Exception genérico
try { ... } catch (Exception e) { return null; }

// ❌ Transação no controller
@Transactional
@PostMapping(...)
public void criar(...) { ... }
```

---

## Exemplos (bom vs ruim)

### Controller fino — bom

```java
@RestController
@RequestMapping("/api/v1/pedidos")
@RequiredArgsConstructor
public class PedidoController {
    private final CriarPedidoUseCase criarPedido;

    @PostMapping
    ResponseEntity<PedidoResponse> criar(@Valid @RequestBody CriarPedidoRequest req) {
        var pedido = criarPedido.executar(req.toCommand());
        return ResponseEntity.status(HttpStatus.CREATED).body(PedidoResponse.from(pedido));
    }
}
```

### Use case — bom

```java
@Service
@RequiredArgsConstructor
public class CriarPedidoUseCase {
    private final PedidoRepository repository;

    @Transactional
    public Pedido executar(CriarPedidoCommand cmd) {
        var pedido = Pedido.criar(cmd.clienteId(), cmd.itens());
        return repository.salvar(pedido);
    }
}
```

### Teste unitário — bom

```java
@ExtendWith(MockitoExtension.class)
class CriarPedidoUseCaseTest {
    @Mock PedidoRepository repository;
    @InjectMocks CriarPedidoUseCase useCase;

    @Test
    void deve_persistir_pedido_valido() {
        when(repository.salvar(any())).thenAnswer(i -> i.getArgument(0));
        var result = useCase.executar(new CriarPedidoCommand("c1", List.of(item())));
        assertThat(result.id()).isNotNull();
    }
}
```

### Problem Details — bom

```java
@ControllerAdvice
public class ProblemDetailsHandler {
    @ExceptionHandler(RegraNegocioException.class)
    ResponseEntity<ProblemDetail> handle(RegraNegocioException ex) {
        var problem = ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_ENTITY, ex.getMessage());
        problem.setTitle("Regra de negócio violada");
        problem.setType(URI.create("/problems/regra-negocio"));
        return ResponseEntity.unprocessableEntity().body(problem);
    }
}
```

---

## Estratégia de testes

| Camada | Anotação / ferramenta | Meta |
|--------|----------------------|------|
| Domínio | JUnit 5 puro | 90% cov + 90% PIT |
| Application | Mockito | Casos de uso + erros |
| Web | `@WebMvcTest` | Status, validação, serialização |
| Persistence | `@DataJpaTest` + Testcontainers | Queries críticas |
| TaaC | `@SpringBootTest` + Testcontainers | Fluxo API + DB |

```xml
<!-- pom.xml — JaCoCo -->
<minimum>0.90</minimum>

<!-- PIT -->
<mutationThreshold>90</mutationThreshold>
<targetClasses>
    <param>com.org.dominio.domain.*</param>
    <param>com.org.dominio.application.*</param>
</targetClasses>
```

Ver [10](10-testes-unitarios.md), [11](11-taac-testes-integrados-na-pipeline.md), [12](12-testes-de-mutacao.md).

---

## Observabilidade (Datadog)

| Sinal | Implementação |
|-------|---------------|
| Logs | JSON com `trace_id`, `correlation_id`, `user_id` (não PII) |
| Métricas | Micrometer → Datadog (`http.server.requests`) |
| Traces | dd-java-agent, spans em use cases críticos |
| SLO | Latência p99, taxa de erro 5xx |

```yaml
# application.yml (trecho)
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
```

Ver [13 — Observabilidade](13-observabilidade.md).

---

## Performance e custo

| Área | Prática |
|------|---------|
| JDBC | HikariCP pool dimensionado; métricas de wait |
| JPA | Evitar N+1 (`@EntityGraph`, fetch join) |
| API | Paginação obrigatória; projeções DTO |
| HTTP clients | Timeout + connection pool limitado |
| CPU | Profile antes de cache agressivo |

Ver [14 — Performance](14-performance.md).

---

## Segurança

- Spring Security com OAuth2/JWT conforme padrão da org
- Validação de entrada; sanitização de logs
- Secrets via AWS Secrets Manager / env injetada em runtime
- Dependências: OWASP dependency-check ou equivalente
- CORS explícito; não `*` em prod

Ver [17 — Segurança](17-seguranca-conformidade-e-dados-sensiveis.md).

---

## Documentação

- OpenAPI em `docs/openapi.yaml` ou gerado em CI
- README: como rodar local, profiles, migrações Flyway
- ADR para decisões de persistência e integração
- Runbook para degradação e rollback

Ver [15 — Documentação](15-documentacao.md).

---

## Checklist de implementação

- [ ] Pacotes adapter/application/domain
- [ ] DTOs e Problem Details
- [ ] Use case com transação
- [ ] Testes unitários domínio + application
- [ ] JaCoCo ≥ 90%
- [ ] PIT ≥ 90% em domínio
- [ ] TaaC Testcontainers
- [ ] OpenAPI atualizado
- [ ] Métricas e traces Datadog

---

## Checklist de code review

- [ ] Controller sem regra de negócio
- [ ] Sem entity na API
- [ ] Transação no lugar certo
- [ ] Testes meaningful (não só happy path)
- [ ] Breaking change em API documentada
- [ ] Migration Flyway reversível ou plano de rollback

Ver [16 — Code review](16-code-review.md).

---

## Checklist operacional

- [ ] Dashboard Datadog (latência, erro, JVM)
- [ ] Alertas SLO
- [ ] Runbook OOM / pool exhausted / dependency down
- [ ] Procedimento de rollback (blue/green ou tag anterior)

---

## Critérios de aceite

1. CI: testes, JaCoCo, PIT, TaaC verdes.
2. OpenAPI reflete contrato implementado.
3. Deploy hml com smoke test documentado.
4. Traces visíveis no Datadog.
5. Migração Flyway aplicada em hml.

---

## Definition of Done (tema Spring Boot)

- [ ] Merge + deploy hml
- [ ] Contrato OpenAPI publicado
- [ ] Cobertura e mutation atendidos
- [ ] Runbook e monitores Datadog
- [ ] [18 — Definition of Done](18-definition-of-done.md)

---

## FAQ

**Sempre `@SpringBootTest`?**  
Não. Reserve para TaaC; domínio e use case são testes rápidos sem contexto.

**Virtual threads em produção?**  
Avaliar com teste de carga; bom para I/O, não milagre para CPU.

**Como versionar API?**  
`/api/v1` no path; breaking change → `v2` ou negociação com consumidores.

**PIT em controllers?**  
Priorize domain/application; MVC testado com `@WebMvcTest`.

---

## Guia de uso para júnior

1. Modele o caso de uso em `domain/` com teste.
2. Implemente `application/` e adapter de persistência.
3. Exponha via `adapter/in/web/`.
4. Rode `./mvnw test` e verifique JaCoCo report.
5. Adicione um TaaC com Testcontainers Postgres.
6. PR com [templates/pr.md](templates/pr.md).

[20 — Onboarding técnico](20-onboarding-tecnico.md).

---

## Foco de revisão sênior

- Limites de transação e consistência
- Contrato público e compatibilidade
- Modelo de domínio vs anêmico
- Resiliência em integrações externas
- Impacto de migration em volume
- Adequação sync vs assíncrono

---

## Documentos relacionados

| # | Documento |
|---|-----------|
| 06 | [Terraform](06-terraform.md) |
| 07 | [Lambda Python](07-lambda-python.md) |
| 10 | [Testes unitários](10-testes-unitarios.md) |
| 11 | [TaaC](11-taac-testes-integrados-na-pipeline.md) |
| 12 | [Testes de mutação](12-testes-de-mutacao.md) |
| 13 | [Observabilidade (Datadog)](13-observabilidade.md) |
| 14 | [Performance](14-performance.md) |
| 15 | [Documentação](15-documentacao.md) |
| 16 | [Code review](16-code-review.md) |
| 17 | [Segurança](17-seguranca-conformidade-e-dados-sensiveis.md) |
| 18 | [Definition of Done](18-definition-of-done.md) |
| 19 | [Padrões para uso de IA](19-padroes-para-uso-de-ia.md) |
| 20 | [Onboarding técnico](20-onboarding-tecnico.md) |
