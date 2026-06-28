param([string]$slug)

$file = "C:\Users\hanss\Documents\agent-workspace\agents\runtime\$slug.md"

$host.UI.RawUI.WindowTitle = "Agent Monitor -- $slug"

while ($true) {
    Clear-Host
    if (Test-Path $file) {
        Get-Content $file
    } else {
        Write-Host "[$slug] Waiting for agent to start..." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds 2
}
