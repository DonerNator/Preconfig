<#
.SYNOPSIS
    Silently uninstalls HP Wolf Security components using a robust hybrid method.
    
.DESCRIPTION
    This script removes HP Wolf Security components in the specific order required by HP support.
    
    Order of removal:
    1. HP Wolf Security
    2. HP Wolf Security - Console
    3. HP Security Update Service
    
    Methodology:
    - Attempt 1: Modern PowerShell 'Uninstall-Package' (Faster, cleaner).
    - Attempt 2: WMIC 'product ... call uninstall' (Legacy fallback from HP documentation).
    
    If Attempt 1 finds the package and successfully removes it, Attempt 2 is skipped.
    If Attempt 1 fails or cannot find the package, Attempt 2 runs to ensure removal.

.NOTES
    Run as Administrator.
    Reference: https://support.hpwolf.com/s/article/How-to-uninstall-HP-Wolf-Pro-Security
#>

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges. Please run as Administrator."
    exit
}

Write-Host "Starting HP Wolf Security Comprehensive Uninstaller..." -ForegroundColor Cyan
Write-Host "----------------------------------------------------" -ForegroundColor Gray

# Define the components with both their Regex pattern (Method 1) and exact WMIC name (Method 2)
$components = @(
    @{ 
        Name = "HP Wolf Security"; 
        Regex = "HP Wolf Security(?!.*Console)"; 
        WmicName = "HP Wolf Security" 
    },
    @{ 
        Name = "HP Wolf Security - Console"; 
        Regex = "HP Wolf Security.*Console"; 
        WmicName = "HP Wolf Security - Console" 
    },
    @{ 
        Name = "HP Security Update Service"; 
        Regex = "HP Security Update Service"; 
        WmicName = "HP Security Update Service" 
    }
)

# Helper function for the WMIC fallback
function Invoke-WmicFallback {
    param ([string]$WmicName)
    Write-Host "  [Fallback] Executing WMIC command for '$WmicName'..." -ForegroundColor Yellow
    
    # Using cmd /c wmic to ensure stable execution
    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c wmic product where name=""$WmicName"" call uninstall" -Wait -PassThru -NoNewWindow
    
    if ($proc.ExitCode -eq 0) {
        Write-Host "  [Fallback] WMIC command completed successfully." -ForegroundColor Green
    } else {
        Write-Host "  [Fallback] WMIC finished with exit code: $($proc.ExitCode)" -ForegroundColor DarkGray
    }
}

# Main Execution Loop
foreach ($comp in $components) {
    Write-Host "`nProcessing: $($comp.Name)" -ForegroundColor Cyan
    
    $resolved = $false
    
    # --- Method 1: Modern PowerShell Package Management ---
    try {
        Write-Host "  [Method 1] Searching via Get-Package..." -NoNewline
        $packages = Get-Package -AllVersions -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $comp.Regex }
        
        if ($packages) {
            Write-Host " Found." -ForegroundColor Green
            foreach ($p in $packages) {
                Write-Host "  [Method 1] Attempting uninstall of '$($p.Name)'..."
                $p | Uninstall-Package -Force -ErrorAction Stop
                Write-Host "  [Method 1] Success." -ForegroundColor Green
                $resolved = $true
            }
        } else {
            Write-Host " Not found." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Error "  [Method 1] Error: $_"
        $resolved = $false
    }

    # --- Method 2: WMIC Fallback ---
    # We run this if Method 1 failed OR if Method 1 didn't find anything (to be double sure it's gone)
    if (-not $resolved) {
        Invoke-WmicFallback -WmicName $comp.WmicName
    } else {
        Write-Host "  Skipping fallback (Method 1 succeeded)." -ForegroundColor DarkGray
    }
}

Write-Host "`n----------------------------------------------------" -ForegroundColor Gray
Write-Host "Uninstallation sequence finished." -ForegroundColor Cyan
Write-Host "A reboot is highly recommended to clear any locked files." -ForegroundColor Yellow