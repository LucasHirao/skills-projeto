# Regra: Java Spring Boot

**Doc:** `docs/padroes/06-java-spring-boot.md` | **Checklist:** `checklists/code-review-java-spring-boot.md`

## Escopo

Repo `{nome-projeto}-api-{servico}/`.

## Faça

- Controller fino → use case → domain → adapter (hexagonal).
- DTOs + Bean Validation na borda.
- Problem Details para erros HTTP.
- Teste domain sem Spring; `@WebMvcTest` / `@DataJpaTest` quando couber.
- Testcontainers para integração DB/mensageria.
- PIT 90% em domain.
- Paginação em listagens; timeouts em clients.

## Não faça

- Lógica em `@Entity` ou controller.
- `@SpringBootTest` quando slice resolve.
- N+1 em listagens críticas.
