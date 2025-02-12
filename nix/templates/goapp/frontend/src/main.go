package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World from the frontend")
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/", indexHandler)

	srv := &http.Server{
		Handler:      r,
		Addr:         ":8080",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	log.Printf("[i] Running the server on %s", srv.Addr)
	log.Fatal(srv.ListenAndServe())
}
