@echo off
chcp 65001 >nul
title Elitzur Games - Mod Installer
cls
echo.
echo  Elitzur Games - Mod Installer
echo  ================================
echo.
echo  מתחיל התקנה אוטומטית...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process Bypass -Force; irm https://elitzurms-art.github.io/elitzur-mods-install/install.ps1 | iex"
echo.
echo  לחץ Enter כדי לסגור.
pause >nul
