const express = require('express');
const app = express();

// Fungsi evaluator matematika sederhana yang aman tanpa eval() / Function()
function safeEval(expr) {
    if (!expr) return 0;
    // Hanya izinkan angka, operator dasar (+, -, *, /), titik, dan spasi
    if (!/^[0-9+\-*/.\s]+$/.test(expr)) {
        throw new Error("Input tidak aman! Hanya mendukung angka dan operator dasar (+, -, *, /)");
    }
    
    let str = expr.replace(/\s+/g, '');
    
    // Selesaikan operasi perkalian & pembagian terlebih dahulu
    const mulDiv = /\d+\.?\d*[\*/]\d+\.?\d*/;
    while (mulDiv.test(str)) {
        str = str.replace(mulDiv, (match) => {
            const parts = match.match(/(\d+\.?\d*)([\*/])(\d+\.?\d*)/);
            const num1 = parseFloat(parts[1]);
            const op = parts[2];
            const num2 = parseFloat(parts[3]);
            return op === '*' ? num1 * num2 : num1 / num2;
        });
    }
    
    // Selesaikan operasi penjumlahan & pengurangan
    const addSub = /(-?\d+\.?\d*)([\+-])(\d+\.?\d*)/;
    while (addSub.test(str)) {
        str = str.replace(addSub, (match) => {
            const parts = match.match(/(-?\d+\.?\d*)([\+-])(\d+\.?\d*)/);
            const num1 = parseFloat(parts[1]);
            const op = parts[2];
            const num2 = parseFloat(parts[3]);
            return op === '+' ? num1 + num2 : num1 - num2;
        });
    }
    
    const finalResult = parseFloat(str);
    if (isNaN(finalResult)) {
        throw new Error("Format ekspresi matematika tidak valid.");
    }
    return finalResult;
}

app.get('/run', (req, res) => {
    const code = req.query.code;

    try {
        const result = safeEval(code);
        res.json({ status: "success", result: result });
    } catch (error) {
        res.status(400).json({ status: "error", message: error.message });
    }
});


app.listen(3000, () => console.log('Server berjalan di port 3000'));

// Uji coba jalankan kembali workflow

