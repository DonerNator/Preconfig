Write-host "Disabling Fastboot." -ForegroundColor Green
# Disable FastBoot
New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -PropertyType DWord -Value 0 -Force | Out-null

Write-host "Disabling privacy questions." -ForegroundColor Green
# Schakelt de privacy vragen uit
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1 -Type DWord | Out-null

Write-host "Disabling OOBE screen for future users." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisableOOBE" -Value 1 -Type DWord | Out-null


