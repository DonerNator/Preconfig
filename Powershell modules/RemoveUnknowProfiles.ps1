# Delete all "Unknown profiles" (SID cannot be resolved) without asking
$unknownProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
    try {
        [void](New-Object System.Security.Principal.SecurityIdentifier($_.SID)).Translate([System.Security.Principal.NTAccount])
        $false  # SID resolved -> not unknown
    } catch {
        $true   # SID cannot be resolved -> unknown profile
    }
}

if ($unknownProfiles) {
    Write-Host "Deleting $($unknownProfiles.Count) unknown profiles..." -ForegroundColor Yellow

    foreach ($p in $unknownProfiles) {
        Write-Host "Deleting profile: SID=$($p.SID), Path=$($p.LocalPath), LastUse=$($p.LastUseTime)" -ForegroundColor Red
        try {
            $p | Remove-CimInstance -ErrorAction Stop
        } catch {
            Write-Host "Failed to delete $($p.LocalPath): $_" -ForegroundColor DarkRed
        }
    }

    Write-Host "Finished cleaning unknown profiles." -ForegroundColor Green
} else {
    Write-Host "No unknown profiles found." -ForegroundColor Green
}
