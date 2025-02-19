package main

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/coreos/go-oidc/v3/oidc"
	"golang.org/x/oauth2"
)

func logInit() loggingMiddleware {
	log.Println("[i] Setting up logging...")
	logFile, err := os.OpenFile(options.LogFilePath, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0664)
	if err != nil {
		log.Fatal("Error opening the server.log file: ", err)
	}
	return loggingMiddleware{logFile}
}

func dbInit() {
	log.Println("[i] Setting up Global State Struct...")
	s, err := NewState()
	if err != nil {
		log.Fatal("Error creating the NewState(): ", err)
	}
	globalState = s
}

func sessionInit() {
	log.Println("[i] Setting up Session Storage...")
	store, err := NewSqliteStore(
		sessiondbPath,
		"sessions",
		"/",
		3600,
		[]byte(os.Getenv("SESSION_KEY")))
	if err != nil {
		panic(err)
	}
	globalState.sessions = store
}

func oauth2Init() (err error) {
	log.Println("[i] Setting up oauth2...")
	var redirectURL *url.URL
	if _, redirectURL, err = getURLs(options.PublicURL); err != nil {
		return fmt.Errorf("could not parse public url: %w", err)
	}

	log.Printf("[ ] provider_url: %s", options.Issuer)
	log.Printf("[ ] redirect_url: %s", redirectURL.String())

	if provider, err = oidc.NewProvider(context.Background(), options.Issuer); err != nil {
		log.Println("Error init oidc provider: ", err)
		return fmt.Errorf("error initializing oidc provider: %w", err)
	}

	verifier = provider.Verifier(&oidc.Config{ClientID: options.ClientID})
	log.Printf("[ ] ClientID: %s", options.ClientID)
	log.Printf("[ ] ClientSecret: %s", options.ClientSecret)
	log.Printf("[ ] redirectURL: %s", redirectURL.String())
	log.Printf("[ ] providerEndpoint: %+v", provider.Endpoint())
	log.Printf("[ ] Scopes: %s", options.Scopes)
	oauth2Config = oauth2.Config{
		ClientID:     options.ClientID,
		ClientSecret: options.ClientSecret,
		RedirectURL:  redirectURL.String(),
		Endpoint:     provider.Endpoint(),
		Scopes:       strings.Split(options.Scopes, ","),
	}
	return nil
}
