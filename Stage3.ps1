# === Stage 3 ===
Start-Sleep -Seconds 15
 Write-Host "=== Stage [3/3]: Bloatware removal + AV Install + Other Settings + Cleanup and finalization === " -ForegroundColor Green

Import-Module "C:\Temp\Preconfig\Powershell modules\Uninstall-HP-Full-Cleanup-Script.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\UninstallBloatware.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\RemoveUnknowProfiles.ps1"




# Retrieve AV_Choice and Install_Office from config.txt
$configFilePath = "C:\Temp\Preconfig\config.txt"
$configLines = Get-Content $configFilePath | Where-Object { $_ -match '=' }
$data = @{}
foreach ($line in $configLines) {
    $parts = $line -split '=', 2
    if ($parts.Count -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        $data[$key] = $value
    }
}

# AV_Choice logic
if ($data.ContainsKey('AV_Choice')) {
    switch ($data['AV_Choice']) {
        '1' {
            Write-Host "AV_Choice 1: Installing ESET..." -ForegroundColor Yellow
            Import-Module "C:\Temp\Preconfig\Powershell modules\ESETCloudAgentScriptPS.ps1" # EM Agent installer
            Import-Module "C:\Temp\Preconfig\Powershell modules\ESETInstallEndpointSecurity.ps1" #ESET Endpoint Security installer
        }
        '2' {
            Write-Host "AV_Choice 2: Installing SentinelOne..." -ForegroundColor Yellow
            Import-Module "C:\Temp\Preconfig\Powershell modules\SentinelOne-Default-site-installer.ps1"
        }
        '3' {
            Write-Host "AV_Choice 3: No AV installation selected. Continuing..." -ForegroundColor Yellow
        }
        Default {
            Write-Host "Unknown AV_Choice value: $($data['AV_Choice']). Skipping AV installation." -ForegroundColor Red
        }
    }
} else {
    Write-Host "AV_Choice not found in config.txt. Skipping AV installation." -ForegroundColor Red
}



# Install_Office logic
if ($data.ContainsKey('Install_Office')) {
    if ($data['Install_Office'].ToLower() -eq 'true') {
        Write-Host "Install_Office True: Installing Office..." -ForegroundColor Yellow
        Import-Module "C:\Temp\Preconfig\Powershell modules\InstallOffice.ps1"
    } else {
        Write-Host "Install_Office=False: Skipping Office installation." -ForegroundColor Yellow
    }
} else {
    Write-Host "Install_Office not found in config.txt. Skipping Office installation." -ForegroundColor Red
}



# RDP Logic 
if ($data.ContainsKey('Apply_Regedit')) {
    if ($data['Apply_Regedit'].ToLower() -eq 'true') {
        Write-Host "Apply_Regedit True: Applying RDP settings..." -ForegroundColor Yellow
        Import-Module "C:\Temp\Preconfig\Powershell modules\RDP-Setting.ps1"
    } else {
        Write-Host "Apply_Regedit=False: Skipping RDP settings installation." -ForegroundColor Yellow
    }
} else {
    Write-Host "Apply_Regedit not found in config.txt. Skipping RDP settings installation." -ForegroundColor Red
}






# Windows Updates installer
Import-Module "C:\Temp\Preconfig\Powershell modules\Windows-Updates.ps1" 




# Press space to continue
Start-Sleep 10
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait(' ')


# Cleanup
Write-Host "Cleaning up temporary files and Scheduled task Stage 3... (Wacht 10 Seconden)" -ForegroundColor Cyan
start-sleep -Seconds 10
Unregister-ScheduledTask -TaskName "Run_Stage3" -Confirm:$false

# Check for ESET Installer location and if they exist, remove them
if ((Test-Path "C:\Temp\Preconfig\ESET_Endpoint_Security.msi") -or (Test-Path "C:\ESET-Management-Agent-Installer")) {
    if (Test-Path "C:\Temp\Preconfig\ESET_Endpoint_Security.msi") {
        Remove-Item "C:\Temp\Preconfig\ESET_Endpoint_Security.msi" -Recurse -Force
    }
    if (Test-Path "C:\ESET-Management-Agent-Installer") {
        Remove-Item "C:\ESET-Management-Agent-Installer" -Recurse -Force
    }
} else {
    Write-Host "ESET not found. Continuing..." -ForegroundColor Yellow
}

Remove-Item "C:\Temp\Preconfig" -Recurse -Force
start-sleep -Seconds 10
Write-Host "Cleaning up successful!" -ForegroundColor Green






# Ask to restart computer to apply changes
do {
    $restartNow = Read-Host "Do you want to restart the computer now? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($restartNow) -or $restartNow.ToUpper() -eq "Y") {
        Restart-Computer -Force
        break
    } elseif ($restartNow.ToUpper() -eq "N") {
        Write-Host "Restart cancelled. Please restart manually to apply changes." -ForegroundColor Yellow
        break
    } else {
        Write-Host "Invalid input. Please enter 'Y' or 'n'." -ForegroundColor Red
    }
} while ($true)