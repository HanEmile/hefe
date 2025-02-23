package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"

	"github.com/coreos/go-oidc/v3/oidc"
	"github.com/gorilla/sessions"
	"golang.org/x/oauth2"
)

func indexHandler(w http.ResponseWriter, r *http.Request) {
	session, err := globalState.sessions.Get(r, options.CookieName)
	if err != nil {
		log.Println("error getting the session")
	}

	tpl := indexTplData{
		Error: r.FormValue("error"),
	}

	tpl.Breadcrumbs = []Breadcrumb{
		{
			Link{"a", "b"},
			[]Link{
				{"c", "d"},
				{"e", "f"},
			},
		},
		{
			Link{"g", "h"},
			[]Link{
				{"i", "j"},
				{"k", "l"},
			},
		},
	}

	//  session.Values["id_token"] = claimsIDToken
	//  session.Values["userinfo"] = claimsUserInfo
	//  session.Values["logged"] = true
	//
	log.Println("logged", session.Values["logged"])
	log.Println("id-token", session.Values["id_token"])
	log.Println("userinfo", session.Values["userinfo"])

	if logged, ok := session.Values["logged"].(bool); ok && logged {
		tpl.LoggedIn = true
		tpl.Claims.IDToken = session.Values["id_token"].(Claims)
		tpl.Claims.UserInfo = session.Values["userinfo"].(Claims)

		if len(options.GroupsFilter) >= 1 {
			for _, group := range tpl.Claims.UserInfo.Groups {
				if isStringInSlice(group, options.GroupsFilter) {
					tpl.Groups = append(tpl.Groups, filterText(group, options.Filters))
				}
			}
		} else {
			tpl.Groups = filterSliceOfText(tpl.Claims.UserInfo.Groups, options.Filters)
		}

		tpl.Claims.IDToken.PreferredUsername = filterText(tpl.Claims.IDToken.PreferredUsername, options.Filters)
		tpl.Claims.UserInfo.PreferredUsername = filterText(tpl.Claims.UserInfo.PreferredUsername, options.Filters)
		tpl.Claims.IDToken.Audience = filterSliceOfText(tpl.Claims.IDToken.Audience, options.Filters)
		tpl.Claims.UserInfo.Audience = filterSliceOfText(tpl.Claims.UserInfo.Audience, options.Filters)
		tpl.Claims.IDToken.Issuer = filterText(tpl.Claims.IDToken.Issuer, options.Filters)
		tpl.Claims.UserInfo.Issuer = filterText(tpl.Claims.UserInfo.Issuer, options.Filters)
		tpl.Claims.IDToken.Email = filterText(tpl.Claims.IDToken.Email, options.Filters)
		tpl.Claims.UserInfo.Email = filterText(tpl.Claims.UserInfo.Email, options.Filters)
		tpl.Claims.IDToken.Name = filterText(tpl.Claims.IDToken.Name, options.Filters)
		tpl.Claims.UserInfo.Name = filterText(tpl.Claims.UserInfo.Name, options.Filters)
		tpl.RawToken = rawTokens[tpl.Claims.IDToken.JWTIdentifier]
		tpl.AuthorizeCodeURL = acURLs[tpl.Claims.IDToken.JWTIdentifier].String()

		tpl.NextLinks = []Link{{"Logout", "/logout"}}
	} else {
		tpl.NextLinks = []Link{{"Login", "/login"}}
	}

	w.Header().Add("Content-Type", "text/html")

	// get the template
	t, err := template.New("index").Funcs(templateFuncMap).ParseGlob(fmt.Sprintf("%s/*.html", options.TemplatesPath))
	if err != nil {
		log.Printf("Error reading the template Path: %s/*.html", options.TemplatesPath)
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte("500 - Error reading template file"))
		return
	}

	// exec!
	err = t.ExecuteTemplate(w, "index", tpl)
	if err != nil {
		log.Println(err)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("[ ] Getting the global session from the session cookie:")
	session, err := globalState.sessions.Get(r, options.CookieName)
	if err != nil {
		log.Println("[ ] Error getting the cookie")
		writeErr(w, nil, "error getting cookie", http.StatusInternalServerError)
		return
	}

	log.Println("[ ] Setting the redirect URL")
	session.Values["redirect-url"] = "/"

	log.Println("[ ] Saving the session")
	if err = session.Save(r, w); err != nil {
		writeErr(w, err, "error saving session", http.StatusInternalServerError)
		return
	}

	log.Printf("[ ] Redirecting to %s", oauth2Config.AuthCodeURL("random-string"))
	http.Redirect(w, r, oauth2Config.AuthCodeURL("random-string-here"), http.StatusFound)
}

