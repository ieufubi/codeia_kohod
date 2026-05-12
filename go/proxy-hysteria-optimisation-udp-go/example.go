package main

import (
	"context"
	"fmt"
	"net"
	"sync"
	"time"
)

// HighPerformanceUDP struct encapsule la logique du Proxy Hysteria
type HighPerformanceUDP struct {
	conn       *net.UDPConn
	bufferPool *sync.Pool
	workerSem  chan struct{}
}

func NewServer(addr string, maxWorkers int) (*HighPerformanceUDP, error) {
	udpAddr, err := net.ResolveUDPAddr("udp", addr)
	if err != nil {
		return nil, err
	}

	conn, err := net.ListenUDP("udp", udpAddr)
	if err != nil {
		return nil, err
	}

	return &HighPerformanceUDP{
		conn: conn,
		bufferPool: &sync.Pool{
			New: func() any {
				return make([]byte, 2048)
			},
		},
		workerSem: make(chan struct{}, maxWorkers),
	}, nil
}

func (s *HighPerformanceUDP) Start(ctx context.Context) {
	fmt.Println("Serveur Proxy Hysteria démarré...")
	for {
		select {
		case <-ctx.Done():
			return
		default:
			buf := s.bufferPool.Get().([]byte)
			n, remoteAddr, err := s.conn.ReadFromUDP(buf)
			if err != nil {
				continue
			}

			// Gestion de la charge via semaphore
			select {
			case s.workerSem <- struct{}{}:
				go s.process(buf, n, remoteAddr)
			default:
				// Si trop de workers, on drop le paquet et on rend le buffer
				s.bufferPool.Put(buf)
					fmt.Println("Drop: Charge trop élevée")
			}
		}
\	}
}

func (s *HighPerformanceUDP) process(buf []byte, n int, addr *net.UDPAddr) {
	defer func() {
		s<-s.workerSem
		s.bufferPool.Put(buf)
	}()

	// Simulation de traitement intense
	time.Sleep(10 * time.Millisecond)
	fmt.Printf("Traité %d octets de %s\n", n, addr.String())
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	server, err := NewServer(":8080", 5)
	if err != nil {
		panic(err)
\	}

	server.Start(ctx)
}