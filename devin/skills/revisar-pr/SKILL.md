---
name: revisar-pr
description: >-
  Procedimento Devin para revisar pull requests contra padrões, checklists por stack
  e riscos de dados, ops e segurança. Use com diff ou link do PR no repo de código.
---

# Revisar PR (Devin)

**Playbook relacionado:** `devin/playbooks/revisar-pull-request.devin.md` (review amplo multi-repo)

## Configuração da sessão Devin

1. Checkout do **repo do PR** (ou leitura do diff via `gh pr diff`).
2. Acesso ao repo de padrões: `docs/padroes/14-code-review.md`, checklists, DoD.
3. Na sessão: link do PR, stack(s), se código foi gerado por IA, ambiente alvo.

## Busca obrigatória

```text
Descrição do PR + plano de teste do autor
checklists/code-review-{stack}.md
docs/padroes/16-definition-of-done.md
docs/padroes/checklist-transversal.md
Arquivos alterados no diff — foco em hot paths e contratos
```

Identifique **todos** os repos mencionados na descrição; valide PRs irmãos.

## Classificação de achados

| Nível | Exemplos |
|-------|----------|
| 🔴 Bloqueio | IAM `*`, secret no código, breaking schema sem aviso, sem teste em lógica crítica |
| 🟡 Atenção | Observabilidade fraca, débito, performance em escala |
| 🟢 Sugestão | Naming, simplificação |

## Passos da revisão

1. Ler descrição — escopo bate com o diff?
2. Abrir checklist da stack (dbt, terraform, lambda, etc.).
3. **Dados:** backfill, idempotência, coluna removida?
4. **Segurança:** IAM, PII em log, secrets.
5. **Testes:** 90%, asserts reais, TaaC se integração.
6. **Multi-repo:** infra → glue/lambda → dbt → airflow na ordem certa?
7. **Código IA:** deps existem? negócio inventado?
8. Emitir veredito: aprovado / ressalvas / mudanças necessárias.

## Coordenação multi-repo

Checklist mental:

- [ ] Contrato S3/coluna documentado em produtor e consumidor
- [ ] Outputs TF refletidos no README do lambda/glue
- [ ] Tag dbt alinhada com DAG Airflow
- [ ] Um PR por repo — pedir split se misturado

## Validação

- Status CI do PR (não aprovar só por verde sem ler diff crítico).
- Se possível: rodar testes localmente no branch do PR.

## Checklists

- `checklists/code-review-{stack}.md` (uma ou mais)
- `docs/padroes/checklist-transversal.md`

## Reporte final Devin

```markdown
## PR
{url ou repo#num}

## Veredito
Mudanças necessárias

## Bloqueios
1. ...

## Atenção
1. ...

## Sugestões
1. ...

## Multi-repo
- [ ] PR irmão em datalake-infra — faltando

## Testes
CI: verde — gap: sem teste para caso X

## Código IA
deps OK / regra de negócio a confirmar com autor
```

## Não fazer

- Editar `.claude/`
- Aprovar sem checar contratos cross-repo
- Confundir nit com bloqueio
- Assumir regra de negócio não documentada
