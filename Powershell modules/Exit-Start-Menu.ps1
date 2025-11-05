# Run keystrokes for Exiting Start Menu
Add-Type -AssemblyName System.Windows.Forms
Start-Sleep 1
[System.Windows.Forms.SendKeys]::SendWait('{ESC}')