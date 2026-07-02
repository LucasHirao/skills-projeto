#!/usr/bin/env bash
# sincronizar-devin.sh — valida estrutura, links e sincroniza skills para .agents/skills/
# Uso:
#   ./devin/sincronizar-devin.sh --check
#   ./devin/sincronizar-devin.sh
#   ./devin/sincronizar-devin.sh /path/repo-codigo

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDBOOK="${ROOT}/docs/engineering-handbook"
DEVIN="${ROOT}/devin"
SKILLS_DIR="${DEVIN}/skills"
PLAYBOOKS_DIR="${DEVIN}/playbooks"
CHECK_ONLY=false
TARGET_ROOT="${ROOT}"

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
  TARGET_ROOT="$1"
fi

LINK_ERRORS=0

fail() {
  echo "[sincronizar-devin] ERRO: $*" >&2
  LINK_ERRORS=$((LINK_ERRORS + 1))
}

log() { echo "[sincronizar-devin] $*"; }

validate_link_in_file() {
  local src_file="$1"
  local link="$2"
  local src_dir link_path dest

  link="${link%%#*}"
  [[ -z "${link}" ]] && return 0
  [[ "${link}" =~ ^https?:// ]] && return 0
  [[ "${link}" =~ ^mailto: ]] && return 0
  [[ "${link}" != *"engineering-handbook"* ]] && return 0

  src_dir="$(dirname "${src_file}")"
  link_path="${src_dir}/${link}"
  dest="$(realpath -m "${link_path}")"

  if [[ -f "${dest}" ]] || [[ -d "${dest}" ]]; then
    return 0
  fi

  fail "link quebrado em ${src_file#${ROOT}/}: ${link} (resolvido: ${dest})"
}

validate_markdown_file() {
  local file="$1"
  local link

  while IFS= read -r link; do
    [[ -n "${link}" ]] && validate_link_in_file "${file}" "${link}"
  done < <(grep -oE '\[[^]]*\]\([^)]+\)' "${file}" 2>/dev/null \
    | sed -E 's/^\[[^]]*\]\(//;s/\)$//' || true)
}

EXPECTED_SKILLS=(
  criar-api-spring-boot
  criar-dag-airflow
  criar-documentacao
  criar-job-glue
  criar-lambda-python
  criar-modelo-dbt
  criar-modulo-terraform
  criar-taac
  criar-testes-unitarios
  investigar-falha
  melhorar-observabilidade
  revisar-codigo
  revisar-desempenho
)

EXPECTED_PLAYBOOKS=(
  implementar-feature.md
  revisar-pr.md
  criar-pipeline-airflow-dbt.md
  criar-componente-aws.md
  criar-taac.md
  investigar-falha-pipeline.md
  melhorar-observabilidade.md
  revisar-desempenho.md
)

[[ -d "${HANDBOOK}" ]] || { echo "ERRO: handbook não encontrado" >&2; exit 1; }
[[ -f "${DEVIN}/AGENTS.md" ]] || { echo "ERRO: devin/AGENTS.md não encontrado" >&2; exit 1; }

log "Validando links..."
validate_markdown_file "${DEVIN}/README.md"
validate_markdown_file "${DEVIN}/AGENTS.md"
validate_markdown_file "${ROOT}/docs/engineering-handbook/artefatos-ia.md"

for skill in "${EXPECTED_SKILLS[@]}"; do
  skill_file="${SKILLS_DIR}/${skill}/SKILL.md"
  [[ -f "${skill_file}" ]] || fail "skill ausente: ${skill}/SKILL.md"
  validate_markdown_file "${skill_file}"
  grep -q "03-padroes-de-codigo.md" "${skill_file}" \
    || fail "capítulo 03 ausente em devin/skills/${skill}/SKILL.md"
  grep -q "## Nomenclatura de código" "${skill_file}" \
    || fail "seção Nomenclatura ausente em devin/skills/${skill}/SKILL.md"
  grep -q '^name:' "${skill_file}" || fail "${skill}/SKILL.md sem campo name"
  grep -q '^description:' "${skill_file}" || fail "${skill}/SKILL.md sem campo description"
  grep -q '## Fonte de verdade' "${skill_file}" || fail "${skill}/SKILL.md sem Fonte de verdade"
done

for pb in "${EXPECTED_PLAYBOOKS[@]}"; do
  playbook="${PLAYBOOKS_DIR}/${pb}"
  [[ -f "${playbook}" ]] || fail "playbook ausente: ${pb}"
  validate_markdown_file "${playbook}"
  grep -q "## Nomenclatura de código" "${playbook}" \
    || fail "seção Nomenclatura ausente em devin/playbooks/${pb}"
done

if [[ "${LINK_ERRORS}" -gt 0 ]]; then
  echo "[sincronizar-devin] ${LINK_ERRORS} erro(s) de validação." >&2
  exit 1
fi

log "Estrutura e links OK."

if [[ "${CHECK_ONLY}" == true ]]; then
  log "Modo --check: nenhuma cópia aplicada."
  exit 0
fi

DEST="${TARGET_ROOT}/.agents/skills"
mkdir -p "${DEST}"
for skill in "${EXPECTED_SKILLS[@]}"; do
  rm -rf "${DEST}/${skill}"
  cp -R "${SKILLS_DIR}/${skill}" "${DEST}/${skill}"
done
log "Skills copiadas para ${DEST}"
log "Sincronização concluída."
