const express = require('express');
const app = express();

// AWS_ACCESS_KEY_ID dummy untuk memicu deteksi Gitleaks (Secrets Leak)
const FAKE_AWS_KEY = "AKIA1234567890ABCDEF";

app.get('/run', (req, res) => {
    const code = req.query.code;

    try {
        // MENGGUNAKAN eval() SECARA TIDAK AMAN untuk memicu deteksi Semgrep (Code Injection)
        const result = eval(code);
        res.json({ status: "success", result: result });
    } catch (error) {
        res.status(400).json({ status: "error", message: error.message });
    }
});

app.listen(3000, () => console.log('Server berjalan di port 3000'));
