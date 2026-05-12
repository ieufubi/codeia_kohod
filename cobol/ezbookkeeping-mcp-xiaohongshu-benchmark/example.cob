IDENTIFICATION DIVISION.
       PROGRAM-ID. EZBOOKKEEPING-PROD.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANS-FILE ASSIGN TO 'transactions.dat'
           ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  TRANS-FILE.
       01  TRANS-RECORD.
           05  TR-ID            PIC 9(05).
           05  TR-AMOUNT        PIC 9(07)V99.
           05  TR-STATUS        PIC X(10).
       WORKING-STORAGE SECTION.
       01  WS-EOF              PIC X VALUE 'N'.
       01  WS-COUNTER          PIC 9(05) VALUE 0.
       PROCEDURE DIVISION.
           OPEN INPUT TRANS-FILE.
           IF NOT EXISTS TRANS-FILE
               DISPLAY "ERREUR: FICHIER MANQUANT"
               STOP RUN.
           
           PERFORM UNTIL WS-EOF = 'Y'
               READ TRANS-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-COUNTER
                       DISPLAY "PROCESSED: " TR-ID " AMT: " TR-AMOUNT
               END-READ
           END-PERFORM.
           
           DISPLAY "TOTAL RECORDS TRAITES: " WS-COUNTER.
           CLOSE TRANS-FILE.
           STOP RUN.