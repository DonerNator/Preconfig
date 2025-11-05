Write-Host "Applying Password + PC Hostname" -ForegroundColor Green

# Retrieve password config from config.txt
$configFilePath = "C:\Temp\Preconfig\config.txt"

# Read config file and parse values
$configLines = Get-Content $configFilePath | Where-Object { $_ -match '=' }
$data = @{}
foreach ($line in $configLines) {
    $parts = $line -split '=', 2
    if ($parts.Count -eq 2) {
        $key = $parts[0].Trim()
        $value = $parts[1].Trim()
        $data[$key] = $value
    }
}

# Change the computer name if PC_Name is present
if ($data.ContainsKey("PC_Name") -and -not [string]::IsNullOrWhiteSpace($data.PC_Name)) {
    $currentName = (Get-ComputerInfo -Property CsName).CsName
    if ($currentName -ne $data.PC_Name) {
        try {
            Rename-Computer -NewName $data.PC_Name -Force
            Write-Host "Computer name will be changed to $($data.PC_Name) after restart." -ForegroundColor Green
        } catch {
            Write-Host "Failed to change computer name. $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Computer name is already set to $($data.PC_Name)." -ForegroundColor Yellow
    }
}
# Decrypt the password from config
$encryptionPassword = "KaasPlank"
$keyString = $encryptionPassword.PadRight(32, 'X').Substring(0,32)
$key = [System.Text.Encoding]::UTF8.GetBytes($keyString)
$secure = ConvertTo-SecureString $data.Password -Key $key
$password = [System.Net.NetworkCredential]::new("", $secure).Password

# Apply the password for the Service.percom user
$serviceUser = "Service.percom"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
try {
    Set-LocalUser -Name $serviceUser -Password $securePassword -PasswordNeverExpires $true
    Write-Host "Password updated for user $serviceUser and set to never expire." -ForegroundColor Green
} catch {
    Write-Host "Failed to update password for user $serviceUser. $_" -ForegroundColor Red
}