func logoutHandler(w http.ResponseWriter, r *http.Request) {
	session, err := globalState.sessions.Get(r, options.CookieName)
	if err != nil {
		writeErr(w, err, "error getting cookie", http.StatusInternalServerError)
		return
	}

	// wet the session
	session.Values = make(map[interface{}]interface{})

	if err = session.Save(r, w); err != nil {
		writeErr(w, err, "error saving session", http.StatusInternalServerError)
		return
	}

	http.Redirect(w, r, "/", http.StatusFound)
}

func oauthCallbackHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("hit the oauth callback handler")
	if r.FormValue("error") != "" {
		log.Printf("got an error from the idp: %s", r.FormValue("error"))
		http.Redirect(w, r, fmt.Sprintf("/error?%s", r.Form.Encode()), http.StatusFound)
		return
	}

	var (
		token      *oauth2.Token
		idToken    *oidc.IDToken
		err        error
		idTokenRaw string
		ok         bool
	)

	log.Println(r.URL)

	// The state should be checked here in production
	if token, err = oauth2Config.Exchange(
		r.Context(),
		r.URL.Query().Get("code"),
		//  oauth2.SetAuthURLParam("client_id", oauth2Config.ClientID),
		//  oauth2.SetAuthURLParam("client_secret", oauth2Config.ClientSecret),
	); err != nil {
		log.Println("Unable to exchange authorization code for tokens")
		log.Println(err)
		writeErr(w, err, "unable to exchange authorization code for tokens", http.StatusInternalServerError)
		return
	}

	// Extract the ID Token from OAuth2 token.
	if idTokenRaw, ok = token.Extra("id_token").(string); !ok {
		log.Println("missing id token")
		writeErr(w, nil, "missing id token", http.StatusInternalServerError)
		return
	}

	// Parse and verify ID Token payload.
	if idToken, err = verifier.Verify(r.Context(), idTokenRaw); err != nil {
		log.Printf("unable to verify id token or token is invalid: %+v", idTokenRaw)
		writeErr(w, err, "unable to verify id token or token is invalid", http.StatusInternalServerError)
		return
	}

	// Extract custom claims
	claimsIDToken := Claims{}

	if err = idToken.Claims(&claimsIDToken); err != nil {
		log.Printf("unable to decode id token claims: %+v", &claimsIDToken)
		writeErr(w, err, "unable to decode id token claims", http.StatusInternalServerError)
		return
	}

	var userinfo *oidc.UserInfo

	if userinfo, err = provider.UserInfo(r.Context(), oauth2.StaticTokenSource(token)); err != nil {
		log.Printf("unable to retreive userinfo claims")
		writeErr(w, err, "unable to retrieve userinfo claims", http.StatusInternalServerError)
		return
	}

	claimsUserInfo := Claims{}

	if err = userinfo.Claims(&claimsUserInfo); err != nil {
		log.Printf("unable to decode userinfo claims")
		writeErr(w, err, "unable to decode userinfo claims", http.StatusInternalServerError)
		return
	}

	var session *sessions.Session

	if session, err = globalState.sessions.Get(r, options.CookieName); err != nil {
		log.Printf("unable to get session from cookie")
		writeErr(w, err, "unable to get session from cookie", http.StatusInternalServerError)
		return
	}

	session.Values["id_token"] = claimsIDToken
	session.Values["userinfo"] = claimsUserInfo
	session.Values["logged"] = true
	rawTokens[claimsIDToken.JWTIdentifier] = idTokenRaw
	acURLs[claimsIDToken.JWTIdentifier] = r.URL

	if err = session.Save(r, w); err != nil {
		log.Printf("unable to save session")
		writeErr(w, err, "unable to save session", http.StatusInternalServerError)
		return
	}

	var redirectUrl string

	if redirectUrl, ok = session.Values["redirect-url"].(string); ok {
		log.Printf("all fine!")
		http.Redirect(w, r, redirectUrl, http.StatusFound)
		return
	}

	http.Redirect(w, r, "/", http.StatusFound)
}

func writeErr(w http.ResponseWriter, err error, msg string, statusCode int) {
	switch {
	case err == nil:
		log.Println(msg)
		http.Error(w, msg, statusCode)
	default:
		log.Println(msg)
		log.Println(err)
		http.Error(w, fmt.Errorf("%s: %w", msg, err).Error(), statusCode)
	}
}
