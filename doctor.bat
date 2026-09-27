@echo off
chcp 65001 >nul
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%~dp0.agent\scripts\check_tools.ps1"
pause
