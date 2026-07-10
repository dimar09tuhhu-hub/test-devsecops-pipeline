package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"
	_ "github.com/go-sql-driver/mysql"
)

func handler(w http.ResponseWriter, r *http.Request) {
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		dsn = "localhost/dbname"
	}
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer db.Close()

	username := r.URL.Query().Get("username")

	// ✅ AMAN: Menggunakan Parameterized Query untuk mencegah SQL Injection
	rows, err := db.Query("SELECT id, name FROM users WHERE username = ?", username)
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
