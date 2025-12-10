Write-Host "Cleaning up all files from preconfig and scheduled tasks." -ForegroundColor Green
try {
    [System.IO.Directory]::Delete("C:\Temp\Preconfig", $true)
} catch {}
try {
    [System.IO.Directory]::Delete("C:\ESET-Management-Agent-Installer", $true)
} catch {}
try {
    [System.IO.Directory]::Delete("C:\Temp\Stage1Percom.txt", $true)
} catch {}
try {
    [System.IO.Directory]::Delete("C:\Temp\Stage2Percom.txt", $true)
} catch {}
try {
    [System.IO.Directory]::Delete("C:\Temp\ESET-Security.msi", $true)
} catch {}
Remove-Item -Path "C:\Temp\Stage1Percom.txt" -Force -ErrorAction Ignore | Out-Null
Remove-Item -Path "C:\Temp\ESET-Security.msi" -Force -ErrorAction Ignore | Out-Null
Remove-Item -Path "C:\Temp\Stage1Percom.txt" -Force -ErrorAction Ignore | Out-Null
Unregister-ScheduledTask -TaskName "Preconfig Stage 3" -Confirm:$false


