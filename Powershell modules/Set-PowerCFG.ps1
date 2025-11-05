Write-Host "Applying Powerplan settings." -ForegroundColor Green
Start-Sleep -Seconds 15

$chassis = Get-WmiObject -Class Win32_SystemEnclosure
$laptopTypes = @(8, 9, 10, 14, 30) # Laptop chassis types
 
if ($chassis.ChassisTypes | Where-Object { $laptopTypes -contains $_ }) {
    Write-Host "This device is a laptop. Applying laptop power settings. (Balanced)" - -ForegroundColor DarkBlue
    # Set the power plan to Balanced
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
} else {
    Write-Host "This device is a desktop. Applying desktop power settings. (High Performance)" -ForegroundColor DarkBlue
    # Set the power plan to High Performance
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
}





# Disable Hibernation/standby/sleep functions (AC=plugged in power - DC=on battery)
powercfg.exe -x -monitor-timeout-ac 0
powercfg.exe -x -monitor-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
