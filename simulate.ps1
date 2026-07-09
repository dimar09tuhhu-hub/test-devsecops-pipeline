# Simulation Script for SCA and SAST
# Usage: .\simulate.ps1 -ScanType All (Options: SCA, SAST, All)

param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("SCA", "SAST", "All")]
    [string]$ScanType = "All"
)

# Color variables
$Green  = "[ConsoleColor]::Green"
$Cyan   = "[ConsoleColor]::Cyan"
$Yellow = "[ConsoleColor]::Yellow"
$Red    = "[ConsoleColor]::Red"
$White  = "[ConsoleColor]::White"
$Gray   = "[ConsoleColor]::Gray"

function Write-Header ($text) {
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor White
    Write-Host "======================================================================" -ForegroundColor Cyan
}

function Write-Info ($text) {
    Write-Host "[*] $text" -ForegroundColor Cyan
}

function Write-Success ($text) {
    Write-Host "[+] $text" -ForegroundColor Green
}

function Write-WarningMsg ($text) {
    Write-Host "[!] $text" -ForegroundColor Yellow
}

function Write-ErrorMsg ($text) {
    Write-Host "[-] $text" -ForegroundColor Red
}

Write-Header "DEVSECOPS PIPELINE LOCAL SIMULATION"
Write-Info "Waktu Mulai: $(Get-Date)"
Write-Info "Tipe Scan: $ScanType"

$rootPath = Resolve-Path .
Write-Info "Workspace Path: $rootPath"

# ==============================================================================
# SCA (Software Composition Analysis) - NPM Audit
# ==============================================================================
if ($ScanType -eq "SCA" -or $ScanType -eq "All") {
    Write-Header "MEMULAI SCA (SOFTWARE COMPOSITION ANALYSIS) - NPM AUDIT"
    Write-Info "Fokus: Memeriksa kerentanan pada pustaka pihak ketiga (package.json / package-lock.json)."
    Write-Info "Pustaka target simulasi: 'lodash' versi 4.17.15 (diketahui memiliki celah keamanan)."
    Write-Host ""

    # 1. Root NPM Audit
    Write-Info "Scanning root directory dependencies..."
    if (Test-Path "$rootPath\package.json") {
        Write-WarningMsg "Menjalankan 'npm audit' di Root Project..."
        # Menjalankan npm audit. Karena lodash 4.17.15 terinstall, npm audit akan keluar dengan exit code bukan 0.
        # Kita bungkus agar script tidak langsung crash.
        try {
            npm audit --audit-level=high
        } catch {
            Write-ErrorMsg "Gagal menjalankan npm audit di root: $_"
        }
    } else {
        Write-ErrorMsg "File package.json tidak ditemukan di root directory."
    }

    # 2. Frontend NPM Audit
    Write-Host ""
    Write-Info "Scanning frontend directory dependencies..."
    $frontendPath = Join-Path $rootPath "frontend"
    if (Test-Path "$frontendPath\package.json") {
        Write-WarningMsg "Menjalankan 'npm audit' di folder 'frontend'..."
        Push-Location $frontendPath
        try {
            npm audit --audit-level=high
        } catch {
            Write-ErrorMsg "Gagal menjalankan npm audit di frontend: $_"
        }
        Pop-Location
    } else {
        Write-ErrorMsg "Folder 'frontend' atau package.json tidak ditemukan."
    }
}

# ==============================================================================
# SAST (Static Application Security Testing) - Semgrep
# ==============================================================================
if ($ScanType -eq "SAST" -or $ScanType -eq "All") {
    Write-Header "MEMULAI SAST (STATIC APPLICATION SECURITY TESTING) - SEMGREP"
    Write-Info "Fokus: Memeriksa baris kode internal untuk mencari celah keamanan (SQLi, XSS, RCE, Secrets)."
    Write-Info "Target yang akan dipindai:"
    Write-Info "  1. app.js -> Mengandung eval() (Remote Code Execution)"
    Write-Info "  2. go-backend/main.go -> Mengandung SQL Injection (fmt.Sprintf)"
    Write-Info "  3. secrets.env -> Mengandung AWS Key dan GitHub Token terkespos"
    Write-Host ""

    # Semgrep akan dijalankan melalui Docker karena tool cli semgrep belum terinstall secara native
    Write-WarningMsg "Memeriksa ketersediaan Docker..."
    $dockerCheck = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCheck) {
        Write-ErrorMsg "Docker tidak ditemukan! Pastikan Docker Desktop berjalan untuk mensimulasikan Semgrep."
        Write-ErrorMsg "Atau jalankan secara online / install Semgrep CLI secara manual."
    } else {
        Write-Success "Docker terdeteksi. Menjalankan Semgrep via Docker..."
        
        # Konversi path ke format POSIX untuk Docker volume mount di Windows
        # Kita butuh path absolut Windows yang valid.
        $winPath = $rootPath.Path
        Write-Info "Mounting path: $winPath ke /src di Container"

        # Menjalankan Semgrep Scan dengan config=auto
        docker run --rm -v "${winPath}:/src" returntocorp/semgrep semgrep scan --config=auto
        
        Write-Success "Semgrep Scan selesai."
    }
}

Write-Header "SIMULASI DEVSECOPS SELESAI"
Write-Success "SCA & SAST simulasi telah selesai dieksekusi."
Write-Info "Rekomendasi tindakan:"
Write-Info "1. Perbaiki SCA: Jalankan 'npm audit fix' atau perbarui versi 'lodash' ke versi terbaru (>= 4.17.21)."
Write-Info "2. Perbaiki SAST (eval): Hindari penggunaan eval() di app.js, validasi input, atau gunakan parse JSON aman."
Write-Info "3. Perbaiki SAST (SQLi): Gunakan parameterized query / placeholder (db.Query('SELECT ... WHERE username = ?', username)) daripada fmt.Sprintf di main.go."
Write-Info "4. Perbaiki Secrets: Pindahkan AWS & GitHub Token dari secrets.env ke secrets manager atau variable environment OS."
Write-Host ""
