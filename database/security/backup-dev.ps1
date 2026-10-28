param(
    [string]$MysqlBin = 'D:\laragon\bin\mysql\mysql-8.0.41-winx64\bin',
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
)

$ErrorActionPreference = 'Stop'
$envPath = Join-Path $ProjectRoot '.env'
if (-not (Test-Path $envPath)) {
    throw '.env tidak ditemukan; buat konfigurasi development terlebih dahulu.'
}

$config = @{}
foreach ($line in Get-Content $envPath) {
    if ($line -match '^([A-Z0-9_]+)=(.*)$') {
        $config[$matches[1]] = $matches[2]
    }
}

$hostName = if ($config['DB_HOST']) { $config['DB_HOST'] } else { '127.0.0.1' }
$port = if ($config['DB_PORT']) { $config['DB_PORT'] } else { '3306' }
$database = $config['DB_DATABASE']
$username = $config['DB_USERNAME']
$password = $config['DB_PASSWORD']
if ([string]::IsNullOrWhiteSpace($database) -or [string]::IsNullOrWhiteSpace($username)) {
    throw 'DB_DATABASE dan DB_USERNAME wajib tersedia di .env.'
}

if ([string]::IsNullOrWhiteSpace($password)) {
    $secure = Read-Host 'Password database development' -AsSecureString
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    )
}

$dump = Join-Path $MysqlBin 'mysqldump.exe'
if (-not (Test-Path $dump)) {
    throw "mysqldump tidak ditemukan: $dump"
}

$backupDir = Join-Path $ProjectRoot 'storage\app\backups'
New-Item -ItemType Directory -Force $backupDir | Out-Null
$backup = Join-Path $backupDir ("{0}_{1}.sql" -f $database, (Get-Date -Format 'yyyyMMdd_HHmmss'))
$optionFile = Join-Path $env:TEMP ("klikkompor-backup-{0}.cnf" -f ([guid]::NewGuid().ToString('N')))

Set-Content $optionFile -Encoding ASCII -Value @(
    '[client]'
    ('host=' + $hostName)
    ('port=' + $port)
    ('user=' + $username)
    ('password=' + $password)
)

try {
    & $dump "--defaults-extra-file=$optionFile" --single-transaction --no-tablespaces `
        --routines --triggers --events --hex-blob --set-gtid-purged=OFF `
        "--result-file=$backup" $database
    if ($LASTEXITCODE -ne 0) {
        throw 'Backup gagal.'
    }
    Write-Output "Backup dibuat: $backup"
}
finally {
    Remove-Item -LiteralPath $optionFile -Force -ErrorAction SilentlyContinue
}
