# Playbook Devin: Revisar pull request

## Objetivo

Review estruturado com foco em **dados, multi-repo, segurança** e código gerado por IA.

## Entradas

- URL ou diff do PR
- Repo e stack identificados
- Descrição do autor e plano de teste

## Procedimento

### 1. Contexto

- Qual repo? (`-airflow`, `-dbt`, `-infra`...)
- Issue/épico linkado?
- PRs irmãos em outros repos?

### 2. Checklists

- `docs/padroes/checklist-transversal.md`
- `checklists/code-review-{stack}.md`
- Se toca contrato: verificar README repo consumidor

### 3. Dimensões (ordem)

1. **Correção** — lógica, idempotência, reprocessamento
2. **Contratos** — breaking change?
3. **Testes** — 90%, asserts reais, TaaC se integração
4. **Segurança** — IAM, secrets, PII em logs
5. **Observabilidade** — não removida; correlation_id
6. **Performance** — volume, N+1, scans
7. **Código IA** — deps reais, negócio não inventado

### 4. Classificação

| Nível | Critério |
|-------|----------|
| 🔴 Bloqueio | Merge inseguro/incorreto |
| 🟡 Atenção | Deve corrigir antes ou logo após |
| 🟢 Sugestão | Opcional |

### 5. Veredito

- Aprovado / Ressalvas / Mudanças necessárias

## Template de comentário

```markdown
### Resumo
...

### Bloqueios
- [ ] ...

### Atenção
- ...

### Veredito
...
```

## Skill alternativa

`devin/skills/revisar-pr/SKILL.md` para reviews recorrentes na mesma stack.

## Não fazer

- Aprovar só porque CI verde
- Ignorar impacto em repo downstream
