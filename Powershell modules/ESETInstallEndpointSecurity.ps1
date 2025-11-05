# Variables
$downloadUrl = "https://download.eset.com/com/eset/apps/business/ees/windows/latest/ees_nt64.msi"  # Update this URL if needed
$downloadPath = "C:\Temp\Preconfig\ESET_Endpoint_Security.msi"
$logPath = "C:\Temp\Preconfig\eset_install.log"

# Ensure the directory exists
if (-Not (Test-Path "C:\Temp\Preconfig")) {
    New-Item -Path "C:\Temp\Preconfig" -ItemType Directory | Out-Null
}

# Download the installer
Write-Host "Downloading ESET Endpoint Security MSI..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Check if the file downloaded successfully
if (-Not (Test-Path $downloadPath)) {
    Write-Host "ERROR: Failed to download the installer." -ForegroundColor Red
    exit 1
}

Write-Host "Starting ESET Endpoint Security installer silent..." -ForegroundColor Cyan	

# Install silently and write log
$arguments = "/i `"$downloadPath`" /qn /norestart /log `"$logPath`""
Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow

# Wait briefly
Start-Sleep -Seconds 20

# Verify installation
$esetInstallDir = "C:\Program Files\ESET\ESET Security"
if (Test-Path $esetInstallDir) {
    Write-Host "ESET Endpoint Security installed successfully." -ForegroundColor Green
} else {
    Write-Host "Installation completed, but ESET install folder not found. Check log at $logPath" -ForegroundColor Red
}

