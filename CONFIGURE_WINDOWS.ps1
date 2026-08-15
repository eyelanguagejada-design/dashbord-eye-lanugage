$subdomain = Read-Host "Daftra subdomain"
$apiKey = Read-Host "Daftra API Key"
$tokenSecure = Read-Host "Daftra Access Token" -AsSecureString
$tokenPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenSecure)
try { $token = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPtr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPtr) }
$db = 'postgresql://postgres:postgres@localhost:5432/daftra_financial_intelligence?schema=public'
@"
DATABASE_URL="$db"
DAFTRA_SUBDOMAIN="$subdomain"
DAFTRA_API_KEY="$apiKey"
DAFTRA_ACCESS_TOKEN="$token"
DAFTRA_BASE_CURRENCY="EGP"
DAFTRA_REQUEST_TIMEOUT_MS="20000"
DAFTRA_MAX_RETRIES="3"
RECONCILIATION_TOLERANCE="0.01"
"@ | Set-Content -Encoding UTF8 .env.local
Write-Host ".env.local created. Keep it private and never commit it." -ForegroundColor Green
