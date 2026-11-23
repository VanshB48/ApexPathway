# Install Git Pre-Commit Hook
$repoRoot = (Resolve-Path "$PSScriptRoot/..").Path
$hookDir = Join-Path $repoRoot ".git/hooks"
$preCommitPath = Join-Path $hookDir "pre-commit"

if (-not (Test-Path $hookDir)) {
    New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
}

$hookContent = @'
#!/bin/sh
# ApexPathway Pre-Commit Hook (Git Bash / POSIX / Windows)
if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -ExecutionPolicy Bypass -File "$(git rev-parse --show-toplevel)/scripts/pre-commit-hook.ps1"
    exit $?
elif command -v pwsh >/dev/null 2>&1; then
    pwsh -File "$(git rev-parse --show-toplevel)/scripts/pre-commit-hook.ps1"
    exit $?
else
    # Fallback POSIX check if PowerShell is unavailable
    if git diff --cached --name-only | grep -E '^(\.env|\.env\.local|.*\.key|.*\.pem|.*\.parquet|.*\.db)$' | grep -v '^\.env\.example$'; then
        echo "SECURITY ERROR: Sensitive files staged for commit!" >&2
        exit 1
    fi
fi
'@

Set-Content -Path $preCommitPath -Value $hookContent -NoNewline
Write-Host "ApexPathway pre-commit hook installed successfully at: $preCommitPath" -ForegroundColor Green
