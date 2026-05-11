package main

import (
	"fmt"
	"time"
)

// ChaosEngine simule un moteur de chaos simplifié utilisant des principes de v2ray
type ChaosEngine struct {
	Latency    time.Duration
	PacketLoss float64 // 0.0 to 1.0
}

// ExecuteSimulatedRequest simule le passage d'une requête à travers le proxy
func (e *ChaosEngine) ExecuteSimulatedRequest(reqID int) error {
	// Simulation de perte de paquet
	if e.PacketLoss > 0.2 && (time.Now().UnixNano()%10 < int64(e.PacketLoss*10)) {
		return fmt.Errorf("REQ-%d: Packet dropped (Chaos Injection)", reqID)
	}

	// Simulation de latence
	if e.Latency > 0 {
		time.Sleep(e.Latency)
	}

	fmt.Printf("REQ-%d: Success after latency\n", reqID)
	return nil
}

func main() {
	engine := ChaosEngine{
		Latency:    100 * time.Millisecond,
		PacketLoss: 0.3, // 30% de perte
	}

	fmt.Println("Starting Chaos Experiment with v2ray-style logic...")

	for i := 1; i <= 10; i++ {
		err := engine.ExecuteSimulatedRequest(i)
		if err != nil {
			fmt.Printf("ERROR: %v\n", err)
		}
		time.Sleep(50 * time.Millisecond)
	}

	fmt.Println("Experiment finished.")
}