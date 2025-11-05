# Read configuration
$configPath = "C:\Temp\Preconfig\config.json"
if (-not (Test-Path $configPath)) {
	Write-Error "Configuration file not found: $configPath"
	exit
}
$config = Get-Content $configPath | ConvertFrom-Json



# Definieer
$msiUrl = "https://download.eset.com/com/eset/apps/business/era/agent/latest/agent_x64.msi"
$destinationFolder = "C:\ESET-Management-Agent-Installer"
$msiPath = Join-Path -Path $destinationFolder -ChildPath "agent_x64.msi"
$iniPath = Join-Path -Path $destinationFolder -ChildPath "install_config.ini"

# ESET Management Agent Configuratie
$pInstallModeEulaOnly=1
$pCertContent=$config.eset.certContent


$pCertPasswordIsBase64="yes"
$pCertPassword=""

$pCertAuthContent=$config.eset.CertAuthContent

$pEnableTelemetry=0
$pHostname=$config.eset.Hostname
$pPort=443



$pInitialStaticGroup=$config.eset.initialStaticGroup
$pCustomPolicy=$config.eset.CustomPolicy





# Controleer of de map bestaat
	Write-Host "Controleren of map $destinationFolder bestaat..." -ForegroundColor Cyan
if (-not (Test-Path -Path $destinationFolder)) {
	Write-Host "Map $destinationFolder bestaat niet, deze map wordt nu aangemaakt..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
	Write-Host "Aanmaken van map $destinationFolder voltooid" -ForegroundColor Green
}
	Write-Host "Map $destinationFolder bestaat." -ForegroundColor Green

	$ProgressPreference = "SilentlyContinue"

# Download het ESET Management Agent MSI-bestand
	Write-Host "Downloaden van het ESET Management Agent MSI-bestand..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -ErrorAction Stop
	Write-Host "Downloaden van het ESET Management Agent MSI-bestand voltooid. Locatie: $msiPath" -ForegroundColor Green
} catch {
	Write-Host "Fout bij downloaden van het ESET Management Agent MSI-bestand: $_" -ForegroundColor Red
    exit 1
}

	$ProgressPreference = "Continue"

# Maak het configuratiebestand aan
$iniContent = @"
[ERA_AGENT_PROPERTIES]
P_INSTALL_MODE_EULA_ONLY=$pInstallModeEulaOnly
P_CERT_CONTENT=$pCertContent
P_CERT_PASSWORD_IS_BASE64=$pCertPasswordIsBase64
P_CERT_PASSWORD=$pCertPassword
P_CERT_AUTH_CONTENT=$pCertAuthContent
P_ENABLE_TELEMTRY=$pEnableTelemetry
P_HOSTNAME=$pHostname
P_PORT= $pPort
P_INITIAL_STATIC_GROUP=$pInitialStaticGroup
P_CUSTOM_POLICY=$pCustomPolicy
"@

	Write-Host "Configuratiebestand aanmaken..." -ForegroundColor Cyan
try {
$utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false) # $false = geen BOM
    [System.IO.File]::WriteAllText($iniPath, $iniContent, $utf8NoBomEncoding)
	Write-Host "Configuratiebestand aanmaken voltooid. Locatie: $iniPath" -ForegroundColor Green
} catch {
	Write-Host "Fout bij aanmaken van configuratiebestand: $_" -ForegroundColor Red
    exit 1
}

# Installeer de ESET Management Agent MSI
	Write-Host "ESET Management Agent MSI installeren..." -ForegroundColor Cyan
try {
    $msiArguments = "/i `"$msiPath`" /qn CONFIGFILE=`"$iniPath`""
    Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArguments -Wait -NoNewWindow
	# Optional: Press Space if a pop-up appears
	Start-Sleep 20
	Add-Type -AssemblyName System.Windows.Forms
	[System.Windows.Forms.SendKeys]::SendWait(' ')
    Write-Host "Installatie voltooid." -ForegroundColor Green
} catch {
	Write-Host "Fout tijdens installatie: $_" -ForegroundColor Red
    exit 1
}