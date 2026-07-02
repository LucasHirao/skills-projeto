# Regra: Java Spring Boot

**Doc:** `docs/padroes/06-java-spring-boot.md` | **Checklist:** `checklists/code-review-java-spring-boot.md`

## Faça

- Controller fino → use case → domínio → adapter
- Problem Details para erros HTTP
- Teste domínio sem Spring
- Testcontainers para IT
- PIT 90% em domain

## Não faça

- Lógica em `@Entity` ou controller
- Listagem sem paginação
- `@SpringBootTest` quando `@WebMvcTest`/`@DataJpaTest` bastam

## Observabilidade

- MDC correlation_id + Micrometer
