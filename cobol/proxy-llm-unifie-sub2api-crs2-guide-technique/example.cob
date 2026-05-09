IDENTIFICATION DIVISION.
       PROGRAM-ID. PROXY-TEST-STANDALONE.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-STATUS          PIC X(20).
       01  WS-MODEL-NAME      PIC X(20) VALUE "gpt-4".
       01  WS-PROMPT          PIC X(50) VALUE "Test de connectivite Proxy LLM unifie.".
       01  WS-CURL-CMD        PIC X(500).
       01  WS-RESULT          PIC X(100).

       PROCEDURE DIVISION.
       000-START.
           DISPLAY "--- TESTER LE PROXY LLM UNIFIE ---"
           
           *> Simulation de construction de requête pour le relais
           STRING "curl -s -X POST http://localhost:8080/v1/chat/completions "
                  "-H 'Content-Type: application/json' "
                  "-d '{\"model\": \"" WS-MODEL-NAME "\", \"messages\": [{\"role\": \"user\", \"content\": \"" WS-PROMPT "\"}]}'"
                  DELIMITED BY SIZE INTO WS-CURL-CMD.

           DISPLAY "EXECUTION: " WS-CURL-CMD
           
           *> Appel au shell pour execution
           CALL "SYSTEM" USING WS-CURL-CMD.
           
           IF RETURN-CODE = 0
               DISPLAY "RESULTAT: SUCCESS"
           ELSE
               DISPLAY "RESULTAT: FAILURE (Check Sub2API-CRS2 service)"
           END-IF.

           STOP RUN.