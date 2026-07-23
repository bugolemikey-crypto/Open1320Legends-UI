@echo off
setlocal
cd /d "%~dp0"
python export_targets.py %*
if errorlevel 1 pause
