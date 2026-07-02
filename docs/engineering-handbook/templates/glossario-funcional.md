# Glossário funcional — {domínio ou processo}

- **Owner:** {time/pessoa}
- **Última revisão:** YYYY-MM-DD

| Termo | Significado simples | Exemplo sintético | Fonte/validador |
|-------|---------------------|-------------------|-----------------|
| {Lote de entrada} | Conjunto de registros recebidos em um arquivo diário | `LOTE-0001` com 150 linhas fictícias | {analista de negócio} |
| {Data de referência} | Dia de negócio ao qual o processamento se aplica | `2025-07-02` | {documentação do processo X} |
| {Chave de negócio} | Identificador interno do registro (nunca PII em claro) | `hash:sha256:abc123...` | {time de dados} |

## Regras do glossário

- Exemplos **sempre sintéticos** — sem CPF, CNPJ, nome, conta, agência, e-mail, telefone ou payload real.
- Termos ambíguos: marcar na coluna Fonte/validador quem confirma.
- Atualizar quando novo termo aparecer em documentação funcional ou reunião de alinhamento.

## Dúvidas abertas

- {termo não validado — aguardando especialista}

## Owner

{time/pessoa}

## Última revisão

YYYY-MM-DD
