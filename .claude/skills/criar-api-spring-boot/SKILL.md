---
name: criar-api-spring-boot
description: >-
  Cria ou altera endpoints e casos de uso Spring Boot projeto com camadas hexagonais,
  validação, erros Problem Details e testes. Use para REST APIs, controllers,
  services, repositories ou adapters Java.
---

# Criar API Spring Boot

**Referência:** `docs/padroes/06-java-spring-boot.md` | **Regra:** `.claude/rules/java-spring-boot.md`

## Quando usar

Novo endpoint, use case, adapter, exception handler ou DTO.

## Entradas esperadas

- Contrato HTTP (método, path, request/response)
- Regras de negócio
- Persistência/integrações
- Auth requerida

## Passo a passo

1. DTO request/response + Bean Validation.
2. Controller fino delegando ao use case.
3. Domínio sem Spring; use case `@Transactional`.
4. Adapter/repository isolado.
5. `GlobalExceptionHandler` com Problem Details.
6. Testes domínio (JUnit5/AssertJ); IT com Testcontainers se DB.
7. PIT 90% em domain; OpenAPI atualizado.

## Checklist de qualidade

- [ ] Sem lógica em controller/entity
- [ ] Paginação em listagens
- [ ] Transação explícita

## Checklist de testes

- [ ] Unitário domínio sem context
- [ ] Slice ou IT conforme necessidade
- [ ] PIT ≥90% domain

## Checklist de observabilidade

- [ ] MDC correlation_id
- [ ] Métricas Micrometer por operação

## Checklist de performance

- [ ] Evitar N+1
- [ ] Timeouts em clients HTTP
- [ ] Pool configurado

## Armadilhas comuns

- `@SpringBootTest` para tudo
- Regra de negócio na entidade JPA acoplada

## Resultado esperado

API documentada, testada, com erros padronizados e observabilidade.

## Exemplo de prompt

```
Use criar-api-spring-boot. POST /api/v1/pedidos com CriarPedidoUseCase,
validação itens não vazio, Problem Details, testes domínio + IT Postgres
Testcontainers.
```
