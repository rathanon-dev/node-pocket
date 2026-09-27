---
name: system-doctor
description: >-
  Diagnose host machine for required tools (Node.js, Deno, Git, Playwright).
  Auto-install missing dependencies or guide the user through installation.
---

# System Doctor Skill

## When to Activate
- On first conversation in this workspace
- When user reports "something doesn't work" or build failures
- Before scaffolding a new web project

## Diagnostic Steps

### 1. Check Node.js
```powershell
node -v
```
- Required: >= 18.0.0
- If missing: `winget install OpenJS.NodeJS.LTS`

### 2. Check Deno
```powershell
deno --version
```
- Required: >= 1.40
- If missing: `winget install DenoLand.Deno`

### 3. Check Git
```powershell
git --version
```
- If missing: `winget install Git.Git`

### 4. Check Playwright Browsers
```powershell
npx playwright install --dry-run
```
- If browsers not installed: `npx playwright install chromium firefox webkit`

## Report Format
After diagnosis, report in this format:
```
🩺 System Doctor Report
━━━━━━━━━━━━━━━━━━━━━━
✅ Node.js: v24.18.1
✅ Deno: 1.45.0
✅ Git: 2.46.0
⚠️  Playwright Browsers: Chromium only (Firefox/WebKit missing)
━━━━━━━━━━━━━━━━━━━━━━
Action: Run `npx playwright install firefox webkit`
```
