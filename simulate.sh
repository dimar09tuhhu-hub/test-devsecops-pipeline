#!/bin/bash
# Simulation Script for SCA and SAST
# Usage: ./simulate.sh [SCA|SAST|All]

SCAN_TYPE=${1:-"All"}

# Color variables
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

write_header() {
    echo -e "\n${CYAN}======================================================================${NC}"
    echo -e "${GREEN}  $1${NC}"
    echo -e "${CYAN}======================================================================${NC}"
}

write_info() {
    echo -e "${CYAN}[*] $1${NC}"
}

write_success() {
    echo -e "${GREEN}[+] $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

write_error() {
    echo -e "${RED}[-] $1${NC}"
}

write_header "DEVSECOPS PIPELINE LOCAL SIMULATION"
write_info "Waktu Mulai: $(date)"
write_info "Tipe Scan: $SCAN_TYPE"

ROOT_PATH=$(pwd)
write_info "Workspace Path: $ROOT_PATH"

# ==============================================================================
# SCA (Software Composition Analysis) - NPM Audit
# ==============================================================================
if [ "$SCAN_TYPE" = "SCA" ] || [ "$SCAN_TYPE" = "All" ]; then
    write_header "MEMULAI SCA (SOFTWARE COMPOSITION ANALYSIS) - NPM AUDIT"
    write_info "Fokus: Memeriksa kerentanan pada pustaka pihak ketiga (package.json / package-lock.json)."
    write_info "Pustaka target simulasi: 'lodash' versi 4.17.15 (diketahui memiliki celah keamanan)."
    echo ""

    # 1. Root NPM Audit
    write-info "Scanning root directory dependencies..."
    if [ -f "$ROOT_PATH/package.json" ]; then
        write_warning "Menjalankan 'npm audit' di Root Project..."
        npm audit --audit-level=high || write_warning "npm audit mendeteksi kerentanan (ini adalah bagian dari simulasi)."
    else
        write_error "File package.json tidak ditemukan di root directory."
    fi

    # 2. Frontend NPM Audit
    echo ""
    write_info "Scanning frontend directory dependencies..."
    FRONTEND_PATH="$ROOT_PATH/frontend"
    if [ -d "$FRONTEND_PATH" ] && [ -f "$FRONTEND_PATH/package.json" ]; then
        write_warning "Menjalankan 'npm audit' di folder 'frontend'..."
        cd "$FRONTEND_PATH" && npm audit --audit-level=high || write_warning "npm audit mendeteksi kerentanan di frontend."
        cd "$ROOT_PATH"
    else
        write_error "Folder 'frontend' atau package.json tidak ditemukan."
    fi
fi

# ==============================================================================
# SAST (Static Application Security Testing) - Semgrep
# ==============================================================================
if [ "$SCAN_TYPE" = "SAST" ] || [ "$SCAN_TYPE" = "All" ]; then
    write_header "MEMULAI SAST (STATIC APPLICATION SECURITY TESTING) - SEMGREP"
    write_info "Fokus: Memeriksa baris kode internal untuk mencari celah keamanan (SQLi, XSS, RCE, Secrets)."
    write_info "Target yang akan dipindai:"
    write_info "  1. app.js -> Mengandung eval() (Remote Code Execution)"
    write_info "  2. go-backend/main.go -> Mengandung SQL Injection (fmt.Sprintf)"
    write_info "  3. secrets.env -> Mengandung AWS Key dan GitHub Token terkespos"
    echo ""

    write_warning "Memeriksa ketersediaan Docker..."
    if ! command -v docker &> /dev/null; then
        write_error "Docker tidak ditemukan! Pastikan Docker Desktop berjalan untuk mensimulasikan Semgrep."
        write_error "Atau jalankan secara online / install Semgrep CLI secara manual."
    else
        write_success "Docker terdeteksi. Menjalankan Semgrep via Docker..."
        
        # Jalankan Semgrep scan via Docker container
        docker run --rm -v "$ROOT_PATH:/src" returntocorp/semgrep semgrep scan --config=auto
        
        write_success "Semgrep Scan selesai."
    fi
fi

write_header "SIMULASI DEVSECOPS SELESAI"
write_success "SCA & SAST simulasi telah selesai dieksekusi."
write_info "Rekomendasi tindakan:"
write_info "1. Perbaiki SCA: Jalankan 'npm audit fix' atau perbarui versi 'lodash' ke versi terbaru (>= 4.17.21)."
write_info "2. Perbaiki SAST (eval): Hindari penggunaan eval() di app.js, validasi input, atau gunakan parse JSON aman."
write_info "3. Perbaiki SAST (SQLi): Gunakan parameterized query / placeholder (db.Query('SELECT ... WHERE username = ?', username)) daripada fmt.Sprintf di main.go."
write_info "4. Perbaiki Secrets: Pindahkan AWS & GitHub Token dari secrets.env ke secrets manager atau variable environment OS."
echo ""
