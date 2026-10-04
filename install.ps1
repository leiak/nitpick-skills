param(
    [ValidateSet("claude", "codex", "both")]
    [string]$Target = "both"
)

$ErrorActionPreference = "Stop"
$skillSource = Join-Path $PSScriptRoot "skills\nitpick"

if (-not (Test-Path $skillSource)) {
    Write-Error "Skill source not found: $skillSource"
    exit 1
}

function Install-Skill {
    param([string]$DestinationRoot, [string]$Label)
    $dest = Join-Path $DestinationRoot "nitpick"
    if (Test-Path $dest) {
        $resolvedDest = [System.IO.Path]::GetFullPath($dest)
        $resolvedRoot = [System.IO.Path]::GetFullPath($DestinationRoot)
        if (-not $resolvedDest.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Error "Destination '$dest' is outside of '$DestinationRoot'. Aborting."
            exit 1
        }
        Write-Host "  [$Label] Removing existing: $dest" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $dest
    }
    New-Item -ItemType Directory -Path $DestinationRoot -Force | Out-Null
    Copy-Item -Recurse $skillSource $dest
    Write-Host "  [$Label] Installed: $dest" -ForegroundColor Green
}

Write-Host "`n  Nitpick Installer" -ForegroundColor Cyan
Write-Host "  =================`n" -ForegroundColor Cyan

if ($Target -in @("claude", "both")) {
    Write-Host "[Claude Code]" -ForegroundColor White
    Install-Skill -DestinationRoot (Join-Path (Get-Location) ".claude\skills") -Label "project"
    try { Install-Skill -DestinationRoot (Join-Path $env:USERPROFILE ".claude\skills") -Label "global " } catch { Write-Host "  [global ] Skipped: $_" -ForegroundColor DarkGray }
    Write-Host ""
}

if ($Target -in @("codex", "both")) {
    Write-Host "[Codex]" -ForegroundColor White
    Install-Skill -DestinationRoot (Join-Path (Get-Location) ".agents\skills") -Label "project"
    try { Install-Skill -DestinationRoot (Join-Path $env:USERPROFILE ".agents\skills") -Label "global " } catch { Write-Host "  [global ] Skipped: $_" -ForegroundColor DarkGray }
    Write-Host ""
}

Write-Host "Done. Ask your agent: 'Nitpick this project'" -ForegroundColor Cyan


