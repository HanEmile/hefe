package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
)

var (
	host          string
	port          int
	logFilePath   string
	databasePath  string
	sessiondbPath string
	globalState   *State
)

func initFlags() {
	flag.StringVar(&host, "host", "127.0.0.1", "The host to listen on")
	flag.StringVar(&host, "h", "127.0.0.1", "The host to listen on (shorthand)")

	flag.IntVar(&port, "port", 8080, "The port to listen on")
	flag.IntVar(&port, "p", 8080, "The port to listen on (shorthand)")

	flag.StringVar(&logFilePath, "logfilepath", "./server.log", "The path to the log file")
	flag.StringVar(&databasePath, "databasepath", "./main.db", "The path to the main database")
	flag.StringVar(&sessiondbPath, "sessiondbpath", "./sessions.db", "The path to the session database")
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World from the frontend")
}

func main() {
	initFlags()
	flag.Parse()

	// log init
	log.Println("[i] Setting up logging...")
	logFile, err := os.OpenFile(logFilePath, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0664)
	if err != nil {
		log.Fatal("Error opening the server.log file: ", err)
	}
	logger := loggingMiddleware{logFile}

	// db init
	log.Println("[i] Setting up Global State Struct...")
	s, err := NewState()
	if err != nil {
		log.Fatal("Error creating the NewState(): ", err)
	}
	globalState = s

	// session init
	log.Println("[i] Setting up Session Storage...")
	store, err := NewSqliteStore(sessiondbPath, "sessions", "/", 3600, []byte(os.Getenv("SESSION_KEY")))
	if err != nil {
		panic(err)
	}
	globalState.sessions = store

	r := mux.NewRouter()
	r.Use(logger.Middleware)
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
