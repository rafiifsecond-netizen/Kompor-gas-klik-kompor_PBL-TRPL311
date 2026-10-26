# KlikKompor Flutter Web Launcher (Main Chrome)
Set-Location $PSScriptRoot
Write-Host "Menjalankan Flutter Web Server pada port 3000..." -ForegroundColor Green
Start-Process "C:\flutter\bin\flutter.bat" -ArgumentList "run","-d","web-server","--web-port=3000"
Start-Sleep -Seconds 3
Write-Host "Membuka Google Chrome Utama..." -ForegroundColor Cyan
& "C:\Program Files\Google\Chrome\Application\chrome.exe" "http://localhost:3000"
