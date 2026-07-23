@echo off
setlocal
cd /d "%~dp0"
python extract_main.py %*
if errorlevel 1 pause
