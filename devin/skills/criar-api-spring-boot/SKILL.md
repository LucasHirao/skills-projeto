---
name: criar-api-spring-boot
description: >-
  Procedimento Devin para criar ou alterar endpoints Spring Boot hexagonais com
  validação e testes. Use no repositório {nome-projeto}-api-{dominio}.
---

# Criar API Spring Boot (Devin)

## Configuração da sessão Devin

1. Clone/checkout **`{nome-projeto}-api-{dominio}`**.
2. Leitura de `docs/padroes/06-java-spring-boot.md`.
3. Na sessão: recurso REST, operações, autorização, persistência ou integrações externas.

## Busca obrigatória no repo API

```text
**/adapter/in/rest/         → controllers e DTOs
**/application/             → use cases
**/domain/                  → entidades e regras
**/adapter/out/             → persistence, HTTP clients
src/test/                   → padrão de teste
openapi.yaml ou /api-docs   → contrato público
```

Siga o package layout **deste** projeto.

## Especificação do endpoint

| Item | Valor |
|------|-------|
| Path | `/api/v1/{recurso}` |
| Validação | `@Valid` na borda; regras no domain |
| Erros | RFC 7807 ProblemDetail |
| Observabilidade | correlation_id no MDC |

## Passos de implementação

1. **Domain** — entidade e invariantes sem anotações Spring.
2. **Use case** — porta in/out; teste com mocks das portas.
3. **Controller** — fino; DTO entrada/saída separados de entity JPA.
4. **Adapter out** — repository ou cliente HTTP.
5. **Testes** — `*UseCaseTest`, `@WebMvcTest` ou MockMvc.
6. **OpenAPI** — atualizar se API pública.
7. **README** — perfil local, novo endpoint.

## Coordenação multi-repo

| Integração | Repo |
|------------|------|
| ECS, ALB, secrets | `-infra` |
| Eventos async | `-lambda-*` ou fila no infra |
| Dados analíticos | `-dbt` exposures — não duplicar mart sem ADR |

## Validação

```bash
./mvnw test -Dtest="*UseCaseTest,*ControllerTest"
./mvnw verify   # se houver integração
```

## Checklists

- `checklists/code-review-java-spring-boot.md`
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## Repo
{nome-projeto}-api-{dominio}

## Endpoints
POST /api/v1/...

## Arquivos
- adapter/in/...
- application/...

## Testes
mvnw test → resultado

## Breaking changes
nenhuma / path v2 necessário

## PRs irmãos
- [ ] infra: env vars

## Riscos
N+1, autorização, ...
```

## Não fazer

- Editar `.claude/`
- Entity JPA exposta no REST
- Lógica de negócio no controller
- Endpoint público sem teste de contrato
