@echo off
rem XR-Port-Kitchen – Doppelklick startet das Menü der Küchenhilfe.
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0kitchen.ps1" %*
echo.
pause
