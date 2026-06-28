param(
    [string]$ApiBase = "http://localhost:8080"
)

$uri = "$ApiBase/api/edition/info"
try {
    $resp = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 5
    if ($resp.machine_id) {
        Write-Host "Machine ID: $($resp.machine_id)"
        Write-Host "Instance plan: $($resp.instance_plan)"
        exit 0
    }
} catch {
    Write-Warning "Could not reach API at $uri"
    Write-Warning $_.Exception.Message
}

Write-Host ""
Write-Host "Start the API with EDITION=selfhosted, then re-run this script."
Write-Host "Or set MACHINE_CODE manually for license-gen --machine."
