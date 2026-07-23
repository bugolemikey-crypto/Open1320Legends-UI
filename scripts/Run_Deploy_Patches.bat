@echo off
setlocal
cd /d "%~dp0"
python deploy_patches.py %*
if errorlevel 1 pause
