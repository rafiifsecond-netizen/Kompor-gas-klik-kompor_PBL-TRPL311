@echo off
title KlikKompor Flutter Web (Main Chrome)
cd /d "%~dp0"

echo ========================================================
echo Menjalankan Flutter Web Server (Port 3000)...
echo ========================================================
start "" C:\flutter\bin\flutter.bat run -d web-server --web-port=3000

echo Menunggu server siap (3 detik)...
timeout /t 3 /nobreak > nul

echo Membuka Google Chrome Utama...
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" "http://localhost:3000"

echo ========================================================
echo Selesai! Aplikasi terbuka di browser Chrome utama Anda.
echo ========================================================
pause
