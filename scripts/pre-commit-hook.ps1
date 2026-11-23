# ApexPathway Pre-Commit Secret Scanner Hook
$ErrorActionPreference = 'Stop'

Write-Host "Running ApexPathway pre-commit secret hygiene checks..." -ForegroundColor Cyan

$hasError = $false

# 1. Check staged file names
$stagedFiles = git diff --cached --name-only
$blockedFilePatterns = @(
    '^\.env(\..+)?$',
    '\.(key|pem|p12|pkcs12|jks)$',
    '\.(parquet|db|duckdb|sqlite|sqlite3)$',
    'application-secret\.(properties|ya?ml)$'
)

foreach ($file in $stagedFiles) {
    if ($file -eq '.env.example') { continue }
    foreach ($pat in $blockedFilePatterns) {
        if ($file -match $pat) {
            Write-Host "SECURITY ERROR: Staging of prohibited file detected: $file" -ForegroundColor Red
            $hasError = $true
        }
    }
}

# 2. Check staged content diff for secret patterns
$secretPatterns = @(
    @{ Name = "Google Gemini API Key"; Pattern = 'AIzaSy[A-Za-z0-9_-]{33}' },
    @{ Name = "Angel One Key Pattern"; Pattern = '(?i)(ANGEL_API_KEY|ANGEL_TOTP_SECRET)\s*[:=]\s*[''"][a-zA-Z0-9_\-\+]{6,}[''"]' },
    @{ Name = "Private Key File Header"; Pattern = '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----' }
)

foreach ($file in $stagedFiles) {
    # Skip self, documentation, contracts, and sample templates from regex scanning
    if ($file -match '^(scripts/|specs/|\.specify/)|\.md$|\.example$') {
        continue
    }
    $fileDiff = git diff --cached --unified=0 -- $file
    foreach ($rule in $secretPatterns) {
        if ($fileDiff -match $rule.Pattern) {
            Write-Host "SECURITY ERROR: Detected $($rule.Name) in staged file: $file!" -ForegroundColor Red
            $hasError = $true
        }
    }
}

if ($hasError) {
    Write-Host "`nCommit aborted by ApexPathway pre-commit security hook." -ForegroundColor Red
    Write-Host "Please remove sensitive credentials or files from staging before committing.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "Secret hygiene checks passed clean." -ForegroundColor Green
exit 0
