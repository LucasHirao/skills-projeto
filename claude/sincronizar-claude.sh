#!/usr/bin/env bash
# sincronizar-claude.sh — valida estrutura, links e sincroniza skills para .claude/skills/
# Uso:
#   ./claude/sincronizar-claude.sh --check          # só valida
#   ./claude/sincronizar-claude.sh                  # valida e copia
#   ./claude/sincronizar-claude.sh /path/repo-codigo # copia para outro diretório

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDBOOK="${REPO_ROOT}/docs/engineering-handbook"
CLAUDE="${REPO_ROOT}/claude"
CHECK_ONLY=false
TARGET_ROOT="${REPO_ROOT}"

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
elif [[ -n "${1:-}" ]]; then
  TARGET_ROOT="$1"
fi

log() { echo "[sincronizar-claude] $*"; }
fail() { echo "[sincronizar-claude] ERRO: $*" >&2; LINK_ERRORS=$((LINK_ERRORS + 1)); }

LINK_ERRORS=0

REGRAS=(
  "00-regras-gerais.md"
  "01-arquitetura.md"
  "02-testes.md"
  "03-observabilidade.md"
  "04-seguranca.md"
  "05-padroes-de-codigo.md"
  "06-uso-de-ia.md"
)

SKILLS=(
  "criar-dag-airflow"
  "criar-modelo-dbt"
  "criar-modulo-terraform"
  "criar-lambda-python"
  "criar-api-spring-boot"
  "criar-job-glue"
  "criar-testes-unitarios"
  "criar-taac"
  "revisar-codigo"
  "revisar-desempenho"
  "melhorar-observabilidade"
  "criar-documentacao"
  "investigar-falha"
  "preparar-prompt-tecnico"
  "revisar-prompt-tecnico"
  "extrair-documentacao-funcional"
  "revisar-documentacao-funcional"
)

PROMPT_SKILLS=(
  "preparar-prompt-tecnico"
  "revisar-prompt-tecnico"
)

FUNC_DOC_SKILLS=(
  "extrair-documentacao-funcional"
  "revisar-documentacao-funcional"
)

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

  fail "link quebrado em ${src_file#${REPO_ROOT}/}: ${link} (resolvido: ${dest})"
}

validate_markdown_file() {
  local file="$1"
  local link

  while IFS= read -r link; do
    [[ -n "${link}" ]] && validate_link_in_file "${file}" "${link}"
  done < <(grep -oE '\[[^]]*\]\([^)]+\)' "${file}" 2>/dev/null \
    | sed -E 's/^\[[^]]*\]\(//;s/\)$//' || true)
}

validate_all_links() {
  local f
  for f in \
    "${CLAUDE}/README.md" \
    "${CLAUDE}/CLAUDE.md" \
    "${REPO_ROOT}/docs/engineering-handbook/artefatos-ia.md"; do
    [[ -f "${f}" ]] && validate_markdown_file "${f}"
  done

  for r in "${REGRAS[@]}"; do
    validate_markdown_file "${CLAUDE}/regras/${r}"
  done

  for s in "${SKILLS[@]}"; do
    validate_markdown_file "${CLAUDE}/skills/${s}/SKILL.md"
    grep -q "03-padroes-de-codigo.md" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "capítulo 03 ausente em claude/skills/${s}/SKILL.md"
    grep -q "## Nomenclatura de código" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "seção Nomenclatura ausente em claude/skills/${s}/SKILL.md"
  done

  for s in "${PROMPT_SKILLS[@]}"; do
    grep -q "## Fonte de verdade" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "seção Fonte de verdade ausente em claude/skills/${s}/SKILL.md"
    grep -q "21-agentes-e-prompts.md" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "capítulo 21 ausente em claude/skills/${s}/SKILL.md"
  done

  for s in "${FUNC_DOC_SKILLS[@]}"; do
    grep -q "## Fonte de verdade" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "seção Fonte de verdade ausente em claude/skills/${s}/SKILL.md"
    grep -q "22-documentacao-funcional.md" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "capítulo 22 ausente em claude/skills/${s}/SKILL.md"
    grep -q "03-padroes-de-codigo.md" "${CLAUDE}/skills/${s}/SKILL.md" \
      || fail "capítulo 03 ausente em claude/skills/${s}/SKILL.md"
  done
}

[[ -d "${HANDBOOK}" ]] || { echo "ERRO: handbook não encontrado: ${HANDBOOK}" >&2; exit 1; }
[[ -f "${HANDBOOK}/21-agentes-e-prompts.md" ]] \
  || { echo "ERRO: capítulo 21 ausente no handbook" >&2; exit 1; }
[[ -f "${HANDBOOK}/22-documentacao-funcional.md" ]] \
  || { echo "ERRO: capítulo 22 ausente no handbook" >&2; exit 1; }
[[ -d "${CLAUDE}" ]] || { echo "ERRO: pasta claude/ não encontrada" >&2; exit 1; }

for r in "${REGRAS[@]}"; do
  [[ -f "${CLAUDE}/regras/${r}" ]] || { echo "ERRO: regra ausente: ${r}" >&2; exit 1; }
done

for s in "${SKILLS[@]}"; do
  [[ -f "${CLAUDE}/skills/${s}/SKILL.md" ]] || { echo "ERRO: skill ausente: ${s}" >&2; exit 1; }
done

log "Validando links relativos ao handbook..."
validate_all_links

if [[ "${LINK_ERRORS}" -gt 0 ]]; then
  echo "[sincronizar-claude] ${LINK_ERRORS} erro(s) de validação." >&2
  exit 1
fi

log "Estrutura e links OK (${#REGRAS[@]} regras, ${#SKILLS[@]} skills)."

if [[ "${CHECK_ONLY}" == true ]]; then
  log "Modo --check: nenhuma cópia aplicada."
  exit 0
fi

DEST="${TARGET_ROOT}/.claude/skills"
mkdir -p "${DEST}"
for s in "${SKILLS[@]}"; do
  rm -rf "${DEST}/${s}"
  cp -R "${CLAUDE}/skills/${s}" "${DEST}/${s}"
done
log "Skills copiadas para ${DEST}"
log "Sincronização concluída."
