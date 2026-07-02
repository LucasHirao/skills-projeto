#!/usr/bin/env bash
# validar-handbook.sh — validação central do handbook, manifesto e artefatos derivados
# Uso: bash scripts/validar-handbook.sh
#
# Limitações: parsing do manifest.yaml é conservador (grep/awk), não valida schema YAML completo.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDBOOK="${REPO_ROOT}/docs/engineering-handbook"
MANIFEST="${HANDBOOK}/manifest.yaml"
CLAUDE="${REPO_ROOT}/claude"
DEVIN="${REPO_ROOT}/devin"

ERRORS=0

log() { echo "[validar-handbook] $*"; }
fail() {
  echo "[validar-handbook] ERRO: $*" >&2
  ERRORS=$((ERRORS + 1))
}

validate_link_in_file() {
  local src_file="$1"
  local link="$2"
  local src_dir dest

  link="${link%%#*}"

  [[ -z "${link}" ]] && return 0
  [[ "${link}" =~ ^https?:// ]] && return 0
  [[ "${link}" =~ ^mailto: ]] && return 0
  [[ "${link}" =~ ^tel: ]] && return 0
  [[ "${link}" =~ ^# ]] && return 0
  # Placeholders intencionais em templates (ex.: {nome}, XXX-titulo.md)
  [[ "${link}" == *'{'* ]] && return 0
  [[ "${link}" == *'XXX'* ]] && return 0

  src_dir="$(dirname "${src_file}")"
  dest="$(realpath -m "${src_dir}/${link}")"

  if [[ -f "${dest}" ]] || [[ -d "${dest}" ]]; then
    return 0
  fi

  fail "link quebrado em ${src_file#${REPO_ROOT}/}: ${link} (resolvido: ${dest})"
}

validate_markdown_file() {
  local file="$1"
  local link

  [[ -f "${file}" ]] || return 0
  while IFS= read -r link; do
    [[ -n "${link}" ]] && validate_link_in_file "${file}" "${link}"
  done < <(grep -oE '\[[^]]*\]\([^)]+\)' "${file}" 2>/dev/null \
    | sed -E 's/^\[[^]]*\]\(//;s/\)$//' || true)
}

validate_all_markdown_links() {
  local md_file

  log "Validando links relativos internos em todos os .md..."
  while IFS= read -r md_file; do
    validate_markdown_file "${md_file}"
  done < <(find "${REPO_ROOT}" \
    -path "${REPO_ROOT}/.git" -prune -o \
    -name "*.md" -type f -print | sort)
}

validate_manifest() {
  log "Validando manifest.yaml..."
  [[ -f "${MANIFEST}" ]] || { fail "manifest.yaml ausente"; return; }

  local path
  while IFS= read -r path; do
    [[ -z "${path}" ]] && continue
    [[ -f "${REPO_ROOT}/${path}" ]] \
      || fail "manifest: caminho inexistente: ${path}"
  done < <(grep -E '^\s+(chapter|claude_skill|devin_skill|required_chapter):' "${MANIFEST}" \
    | sed -E 's/^[[:space:]]+[^:]+:[[:space:]]*//' | sed 's/#.*//' | tr -d '"' | tr -d "'")

  while IFS= read -r path; do
    [[ -z "${path}" ]] && continue
    [[ -f "${REPO_ROOT}/${path}" ]] \
      || fail "manifest: template ausente: ${path}"
  done < <(grep -E '^\s+- docs/engineering-handbook/templates/' "${MANIFEST}" \
    | sed -E 's/^[[:space:]]+- //')

  local regra
  while IFS= read -r regra; do
    [[ -z "${regra}" ]] && continue
    [[ -f "${CLAUDE}/regras/${regra}" ]] \
      || fail "manifest: regra ausente: claude/regras/${regra}"
  done < <(awk '/^claude_regras:/{f=0} /^  files:/{f=1;next} f && /^  - /{print $2}' "${MANIFEST}")
}

validate_stack_entry() {
  local stack_id="$1"
  local chapter="$2"
  local claude_skill="$3"
  local devin_skill="$4"
  local chapter_path="${REPO_ROOT}/${chapter}"
  local chapter_base

  chapter_base="$(basename "${chapter}")"

  [[ -f "${chapter_path}" ]] \
    || fail "stack ${stack_id}: capítulo ausente: ${chapter}"

  grep -q '## Padrões de código da stack' "${chapter_path}" \
    || fail "stack ${stack_id}: capítulo sem '## Padrões de código da stack': ${chapter}"

  grep -q '03-padroes-de-codigo.md' "${chapter_path}" \
    || fail "stack ${stack_id}: capítulo sem referência a 03-padroes-de-codigo.md: ${chapter}"

  grep -q '18-definition-of-done.md' "${chapter_path}" \
    || fail "stack ${stack_id}: capítulo sem referência a 18-definition-of-done.md: ${chapter}"

  if [[ -n "${claude_skill}" ]]; then
    [[ -f "${REPO_ROOT}/${claude_skill}" ]] \
      || fail "stack ${stack_id}: claude_skill ausente: ${claude_skill}"
    grep -q "${chapter_base}" "${REPO_ROOT}/${claude_skill}" \
      || fail "stack ${stack_id}: claude_skill não referencia capítulo: ${claude_skill} → ${chapter_base}"
  fi

  if [[ -n "${devin_skill}" ]]; then
    [[ -f "${REPO_ROOT}/${devin_skill}" ]] \
      || fail "stack ${stack_id}: devin_skill ausente: ${devin_skill}"
    grep -q "${chapter_base}" "${REPO_ROOT}/${devin_skill}" \
      || fail "stack ${stack_id}: devin_skill não referencia capítulo: ${devin_skill} → ${chapter_base}"
  fi
}

validate_stacks_from_manifest() {
  local in_stack=0 stack_id="" chapter="" claude_skill="" devin_skill="" enabled="true"

  log "Validando stacks registradas no manifesto..."

  while IFS= read -r line; do
    case "${line}" in
      "  - id:"*)
        in_stack=1
        stack_id="$(echo "${line}" | sed -E 's/^[[:space:]]+- id:[[:space:]]*//')"
        chapter=""
        claude_skill=""
        devin_skill=""
        enabled="true"
        ;;
      "    chapter:"*)
        [[ "${in_stack}" -eq 1 ]] && chapter="$(echo "${line}" | sed -E 's/^[[:space:]]+chapter:[[:space:]]*//')"
        ;;
      "    claude_skill:"*)
        [[ "${in_stack}" -eq 1 ]] && claude_skill="$(echo "${line}" | sed -E 's/^[[:space:]]+claude_skill:[[:space:]]*//')"
        ;;
      "    devin_skill:"*)
        [[ "${in_stack}" -eq 1 ]] && devin_skill="$(echo "${line}" | sed -E 's/^[[:space:]]+devin_skill:[[:space:]]*//')"
        ;;
      "    enabled: false"*)
        [[ "${in_stack}" -eq 1 ]] && enabled="false"
        ;;
      "    enabled: true"*)
        if [[ "${in_stack}" -eq 1 && "${enabled}" == "true" && -n "${chapter}" ]]; then
          validate_stack_entry "${stack_id}" "${chapter}" "${claude_skill}" "${devin_skill}"
        fi
        in_stack=0
        ;;
    esac
  done < "${MANIFEST}"
}

