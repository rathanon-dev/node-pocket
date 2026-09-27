# ==============================================================================
# Node-Pocket: System Doctor & Toolchain Diagnostics (PowerShell 5.1 Compatible)
# ==============================================================================
param(
    [switch]$NonInteractive
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  NODE-POCKET SYSTEM DOCTOR (v2.0)" -ForegroundColor Cyan
Write-Host "  Sovereign Toolchain & Agent Health Diagnostics" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

$passCount = 0
$failCount = 0

# ------------------------------------------------------------------------------
# 1. Check Git (Host OS Level)
# ------------------------------------------------------------------------------
Write-Host "[1/5] Checking Git for Windows..." -ForegroundColor White
$gitCmd = Get-Command "git.exe" -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVer = (& git --version) 2>$null
    Write-Host "  [OK] Git: $gitVer" -ForegroundColor Green
    $passCount++

    $gitDir = Join-Path $projectRoot ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Host "     Initializing local Git repository..." -ForegroundColor Yellow
        Push-Location $projectRoot
        git init -q
        git config user.name "AI Auto-Snapshot"
        git config user.email "local@node-pocket.internal"
        git add -A
        git commit -m "init: baseline repository initialized by doctor" -q
        Pop-Location
        Write-Host "     [OK] Local Git repository initialized!" -ForegroundColor Green
    } else {
        Write-Host "     [OK] Git Repository: Active (.git present)" -ForegroundColor Green
    }
} else {
    Write-Host "  [FAIL] Git: NOT FOUND" -ForegroundColor Red
    Write-Host "     Install via: winget install Git.Git" -ForegroundColor Gray
    Write-Host "     Or download: https://git-scm.com" -ForegroundColor Gray
    $failCount++
}

Write-Host ""

# ------------------------------------------------------------------------------
# 2. Check GitHub MCP Server (Global Host Tool Level)
# ------------------------------------------------------------------------------
Write-Host "[2/5] Checking GitHub MCP Server (.exe)..." -ForegroundColor White
$targetGlobalPath = "C:\tools\github-mcp-server\github-mcp-server.exe"

$mcpPath = $null
$envPath = [Environment]::GetEnvironmentVariable("GITHUB_MCP_SERVER_PATH", "User")
if ($envPath -and (Test-Path $envPath)) {
    $mcpPath = $envPath
} elseif (Test-Path $targetGlobalPath) {
    $mcpPath = $targetGlobalPath
} elseif (Test-Path "C:\dev\github-mcp-server\github-mcp-server.exe") {
    $mcpPath = "C:\dev\github-mcp-server\github-mcp-server.exe"
} else {
    $foundCmd = Get-Command "github-mcp-server.exe" -ErrorAction SilentlyContinue
    if ($foundCmd) { $mcpPath = $foundCmd.Source }
}

