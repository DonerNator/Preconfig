Write-Host "Checking if ESET Agent is installed" -ForegroundColor Green
winget install --id "XPDP273C0XHQH2" --accept-source-agreements --accept-package-agreements --source "msstore" | Out-null

$CheckForESETAgent = Winget list | Select-String "ËSET Management Agent"
if ($null -eq $CheckForESETAgent)
{
    Write-Host "ESET Agent has not been installed correctly, Retrying install" -ForegroundColor Red
    Import-Module "C:\Temp\Preconfig\Powershell modules\ESETCloudAgentScriptPS.ps1"
    
} else {
    Write-Host "ESET Agent is correctly installed" -ForegroundColor Green
}