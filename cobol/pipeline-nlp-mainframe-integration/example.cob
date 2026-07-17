IDENTIFICATION DIVISION.
PROGRAM-ID NLPPROC_BATCH.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-INPUT-FILE    PIC X(256).
01 WS-OUTPUT-STATUS PIC XX.

*> Simulation des données entrantes (fichier plat contenant les notes client)
77 FILE INPUT RECORD DEFINITION.
VALUE "Le service est inacceptable et j'exige un remboursement immédiat." TO WS-INPUT-FILE.

PROCEDURE DIVISION.
MAIN-START.
* Simule la lecture d'un bloc de données (Batch job).
PERFORM READ-RECORD UNTIL EOF.
QUIT.