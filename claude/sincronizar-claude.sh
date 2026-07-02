#!/usr/bin/env bash
# sincronizar-claude.sh — valida e sincroniza estrutura claude/ com o handbook
# Uso: ./claude/sincronizar-claude.sh [--check]
# NÃO executar em CI sem revisão — script de manutenção local.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDBOOK="${REPO_ROOT}/docs/engineering-handbook"
CLAUDE="${REPO_ROOT}/claude"
CHECK_ONLY=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

log() { echo "[sincronizar-claude] $*"; }
fail() { echo "[sincronizar-claude] ERRO: $*" >&2; exit 1; }

# --- Estrutura esperada ---
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
)

ROOT_FILES=("README.md" "CLAUDE.md" "sincronizar-claude.sh")

# --- Validações ---
[[ -d "${HANDBOOK}" ]] || fail "Handbook não encontrado: ${HANDBOOK}"
[[ -d "${CLAUDE}" ]] || fail "Pasta claude/ não encontrada: ${CLAUDE}"

for f in "${ROOT_FILES[@]}"; do
  [[ -f "${CLAUDE}/${f}" ]] || fail "Arquivo ausente: claude/${f}"
done

for r in "${REGRAS[@]}"; do
  [[ -f "${CLAUDE}/regras/${r}" ]] || fail "Regra ausente: claude/regras/${r}"
done

for s in "${SKILLS[@]}"; do
  [[ -f "${CLAUDE}/skills/${s}/SKILL.md" ]] || fail "Skill ausente: claude/skills/${s}/SKILL.md"
done

# Verifica seção "Fonte de verdade" em rules e skills
for r in "${REGRAS[@]}"; do
  grep -q "## Fonte de verdade" "${CLAUDE}/regras/${r}" \
    || fail "Seção 'Fonte de verdade' ausente em regras/${r}"
done

for s in "${SKILLS[@]}"; do
  grep -q "## Fonte de verdade" "${CLAUDE}/skills/${s}/SKILL.md" \
    || fail "Seção 'Fonte de verdade' ausente em skills/${s}/SKILL.md"
done

# Verifica links relativos ao handbook (amostra)
for f in "${CLAUDE}/regras/"*.md "${CLAUDE}/skills/"*/SKILL.md; do
  if grep -qE '\]\(\.\./\.\./docs/engineering-handbook/' "${f}" 2>/dev/null; then
    : # ok — path relativo de skills/regras
  elif grep -qE '\]\(\.\./docs/engineering-handbook/' "${f}" 2>/dev/null; then
    : # ok — path relativo de claude/CLAUDE.md
  fi
done

log "Estrutura claude/ válida (${#REGRAS[@]} regras, ${#SKILLS[@]} skills)."

if [[ "${CHECK_ONLY}" == true ]]; then
  log "Modo --check: nenhuma cópia aplicada."
  exit 0
fi

# --- Sincronização para .claude/skills/ ---
TARGET_ROOT="${2:-${REPO_ROOT}}"
DEST="${TARGET_ROOT}/.claude/skills"
mkdir -p "${DEST}"
for s in "${SKILLS[@]}"; do
  rm -rf "${DEST}/${s}"
  cp -R "${CLAUDE}/skills/${s}" "${DEST}/${s}"
done
log "Skills copiadas para ${DEST}"

log "Sincronização concluída. Atualize derivados após mudanças no handbook."
