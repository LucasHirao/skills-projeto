# Regra Cursor

Espelha `.claude/rules/arquitetura.md`. Detalhes em `docs/padroes/`.

---

# Regra: Arquitetura

**Doc completo:** `docs/padroes/01-arquitetura-de-codigo.md`

## Faça

- Separe domínio, aplicação, infraestrutura e orquestração.
- Valide na borda; fail fast.
- Mantenha handlers/DAGs/controllers finos.
- Documente idempotência e contratos.

## Não faça

- Regra de negócio em DAG, handler, controller, Glue monolítico ou Terraform.
- God class/DAG/Lambda/module.
- Acoplamento domínio → framework/AWS.

## Critérios de aceite

- Domínio testável sem I/O
- Arquivos coesos (< 300 linhas quando possível)
- Nomes explícitos
