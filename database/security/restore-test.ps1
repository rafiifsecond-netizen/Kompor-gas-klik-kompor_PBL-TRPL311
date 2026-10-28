param(
    [Parameter(Mandatory = $true)]
    [string]$BackupFile,
    [string]$MysqlBin = 'D:\laragon\bin\mysql\mysql-8.0.41-winx64\bin',
    [string]$HostName = '127.0.0.1',
    [string]$Port = '3306',
    [string]$RestoreDatabase = 'klikkompor_restore_test'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $BackupFile)) {
    throw "File backup tidak ditemukan: $BackupFile"
}

$mysql = Join-Path $MysqlBin 'mysql.exe'
$username = Read-Host 'Akun MySQL administrator untuk restore test'
$secure = Read-Host 'Password administrator' -AsSecureString
$password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
)
$optionFile = Join-Path $env:TEMP ("klikkompor-restore-{0}.cnf" -f ([guid]::NewGuid().ToString('N')))

Set-Content $optionFile -Encoding ASCII -Value @(
    '[client]'
    ('host=' + $HostName)
    ('port=' + $Port)
    ('user=' + $username)
    ('password=' + $password)
)

try {
    & $mysql "--defaults-extra-file=$optionFile" -e `
        "CREATE DATABASE IF NOT EXISTS ``$RestoreDatabase`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    if ($LASTEXITCODE -ne 0) { throw 'Tidak dapat membuat database restore terpisah.' }

    Get-Content -Raw $BackupFile | & $mysql "--defaults-extra-file=$optionFile" $RestoreDatabase
    if ($LASTEXITCODE -ne 0) { throw 'Restore gagal.' }

    $tableCount = & $mysql "--defaults-extra-file=$optionFile" --batch --skip-column-names `
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$RestoreDatabase';"
    $userCount = & $mysql "--defaults-extra-file=$optionFile" --batch --skip-column-names `
        -e "SELECT COUNT(*) FROM ``$RestoreDatabase``.users;"
    Write-Output "Restore selesai. tables=$tableCount users=$userCount database=$RestoreDatabase"
}
finally {
    Remove-Item -LiteralPath $optionFile -Force -ErrorAction SilentlyContinue
}
