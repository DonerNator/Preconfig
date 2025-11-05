# Read configuration
$configPath = "C:\Temp\Preconfig\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file not found: $configPath"
    exit
}
$config = Get-Content $configPath | ConvertFrom-Json

# Variables
$downloadUrl = $config.sentinelOne.downloadUrl
$siteKey = $config.sentinelOne.siteKey
$downloadPath = "C:\Temp\Preconfig\Files\SentinelOne.exe"
$logPath = "C:\Temp\Preconfig\Files\SentinelOne_install.log"

# Ensure the directory exists
if (-Not (Test-Path "C:\Temp\Preconfig\Files")) {
    New-Item -Path "C:\Temp\Preconfig\Files" -ItemType Directory | Out-Null
}

# Download the installer
Write-Host "Downloading SentinelOne EXE..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Check if the file downloaded successfully
if (-Not (Test-Path $downloadPath)) {
    Write-Host "ERROR: Failed to download the installer." -ForegroundColor Red
    exit 1
}

Write-Host "Starting SentinelOne installer silent..." -ForegroundColor Cyan	

# Install silently and write log
Start-Process -FilePath $downloadPath -ArgumentList "-t $siteKey -q" -Wait

# Wait briefly
Start-Sleep -Seconds 20

# Verify installation
$SentineOneInstallDir = "C:\Program Files\SentinelOne"
if (Test-Path $SentineOneInstallDir) {
    Write-Host "SentinelOne installed successfully." -ForegroundColor Green
} else {
    Write-Host "Installation completed, but SentinelOne install folder not found. Check log at $logPath" -ForegroundColor Red
}

