Write-Host "Setting time to W. Europe Standard Time. (Oude backup manier voor als de volgende niet werk, valt hij terug naar dit.)" -ForegroundColor Yellow
Set-TimeZone -Id "W. Europe Standard Time" -ErrorAction Ignore -WarningAction Ignore

$StopTimeService = net stop w32time | Out-Null;
$StartTimeService = net start w32time | Out-Null;
$StartTimeService | Out-Null
$StopTimeService | Out-Null

