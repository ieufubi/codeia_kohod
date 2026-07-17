package main

import (
	"context"
	fmt
	log
	sync"
	time"
)

type ExpensiveResource struct {
	ID string
}

var resource *ExpensiveResource
var once sync.Once
var initErr error // Variable pour stocker l'erreur globale de l'initialisation.

// Simule une initialisation qui peut échouer après un délai.
func initializeComplexResource(ctx context.Context) (*ExpensiveResource, error) {
    fmt.Println("-> Tentative d'acquisition des dépendances coûteuses...")
    select {
    case <-time.After(50 * time.Millisecond): // Simulation IO
        if ctx.Err() != nil { 
            return nil, fmt.Errorf("contexte annulé pendant l'init : %v", ctx.Err())}
        // Simule une vérification de credential qui pourrait échouer.
        if time.Now().Second()%3 == 0 { 
             return nil, fmt.Errorf("credentials invalides pour le service")
        }
        resource = &ExpensiveResource{ID: "XYZ-123"}
        fmt.Println("<- Initialisation réussie.")
        return resource, nil
    case <-ctx.Done():
        // Gestion du timeout/annulation externe
        return nil, ctx.Err()
    }
}

// GetResourceWrapper est le point d'accès unique et sûr pour la ressource globale.
func GetResourceWrapper(parentCtx context.Context) (*ExpensiveResource, error) {
    // Reset l'erreur au début de chaque appel (pour ne pas garder une erreur ancienne).
    var currentInitErr error

    once.Do(func() { 
        // On passe le contexte parent pour que la fonction coûteuse puisse réagir à son état.
        _, initErr = initializeComplexResource(parentCtx)
        if initErr != nil {
            currentInitErr = initErr // Capture l'erreur
        }
    })

    return resource, currentInitErr
}

func main() {
    // 1. Test avec un contexte valide (le succès est dépendant du temps système)
    ctxValid, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()

    fmt.Println("\n=== Tentative d'initialisation 1: Succès attendu ===")
    res1, err1 := GetResourceWrapper(ctxValid)
    if err1 != nil { 
        log.Printf("Échec de l'accès à la ressource : %v", err1) // Peut échouer si second() est divisible par 3.
    } else {
         fmt.Printf("Résultat OK. Resource ID: %s\n", res1.ID)
    }

    // 2. Test de contention (doit ne pas réinitialiser la ressource et doit retourner le même état).
    sync.WaitGroup{}
    var wg sync.WaitGroup
    for i := 0; i < 5; i++ {
        wg.Add(1)
        go func() { 
            defer wg.Done()
            fmt.Printf("Goroutine %d tente d'accéder à la ressource...", i)
            GetResourceWrapper(context.Background()) // Utilise un nouveau contexte pour simuler l'indépendance
        }()
    }
    wg.Wait() 

    // 3. Simuler une tentative de réinitialisation (mécaniquement impossible avec sync.Once, mais utile à savoir).
    fmt.Println("\n(Tentative théorique d'appel après l'init : le mécanisme garantit que seul le premier appel a servi.)")
}