# Java Spring Boot

## Arquitetura

Preferir **hexagonal** ou camadas claras:

```
controller → application (use case) → domain → adapter (repository, client)
```

Domínio sem dependência de Spring quando possível.

## Controller fino

```java
@RestController
@RequestMapping("/api/v1/pedidos")
@RequiredArgsConstructor
public class PedidoController {
    private final CriarPedidoUseCase criarPedido;

    @PostMapping
    public ResponseEntity<PedidoResponse> criar(@Valid @RequestBody CriarPedidoRequest req) {
        var pedido = criarPedido.executar(req.toCommand());
        return ResponseEntity.status(HttpStatus.CREATED).body(PedidoResponse.from(pedido));
    }
}
```

## Use case

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

## Erros — Problem Details

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(RegraNegocioException.class)
    public ProblemDetail regraNegocio(RegraNegocioException ex) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_ENTITY, ex.getMessage());
    }
}
```

## Observabilidade

- Logs estruturados (JSON) com `correlationId` (MDC).
- Micrometer para métricas (`pedidos_criados_total`).
- Tracing OpenTelemetry/Micrometer Tracing.

## Testes

### Unitário (sem Spring)

```java
@Test
void deve_rejeitar_pedido_sem_itens() {
    assertThatThrownBy(() -> Pedido.criar("c1", List.of()))
        .isInstanceOf(RegraNegocioException.class);
}
```

### Integrado (Testcontainers)

```java
@SpringBootTest
@Testcontainers
class PedidoRepositoryIT {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");
    // ...
}
```

## Mutation testing — PIT

```xml
<plugin>
  <groupId>org.pitest</groupId>
  <artifactId>pitest-maven</artifactId>
  <configuration>
    <mutationThreshold>90</mutationThreshold>
    <targetClasses>
      <param>com.empresa.projeto.*.domain.*</param>
    </targetClasses>
  </configuration>
</plugin>
```

## Performance

- Pool de conexão dimensionado.
- Paginação obrigatória em listagens.
- Evitar N+1 (`@EntityGraph` ou fetch join consciente).
- Timeouts em clients HTTP.

## Adapter / repository

Ver `examples/spring/PedidoJpaAdapter.java` — porta hexagonal isolada.

## Testes slice e WireMock

- `@WebMvcTest` para controller; `@DataJpaTest` para repository.
- API externa: WireMock no `docker-compose.test.yml` (porta 8089).

## Resilience4j

Circuit breaker + retry em clients HTTP críticos; timeouts alinhados ao SLA.

## Code review

Ver `checklists/code-review-java-spring-boot.md`.
