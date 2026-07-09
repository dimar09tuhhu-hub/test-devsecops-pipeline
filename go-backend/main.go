package main

import (
	"database/sql"
	"fmt"
	"net/http"
	_ "github.com/go-sql-driver/mysql"
)

func handler(w http.ResponseWriter, r *http.Request) {
	db, err := sql.Open("mysql", "user:password@/dbname")
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer db.Close()

	username := r.URL.Query().Get("username")

	// 🔴 SANGAT BERBAHAYA: Menggabungkan input langsung (string concatenation) ke dalam query SQL.
	// Ini menimbulkan celah keamanan SQL Injection yang akan dideteksi oleh Semgrep.
	query := fmt.Sprintf("SELECT id, name FROM users WHERE username = '%s'", username)
	rows, err := db.Query(query)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	for rows.Next() {
		var id int
		var name string
		_ = rows.Scan(&id, &name)
		fmt.Fprintf(w, "User ID: %d, Name: %s\n", id, name)
	}
}

func main() {
	http.HandleFunc("/user", handler)
	fmt.Println("Server berjalan di port 8080...")
	_ = http.ListenAndServe(":8080", nil)
}
