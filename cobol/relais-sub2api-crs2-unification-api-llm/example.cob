IDENTIFICATION DIVISION.
PROGRAM-ID. STANDALONE-LLM-CLIENT.
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
SPECIAL-MODE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-PROMPT        PIC X(50) VALUE "Analyze this COBOL code.".
01 WS-API-ENDPOINT  PIC X(50) VALUE "http://localhost:8080/v1/chat/completions".
01 WS-RESPONSE-BUF  PIC X(500).
01 WS-EXIT-CODE     PIC 9(4).
PROCEDURE DIVISION.
    DISPLAY "--- STARTING LLM CLIENT TEST ---".
    DISPLAY "TARGET ENDPOINT: " WS-API-ENDPOINT.
    
    * Construction de la commande curl pour le Relais Sub2API-CARES2
    DISPLAY "EXECUTING REQUEST..."
    STRING "curl -s -X POST " WS-API-ENDPOINT " -H 'Content-Type: application/json' -d '{\"messages\":[{\"role\":\"user\",\"content\":\"" WS-PROMPT "\"}]}'" 
           DELIMITED BY SIZE INTO WS-PROMPT.
    
    CALL "SYSTEM" USING WS-PROMPT.
    
    * Dans un vrai cas, on lirait la sortie vers WS-RESPONSE-BUF
    DISPLAY "--- TEST COMPLETED ---".
    STOP RUN.