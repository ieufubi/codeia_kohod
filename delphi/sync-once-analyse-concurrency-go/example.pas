package main
import (
    "fmt"
    "sync"
    "time"
)

type GlobalResource struct {
    status string
}
var globalRes *GlobalResource 
var once sync.Once

func setupCriticalService() *GlobalResource {
    // Le mécanisme qui garantit l'exécution unique et visible.
    once.Do(func() {
        fmt.Println("[SETUP] Initialisation critique du service globale en cours...")
        time.Sleep(100 * time.Millisecond) // Simulation de charge lourde (DB, I/O)
        globalRes = &GlobalResource{status: "READY_V2"}
    })
    return globalRes
}

func main() {
    var wg sync.WaitGroup
    const count = 50 	// Test avec un nombre raisonnable de goroutines.
	
    fmt.Println("--- Début du test multi-goroutine ---")
    startTime := time.Now()

    for i := 1; i <= count; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            resource := setupCriticalService() 
            // Lecture du résultat garanti après le Do().
            fmt.Printf("Goroutine %d : Accès au service - Statut: %s\n", id, resource.status)
        }(i)
    }

    wg.Wait()
    duration := time.Since(startTime)
    // Le temps total devrait être proche de 100ms (le setup), pas 50 * N.
    fmt.Printf("\n===============================")
    fmt.Printf("\nToutes les opérations sont terminées en : %v", duration)
}