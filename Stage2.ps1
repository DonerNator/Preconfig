#HIER MOET EEN START VAN 3 MINUTEN KOMEN VOOR DE USER SETUP
Start-Sleep -Seconds 120
Write-Host "=== Stage [2/3]: Configuration + Set password and hostname + Adobe install + HP Wolf removal === " -ForegroundColor Green

# Register Stage3.ps1 to run at next logon
$stage3Path = "C:\Temp\Preconfig\Stage3.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$stage3Path`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "Run_Stage3" -Action $action -Trigger $trigger -RunLevel Highest -Force

# Clean up this task
Unregister-ScheduledTask -TaskName "Run_Stage2" -Confirm:$false

# === STAGE 2 ===



Import-Module "C:\Temp\Preconfig\Powershell modules\Exit-Start-Menu.ps1"

Import-Module "C:\Temp\Preconfig\Powershell modules\Set-Correct-Time.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Set-DutchSettings.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Set-UAC.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Set-RegistryKeys.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\CtrlAltDelFix-V2.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Set-PowerCFG.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Remove-DefaultUser0.ps1"
Import-Module "C:\Temp\Preconfig\Powershell modules\Winget-Adobe-Install.ps1"

Start-Sleep -Seconds 5


Import-module "C:\Temp\Preconfig\Powershell modules\Set-Service.percom-To-Hidden.ps1"
Start-Process powershell.exe -Verb RunAs -ArgumentList "-WindowStyle Hidden", "-ExecutionPolicy Bypass", "-File `"C:\Temp\Preconfig\Powershell modules\Set-Hostname-And-Password-Service.percom.ps1`""; Start-Sleep 10;



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