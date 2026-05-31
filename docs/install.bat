@echo off
title Elitzur Games Installer
cls
echo.
echo  Elitzur Games - Mod Installer
echo  =============================
echo.
echo  Starting auto-install...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Set-ExecutionPolicy -Scope Process Bypass -Force; iex (irm https://elitzurms-art.github.io/elitzur-mods-install/install.ps1)}"
echo.
echo  Press any key to close.
pause >nul
