# Onboarding

Guia para desenvolvedores internos e terceiros.

## Ordem de leitura (≈ 2–3 h)

1. [00-visao-geral.md](00-visao-geral.md)
2. [AGENTS.md](../../AGENTS.md) ou guia do seu agente: [CURSOR.md](../../CURSOR.md) / [CLAUDE.md](../../CLAUDE.md) / [DEVIN.md](../../DEVIN.md)
3. [18-estrutura-repositorios.md](18-estrutura-repositorios.md)
4. Padrão da(s) stack(s) que você vai tocar (`02`–`07`)
5. [16-definition-of-done.md](16-definition-of-done.md)
6. [19-onboarding.md](19-onboarding.md) — você está aqui

## Primeiro PR sugerido

1. Identifique o **repositório de código** correto (`18-estrutura-repositorios.md`).
2. Leia código similar **nesse repo**.
3. Use template [template-pr.md](templates/template-pr.md).
4. Preencha checklist DoD.
5. Se cruzar contrato com outro repo, mencione no PR e abra issue/PR coordenado.

## Exceções à Definition of Done

| Situação | Quem aprova | O que documentar |
|----------|-------------|------------------|
| Cobertura < 90% em DTO/bootstrap | Reviewer no PR | Justificativa + issue se débito |
| Spike < 2 dias | Tech lead | Label `spike` + débito listado |
| Breaking change | Tech lead + consumidores | ADR + comunicação |

Preencha contatos reais do seu time na tabela abaixo:

| Domínio | Responsável | Canal |
|---------|-------------|-------|
| Dados / dbt | _a definir_ | |
| Orquestração / Airflow | _a definir_ | |
| Infra / Terraform | _a definir_ | |
| APIs / Spring | _a definir_ | |

## Ferramentas de IA no dia a dia

| Ferramenta | Comece por |
|------------|------------|
| Cursor | `CURSOR.md` |
| Claude Code | `CLAUDE.md` + skill da tarefa |
| Devin | `DEVIN.md` + playbook em `devin-playbooks/` |

## Anti-padrões no onboarding

- Implementar sem ler padrão da stack
- Copiar código de outro cliente/projeto sem adaptar naming
- PR grande sem testes
- Ignorar impacto em dados/reprocessamento

## Checklist do primeiro dia

- [ ] Acesso ao repositório e ambiente
- [ ] Pipeline do time conhecido (onde ver resultado de build/test)
- [ ] Padrão da stack lido
- [ ] Um exemplo em `examples/` executado ou compreendido
- [ ] Canal do time identificado
