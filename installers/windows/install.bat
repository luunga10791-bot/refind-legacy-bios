@echo off
setlocal
set "SCRIPT=%~dp0install.ps1"
if not exist "%SCRIPT%" (
  echo ERROR: install.ps1 is missing beside this launcher.
  exit /b 2
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %*
exit /b %errorlevel%
