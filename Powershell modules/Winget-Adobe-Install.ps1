# Write-Host "Installing Adobe Acrobat Reader DC" -ForegroundColor Green

# # Install Adobe Acrobat Reader DC using Chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force;
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
# Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# choco install adobereader -y --force --ignore-checksums
# Start-Sleep -Seconds 10

# Add-Type -AssemblyName System.Windows.Forms
# Start-Sleep 1
# [System.Windows.Forms.SendKeys]::SendWait(' ')





Write-Host "Installing Adobe Acrobat Reader DC via Chocolatey..." -ForegroundColor Green

# Install Chocolatey
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} catch {
    Write-Host "Failed to install Chocolatey. Continuing anyway..." -ForegroundColor Yellow
}

# Try to install Adobe Acrobat Reader using Chocolatey
$chocoInstallSuccess = $false
try {
    choco install adobereader -y --force --ignore-checksums
    Start-Sleep -Seconds 15

    Add-Type -AssemblyName System.Windows.Forms
    Start-Sleep 1
    [System.Windows.Forms.SendKeys]::SendWait(' ')

    # Check if installed
    $installed = Get-Command "AcroRd32.exe" -ErrorAction SilentlyContinue
    if ($installed) {
        $chocoInstallSuccess = $true
    }
} catch {
    Write-Host "Chocolatey installation failed." -ForegroundColor Red
}

# If Chocolatey failed, fallback to Winget
if (-not $chocoInstallSuccess) {
    Write-Host "Falling back to Winget method..." -ForegroundColor Yellow

    Write-Host "Installing Adobe Acrobat Reader DC via Winget..." -ForegroundColor Green
    winget install --id "XPDP273C0XHQH2" --accept-source-agreements --accept-package-agreements --source "msstore"

    $CheckForAdobe = winget list | Select-String "XPDP273C0XHQH2"
    if ($null -eq $CheckForAdobe) {
        Write-Host "Adobe Acrobat Reader DC has not been installed correctly, retrying..." -ForegroundColor Red
        winget settings --enable BypassCertificatePinningForMicrosoftStore
        winget install --id "XPDP273C0XHQH2" --accept-source-agreements --accept-package-agreements --source "msstore"
        winget settings --disable BypassCertificatePinningForMicrosoftStore
    }
}

# Optional: Press Space if a pop-up appears
Start-Sleep 1
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait(' ')