if ($mcpPath) {
    Write-Host "  [OK] GitHub MCP Server: Found at $mcpPath" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "  [WARN] GitHub MCP Server: NOT FOUND" -ForegroundColor Yellow
    Write-Host "     Target Destination: $targetGlobalPath" -ForegroundColor Gray
    Write-Host "     Purpose: Enables AI agents to create GitHub repos, sync code, and manage PRs." -ForegroundColor Gray
    
    if (-not $NonInteractive) {
        Write-Host ""
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  Select Installation Mode for GitHub MCP Server:" -ForegroundColor Yellow
        Write-Host "    [1] Auto-Install (Download official 8MB binary to C:\tools\github-mcp-server\)" -ForegroundColor White
        Write-Host "    [2] Manual Install Guide (View instructions)" -ForegroundColor White
        Write-Host "    [3] Skip for now (Local development only)" -ForegroundColor White
        Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
        $choice = Read-Host "  Enter choice [1, 2, or 3] (Default: 1)"
        if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

        if ($choice -eq "1") {
            try {
                Write-Host "  [*] Querying latest release from GitHub API..." -ForegroundColor Cyan
                $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/github/github-mcp-server/releases/latest" -UserAgent "NodePocket-Doctor" -TimeoutSec 15
                $asset = $rel.assets | Where-Object { $_.name -match "Windows_x86_64\.zip$" } | Select-Object -First 1
                
                $dlUrl = if ($asset) { $asset.browser_download_url } else { "https://github.com/github/github-mcp-server/releases/download/v1.12.2/github-mcp-server_Windows_x86_64.zip" }

                $toolsParent = "C:\tools\github-mcp-server"
                if (-not (Test-Path $toolsParent)) { New-Item -ItemType Directory -Path $toolsParent -Force | Out-Null }
                
                $tempZip = Join-Path $env:TEMP "github-mcp-server.zip"
                Write-Host "  [*] Downloading $dlUrl..." -ForegroundColor Cyan
                Invoke-WebRequest -Uri $dlUrl -OutFile $tempZip -UseBasicParsing

                Write-Host "  [*] Extracting to $toolsParent..." -ForegroundColor Cyan
                Expand-Archive -Path $tempZip -DestinationPath $toolsParent -Force
                Remove-Item $tempZip -Force -ErrorAction SilentlyContinue

                if (Test-Path $targetGlobalPath) {
                    [Environment]::SetEnvironmentVariable("GITHUB_MCP_SERVER_PATH", $targetGlobalPath, "User")
                    Write-Host "  [OK] Auto-installed successfully to $targetGlobalPath!" -ForegroundColor Green
                    Write-Host "  [OK] Environment Variable 'GITHUB_MCP_SERVER_PATH' registered." -ForegroundColor Green
                    $passCount++
                } else {
                    Write-Host "  [FAIL] Extraction completed, but binary not found at $targetGlobalPath" -ForegroundColor Red
                    $failCount++
                }
            } catch {
                Write-Host "  [FAIL] Auto-installation failed: $($_.Exception.Message)" -ForegroundColor Red
                $failCount++
            }
        } elseif ($choice -eq "2") {
            Write-Host ""
            Write-Host "  Manual Installation Instructions:" -ForegroundColor Cyan
            Write-Host "  1. Download: https://github.com/github/github-mcp-server/releases/latest" -ForegroundColor White
            Write-Host "     (Choose github-mcp-server_Windows_x86_64.zip)" -ForegroundColor Gray
            Write-Host "  2. Create folder: C:\tools\github-mcp-server\" -ForegroundColor White
            Write-Host "  3. Extract 'github-mcp-server.exe' into that folder." -ForegroundColor White
            Write-Host "  4. Set User Environment Variable: GITHUB_MCP_SERVER_PATH = C:\tools\github-mcp-server\github-mcp-server.exe" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "  Skipped GitHub MCP Server." -ForegroundColor Gray
        }
    }
}

Write-Host ""

# ------------------------------------------------------------------------------
# 3. Check Agent Credentials (.agent/.env)
# ------------------------------------------------------------------------------
Write-Host "[3/5] Checking AI Agent Credentials..." -ForegroundColor White
$agentEnv = Join-Path $projectRoot ".agent\.env"
$agentExample = Join-Path $projectRoot ".agent\env.example"

if (Test-Path $agentEnv) {
    Write-Host "  [OK] Agent Credentials: .agent\.env is active" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "  [WARN] Agent Credentials: .agent\.env NOT found" -ForegroundColor Yellow
    Write-Host "     To connect AI to GitHub: Copy '.agent\env.example' to '.agent\.env'" -ForegroundColor Gray
    Write-Host "     and paste your Fine-Grained Personal Access Token (PAT)." -ForegroundColor Gray
}

Write-Host ""

# ------------------------------------------------------------------------------
# 4. Check Node.js (Web Application Runtime)
# ------------------------------------------------------------------------------
Write-Host "[4/5] Checking Node.js Runtime..." -ForegroundColor White
$nodeCmd = Get-Command "node.exe" -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = (& node -v) 2>$null
    Write-Host "  [OK] Node.js: $nodeVer" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "  [FAIL] Node.js: NOT FOUND" -ForegroundColor Red
    Write-Host "     Install via: winget install OpenJS.NodeJS.LTS" -ForegroundColor Gray
    Write-Host "     Or download: https://nodejs.org" -ForegroundColor Gray
    $failCount++
}

Write-Host ""

# ------------------------------------------------------------------------------
# 5. Check Deno (Isolated Test Harness)
# ------------------------------------------------------------------------------
Write-Host "[5/5] Checking Deno Test Engine..." -ForegroundColor White
$denoCmd = Get-Command "deno.exe" -ErrorAction SilentlyContinue
if ($denoCmd) {
    $denoVer = (& deno --version | Select-Object -First 1) 2>$null
    Write-Host "  [OK] Deno: $denoVer" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "  [FAIL] Deno: NOT FOUND" -ForegroundColor Red
    Write-Host "     Install via: winget install DenoLand.Deno" -ForegroundColor Gray
    Write-Host "     Or download: https://deno.land/#installation" -ForegroundColor Gray
    $failCount++
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  Diagnostic Summary: $passCount passed, $failCount failed" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
