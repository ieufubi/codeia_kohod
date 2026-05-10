IDENTIFICATION DIVISION.
       PROGRAM-ID. PROXY-RESILIENCE-DEMO.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  PROXY-CMD         PIC X(500).
       01  PROXY-URL         PIC X(50) VALUE "socks5://12    ".
       01  TARGET-URL        PIC X(50) VALUE "http://example.com".
       01  ITERATION         PIC 9(2) VALUE 0.
       01  MAX-RETRIES        PIC 9(2) VALUE 3.
       01  EXIT-FLAG         PIC X VALUE 'N'.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM UNTIL EXIT-FLAG = 'Y' OR ITERATION >= MAX-RETRIES
               ADD 1 TO ITERATION
               DISPLAY "Tentative " ITERATION " sur WeKnora : mieru proxy..."
               
               MOVE "curl -s -x " TO PROXY-CMD
               STRING PROXY-URL DELIMITED BY SIZE
                     " " DELIMITED BY SIZE
                     TARGET-URL DELIMITED BY SIZE
                     INTO PROXY-CMD
               
               CALL "SYSTEM" USING PROXY-CMD
               
               IF FUNCTION STATUS OF PROXY-CMD = 0
                   DISPLAY "Succes : Connexion etablie."
                   MOVE 'Y' TO EXIT-FLAG
               ELSE
                   DISPLAY "Echec de la tentative " ITERATION
               END-IF
           END-PERFORM.
           
           IF EXIT-FLAG = 'N'
               DISPLAY "ALERTE : Le tunnel WeKnora : mieru proxy est indisponible."
           END-IF.
           STOP RUN.