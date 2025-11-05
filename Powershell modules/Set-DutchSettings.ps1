# Run as Administrator

# --- Settings ---
$Language = "nl-NL"
$KeyboardLayout = "0409:00020409"  # US-International layout
$GeoID = 176  # Netherlands

Write-Host "Starting setup for Dutch language, Time settings and US-International keyboard layout..." -ForegroundColor Green

# --- Step 1: Check and Install Dutch language ---
$installed = Get-WinUserLanguageList | Where-Object { $_.LanguageTag -eq $Language }
if (-not $installed) {
    Write-Host "Dutch language pack not found. Installing..." -ForegroundColor Yellow
    Install-Language $Language
    Start-sleep -Seconds 5  # Wait for installation to complete
} else {
    Write-Host "Dutch language pack is already installed." -ForegroundColor Green
}

# --- Step 2: Apply system-wide language and input settings ---
Write-Host "Setting display language to Dutch and keyboard to US-International..." -ForegroundColor Cyan
Set-WinSystemLocale -SystemLocale $Language
Set-Culture $Language
Set-WinUILanguageOverride -Language $Language
Set-WinHomeLocation -GeoId $GeoID
Set-SystemLanguage $Language

# Configure language list with US-International keyboard only
$LangList = New-WinUserLanguageList $Language
$LangList[0].InputMethodTips.Clear()
$LangList[0].InputMethodTips.Add($KeyboardLayout)
Set-WinUserLanguageList $LangList -Force
Set-WinDefaultInputMethodOverride -InputTip $KeyboardLayout

# --- Step 3: Registry edits for welcome screen / default user via REG.EXE ---
Write-Host "Configuring registry for welcome screen and default user keyboard settings..." -ForegroundColor Cyan

# US-International as default input method for .DEFAULT user
reg add "HKU\.DEFAULT\Keyboard Layout\Preload" /v 1 /t REG_SZ /d 00020409 /f

# Dutch locale for .DEFAULT user
reg add "HKU\.DEFAULT\Control Panel\International" /v Locale /t REG_SZ /d 00000413 /f
reg add "HKU\.DEFAULT\Control Panel\International" /v LocaleName /t REG_SZ /d nl-NL /f

# --- Done ---
Write-Host "Setup complete! Please reboot to apply all changes." -ForegroundColor Green