validate_claude_skill() {
  local skill_file="$1"
  local skill_name
  skill_name="$(basename "$(dirname "${skill_file}")")"

  grep -q '^---' "${skill_file}" || fail "sem frontmatter YAML: ${skill_file}"
  grep -q '^name:' "${skill_file}" || fail "sem campo name: ${skill_file}"
  grep -q '^description:' "${skill_file}" || fail "sem campo description: ${skill_file}"
  grep -q '03-padroes-de-codigo.md' "${skill_file}" || fail "sem capítulo 03: ${skill_file}"
  grep -q '## Nomenclatura de código' "${skill_file}" || fail "sem Nomenclatura de código: ${skill_file}"
  grep -q '## Fonte de verdade' "${skill_file}" || fail "sem Fonte de verdade: ${skill_file}"

  if [[ "${skill_name}" == *prompt* ]]; then
    grep -q '21-agentes-e-prompts.md' "${skill_file}" \
      || fail "skill de prompt sem capítulo 21: ${skill_file}"
  fi
  if [[ "${skill_name}" == *documentacao-funcional* ]]; then
    grep -q '22-documentacao-funcional.md' "${skill_file}" \
      || fail "skill de doc funcional sem capítulo 22: ${skill_file}"
  fi
  if [[ "${skill_name}" == *observabilidade* || "${skill_name}" == *investigar-falha* ]]; then
    grep -q '13-observabilidade.md' "${skill_file}" \
      || fail "skill de observabilidade sem capítulo 13: ${skill_file}"
  fi
}

validate_devin_skill() {
  validate_claude_skill "$1"
}

validate_devin_playbook() {
  local playbook="$1"
  local playbook_name
  playbook_name="$(basename "${playbook}")"

  grep -q '## Nomenclatura de código' "${playbook}" \
    || fail "playbook sem Nomenclatura de código: ${playbook}"
  grep -q '## Fonte de verdade' "${playbook}" \
    || fail "playbook sem Fonte de verdade: ${playbook}"
  grep -q '03-padroes-de-codigo.md' "${playbook}" \
    || fail "playbook sem capítulo 03: ${playbook}"

  if [[ "${playbook_name}" == *prompt* ]]; then
    grep -q '21-agentes-e-prompts.md' "${playbook}" \
      || fail "playbook de prompt sem capítulo 21: ${playbook}"
  fi
  if [[ "${playbook_name}" == *documentacao-funcional* ]]; then
    grep -q '22-documentacao-funcional.md' "${playbook}" \
      || fail "playbook de doc funcional sem capítulo 22: ${playbook}"
  fi
  if [[ "${playbook_name}" == *observabilidade* || "${playbook_name}" == *investigar-falha* ]]; then
    grep -q '13-observabilidade.md' "${playbook}" \
      || fail "playbook de observabilidade sem capítulo 13: ${playbook}"
  fi
}

validate_discovered_artifacts() {
  local skill_file playbook

  log "Validando Skills Claude (descoberta por convenção)..."
  while IFS= read -r skill_file; do
    validate_claude_skill "${skill_file}"
  done < <(find "${CLAUDE}/skills" -name 'SKILL.md' | sort)

  log "Validando Skills Devin (descoberta por convenção)..."
  while IFS= read -r skill_file; do
    validate_devin_skill "${skill_file}"
  done < <(find "${DEVIN}/skills" -name 'SKILL.md' | sort)

  log "Validando Playbooks Devin..."
  while IFS= read -r playbook; do
    validate_devin_playbook "${playbook}"
  done < <(find "${DEVIN}/playbooks" -name '*.md' | sort)
}

[[ -d "${HANDBOOK}" ]] || { echo "ERRO: handbook não encontrado" >&2; exit 1; }

validate_manifest
validate_stacks_from_manifest
validate_discovered_artifacts
validate_all_markdown_links

if [[ "${ERRORS}" -gt 0 ]]; then
  echo "[validar-handbook] ${ERRORS} erro(s) encontrado(s)." >&2
  exit 1
fi

log "Validação concluída com sucesso."
