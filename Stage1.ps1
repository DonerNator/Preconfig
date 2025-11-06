# === STAGE 1 Keuze menu en Bypass OOBE===
Write-Host "=== Stage [1/3]: Copy Temp files + Keuze Menu + Bypass OOBE + Creating User  === " -ForegroundColor Green

# Define temp folder
$tempPath = "C:\Temp\Preconfig"

# Get the path of the current script to determine the source directory

Write-Host "Loading preconfig script..." -ForegroundColor Green

# Create temp directory if it doesn't exist
if (-not (Test-Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath | Out-Null
}



# ======================================= Begin Keuze Menu =======================================

# --- Step 1: Define the Configuration File Path ---
# Set the path for the configuration file. It will be created in the same directory as the script.
$configFilePath = Join-Path -Path $tempPath -ChildPath "config.txt"



# --- Step 2: Get User Input ---


# Get the PC name from the user.
$pcName = Read-Host "Please enter the desired PC name"


# Get service.percom password with encryption
$encryptionPassword = "KaasPlank"
$keyString = $encryptionPassword.PadRight(32, 'X').Substring(0,32)
$key = [System.Text.Encoding]::UTF8.GetBytes($keyString)
do {
    $servicePassword1 = Read-Host "Enter the password you want to save" -AsSecureString
    $servicePassword2 = Read-Host "Confirm the password" -AsSecureString

    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($servicePassword1))
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($servicePassword2))

    if ($plain1 -ne $plain2) {
        Write-Host "Passwords do not match. Please try again." -ForegroundColor Red
        $retry = $true
    } else {
        $retry = $false
    }
} while ($retry)
$encrypted = $servicePassword1 | ConvertFrom-SecureString -Key $key



# Ask the user for the AV choice with a default value of 1.
do {
    $avChoice = Read-Host "Please choose which AV to install (1=ESET (Default), 2=SentinelOne, 3=No AV)"
    if ([string]::IsNullOrWhiteSpace($avChoice)) {
        $avChoice = "1"
    }

    # Validate the user's input to ensure it's a valid choice (1, 2, or 3).
    if ($avChoice -match "^[1-3]$") {
        $validChoice = $true
    } else {
        Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Red
        $validChoice = $false
    }
} while (-not $validChoice)


# Get if they want to install office
$installOffice = Read-Host "Do you want to install Office?(Ictivate=Y)(Y/n)"
if ([string]::IsNullOrWhiteSpace($installOffice) -or $installOffice.ToUpper() -eq "Y") {
    $installOffice = $true
} else {
    $installOffice = $false
}

# Get if they want to apply regedit
$applyRegedit = Read-Host "Do you want to apply Password regedit for Cloud RDP (Ictivate=Y)(Y/n)"
if ([string]::IsNullOrWhiteSpace($applyRegedit) -or $applyRegedit.ToUpper() -eq "Y") {
    $applyRegedit = $true
} else {
    $applyRegedit = $false
}



# Are you sure to save configuration
do {
    $saveConfig = Read-Host "`nAre you sure you want to save this configuration and continue? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($saveConfig) -or $saveConfig.ToUpper() -eq "Y") {
        $saveConfig = $true
        $validInput = $true
    } elseif ($saveConfig.ToUpper() -eq "N") {
        Write-Host "Exiting without saving configuration." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "Invalid input. Please enter Y or N." -ForegroundColor Red
        $validInput = $false
    }
} while (-not $validInput)












# --- Step 3: Save User Choices to a Text File ---

Write-Host "`nSaving your choices to '$configFilePath'..." -ForegroundColor Yellow

# Create the content to be saved, with one key-value pair per line.
# To add more options, simply add another line here, e.g., "New_Option=$newOption"
$configContent = @(
    "PC_Name=$pcName",
    "Password=$encrypted",
    "AV_Choice=$avChoice",
    "Install_Office=$installOffice",
    "Apply_Regedit=$applyRegedit"
)

# Use Set-Content to write the content to the file. This will overwrite the file if it exists.
$configContent | Set-Content -Path $configFilePath

Write-Host "Choices saved successfully!" -ForegroundColor Green




# ======================================= Einde Keuze Menu =======================================











# Create local admin user
Write-Host "Creating admin user 'Service.percom'..." -ForegroundColor Green
$user = "Service.percom"
$password = ConvertTo-SecureString "1234" -AsPlainText -Force

# Create user and add to Administrators group
New-LocalUser -Name $user -Password $password -AccountNeverExpires -FullName "Service.percom" | Out-Null
Add-LocalGroupMember -Group "Administrators" -Member $user | Out-Null

# Hide DefaultUser0 from login screen
Write-Host "Hiding DefaultUser0 from login screen..." -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name "DefaultUser0" -Value 0 -Type DWord

# Disable OOBE privacy experience
Write-Host "Disabling OOBE privacy experience..." -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1 -Type DWord


# Set password to blank after user creation for Automation of script in Stage 2
Set-LocalUser -Name $user -Password ([securestring]::new()) | Out-Null


# Register stage2.ps1 to run at next logon of Service.percom with admin rights
$stage2Path = Join-Path $tempPath "Stage2.ps1"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$stage2Path`""
$trigger = New-ScheduledTaskTrigger -AtLogOn

# Define principal to run with highest privileges when user is logged in
$principal = New-ScheduledTaskPrincipal -UserId "Service.percom" -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName "Run_Stage2" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null



# Final reboot to apply changes
Write-Host "Rebooting system to apply changes..." -ForegroundColor Cyan
Start-Sleep -Seconds 5
C:\Windows\System32\oobe\msoobe.exe
shutdown.exe -r