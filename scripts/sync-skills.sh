#!/usr/bin/env bash
# Sync skills: .claude/skills -> .agents/skills
# Fonte canônica: .claude/skills/
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$ROOT/.claude/skills"
DEST="$ROOT/.agents/skills"

for dir in "$SOURCE"/*/; do
  name="$(basename "$dir")"
  src="$dir/SKILL.md"
  [[ -f "$src" ]] || { echo "Ignorando $name (sem SKILL.md)"; continue; }
  mkdir -p "$DEST/$name"
  {
    echo "<!-- Sincronizado de .claude/skills/$name/SKILL.md — não editar aqui. Rode scripts/sync-skills.sh -->"
    cat "$src"
  } > "$DEST/$name/SKILL.md"
  echo "Sync: $name"
done
echo "Concluído: $DEST"
