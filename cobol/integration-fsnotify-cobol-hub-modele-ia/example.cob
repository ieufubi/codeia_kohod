IDENTIFICATION DIVISION.
PROGRAM-ID. FSNOTIFY-INTEGRATOR.
ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INPUT-DATA ASSIGN TO 'input_data.dat'.
    SELECT OUTPUT-RESULT ASSIGN TO 'output_results.dat'.
DATA DIVISION.
FILE SECTION.
FD  INPUT-DATA.
01  IN-REC          PIC X(100).
FD  OUTPUT-RESULT.
01  OUT-REC         PIC X(100).
WORKING-STORAGE SECTION.
01  CMD-STRING       PIC X(200).
01  MODEL-NAME       PIC X(30) VALUE 'finance-model-v2'.
01  DATA-VAL         PIC X(50).
01  STATUS-CODE      PIC 99.
PROCEDURE DIVISION.
    OPEN INPUT INPUT-DATA.
    OPEN OUTPUT OUTPUT-RESULT.

    DISPLAY 'DÉBUT DU TRAITEMENT BATCH IA'.

    PERFORM UNTIL END-OF-FILE
        READ INPUT-DATA
            AT END SET END-OF-FILE TO TRUE
            NOT AT END
                MOVE IN-REC TO DATA-VAL
                
                * Construction de la commande pour le hub modèle IA
                STRING 'fsnotify-cli query --model ' MODEL-NAME 
                       ' --data "' DATA-VAL '"' 
                       DELIMITED BY SIZE INTO CMD-STRING
                
                DISPLAY 'EXÉCUTION : ' CMD-STRING
                
                * Appel au hub
                CALL 'SYSTEM' USING CMD-STRING
                
                * Simulation de capture de sortie
                MOVE IN-REC TO OUT-REC
                WRITE OUT-REC
                
                DISPLAY 'LIGNE TRAITÉE.'
        END-READ
    END-PERFORM.

    CLOSE INPUT-DATA.
    CLOSE OUTPUT-RESULT.
    DISPLAY 'TRAITEMENT TERMINÉ.'.
    STOP RUN.