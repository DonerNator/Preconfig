Write-Host "Checking if 7Zip is installed..." -ForegroundColor Green
$CheckFor7Zip = Winget list | Select-String "7zip.7zip"
if ($CheckFor7Zip -eq $null)
{
    Write-Host "7Zip not found, installing..." -ForegroundColor Yellow
    winget install --id "7zip.7zip" --accept-source-agreements --accept-package-agreements | Out-Null

    $CheckFor7Zip = Winget list | Select-String "7zip.7zip"
    if ($CheckFor7Zip -eq $null)
    {
        Write-Host "7zip has not been installed correctly after retry." -ForegroundColor Red
    }
    else
    {
        Write-Host "7Zip installed successfully." -ForegroundColor Green
    }
}
else
{
    Write-Host "7Zip is already installed." -ForegroundColor Green
}