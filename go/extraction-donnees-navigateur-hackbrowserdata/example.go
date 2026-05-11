package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/base64"
	"fmt"
	"os"
)

// Ce programme simule la logique de HackBrowserData.
// Il démontre le décryptage d'une valeur chiffrée fictive.

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: go run main.go <base64_encrypted_blob>")
		return
	}

	encodedData := os.Args[1]
	encryptedData, err := base64.StdEncoding.DecodeString(encodedData)
	if err != nil {
		fmt.Printf("Erreur décodage Base64: %v\n", err)
		return
	}

	// Clé fictive (dans la réalité, elle vient de DPAPI)
	key := []byte("thisis32byteslongsecretkeyforaes") // 32 octets pour AES-256

	// Simulation d'un blob avec préfixe 'v10'
	// Format: v10 + nonce + ciphertext
	// Pour l'exemple, on part du principe que le blob est déjà pré-construit

	result, err := decryptSimulatedBlob(key, encryptedData)
	if err != nil {
		fmt.Printf("Erreur décryptage: %v\n", err)
		return
	}

	fmt.Printf("Donnée décryptée: %s\n", string(result))
}

func decryptSimulatedBlob(key, data []byte) ([]byte, error) {
	if len(data) < 3 {
		return nil, fmt.Errorf("blob trop court")
	}

	// On ignore le préfixe 'v10'
	payload := data[3:]

	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonceSize := gcm.NonceSize()
	if len(payload) < nonceSize {
		return nil, fmt.Errorf("nonce manquant")
	}

	nonce, ciphertext := payload[:nonceSize], payload[nonceSize:]
	return gcm.Open(nil, nonce, ciphertext, nil)
}