@echo off
:: Run as administrator
powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0zoom-windows-setup.ps1\"' -Verb RunAs"
