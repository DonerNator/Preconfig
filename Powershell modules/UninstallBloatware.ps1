# Define variables
$downloadUrl = "https://aka.ms/SaRA_CommandLineVersionFiles"
$downloadPath = "$env:TEMP\SaRA.zip"
$extractPath = "$env:TEMP\SaRA"
$logFolder = "$env:TEMP\SaRA_Logs"
$OffScrubFolder = "$env:TEMP\OffScrubC2R"

# Create necessary directories
New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
New-Item -ItemType Directory -Path $logFolder -Force | Out-Null

# Download SaRAcmd zip file
Write-Host "Downloading SaRAcmd..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# Extract the zip file
Write-Host "Extracting SaRAcmd..." -ForegroundColor Cyan
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# Define the path to SaRAcmd.exe
$saraCmdPath = Join-Path -Path $extractPath -ChildPath "SaRAcmd.exe"

# Check if SaRAcmd.exe exists
if (Test-Path $saraCmdPath) {
    Write-Host "SaRAcmd.exe found. Proceeding with uninstallation..." -ForegroundColor Cyan

    # Terminate running Office applications
    $officeApps = @('winword', 'excel', 'outlook', 'powerpnt', 'onenote', 'teams')
    foreach ($app in $officeApps) {
        Get-Process -Name $app -ErrorAction SilentlyContinue | Stop-Process -Force
    }

    # Execute the uninstallation command
    & $saraCmdPath -S OfficeScrubScenario -AcceptEula -Officeversion All -LogFolder $logFolder

    Write-Host "Uninstallation process initiated. Logs are available at $logFolder" -ForegroundColor Green
} else {
    Write-Error "SaRAcmd.exe not found in the extracted files." -ForegroundColor Red
}

Write-Host "Uninstallation process completed." -ForegroundColor Green

# Clean up temporary files
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item -Path $downloadPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $OffScrubFolder -Recurse -Force -ErrorAction SilentlyContinue

# --- Uncomment als je de log folder wilt verwijderen ---
#Remove-Item -Path $logFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Temporary files cleaned up." -ForegroundColor Green




# -------- Functions for uninstalling applications, deze worden gebruikt in de uninstaller op het einde van het script  --------

function Get-UninstallString {
    param([string]$ProgramName)

    $paths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $paths) {
        $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -like "*$ProgramName*"
        }
        foreach ($app in $apps) {
            if ($app.UninstallString) {
                return $app.UninstallString
            }
        }
    }
    return $null
}

function Uninstall-Program {
    param([string]$ProgramName)
    Write-Verbose "Looking for $ProgramName..."

    $uninstallCmd = Get-UninstallString -ProgramName $ProgramName

    if ($null -eq $uninstallCmd) {
        Write-Warning "$ProgramName not found in registry."
        return
    }

    Write-Host "Uninstalling $ProgramName..."

    if ($uninstallCmd -match "msiexec") {
        $arguments = $uninstallCmd -replace 'msiexec.exe', ''
        if ($arguments -notmatch "/quiet") {
            $arguments += " /quiet /norestart"
        }
        Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -WindowStyle Hidden
    } else {
        # Wrap in quotes and ensure silent/unattended if supported
        if ($uninstallCmd -notmatch "/quiet") {
            $uninstallCmd += " /quiet /norestart"

        }

        Start-Process "cmd.exe" -ArgumentList "/c", $uninstallCmd -Wait -WindowStyle Hidden
    }
    Write-Host "$ProgramName uninstallation attempted silently - Success!." -ForegroundColor Green
}




# -------- Remove Bloatware from CSV --------

# The script assumes it is running from C:\Temp\Preconfig on the target machine.
$csvPath = "C:\Temp\Preconfig\Files\Bloatware.csv"


if (-not (Test-Path $csvPath)) {
    # If the script is running from the project root, the relative path would be:
    # $csvPath = Resolve-Path -Path "../Files/Bloatware.csv"
    # For now, we assume the fixed path.
    Write-Error "Bloatware.csv not found at $csvPath" 
    return
}

$bloatware = Import-Csv -Path $csvPath

