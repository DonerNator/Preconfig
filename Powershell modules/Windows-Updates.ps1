# Ensure script runs as Administrator
try {
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error "Please run this script as Administrator."
        throw "Not running as Administrator"
    }
} catch {
    Write-Host "Admin check failed" -ForegroundColor Red
    exit 1
}

# Install PSWindowsUpdate module if not installed
try {
    If (-Not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Cyan
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
    }
} catch {
    Write-Host "Failed to install PSWindowsUpdate module" -ForegroundColor Red
    exit 1
}

# Import the module
try {
    Write-Host "Importing PSWindowsUpdate module..." -ForegroundColor cyan
    Import-Module PSWindowsUpdate -ErrorAction Stop
} catch {
    Write-Error "Failed to import PSWindowsUpdate module: $_"
    exit 1
}

# Register Microsoft Update Service (includes optional updates)
try {
    Write-Host "Registering Microsoft Update Service..." -ForegroundColor Cyan
    Add-WUServiceManager -MicrosoftUpdate -Confirm:$false -ErrorAction Stop | Out-Null
} catch {
    Write-Error "Failed to register Microsoft Update Service: $_"
}

# Optional: Press A (Consider removing this for unattended scripts)
Start-Sleep 10
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop | Out-Null
[System.Windows.Forms.SendKeys]::SendWait('a')

# Retrieve all available updates
$updates = Get-WUList -MicrosoftUpdate

# Filter out updates with "Cumulative Update" in the title
$filteredUpdates = $updates | Where-Object {
    $_.Title -notmatch '(?i)cumul.*update'
}

if (-not $filteredUpdates) {
    Write-Host "No applicable updates found to install after filtering cumulative updates." -ForegroundColor Yellow
    exit 0
}

# Show what's being installed
Write-Host "The following updates will be installed (cumulative updates excluded):" -ForegroundColor Cyan
$filteredUpdates | Format-Table KBArticleID, Title, Size -AutoSize

foreach ($u in $filteredUpdates) {
    $kb = $u.KBArticleID
    $sizeGB = if ($u.Size -and $u.Size -gt 0) { "{0:N2}" -f ($u.Size / 1GB) } else { "Unknown" }
    $sizeText = if ($sizeGB -ne "Unknown") { "$sizeGB GB" } else { "Size Unknown" }
    try {
        if ($kb) {
            Write-Host "Installing KB$kb - $($u.Title) [$sizeText]" -ForegroundColor Cyan
            Install-WindowsUpdate -KBArticleID $kb -AcceptAll -IgnoreReboot -ErrorAction Stop | Out-Null
        } else {
            Write-Host "Installing update (no KB) - $($u.Title) [$sizeText]" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            Install-WindowsUpdate -Title $u.Title -AcceptAll -IgnoreReboot -ErrorAction Stop | Out-Null
        }
        Write-Host "Installed: $($u.Title)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install: $($u.Title): $_" -ForegroundColor Red
    }
}

# End of update logic