const express = require('express');
const app = express();

// AWS_ACCESS_KEY_ID dummy untuk memicu deteksi Gitleaks (Secrets Leak)
const FAKE_AWS_KEY = "AKIA3V2K7M5R9P1Q8S4T";
const FAKE_AWS_SECRET = "v1aBcD2eF3gHiJ4kLm5nOp6qRs7tU8vW9xYz0123";

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
