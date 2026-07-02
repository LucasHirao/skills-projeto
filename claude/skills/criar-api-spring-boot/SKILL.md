---
name: criar-api-spring-boot
description: Implementar APIs REST Java Spring Boot em {nome-projeto} com camadas hexagonais, OpenAPI, testes e observabilidade Datadog.
---

# Criar API Spring Boot

## Quando usar

- Novo endpoint ou serviço REST
- Adaptadores JPA/HTTP e casos de uso
- Alteração de contrato OpenAPI

## Pré-leitura

- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [08 — Java Spring Boot](../../../docs/engineering-handbook/08-java-spring-boot.md)
- [02 — Arquitetura transversal](../../../docs/engineering-handbook/02-arquitetura-transversal.md)
- [10 — Testes unitários](../../../docs/engineering-handbook/10-testes-unitarios.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Java: classes, métodos, variáveis e testes em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Entradas

| Campo | Obrigatório | Exemplo |
|-------|-------------|---------|
| Repositório | Sim | `{nome-projeto}-api-pedidos` |
| Endpoint / recurso | Sim | `POST /pedidos` |
| Caso de uso | Sim | `CriarPedidoUseCase` |
| Autenticação | Sim | JWT, API key |
| Contrato | Sim | OpenAPI existente ou novo |

## Passos

1. Plano: camadas, DTOs, erros HTTP, dependências.
2. Controller fino → caso de uso → portas/adaptadores.
3. Validação na borda (`@Valid`, Bean Validation).
4. Exceções de domínio mapeadas para HTTP sem vazar stack.
5. OpenAPI (`springdoc`) atualizado.
6. Logs JSON + `correlation_id` (filter/interceptor).
7. Métricas e trace APM Datadog.
8. Testes unitários nos casos de uso; integração nos adaptadores.
9. Mutation em domain/application onde há lógica.
10. TaaC para fluxos com DB/fila externos.

## Checklist de qualidade

- [ ] Controller sem regra de negócio
- [ ] Nomes de domínio em português
- [ ] Estilo alinhado ao módulo vizinho

## Checklist de testes

- [ ] Cobertura ≥ 90%
- [ ] Testes de controller com MockMvc
- [ ] TaaC/Testcontainers para repositório real

## Checklist de observabilidade

- [ ] `correlation_id` em todo request
- [ ] Métricas por endpoint (latência, 4xx, 5xx)
- [ ] Trace APM habilitado

## Checklist de desempenho

- [ ] Sem N+1 em JPA (fetch join / batch)
- [ ] Paginação em listagens
- [ ] Timeout em chamadas downstream

## Checklist de segurança

- [ ] Autenticação/autorização documentada
- [ ] Input sanitizado; sem SQL injection
- [ ] Sem dados sensíveis em log

## Critérios de aceite

- DoD Spring em [18](../../../docs/engineering-handbook/18-definition-of-done.md) §2.5
- OpenAPI publicado e exemplos curl

## O que não fazer

- Lógica de negócio no `@RestController`
- Entity JPA vazando para API pública
- Breaking change sem versionamento
- `ResponseEntity` genérico sem tipo

## Como reportar

- Endpoints alterados e exemplos request/response
- Comandos `./mvnw test` ou equivalente
- Mudanças em OpenAPI anexadas

## Fonte de verdade

- [08 — Java Spring Boot](../../../docs/engineering-handbook/08-java-spring-boot.md)
- [Template — readme-componente](../../../docs/engineering-handbook/templates/readme-componente.md)
