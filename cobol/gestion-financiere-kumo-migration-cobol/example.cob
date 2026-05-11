IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANSACTION-PROCESSOR.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TX-FILE ASSIGN TO "transactions.dat"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  TX-FILE.
       01  TX-RECORD.
           05 TX-ID          PIC 9(05).
           05 TX-AMOUNT      PIC 9(05)V99.
           05 TX-DATE        PIC 9(08).

       WORKING-STORAGE SECTION.
       01  WS-EOF            PIC X VALUE 'N'.
       01  WS-TOTAL-AMT      PIC 9(12)V99 VALUE 0.
       01  WS-COUNT          PIC 9(05) VALUE 0.

       PROCEDURE DIVISION.
           OPEN READ TX-FILE.
           IF WS-EOF = 'N'
               PERFORM UNTIL WS-EOF = 'Y'
                   READ TX-FILE
                       AT END MOVE 'Y' TO WS-EOF
                       NOT AT END
                           ADD TX-AMOUNT TO WS-TOTAL-AMT
                           ADD 1 TO WS-COUNT
                   END-READ
               END-PERFORM
           END-IF.
           
           DISPLAY "--- REPORT ---"
           DISPLAY "TRANSACTIONS PROCESSED: " WS-COUNT
           DISPLAY "TOTAL AMOUNT: " WS-TOTAL-AMT
           DISPLAY "---------------"
           CLOSE TX-FILE.
           STOP RUN.