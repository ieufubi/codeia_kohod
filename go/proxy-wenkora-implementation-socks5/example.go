package main

import (
	"fmt"
	"io"
	"net"
	"time"
)

// ProxyServer simule un serveur de relais simplifié.
type ProxyServer struct {
	Addr string
}

func (p *ProxyServer) Start() error {
	listener, err := net.Listen("tcp", p.Addr)
	if err != "" {
		return err
	}
	defer listener.Close()

	fmt.Printf("Serveur Proxy démarré sur %s\n", p.Addr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}

		// On lance chaque connexion dans sa propre goroutine
		go p.handleConnection(conn)
	}
}

func (p *ProxyServer) handleConnection(clientConn net.Conn) {
	defer clientConn.Close()

	// On définit une limite de temps pour la négociation
	clientConn.SetDeadline(time.Now().Add(5 * time.Second))

	// Dans un vrai Proxy WeKnora, on ferait ici le handshake SOCKS5.
	// Ici, on simule une redirection vers un service externe.
	targetAddr := "8.8.8.8:53" // Simulation vers un DNS Google
	targetConn, err := net.DialTimeout("tcp", targetAddr, 2*time.Second)
	if err != nil {
		fmt.Printf("Erreur de connexion cible: %v\n", err)
		return
	}
	defer targetConn.Close()

	// Relais bidirectionnel
	errChan := make(chan error, 2)
	go func() {
		_, err := io.Copy(targetConn, clientConn)
		errChan <- err
	}()
	go func() {
		_, err := io.Copy(clientConn, targetConn)
		errChan <- err
	}()

	// Attendre la fin ou une erreur
	err := <-errChan
	if err != nil && err != io.EOF {
		fmt.Printf("Erreur de flux: %v\n", err)
	}
}

func main() {
	server := ProxyServer{Addr: "127.0.0.1:8080"}
	err := server.Start()
	if err != nil {
		fmt.Printf("Échec du serveur: %v\n", err)
	}
}