IDENTIFICATION DIVISION.
       PROGRAM-ID. MONITOR-TRAFFIC.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       FILE SECTION.
       FD  TRAFFIC-LOG.
       01  LOG-REC            PIC X(80).
       WORKING-STORAGE SECTION.
       01  WS-COUNTER         PIC 9(5) VALUE 0.
       01  WS-THRESHOLD       PIC 9(5) VALUE 100.
       01  WS-MSG             PIC X(50).
       PROCEDURE DIVISION.
           OPEN INPUT TRAFFIC-LOG.
           PERFORM UNTIL WS-COUNTER >= WS-THRESHOLD
               READ TRAFFIC-LOG
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       ADD 1 TO WS-COUNTER
                       DISPLAY "LOG LINE: " LOG-REC
                   END-READ
               END-READ
           END-PERFORM.
           IF WS-COUNTER < WS-THRESHOLD
               DISPLAY "AVERTISSEMENT: FIN DE FICHIER PREMATUREE"
           ELSE
               DISPLAY "TRAFFIC ANALYSE AVEC SUCCES."
           END-IF.
           CLOSE TRAFFIC-LOG.
           STOP RUN.