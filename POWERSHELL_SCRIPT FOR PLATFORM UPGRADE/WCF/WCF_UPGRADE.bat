@echo off
Powershell.exe -ExecutionPolicy Bypass -File "%~dp0WCF_UPGRADE.ps1" -Verb RunAs

pause
