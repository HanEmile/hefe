package main

import (
	"crypto/tls"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"time"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/gorilla/mux"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2"
)

var (
	host          string
	port          int
	databasePath  string
	logFilePath   string
	sessiondbPath string
	templatesPath string
	globalState   *State

	options      Options
	oauth2Config oauth2.Config
	provider     *oidc.Provider
	verifier     *oidc.IDTokenVerifier

	rawTokens = make(map[string]string)
	acURLs    = make(map[string]*url.URL)
)

func main() {

	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}

	rootCmd := &cobra.Command{Use: "goapp", RunE: root}

	rootCmd.Flags().StringVar(&options.Host, "host", "127.0.0.1", "Specifies the tcp host to listen on")
	rootCmd.Flags().IntVar(&options.Port, "port", 8080, "Specifies the port to listen on")
	rootCmd.Flags().StringVar(&options.PublicURL, "public-url", "http://localhost:8080/", "Specifies the root URL to generate the redirect URI")
	rootCmd.Flags().StringVar(&options.ClientID, "id", "", "Specifies the OpenID Connect Client ID")
	rootCmd.Flags().StringVarP(&options.ClientSecretPath, "oidc-secret-path", "s", "", "Specifies the OpenID Connect Client Secret path")
	rootCmd.Flags().StringVarP(&options.Issuer, "issuer", "i", "", "Specifies the URL for the OpenID Connect OP")
	rootCmd.Flags().StringVar(&options.Scopes, "scopes", "openid,profile,email,groups", "Specifies the OpenID Connect scopes to request")
	rootCmd.Flags().StringVar(&options.CookieName, "cookie-name", "oidc-client", "Specifies the storage cookie name to use")
	rootCmd.Flags().StringSliceVar(&options.Filters, "filters", []string{}, "If specified filters the specified text from html output (not json) out of the email addresses, display names, audience, etc")
	rootCmd.Flags().StringSliceVar(&options.GroupsFilter, "groups-filter", []string{}, "If specified only shows the groups in this list")
	rootCmd.Flags().StringVar(&options.LogFilePath, "logfilepath", "./server.log", "Specifies the path to store the server logs at")
	rootCmd.Flags().StringVar(&options.TemplatesPath, "templatespath", "./templates", "Specifies the path to where the templates are stored")
	rootCmd.Flags().StringVar(&options.DatabasePath, "databasepath", "./main.db", "Specifies the path to where the database is stored")
	rootCmd.Flags().StringVar(&options.SessionDBPath, "sessiondbpath", "./sessions.db", "Specifies the path to where the session database is stored")
	rootCmd.Flags().StringVar(&options.SessionKeyPath, "sessionkeypath", "", "Specifies the path to where the session key is stored")

	_ = rootCmd.MarkFlagRequired("id")
	_ = rootCmd.MarkFlagRequired("secret")
	_ = rootCmd.MarkFlagRequired("issuer")

	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func root(cmd *cobra.Command, args []string) (err error) {

	logger := logInit()
	oauth2Init()
	dbInit()
	sessionInit()

	r := mux.NewRouter()
	r.Use(logger.Middleware)
	r.HandleFunc("/", indexHandler)
	r.HandleFunc("/login", loginHandler)
	//  r.HandleFunc("/logout", )
	//  r.HandleFunc("/error", loginHandler)
	r.HandleFunc("/oauth2/callback", oauthCallbackHandler)
	//  r.HandleFunc("/json", loginHandler)
	//  r.HandleFunc("/jwt.json", loginHandler)

	// endpoints with auth needed
	auth_needed := r.PathPrefix("/").Subrouter()
	auth_needed.Use(authMiddleware)
	auth_needed.HandleFunc("/logout", logoutHandler)

	serverAddress := fmt.Sprintf("%s:%d", options.Host, options.Port)
	srv := &http.Server{
		Handler:      r,
		Addr:         serverAddress,
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	log.Printf("[i] Running the server on %s", serverAddress)
	log.Fatal(srv.ListenAndServe())
	return
}
