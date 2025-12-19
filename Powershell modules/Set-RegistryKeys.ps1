# Disable FastBoot
Write-host "Disabling Fastboot." -ForegroundColor Green
New-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -PropertyType DWord -Value 0 -Force | Out-null


# Schakelt de privacy vragen uit
Write-host "Disabling privacy questions." -ForegroundColor Green
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1 -Type DWord | Out-null


# Schakelt de OOBE screen uit
Write-host "Disabling OOBE screen for future users." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisableOOBE" -Value 1 -Type DWord | Out-null


# Schakelt Smart App Control uit - Problemen met bepaalde software installaties
Write-Host "Disabling Smart App Control." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy" -Name "VerifiedAndReputablePolicyState" -Value 0 | Out-null