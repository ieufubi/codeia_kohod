IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-SIMULATOR.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE ASSIGN TO 'INPUT.DAT'.
           SELECT OUTPUT-FILE ASSIGN TO 'OUTPUT.DAT'.
       DATA DIVISION.
       FILE SECTION.
       FD  INPUT-FILE.
       01  IN-REC PIC X(50).
       FD  OUTPUT-FILE.
       01  OUT-REC PIC X(50).
       WORKING-STORAGE SECTION.
       01  WS-EOF          PIC X VALUE 'N'.
       01  WS-COUNTER      PIC 9(05) VALUE 0.
       01  WS-DATA-LINE     PIC X(50).
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           OPEN INPUT INPUT-FILE.
           OPEN OUTPUT OUTPUT-FILE.
           DISPLAY "DÉMARRAGE DU TRAITEMENT BATCH".
           
           PERFORM UNTIL WS-EOF = 'Y'
               READ INPUT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-COUNTER
                       MOVE IN-REC TO WS-DATA-LINE
                       WRITE OUT-REC FROM WS-DATA-LINE
               END-READ
           END-PERFORM.
           
           DISPLAY "TRAITEMENT TERMINÉ".
           DISPLAY "NOMBRE DE LIGNES TRAITÉES : " WS-COUNTER.
           
           CLOSE INPUT-FILE.
           CLOSE OUTPUT-FILE.
           STOP RUN.