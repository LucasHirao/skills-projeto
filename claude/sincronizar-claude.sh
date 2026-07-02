#!/usr/bin/env bash
# sincronizar-claude.sh — valida estrutura, links e sincroniza skills para .claude/skills/
# Uso:
#   ./claude/sincronizar-claude.sh --check          # só valida
#   ./claude/sincronizar-claude.sh                  # valida e copia
#   ./claude/sincronizar-claude.sh /path/repo-codigo # copia para outro diretório

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE="${REPO_ROOT}/claude"
CHECK_ONLY=false
TARGET_ROOT="${REPO_ROOT}"

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
  TARGET_ROOT="$1"
fi

log() { echo "[sincronizar-claude] $*"; }

log "Executando validação central..."
bash "${REPO_ROOT}/scripts/validar-handbook.sh"

SKILL_COUNT="$(find "${CLAUDE}/skills" -name 'SKILL.md' | wc -l | tr -d ' ')"
log "Estrutura OK (${SKILL_COUNT} skills descobertas por convenção)."

if [[ "${CHECK_ONLY}" == true ]]; then
  log "Modo --check: nenhuma cópia aplicada."
  exit 0
fi

DEST="${TARGET_ROOT}/.claude/skills"
mkdir -p "${DEST}"

while IFS= read -r skill_file; do
  skill_dir="$(basename "$(dirname "${skill_file}")")"
  rm -rf "${DEST}/${skill_dir}"
  cp -R "${CLAUDE}/skills/${skill_dir}" "${DEST}/${skill_dir}"
done < <(find "${CLAUDE}/skills" -name 'SKILL.md' | sort)

log "Skills copiadas para ${DEST}"
log "Sincronização concluída."
