# Installeert office op basis van XML config.
Write-Host "Installing Office" -ForegroundColor Green
$officeSetupPath = "C:\Temp\Preconfig\Files\Office\OfficeSetup.exe"
$configXmlPath = "C:\Temp\Preconfig\Files\Office\Configuratie64Bit.xml"
if (Test-Path $officeSetupPath) {
	Start-Process -FilePath $officeSetupPath -ArgumentList "/configure `"$configXmlPath`"" -Wait
	Write-Host "Office installation process completed." -ForegroundColor Green
} else {
	Write-Host "ERROR: OfficeSetup.exe not found at $officeSetupPath" -ForegroundColor Red
}


