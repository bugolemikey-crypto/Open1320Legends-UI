@echo off
title SWF Editor - Open1320Legends
echo ============================================
echo   SWF Editor - Open1320Legends
echo   Wraps all FFDec capabilities in browser
echo ============================================
echo.
echo Starting server on http://127.0.0.1:8322
echo.
python "%~dp0swf_editor_server.py" --port 8322
pause
