$ErrorActionPreference = "SilentlyContinue"

# 1. Resolve Project Root (100% Relative & Portable)
$scriptDir = Split-Path -Parent $PSCommandPath
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)

# Fallback check for package.json
if (-not (Test-Path (Join-Path $projectRoot "package.json"))) {
    $projectRoot = (Get-Location).Path
    if (Test-Path (Join-Path $projectRoot "..\package.json")) {
        $projectRoot = (Resolve-Path (Join-Path $projectRoot "..")).Path
    }
}

Push-Location -Path $projectRoot

# 2. Verify Git Availability
where.exe git >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Pop-Location
    Write-Output "{}"
    exit
}

# 3. Auto-Initialize Git if missing (First-Boot Resilience)
if (-not (Test-Path ".git")) {
    git init -q *>&1 | Out-Null
    
    # Configure fallback user identity if none exists globally
    $currentName = git config user.name 2>$null
    if ([string]::IsNullOrWhiteSpace($currentName)) {
        git config user.name "AI Auto-Snapshot"
        git config user.email "local@node-pocket.internal"
    }
    
    # Initial Baseline Commit
    git add -A *>&1 | Out-Null
    git commit -m "init: baseline repository initialized by node-pocket" -q *>&1 | Out-Null
    Pop-Location
    Write-Output "{}"
    exit
}

# 4. Check for unstaged or untracked changes
$status = git status --porcelain 2>$null
if ([string]::IsNullOrWhiteSpace($status)) {
    # Working tree clean - no snapshot needed
    Pop-Location
    Write-Output "{}"
    exit
}

# 5. Extract topic/message from transcript (if accessible)
$commitMsg = ""
$brainDir = "$env:USERPROFILE\.gemini\antigravity\brain"

if (Test-Path $brainDir) {
    $candidateDirs = Get-ChildItem -Path $brainDir -Directory | Where-Object { $_.Name -ne "tempmediaStorage" } | Sort-Object LastWriteTime -Descending | Select-Object -First 3
    foreach ($d in $candidateDirs) {
        $tf = Join-Path $d.FullName ".system_generated\logs\transcript_full.jsonl"
        $tc = Join-Path $d.FullName ".system_generated\logs\transcript.jsonl"
        $targetLog = if (Test-Path $tf) { $tf } elseif (Test-Path $tc) { $tc } else { $null }

        if ($targetLog) {
            try {
                $fs = New-Object System.IO.FileStream($targetLog, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                $reader = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
                $lines = New-Object System.Collections.Generic.List[string]
                while (-not $reader.EndOfStream) {
                    $l = $reader.ReadLine()
                    if (-not [string]::IsNullOrWhiteSpace($l)) { $lines.Add($l) }
                }
                $reader.Close()
                $fs.Close()

                for ($i = $lines.Count - 1; $i -ge 0; $i--) {
                    $obj = $lines[$i] | ConvertFrom-Json
                    if ($obj.type -eq "USER_INPUT" -and $null -ne $obj.content -and $obj.content -ne "") {
                        $raw = $obj.content -replace '\s+', ' '
                        $words = $raw.Split(' ')
                        if ($words.Length -gt 10) { $raw = ($words[0..9] -join ' ') + "..." }
                        if ($raw.Length -gt 60) { $raw = $raw.Substring(0, 57) + "..." }
                        $commitMsg = ($raw -replace '"', '\"' -replace "'", "")
                        break
                    }
                }
            } catch {}
            if ($commitMsg -ne "") { break }
        }
    }
}

if ($commitMsg -eq "") {
    $nowStr = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $commitMsg = "snapshot: auto-save at $nowStr"
} else {
    $commitMsg = "snapshot: $commitMsg"
}

# 6. Zero-Leak Security Gate (Prevent secret leaks)
$leakFound = $false
$pendingFiles = git status --porcelain 2>$null
if ($pendingFiles) {
    foreach ($p in $pendingFiles) {
        if ($p -match "\.env$" -or $p -match "\.env\." -or $p -match "id_rsa|id_ed25519") {
            if ($p -notmatch "\.example") {
                $leakFound = $true
                break
            }
        }
    }
}

if ($leakFound) {
    Pop-Location
    Write-Output "{}"
    exit
}

# 7. Execute atomic local micro-commit
git add -A *>&1 | Out-Null
git commit -m "$commitMsg" -q *>&1 | Out-Null

Pop-Location

# 7. Output empty JSON to satisfy Antigravity Hook Contract
Write-Output "{}"
