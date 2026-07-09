# Panduan Simulasi Keamanan: SCA & SAST

Dokumen ini menjelaskan cara mensimulasikan pemindaian keamanan menggunakan **SCA (Software Composition Analysis)** dan **SAST (Static Application Security Testing)** secara lokal di dalam proyek ini.

---

## 1. Konsep & Celah Keamanan yang Disimulasikan

### A. SCA (Software Composition Analysis)
*   **Alat**: `NPM Audit`
*   **Fokus**: Memeriksa pustaka (library) pihak ketiga yang digunakan oleh proyek.
*   **Celah Keamanan dalam Simulasi**:
    *   File [package.json](file:///c:/Users/Dimar%20Alam/OneDrive/Desktop/Test/devsecops-pipeline/test-devsecops-pipeline/package.json) dan [frontend/package.json](file:///c:/Users/Dimar%20Alam/OneDrive/Desktop/Test/devsecops-pipeline/test-devsecops-pipeline/frontend/package.json) menggunakan dependensi `lodash` dengan versi **`4.17.15`**.
    *   Versi `lodash` ini sudah usang dan terbukti memiliki celah keamanan serius (seperti *Prototype Pollution* - CVE-2020-8203, CVE-2020-28500) yang tercatat dalam basis data kerentanan global (GitHub Advisory Database).

### B. SAST (Static Application Security Testing)
*   **Alat**: `Semgrep` (Dijalankan melalui Docker)
*   **Fokus**: Memindai kode internal buatan developer tanpa menjalankan aplikasinya.
*   **Celah Keamanan dalam Simulasi**:
    *   **JavaScript (eval/RCE)** di [app.js](file:///c:/Users/Dimar%20Alam/OneDrive/Desktop/Test/devsecops-pipeline/test-devsecops-pipeline/app.js#L7-L11): Menggunakan fungsi `eval()` untuk mengevaluasi input dinamis dari query string. Ini memungkinkan serangan Remote Code Execution (RCE).
    *   **Go (SQL Injection)** di [go-backend/main.go](file:///c:/Users/Dimar%20Alam/OneDrive/Desktop/Test/devsecops-pipeline/test-devsecops-pipeline/go-backend/main.go#L20-L23): Melakukan konkatenasi string secara langsung menggunakan `fmt.Sprintf` untuk menyusun query SQL. Ini memungkinkan serangan SQL Injection (SQLi).
    *   **Secrets Exposure** di [secrets.env](file:///c:/Users/Dimar%20Alam/OneDrive/Desktop/Test/devsecops-pipeline/test-devsecops-pipeline/secrets.env): Menyimpan AWS Access Keys dan GitHub Personal Access Tokens secara hardcoded.

---

## 2. Cara Menjalankan Simulasi

### Prasyarat
1.  **Node.js & NPM**: Harus terinstall untuk menjalankan `npm audit`.
2.  **Docker Desktop**: Harus berjalan untuk menjalankan `semgrep` melalui Docker container secara lokal.

### Opsi A: Menggunakan PowerShell (Rekomendasi untuk Windows)
Buka PowerShell di folder `test-devsecops-pipeline` dan jalankan perintah berikut:

1.  **Simulasi Seluruhnya (SCA & SAST)**:
    ```powershell
    .\simulate.ps1 -ScanType All
    ```
2.  **Simulasi SCA saja (NPM Audit)**:
    ```powershell
    .\simulate.ps1 -ScanType SCA
    ```
3.  **Simulasi SAST saja (Semgrep via Docker)**:
    ```powershell
    .\simulate.ps1 -ScanType SAST
    ```

### Opsi B: Menggunakan Bash (Git Bash / Linux / WSL)
Buka terminal Bash di folder `test-devsecops-pipeline` dan jalankan:

1.  **Beri hak akses eksekusi script**:
    ```bash
    chmod +x simulate.sh
    ```
2.  **Jalankan simulasi**:
    ```bash
    # Simulasi seluruhnya
    ./simulate.sh All
    
    # Jalankan SCA saja
    ./simulate.sh SCA
    
    # Jalankan SAST saja
    ./simulate.sh SAST
    ```

---

## 3. Cara Memperbaiki Temuan Keamanan (Remediasi)

Setelah melihat laporan kesalahan dari hasil scan, Anda dapat mencoba langkah berikut untuk memverifikasi perbaikan:

1.  **Memperbaiki SCA**:
    *   Ubah versi `lodash` di `package.json` menjadi `"^4.17.21"` atau versi terbaru yang aman.
    *   Jalankan `npm install` untuk memperbarui `package-lock.json`.
    *   Jalankan kembali `./simulate.ps1 -ScanType SCA` untuk memastikan statusnya bersih.

2.  **Memperbaiki SAST - JavaScript (`app.js`)**:
    *   Jangan pernah menggunakan `eval()`. Gunakan parser yang aman seperti `JSON.parse()` jika tujuannya memproses JSON, atau gunakan logika pemrograman standar lainnya.

3.  **Memperbaiki SAST - Go SQL Injection (`go-backend/main.go`)**:
    *   Ganti:
        ```go
        query := fmt.Sprintf("SELECT id, name FROM users WHERE username = '%s'", username)
        rows, err := db.Query(query)
        ```
    *   Menjadi parameterized query:
        ```go
        rows, err := db.Query("SELECT id, name FROM users WHERE username = ?", username)
        ```

4.  **Memperbaiki Secrets (`secrets.env`)**:
    *   Hapus credentials hardcoded dari file `.env` yang dicommit.
    *   Masukkan file `.env` ke dalam `.gitignore` agar tidak terunggah ke repositori, dan gunakan environment variable sistem atau platform cloud.
