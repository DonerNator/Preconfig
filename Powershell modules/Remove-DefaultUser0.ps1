Write-Host "Removing DefaultUser0" -ForegroundColor Green
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
# Remove DefaultUserName and DefaultDomainName to stop pre-filling
Remove-ItemProperty -Path $regPath -Name "DefaultUserName" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regPath -Name "DefaultDomainName" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -ErrorAction SilentlyContinue
# Disable AutoAdminLogon
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "0"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /t REG_DWORD /f /d 0 /v DefaultUser0 | Out-Null
net user DefaultUser0 /delete | Out-Null

