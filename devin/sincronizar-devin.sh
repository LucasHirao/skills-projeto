#!/usr/bin/env bash
# sincronizar-devin.sh — valida estrutura, links e sincroniza skills para .agents/skills/
# Uso:
#   ./devin/sincronizar-devin.sh --check
#   ./devin/sincronizar-devin.sh
#   ./devin/sincronizar-devin.sh /path/repo-codigo

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVIN="${REPO_ROOT}/devin"
CHECK_ONLY=false
TARGET_ROOT="${REPO_ROOT}"

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
  TARGET_ROOT="$1"
fi

log() { echo "[sincronizar-devin] $*"; }

log "Executando validação central..."
bash "${REPO_ROOT}/scripts/validar-handbook.sh"

SKILL_COUNT="$(find "${DEVIN}/skills" -name 'SKILL.md' | wc -l | tr -d ' ')"
PLAYBOOK_COUNT="$(find "${DEVIN}/playbooks" -name '*.md' | wc -l | tr -d ' ')"
log "Estrutura OK (${SKILL_COUNT} skills, ${PLAYBOOK_COUNT} playbooks descobertos por convenção)."

if [[ "${CHECK_ONLY}" == true ]]; then
  log "Modo --check: nenhuma cópia aplicada."
  exit 0
fi

DEST="${TARGET_ROOT}/.agents/skills"
mkdir -p "${DEST}"

while IFS= read -r skill_file; do
  skill_dir="$(basename "$(dirname "${skill_file}")")"
  rm -rf "${DEST}/${skill_dir}"
  cp -R "${DEVIN}/skills/${skill_dir}" "${DEST}/${skill_dir}"
done < <(find "${DEVIN}/skills" -name 'SKILL.md' | sort)

log "Skills copiadas para ${DEST}"
log "Sincronização concluída."
