# Playbook: Revisar PR projeto

## Objetivo

Review estruturado antes do merge, com foco em riscos de dados, ops e código IA.

## Escopo

Análise do diff, checklists por stack, veredito com severidade.

## Contexto

- `docs/padroes/14-code-review.md`
- `checklists/code-review-*.md`
- Skill `revisar-pr`

## O que procurar no repositório

- Padrão do módulo vizinho
- Testes existentes para o componente
- ADRs relacionados

## Como planejar

1. Identificar stacks no PR.
2. Carregar checklists correspondentes.
3. Ler plano de teste do autor.

## Como implementar (review)

1. Correção funcional e casos limite.
2. Testes 90% + mutation onde aplicável.
3. Segurança, observabilidade, performance.
4. Impacto dados/backfill/breaking change.
5. Código IA: deps, negócio, testes substantivos.

## Como testar

- Verificar evidência CI no PR
- Opcional: checkout branch e rodar testes localmente

## Como revisar

Classificar: 🔴 bloqueio | 🟡 atenção | 🟢 sugestão

## Como reportar resultado

Usar `docs/padroes/templates/template-code-review.md` ou comentários no PR com veredito final.

## Critérios de aceite

- [ ] Todos bloqueios resolvidos
- [ ] DoD atendida
- [ ] Breaking changes comunicados

## O que não fazer

- Aprovar sem checar impacto em dados
- Nitpicking sem priorização
