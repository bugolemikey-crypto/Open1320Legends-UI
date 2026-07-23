@echo off
cd /d "%~dp0.."
python scripts\import_patches.py --target main_client
pause
