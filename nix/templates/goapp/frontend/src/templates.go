package main

import (
	"html/template"
	"strings"
)

var (
	templateFuncMap = template.FuncMap{
		"stringsJoin":      strings.Join,
		"stringsEqualFold": strings.EqualFold,
		"isStringInSlice":  isStringInSlice,
	}
)

type indexTplData struct {
	Title, Description, RawToken string

	Breadcrumbs []Breadcrumb
	NextLinks   []Link

	Error            string
	LoggedIn         bool
	Claims           tplClaims
	Groups           []string
	AuthorizeCodeURL string
}

type Link struct {
	Name   string
	Target string
}

type Breadcrumb struct {
	Main    Link
	Options []Link
}

type tplClaims struct {
	IDToken  Claims
	UserInfo Claims
}
