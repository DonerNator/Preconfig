Write-Host "Setting UAC to level 2." -ForegroundColor Green
function Set-UACLevel {
    param (
        [int]$level,
        [bool]$promptOnSecureDesktop
    )

    $regKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    $regValueName_UAC = "ConsentPromptBehaviorAdmin"
    $regValueName_PromptOnSecureDesktop = "PromptOnSecureDesktop"

    # Check if registry key exists, if not create it
    if (-not (Test-Path $regKeyPath)) {
        New-Item -Path $regKeyPath -Force | Out-Null
    }

    # Set UAC level
    Set-ItemProperty -Path $regKeyPath -Name $regValueName_UAC -Value $level | Out-null

    # Set PromptOnSecureDesktop
    Set-ItemProperty -Path $regKeyPath -Name $regValueName_PromptOnSecureDesktop -Value $promptOnSecureDesktop | Out-null
}

#Set UAC to level 5.
Set-UACLevel -Level 5 -PromptOnSecureDesktop $false;


# Usage example for the UAC levels:
# Set-UACLevel -Level 0 -PromptOnSecureDesktop $false # this is Uac off. so level 1
# Set-UACLevel -Level 5 -PromptOnSecureDesktop $false # This is the same as Default, but doenst dim the desktop. level 2
# Set-UACLevel -Level 5 -PromptOnSecureDesktop $true # This is the Default setting. so level 3
# Set-UACLevel -Level 2 -PromptOnSecureDesktop $true # this is the highest setting, level 4
