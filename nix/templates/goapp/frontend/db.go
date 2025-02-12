package main

import (
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
)

const create string = `
CREATE TABLE IF NOT EXISTS users (
	id INTEGER NOT NULL PRIMARY KEY,
	created_at DATETIME NOT NULL,
	name TEXT,
	passwordHash TEXT
);
`

type State struct {
	db       *sql.DB      // the database storing the "business data"
	sessions *SqliteStore // the database storing sessions
}

func NewState() (*State, error) {
	db, err := sql.Open("sqlite3", databasePath)
	if err != nil {
		log.Println("Error opening the db: ", err)
		return nil, err
	}
	if _, err := db.Exec(create); err != nil {
		log.Println("Error creating the tables: ", err)
		return nil, err
	}
	return &State{
		db: db,
	}, nil
}
