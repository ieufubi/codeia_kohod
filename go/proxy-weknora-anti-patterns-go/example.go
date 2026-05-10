package main

import (
	"context"
	"fmt"
	"io"
	"net"
	"time"
)

// ProxyServer gère le cycle de vie d'une connexion Proxy WeKnora
type ProxyServer struct {
	Addr string
}

func (p *ProxyServer) Start(ctx context.Context, targetAddr string) error {
	listener, err := net.Listen("tcp", p.Addr)
	if err != nil {
		return err
	}
	defer listener.Close()

	fmt.Printf("Proxy WeKnora démarré sur %s -> cible %s\n", p.Addr, targetAddr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			select {
			case <-ctx.Done():
				return nil
			default:
				fmt.Printf("Erreur Accept: %v\n", err)
				continue
			}
		}

		// On lance le relais dans une goroutine isolée
		go p.handleConnection(ctx, conn, targetAddr)
	}
}

func (p *ProxyServer) handleConnection(ctx context.Context, clientConn net.Conn, targetAddr string) {
	defer clientConn.Close()

	// Connexion vers la destination
	targetConn, err := net.DialTimeout("tcp", targetAddr, 5*time.Second)
	if err != nil {
		fmt.Printf("Impossible de joindre la cible: %v\n", err)
		return
	}
	defer targetConn.Close()

	// Utilisation de context pour la gestion de l'annulation
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	errChan := make(chan error, 2)

	// Transfert bidirectionnel
	go func() {
		_, err := io.Copy(targetConn, clientConn)
		errChan <- err
	}()

	go func() {
		_, err := io.Copy(clientConn, targetConn)
		errChan <- err
	}()

	// Attente de la fin ou de l'annulation
	select {
	case <-ctx.Done():
		fmt.Println("Connexion interrompue par le système")
	case err := <-errChan:
		if err != nil && err != io.EOF {
			fmt.Printf("Erreur de flux: %v\n", err)
		}
	}
}

func main() {
	server := &ProxyServer{Addr: ":9090"}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Simuler un démarrage de serveur
	err := server.Start(ctx, "google.com:80")
	if err != nil {
		fmt.Printf("Serveur arrêté: %v\n", err)
	}
}