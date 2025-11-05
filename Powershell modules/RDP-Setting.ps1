# Schakelt password saving uit.
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$propertyName = "DisablePasswordSaving"
$propertyValue = 1

New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name $propertyName -Value $propertyValue

Write-Host "RDP settings applied successfully." -ForegroundColor Green

