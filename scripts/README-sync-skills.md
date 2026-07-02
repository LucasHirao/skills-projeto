# Sincronização de Skills

**Fonte canônica:** `.claude/skills/`

**Destino:** `.agents/skills/` (Devin e agentes compatíveis)

## Uso

```powershell
.\scripts\sync-skills.ps1
```

```bash
./scripts/sync-skills.sh
```

Execute após alterar qualquer `SKILL.md` em `.claude/skills/`.

## Regra

Não editar `.agents/skills/` diretamente — alterações serão sobrescritas na próxima sync.
