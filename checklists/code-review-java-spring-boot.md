# Checklist: Code Review Java Spring Boot

## Perguntas objetivas

- [ ] Controller fino?
- [ ] Use case com transação explícita?
- [ ] DTOs na borda + Bean Validation?
- [ ] Problem Details para erros?
- [ ] Testes domínio sem Spring?
- [ ] IT com Testcontainers se DB?
- [ ] PIT ≥ 90% em domain?
- [ ] Paginação em listagens?

## 🔴 Bloqueio

- Lógica de negócio em `@Entity` ou controller
- Endpoint sem autenticação documentada
- N+1 em path crítico

## 🟡 Atenção

- `@SpringBootTest` onde slice bastaria
- Stream encadeado difícil de ler

## Exemplos de comentário

> 🔴 Validação de estoque no controller — mover para `Pedido.criar()`.

> 🟡 Adicionar `@Transactional(readOnly=true)` na listagem.
