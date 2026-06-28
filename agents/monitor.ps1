# Agent status monitor — runs in a Windows Terminal pane to show live agent status.
# Usage: .\agents\monitor.ps1 -AgentSlug tech-lead
#
# The main Claude Code conversation writes to agents/runtime/<slug>.md when an
# agent is spawned and again when it completes. This script refreshes every 3s.

param([string]$AgentSlug = "agent")

$workspace = "C:\Users\hanss\Documents\agent-workspace"
$statusFile = Join-Path $workspace "agents\runtime\$AgentSlug.md"

while ($true) {
    Clear-Host

    if (Test-Path $statusFile) {
        $lines = Get-Content $statusFile
        foreach ($line in $lines) {
            if ($line -match "STATUS:.*RUNNING") {
                Write-Host $line -ForegroundColor Yellow
            } elseif ($line -match "STATUS:.*COMPLETE") {
                Write-Host $line -ForegroundColor Green
            } elseif ($line -match "STATUS:.*BLOCKED|STATUS:.*FAILED") {
                Write-Host $line -ForegroundColor Red
            } elseif ($line -match "^(AGENT|MODE|PROJECT|STARTED|DONE):") {
                Write-Host $line -ForegroundColor Cyan
            } else {
                Write-Host $line
            }
        }
    } else {
        Write-Host ""
        Write-Host "  [$AgentSlug]" -ForegroundColor DarkGray
        Write-Host "  Waiting for agent to be spawned..." -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Last refresh: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor DarkGray
    Start-Sleep -Seconds 3
}
