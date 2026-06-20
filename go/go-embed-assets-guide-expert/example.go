package main

import (
	"embed"
	fmt
)

// Ceci simule un dossier assets/templates contenant : 
// index.html (simple HTML) et greeting.tmpl.
//go:embed "./assets/templates/*"
var content embed.FS // Le compilateur inclut ici les données binaires des templates

type AssetHandler struct {
    fs embed.FS
}

func NewAssetHandler(fs embed.FS) *AssetHandler {
    return &AssetHandler{fs: fs}
}

// GetContent lit un asset spécifique du système de fichiers embarqué.
func (ah *AssetHandler) GetContent(path string) ([]byte, error) {
    if path == "nonexistent.txt" {
        return nil, fmt.Errorf("asset non trouvé dans l'embedding")
    }
    // Cette lecture est purement mémoire et ne dépend pas de syscall I/O.
    data, err := ah.fs.ReadFile(path)
    if err != nil { 
        return nil, fmt.Errorf("erreur de lecture embed: %w", err)}
    }
    return data, nil
}

func main() {
    // Simulation : On suppose que le dossier assets/templates existe et contient les fichiers.
    handler := NewAssetHandler(content)

    fmt.Println("--- Test 1: Chargement réussi ---")
    data, err := handler.GetContent("index.html")
    if err == nil {
        // Afficher un extrait pour prouver que le contenu est bien lu en mémoire.
        fmt.Printf("Assets chargés avec succès. Taille : %d octets.\n", len(data))
    }

    fmt.Println("
--- Test 2: Gestion d'erreur ---")
    _, err = handler.GetContent("nonexistent.txt")
    if err != nil {
        // Le message d'erreur provient de notre logique et non du système I/O.
        fmt.Printf("Gestion réussie de l'absence : %v\n", err)
    }
}