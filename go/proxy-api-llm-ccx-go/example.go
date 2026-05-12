package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
)

// CCXProxy structure le proxy unifié
type CCXProxy struct {
	Target *url.URL
}

func (p *CCXProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Seul le POST est supporté", http.StatusMethodNotAllowed)
		return
	}

	// Lecture et transformation du corps
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Erreur lecture corps", http.StatusBadRequest)
		return
	}

	var unified UnifiedRequest
	if err := json.Unmarshal(body, &unified); err != nil {
		http.Error(w, "JSON invalide", http.StatusBadRequest)
		return
	}

	// Simulation de transformation vers format Claude
	claudeReq := map[string]interface{}{
		"messages": []map[string]string{{"role": "user", "content": unified.Prompt}},
		"max_tokens": unified.MaxToken,
	}
	newBody, _ := json.Marshal(claudeReq)

	// Configuration du Reverse Proxy
	proxy := httputil.NewSingleHostReverseProxy(p.Target)
	proxy.Director = func(req *http.Request) {
		req.URL.Scheme = p.Target.Scheme
		req.URL.Host = p.Target.Host
		req.Host = p.Target.Host
		req.URL.Path = req.URL.Path
		req.Header.Set("Content-Type", "application/json")
		req.Body = io.NopCloser(bytes.NewBuffer(newBody))
		req.ContentLength = int64(len(newBody))
	}

	proxy.ServeHTTP(w, r)
}

func main() {
	target, _ := url.Parse("https://api.anthropic.com")
	proxy := &CCXProxy{Target: target}

	server := &http.Server{
		Addr:    ":8080",
		Handler: proxy,
	}

	log.Println("Proxy API LLM démarré sur :8080")
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}