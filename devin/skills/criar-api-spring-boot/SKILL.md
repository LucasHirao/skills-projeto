---
name: criar-api-spring-boot
description: Cria ou altera APIs REST em Java Spring Boot no ecossistema {nome-projeto}, com camadas domain/application/infrastructure, testes e observabilidade Datadog. Use ao criar endpoint, serviço, adapter JPA ou módulo Spring Boot.
allowed-tools: read, write, bash, grep, glob
argument-hint: "{org}/{repo} {pacote-base} {objetivo — ex. endpoint POST /pedidos}"
triggers:
  - criar api spring boot
  - novo endpoint rest
  - serviço java spring
  - adapter jpa
---

# criar-api-spring-boot

## Fonte de verdade

- [08 — Java Spring Boot](../../../docs/engineering-handbook/08-java-spring-boot.md)
- [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
- [10 — Testes unitários](../../../docs/engineering-handbook/10-testes-unitarios.md)
- [18 — Definition of Done](../../../docs/engineering-handbook/18-definition-of-done.md)

## Quando usar

- Novo endpoint, caso de uso, adapter ou módulo em `{nome-projeto}-api` (ou repo Spring equivalente)
- Refatoração que preserva contrato OpenAPI
- Adição de integração (fila, DB, cliente HTTP) com testes

## Nomenclatura de código

- Use português para identificadores internos criados pelo time: classes, funções, métodos, variáveis, testes, tasks, DAGs, models dbt e módulos internos.
- Preserve nomes externos, SDKs, frameworks, comandos, schemas, contratos públicos, tags técnicas e campos exigidos por ferramentas.
- Se o repositório alvo já tiver padrão consolidado em inglês, documente a exceção no PR ou em ADR.
- Java: classes, métodos, variáveis e testes em português.
- Referência: [03 — Padrões de código](../../../docs/engineering-handbook/03-padroes-de-codigo.md)
## Passos

1. Ler README do repo e módulo vizinho; copiar estrutura de pacotes.
2. Apresentar **plano** (5–10 bullets) antes de editar.
3. Implementar: `domain` → `application` → `infrastructure` → `api` (controller).
4. Validar input na borda; erros com RFC 7807 ou padrão do projeto.
5. Testes unitários (domain/application ≥ 90% cov + mutation); integração onde necessário.
6. Logs JSON + trace APM Datadog; métricas de latência e erro.
7. Atualizar OpenAPI/README se contrato mudou.

## Checklist DoD (recorte)

- [ ] Regra de negócio em `domain/`, não no controller
- [ ] Cobertura ≥ 90%; mutation em domain/application
- [ ] Sem segredo em `application.yml`; usar secrets manager
- [ ] `correlation_id` propagado em logs
- [ ] CI verde (build, testes, checkstyle/spotbugs se aplicável)

## Templates

- [readme-componente](../../../docs/engineering-handbook/templates/readme-componente.md)
- [pr](../../../docs/engineering-handbook/templates/pr.md)

## Não fazer

Ver anti-padrões em [08 — Java Spring Boot](../../../docs/engineering-handbook/08-java-spring-boot.md) — não duplicar aqui.
