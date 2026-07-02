<!-- Sincronizado de .claude/skills/revisar-pr/SKILL.md â€” nÃ£o editar aqui. Rode scripts/sync-skills.ps1 -->
---
name: revisar-pr
description: >-
  Revisa pull requests projeto contra padrões, checklists por stack e riscos de
  dados/ops/segurança. Use ao revisar PR, diff, branch ou código gerado por IA
  antes do merge.
---

# Revisar PR

**Referência:** `docs/padroes/14-code-review.md` | **Template:** `docs/padroes/templates/template-code-review.md`

## Quando usar

Review de PR, validação pré-merge, auditoria de código de agente IA.

## Entradas esperadas

- Diff ou link do PR
- Stack(s) afetada(s)
- Descrição do autor e plano de teste

## Passo a passo

1. Ler descrição e identificar stacks.
2. Abrir checklist(s) em `checklists/code-review-{stack}.md`.
3. Verificar DoD (`16-definition-of-done.md`).
4. Classificar achados: 🔴 bloqueio, 🟡 atenção, 🟢 sugestão.
5. Checar código IA: deps reais, negócio não inventado, testes substantivos.
6. Avaliar impacto dados, custo, rollback.
7. Emitir veredito: aprovado / ressalvas / mudanças necessárias.

## Checklist de qualidade

- [ ] Aderência a `docs/padroes/`
- [ ] Simplicidade e coesão
- [ ] Breaking changes explícitos

## Checklist de testes

- [ ] 90% cov; mutation onde aplicável
- [ ] TaaC se integração

## Checklist de observabilidade

- [ ] Sem remoção de telemetria
- [ ] Logs/métricas adequados

## Checklist de performance

- [ ] Volume considerado
- [ ] Sem anti-padrões óbvios

## Armadilhas comuns

- Aprovar só porque CI verde
- Ignorar impacto em backfill
- Nit sem distinguir bloqueio

## Resultado esperado

Review estruturado com achados priorizados e veredito claro.

## Exemplo de prompt

```
Use revisar-pr. Revise este diff de DAG Airflow + dbt contra checklists.
Classifique achados e veredito. Atente código gerado por IA.
```

