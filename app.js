const express = require('express');
const app = express();

app.get('/run', (req, res) => {
    const code = req.query.code;

    // 🔴 SANGAT BERBAHAYA: Menggunakan eval() untuk menjalankan input dari query string secara langsung.
    // Ini menimbulkan celah keamanan Remote Code Execution (RCE) yang akan dideteksi oleh Semgrep.
    const result = eval(code);

    res.send(`Hasil evaluasi: ${result}`);
});

app.listen(3000, () => console.log('Server berjalan di port 3000'));

// Uji coba jalankan kembali workflow

