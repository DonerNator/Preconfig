# Uninstall HP Wolf Security
function Uninstall-HPWolf {
    Write-Host "Attempting to uninstall HP Wolf Security components..." -ForegroundColor Yellow

    $wolfComponents = @(
        "HP Wolf Security",
        "HP Wolf Security - Console",
        "HP Security Update Service"
    )

    foreach ($component in $wolfComponents) {
        Write-Host "Uninstalling $component using WMIC..." -ForegroundColor Cyan
        $wmicCmd = "wmic product where name=`"$component`" call uninstall /nointeractive"
        Start-Process "cmd.exe" -ArgumentList "/c", $wmicCmd -Wait -WindowStyle Hidden
        Write-Host "Uninstallation of $component attempted." -ForegroundColor Green
    }
}

Uninstall-HPWolf

# Uninstall HP bloatware using partial name matching

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

# HP bloatware list (deduplicated)
$hpBloatware = @(
    "HP Client Security Manager",
    "HP Sure Click",
    "HP Sure Sense",
    "HP Sure Recover",
    "HP Sure Run Module",
    "HP Documentation",
    "HP Support Assistant",
    "HP JumpStart",
    "HP Audio Control",
    "HP Connection Optimizer",
    "HP Privacy Settings",
    "HP QuickDrop",
    "HP Notifications",
    "HP WorkWell",
    "HP System Default Settings",
    "HPAudioControl",
    "RealtekSemiconductorCorp.HPAudioControl",
    "HPSystemInformation",
    "AD2F1837.HPSystemInformation",
    "AD2F1837.HPDesktopSupportUtilities",
    "AD2F1837.HPSupportAssistant",
    "AD2F1837.HPEasyClean",
    "RealtekSemiconductorCorp.HPAudioControl"
    # "AD2F1837.HPPresenceAware"
)

# Begin uninstallation
Write-Host "Starting HP software cleanup..." -ForegroundColor Cyan

foreach ($app in $hpBloatware) {
    Uninstall-Program -ProgramName $app
    Start-Sleep -Seconds 3
}

Write-Host "Completed traditional MSI-based uninstalls." -ForegroundColor Cyan


# Also remove modern HP Appx packages (Store-style apps)
$hpAppxPackages = @(
    "HPPCHardwareDiagnosticsWindows",
    "HPPrivacySettings",
    "HPSystemInformation",
    "HP Support Assistant",
    "myHP",
    "HPAudioControl",
    "AD2F1837.HPSystemInformation"
    "AD2F1837.HPDesktopSupportUtilities",
    "AD2F1837.HPSupportAssistant",
    "AD2F1837.HPEasyClean",
    "RealtekSemiconductorCorp.HPAudioControl"
    # "AD2F1837.HPPresenceAware"
)

foreach ($appx in $hpAppxPackages) {
    $packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*$appx*" }
    foreach ($pkg in $packages) {
        Write-Host "Removing Appx package: $($pkg.Name)" -ForegroundColor Yellow
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers
            Write-Host "Removed: $($pkg.Name)" -ForegroundColor Green
        } catch {
            Write-Warning "Failed to remove $($pkg.Name): $_"
        }
    }
}

Write-Host "HP Appx package removal completed." -ForegroundColor Cyan





# ---- HP Documentation Uninstall Script ----

$uninstallScript = "C:\Program Files\HP\Documentation\Doc_Uninstall.cmd"

if (Test-Path $uninstallScript) {
    Write-Host "Attempting to silently uninstall HP Documentation..." -Foregroundcolor Yellow

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/C `"$uninstallScript`""
    $psi.Verb = "RunAs"             # Correct casing for clarity (works either way)
    $psi.WindowStyle = "Hidden"
    $psi.UseShellExecute = $true

    [System.Diagnostics.Process]::Start($psi) | Out-Null

    Start-Sleep -Seconds 5
    Write-Host "HP Documentation uninstallation Success." -Foregroundcolor Green
} else {
    Write-Warning "Hp Documentation Uninstall script not found at: $uninstallScript"
}






# ---- HP Support Assistant Uninstall Script ----

# Delete the registry key
$regPath = "HKLM:\Software\WOW6432Node\Hewlett-Packard\HPActiveSupport"
if (Test-Path $regPath) {
    Remove-Item -Path $regPath -Recurse -Force
    Write-Output "Registry key deleted: $regPath"
} else {
    Write-Output "Registry key not found: $regPath"
}


# Define possible uninstall paths
$uninstallExePaths = @(
    "C:\Program Files (x86)\Hewlett-Packard\HP Support Framework\UninstallHPSA.exe",
    "C:\Program Files (x86)\HP\HP Support Framework\UninstallHPSA.exe"
)

$uninstallExe = $null
foreach ($path in $uninstallExePaths) {
    if (Test-Path $path) {
        $uninstallExe = $path
        break
    }
}

if ($uninstallExe) {
    # Execute the uninstaller silently
    Start-Process -FilePath $uninstallExe -ArgumentList '/s', '/v/qn', 'UninstallKeepPreferences=FALSE' -Wait -NoNewWindow
    Write-Output "Uninstall process started: $uninstallExe"
} else {
    Write-Output "Uninstaller not found in expected locations."
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

Write-Host "`nVerifying removal..." -ForegroundColor Yellow
$remaining = @()
foreach ($program in $hpBloatware) {
    $check = Get-UninstallString -ProgramName $program
    if ($check) {
        $remaining += $program
    }
}

if ($remaining.Count -gt 0) {
    Write-Warning "`nSome components were not removed:"
    $remaining | ForEach-Object { Write-Warning $_ }
    Write-Host "`nAttempting WMIC uninstall for remaining components..." -ForegroundColor Yellow
    foreach ($prog in $remaining) {
        Write-Host "Trying WMIC uninstall for $prog..." -ForegroundColor Cyan
        $wmicCmd = "wmic product where name=`"$prog`" call uninstall /nointeractive"
        Start-Process "cmd.exe" -ArgumentList "/c", $wmicCmd -Wait -WindowStyle Hidden
    }

    throw "HP Wolf remnants remain."
} else {
    Write-Host "`nAll targeted HP components successfully removed." -ForegroundColor Green
}

Start-Sleep -Seconds 30
Write-Host "Full HP Bloatware Cleanup completed!" -ForegroundColor Green