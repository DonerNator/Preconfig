# Set-DisableCAD-System.ps1
# Run as Administrator

$psexecPath = 'C:\Temp\Preconfig\Files\PsExec.exe'
if (-not (Test-Path $psexecPath)) {
    Write-Host "psexec.exe not found at $psexecPath" -ForegroundColor Red
    exit 1
}

$regKey     = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\SystemProtected'
$valueName  = 'DisableCAD'
$desiredVal = 0
$maxRetries = 3
$waitBetween = 2

function Invoke-AsSystem-RegAdd {
    param($key, $name, $val)

    $cmd = "reg add `"$key`" /v $name /t REG_DWORD /d $val /f"
    $psexecArgs = @('-accepteula','-s','cmd','/c',$cmd)
    $proc = Start-Process -FilePath $psexecPath -ArgumentList $psexecArgs -NoNewWindow -Wait -PassThru
    return $proc.ExitCode
}

function Get-AsSystem-RegValue {
    param($key, $name)

    $cmd = "reg query `"$key`" /v $name"
    $psexecArgs = @('-accepteula','-s','cmd','/c',$cmd)
    $out = & $psexecPath @psexecArgs 2>&1
    return ($out -join "`n")
}

$attempt = 0
$success = $false

while ($attempt -lt $maxRetries -and -not $success) {
    $attempt++
    Write-Host "Attempt $attempt..."
    Invoke-AsSystem-RegAdd -key $regKey -name $valueName -val $desiredVal | Out-Null
    Start-Sleep -Seconds $waitBetween

    $query = Get-AsSystem-RegValue -key $regKey -name $valueName
    if ($query -match "$valueName\s+REG_DWORD\s+0x0\b") {
        Write-Host "Success: $valueName set to 0" -ForegroundColor Green
        $success = $true
    } else {
        Write-Warning "Verification failed:`n$query"
        if ($attempt -lt $maxRetries) {
            Start-Sleep -Seconds $waitBetween
        }
    }
}

if (-not $success) {
    Write-Error "Could not set $valueName after $maxRetries attempts"
    exit 2
}
