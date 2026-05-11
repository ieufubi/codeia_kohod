IDENTIFICATION DIVISION.
       PROGRAM-ID. SKILL-TEST-MASTER.
      * Programme de génération de cas de test pour le Framework pour agents
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-COUNTER          PIC 9(05) VALUE 0.
       01  WS-MAX-TESTS        PIC 9(05) VALUE 100.
       01  WS-GEN-RECORD.
           05  WS-ID            PIC 9(10).
           05  WS-DATE          PIC X(08).
           05  WS-AMOUNT        PIC 9(07)V99.
           05  WS-CURRENCY      PIC X(03).
           05  WS-STATUS        PIC X(01).

       PROCEDURE DIVISION.
       000-MAIN.
           OPEN OUTPUT TXN-FILE.
           PERFORM UNTIL WS-COUNTER >= WS-MAX-TESTS
               PERFORM 100-GENERATE-DATA
               WRITE TXN-RECORD
               ADD 1 TO WS-COUNTER
           END-PERFORM.
           CLOSE TXN-FILE.
           DISPLAY "TEST DATA GENERATION COMPLETE: " WS-COUNTER.
           STOP RUN.

       100-GENERATE-DATA.
           COMPUTE WS-ID = 1000 + WS-COUNTER.
           MOVE "20231027" TO WS-DATE.
           COMPUTE WS-AMOUNT = 100.00 + (WS-COUNTER * 1.5).
           MOVE "USD" TO WS-CURRENCY.
           MOVE "Y" TO WS-STATUS.