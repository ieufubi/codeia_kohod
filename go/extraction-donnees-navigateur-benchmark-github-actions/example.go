package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os"
)

// Cette application démontre l'extraction et le décryptage
// d'un payload simulé pour l'extraction données navigateur.

type MockData struct {
	EncryptedKey string `json:"encrypted_key"`
	Payload      string `json:"payload"` // Base64 de l'AES-GCM
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run main.go <mock_json_file>")
		return
	}

	// Lecture du fichier de mock
	content, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Printf("Erreur lecture: %v\n", err)
		return
	}

	var mock MockData
	if err := json.Unmarshal(content, &mock); err != nil {
		fmt.Printf("Erreur JSON: %v\n", err)
		return
	}

	// Simulation de la clé maîtresse (déjà décryptée pour l'exemple)
	// Dans la réalité, il faut traiter le préfixe v10
	masterKey := []byte("0123456789abcdef0123456789abcdef") // 32 octets

	// Décodage du payload
	ciphertext, err := base64.StdEncoding.DecodeString(mock.Payload)
	if err != nil {
		fmt.Printf("Erreur Base64: %v\n", err)
		return
	}

	// Initialisation AES-GCM
	block, err := aes.NewCipher(masterKey)
	if err != nil {
		fmt.Printf("Erreur AES: %v\n", err)
		return
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		fmt.Printf("Erreur GCM: %v\n", err)
		return
	}

	// Séparation du nonce et du ciphertext
	nonceSize := gcm.NonceSize()
	if len(ciphertext) < nonceSize {
		fmt.Println("Payload invalide")
		return
	}

	nonce, actualCiphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]

	// Décryptage final
	plaintext, err := gcm.Open(nil, nonce, actualCiphertext, nil)
	if err != nil {
		fmt.Printf("Échec du décryptage: %v\n", err)
		return
	}

	fmt.Printf("Succès ! Donnée extraite: %s\n", string(plaintext))
}