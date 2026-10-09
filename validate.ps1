# validate.ps1 — Automated cross-reference and integrity validation
# Usage: .\validate.ps1 [-TestInstall]
param(
    [switch]$TestInstall
)

$ErrorActionPreference = "Stop"
$pass = 0; $fail = 0

function Check {
    param([string]$Description, [bool]$Condition)
    if ($Condition) {
        Write-Host "  PASS: $Description" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "  FAIL: $Description" -ForegroundColor Red
        $script:fail++
    }
}

Write-Host "`n  Nitpick Validator" -ForegroundColor Cyan
Write-Host "  ==================`n" -ForegroundColor Cyan

# 1. Skill source integrity
Write-Host "[1] Skill source structure" -ForegroundColor White
$skillRoot = Join-Path $PSScriptRoot "skills\nitpick"
Check "SKILL.md exists" (Test-Path (Join-Path $skillRoot "SKILL.md"))
Check "Rubric exists" (Test-Path (Join-Path $skillRoot "dimensions\00-rubric.md"))

$expectedDimensions = @("01-architecture.md", "02-code-quality.md", "03-security.md", "04-performance.md", "05-testing.md", "06-dx.md")
foreach ($dim in $expectedDimensions) {
    Check "Dimension file: $dim" (Test-Path (Join-Path $skillRoot "dimensions\$dim"))
}

$languages = @("typescript.md", "python.md", "go.md", "rust.md", "java.md", "kotlin.md", "csharp.md", "cpp.md", "swift.md", "ruby.md", "php.md")
foreach ($lang in $languages) {
    Check "Language guide: $lang" (Test-Path (Join-Path $skillRoot "languages\$lang"))
}

# 2. Cross-reference validation
Write-Host "`n[2] SKILL.md cross-references" -ForegroundColor White
$skillContent = Get-Content (Join-Path $skillRoot "SKILL.md") -Raw

$templateRefs = [regex]::Matches($skillContent, 'templates/[\w\.\-]+\.md') | ForEach-Object { $_.Value } | Select-Object -Unique
foreach ($ref in $templateRefs) {
    Check "Template reference: $ref" (Test-Path (Join-Path $skillRoot $ref))
}

$dimRefs = [regex]::Matches($skillContent, 'dimensions/(\d{2}[\w\-]+\.md)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
foreach ($ref in $dimRefs) {
    Check "Dimension reference: $ref" (Test-Path (Join-Path $skillRoot "dimensions\$ref"))
}

$langRefs = [regex]::Matches($skillContent, 'languages/([\w]+\.md)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
foreach ($ref in $langRefs) {
    Check "Language reference: $ref" (Test-Path (Join-Path $skillRoot "languages\$ref"))
}

$brokenPaths = [regex]::Matches($skillContent, '\.\./\.\./templates/') | ForEach-Object { $_.Value }
Check "No broken ../../ template paths" ($brokenPaths.Count -eq 0)

# 3. Dimension cross-references (rubric)
Write-Host "`n[3] Dimension file cross-references" -ForegroundColor White
foreach ($dim in $expectedDimensions) {
    $dimContent = Get-Content (Join-Path $skillRoot "dimensions\$dim") -Raw
    Check "$dim references rubric" ($dimContent -match '00-rubric\.md')
}

# 4. Templates consistency
Write-Host "`n[4] Template files" -ForegroundColor White
$templates = @("report-template.md", "report-template.zh.md")
foreach ($tpl in $templates) {
    Check "Template: $tpl" (Test-Path (Join-Path $skillRoot "templates\$tpl"))
}
foreach ($tpl in $templates) {
    Check "Root template: $tpl" (Test-Path (Join-Path $PSScriptRoot "templates\$tpl"))
}

# 5. Install script integrity
Write-Host "`n[5] Install script" -ForegroundColor White
$installScript = Get-Content (Join-Path $PSScriptRoot "install.ps1") -Raw
Check "install.ps1 has path validation" ($installScript -match 'GetFullPath|StartsWith')
Check "install.ps1 has -Target param" ($installScript -match 'ValidateSet')
Check "install.ps1 references skill path" ($installScript -match 'nitpick')

# 6. Optional: install-and-verify test
if ($TestInstall) {
    Write-Host "`n[6] Install test (temp directory)" -ForegroundColor White
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "nitpick-test-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        $tempSkill = Join-Path $tempDir "nitpick"
        Copy-Item -Recurse $skillRoot $tempSkill

        $srcFiles = Get-ChildItem $skillRoot -Recurse -File | ForEach-Object { $_.FullName.Replace("$skillRoot\", "") }
        $allCopied = $true
        foreach ($f in $srcFiles) {
            if (-not (Test-Path (Join-Path $tempSkill $f))) {
                Write-Host "  FAIL: Missing after install: $f" -ForegroundColor Red
                $allCopied = $false
                $fail++
            }
        }
        if ($allCopied) {
            Write-Host "  PASS: All files copied intact" -ForegroundColor Green
            $pass++
        }

        $installedSkill = Get-Content (Join-Path $tempSkill "SKILL.md") -Raw
        $installedRefs = [regex]::Matches($installedSkill, 'templates/[\w\.\-]+\.md') | ForEach-Object { $_.Value }
        $refOk = $true
        foreach ($ref in $installedRefs) {
            if (-not (Test-Path (Join-Path $tempSkill $ref))) {
                Write-Host "  FAIL: Broken reference from installed: $ref" -ForegroundColor Red
                $refOk = $false
                $fail++
            }
        }
        if ($refOk) {
            Write-Host "  PASS: All references resolve from installed location" -ForegroundColor Green
            $pass++
        }
    } finally {
        Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
    }
}

# 6. Trigger evaluation
Write-Host "`n[6] Trigger evaluation" -ForegroundColor White
$evalCasePath = Join-Path $PSScriptRoot "evals\cases\nitpick.json"
Check "Eval case exists" (Test-Path $evalCasePath)
if (Test-Path $evalCasePath) {
    try {
        $evalData = Get-Content $evalCasePath -Raw | ConvertFrom-Json
        $posCount = $evalData.trigger.positive.Count
        $negCount = $evalData.trigger.negative.Count
        Check "At least 3 positive triggers (found: $posCount)" ($posCount -ge 3)
        Check "At least 2 negative triggers (found: $negCount)" ($negCount -ge 2)
    } catch {
        Check "Eval case is valid JSON" $false
    }
}
# Summary
Write-Host "`n  ==================" -ForegroundColor Cyan
Write-Host "  Results: $pass pass, $fail fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host "  ==================`n" -ForegroundColor Cyan

exit $(if ($fail -eq 0) { 0 } else { 1 })
