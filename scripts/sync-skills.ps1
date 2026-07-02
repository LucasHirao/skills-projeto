# Sync skills: .claude/skills -> .agents/skills
# Fonte canônica: .claude/skills/
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$source = Join-Path $root ".claude\skills"
$dest = Join-Path $root ".agents\skills"

if (-not (Test-Path $source)) {
    Write-Error "Fonte não encontrada: $source"
}

Get-ChildItem $source -Directory | ForEach-Object {
    $skillName = $_.Name
    $srcSkill = Join-Path $_.FullName "SKILL.md"
    $destDir = Join-Path $dest $skillName
    $destSkill = Join-Path $destDir "SKILL.md"

    if (-not (Test-Path $srcSkill)) {
        Write-Warning "Ignorando $skillName (sem SKILL.md)"
        return
    }

    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $content = Get-Content $srcSkill -Raw -Encoding UTF8
    $header = @"
<!-- Sincronizado de .claude/skills/$skillName/SKILL.md — não editar aqui. Rode scripts/sync-skills.ps1 -->

"@
    Set-Content -Path $destSkill -Value ($header + $content) -Encoding UTF8
    Write-Host "Sync: $skillName"
}

Write-Host "Concluído: $dest"