foreach ($app in $bloatware) {
    $appName = $app.Name
    $appType = $app.Type
    Write-Host "Processing $appName ($appType)..." -ForegroundColor Cyan
    
    
    ### Remove Appx package ###
    if ($appType -eq "Appx") {

        $packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*$appName*" }
        foreach ($pkg in $packages) {
            Write-Host "Removing Appx package: $($pkg.Name)"
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
                Write-Host "Removed: $($pkg.Name)" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to remove Appx package $($pkg.Name): $_"
            }
        }

        # Remove provisioned package
        $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$appName*" }
        foreach ($prov in $provisioned) {
            Write-Host "Removing provisioned package: $($prov.DisplayName)"

            try {
                Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop
                Write-Host "Removed provisioned package: $($prov.DisplayName)" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to remove provisioned package $($prov.DisplayName): $_"
            }
        }
    }




    ### Remove Win32 Apps ###
    elseif ($appType -eq "Win32") {

        # First try quiet uninstallation
        try {
            Write-Host "Attempting quiet uninstallation of $appName..." -ForegroundColor Cyan
            $uninstallString = Get-UninstallString -ProgramName $appName
            if ($uninstallString -match "msiexec") {
                $arguments = ($uninstallString -replace 'msiexec.exe', '') + " /quiet /norestart"
                Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -WindowStyle Hidden
            } else {
                $arguments = $uninstallString + " /S /silent /quiet /norestart"
                Start-Process -FilePath $uninstallString -ArgumentList "/S /silent /quiet /norestart" -Wait -WindowStyle Hidden
            }
            Write-Host "$appName uninstalled silently" -ForegroundColor Green
        }
        catch {
            # Fall back to normal uninstallation
            Write-Warning "Quiet uninstallation failed for $appName. Attempting normal uninstallation..."
            Uninstall-Program -ProgramName $appName
        }
    }
    else {
        Write-Warning "Unknown app type '$appType' for '$appName'."
    }
}





# ---- Remove HP Connection Optimizer ----


Write-Host "Attempting to remove HP Connection Optimizer..." -ForegroundColor Yellow
$HPCOuninstall = "C:\Program Files (x86)\InstallShield Installation Information\{6468C4A5-E47E-405F-B675-A70A70983EA6}\setup.exe"

if (Test-Path $HPCOuninstall -PathType Leaf){
Try {
        & $HPCOuninstall -runfromtemp -l0x0413  -removeonly -s -f1C:\Temp\Preconfig\Files\uninstallHPCO.iss
        Start-Sleep -Seconds 20
        Write-Host "Successfully uninstalled HP Connection Optimizer" -ForegroundColor Green
        }
Catch {
        Write-Host -Value  "Error uninstalling HP Connection Optimizer: RETRYING DIFFERENT METHOD" -ForegroundColor Red
        function Uninstall-ByRegistryName {
            param (
                [string]$AppName
            )
            $uninstallKeys = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
        
            foreach ($keyPath in $uninstallKeys) {
                $apps = Get-ItemProperty $keyPath | Where-Object { $_.DisplayName -like "*$AppName*" }
                foreach ($app in $apps) {
                    Write-Host "Found: $($app.DisplayName)" -ForegroundColor Yellow
                    if ($app.UninstallString) {
                        # Ensure quiet uninstall by appending /quiet and /norestart if not already present
                        $uninstallCmd = $app.UninstallString
                        if ($uninstallCmd -notmatch "/quiet") { $uninstallCmd += " /quiet" }
                        if ($uninstallCmd -notmatch "/qn") { $uninstallCmd += " /qn" }
                        if ($uninstallCmd -notmatch "/norestart") { $uninstallCmd += " /norestart" }
        
                        Write-Host "Uninstalling via: $uninstallCmd" -ForegroundColor Cyan
                        try {
                            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$uninstallCmd" -Wait -NoNewWindow
                            Write-Host "Uninstalled $($app.DisplayName) Wacht een paar seconden." -ForegroundColor Green
                        } catch {
                            Write-Warning "Failed to uninstall $($app.DisplayName): $_"
                        }
                    }
                }
            }
        }

        # Uninstall HP Connection Optimizer using registry name
        Uninstall-ByRegistryName -AppName "HP Connection Optimizer"
        }
}
Else {
        Write-Host "HP Connection Optimizer not found" -ForegroundColor Yellow
}
# ---- End of HP Connection Optimizer Uninstall ----



Write-Host "Bloatware removal process completed." -ForegroundColor Green