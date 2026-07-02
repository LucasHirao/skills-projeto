#!/usr/bin/env bash
# sincronizar-devin.sh — valida e mantém devin/ alinhado ao Engineering Handbook
# Uso: ./devin/sincronizar-devin.sh (a partir da raiz do repo orientacoes)
# NÃO executar em produção sem revisar o diff.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDBOOK="${ROOT}/docs/engineering-handbook"
DEVIN="${ROOT}/devin"
SKILLS_DIR="${DEVIN}/skills"
PLAYBOOKS_DIR="${DEVIN}/playbooks"
SKILL_ERRORS=0

warn() {
  echo "  AVISO: $*" >&2
  SKILL_ERRORS=$((SKILL_ERRORS + 1))
}

check_handbook_link() {
  local source_file="$1"
  local rel="$2"
  local target="${ROOT}/${rel#../../}"
  if [[ ! -f "${target}" ]]; then
    echo "  ERRO: link quebrado em ${source_file}: ${rel}" >&2
    SKILL_ERRORS=$((SKILL_ERRORS + 1))
  fi
}

echo "==> Sincronizando Devin com Engineering Handbook"
echo "    ROOT:     ${ROOT}"
echo "    Handbook: ${HANDBOOK}"
echo "    Devin:    ${DEVIN}"

if [[ ! -d "${HANDBOOK}" ]]; then
  echo "ERRO: handbook não encontrado em ${HANDBOOK}" >&2
  exit 1
fi

if [[ ! -f "${DEVIN}/AGENTS.md" ]]; then
  echo "ERRO: ${DEVIN}/AGENTS.md não encontrado" >&2
  exit 1
fi

echo "==> Validando links em skills/"
if [[ -d "${SKILLS_DIR}" ]]; then
  while IFS= read -r -d '' skill_file; do
    while IFS= read -r rel; do
      [[ -n "${rel}" ]] && check_handbook_link "${skill_file}" "${rel}"
    done < <(grep -oE '\.\./\.\./docs/engineering-handbook/[^)"]+' "${skill_file}" 2>/dev/null || true)
  done < <(find "${SKILLS_DIR}" -name 'SKILL.md' -print0)
fi

echo "==> Validando links em playbooks/"
if [[ -d "${PLAYBOOKS_DIR}" ]]; then
  while IFS= read -r -d '' playbook; do
    while IFS= read -r rel; do
      [[ -n "${rel}" ]] && check_handbook_link "${playbook}" "${rel}"
    done < <(grep -oE '\.\./\.\./docs/engineering-handbook/[^)"]+' "${playbook}" 2>/dev/null || true)
  done < <(find "${PLAYBOOKS_DIR}" -name '*.md' -print0)
fi

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

echo "==> Verificando skills obrigatórias"
for skill in "${EXPECTED_SKILLS[@]}"; do
  skill_file="${SKILLS_DIR}/${skill}/SKILL.md"
  if [[ ! -f "${skill_file}" ]]; then
    warn "skill ausente: ${skill}/SKILL.md"
    continue
  fi
  grep -q '^name:' "${skill_file}" || warn "${skill}/SKILL.md sem campo 'name'"
  grep -q '^description:' "${skill_file}" || warn "${skill}/SKILL.md sem campo 'description'"
  grep -q '## Fonte de verdade' "${skill_file}" || warn "${skill}/SKILL.md sem seção 'Fonte de verdade'"
done

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

echo "==> Verificando playbooks obrigatórios"
for pb in "${EXPECTED_PLAYBOOKS[@]}"; do
  [[ -f "${PLAYBOOKS_DIR}/${pb}" ]] || warn "playbook ausente: ${pb}"
done

echo "==> Verificando tamanho das skills (não duplicar handbook)"
MAX_SKILL_LINES=120
if [[ -d "${SKILLS_DIR}" ]]; then
  while IFS= read -r -d '' skill_file; do
    lines=$(wc -l < "${skill_file}")
    if [[ "${lines}" -gt "${MAX_SKILL_LINES}" ]]; then
      warn "${skill_file} tem ${lines} linhas (máx recomendado: ${MAX_SKILL_LINES})"
    fi
  done < <(find "${SKILLS_DIR}" -name 'SKILL.md' -print0)
fi

if [[ "${SKILL_ERRORS}" -gt 0 ]]; then
  echo "==> Sincronização concluída com ${SKILL_ERRORS} aviso(s)/erro(s)" >&2
  exit 1
fi

echo "==> Copiando skills para .agents/skills/"
TARGET_ROOT="${1:-${ROOT}}"
DEST="${TARGET_ROOT}/.agents/skills"
mkdir -p "${DEST}"
for skill in "${EXPECTED_SKILLS[@]}"; do
  rm -rf "${DEST}/${skill}"
  cp -R "${SKILLS_DIR}/${skill}" "${DEST}/${skill}"
done
echo "    Destino: ${DEST}"

echo "==> Sincronização OK — devin/ alinhado ao handbook"
echo "    Skills:    $(find "${SKILLS_DIR}" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')"
echo "    Playbooks: $(find "${PLAYBOOKS_DIR}" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "Lembrete: handbook é fonte de verdade. Atualize docs/engineering-handbook/ antes de devin/."
