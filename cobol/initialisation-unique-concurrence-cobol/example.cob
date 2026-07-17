IDENTIFICATION DIVISION.
PROGRAM-ID TESTUNICE.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-INITIALIZED-FLAG PIC X(1) VALUE 'N'.
* Ce flag doit être protégé par un mécanisme de verrouillage système réel.*

PROCEDURE DIVISION.
MAIN-LOGIC.
    PERFORM CHECK-AND-INIT.
    DISPLAY 'Le programme s''est terminé avec succès. Constante: ' INITIALIZATION-CONSTANT$.
STOP RUN.

CHECK-AND-INIT.
*> Simule l'entrée dans une zone critique de ressources partagées.*
CALL ACQUIRE_GLOBAL_LOCK.* Simulation d'acquisition exclusive *.
IF WS-INITIALIZED-FLAG = 'N'.
    DISPLAY '--- EXÉCUTION DU BLOC CRITIQUE (Seulement si N) ---'.
    * Le calcul coûteux qui ne doit se faire qu'une fois. *
    CALL CALCULER_CONSTANTE(INITIALIZATION-CONSTANT).
    MOVE 'Y' TO WS-INITIALIZED-FLAG.
    DISPLAY '+++ Initialisation réussie et flag mis à Y. +++'.
ELSE
    DISPLAY '--- BLOC CRITIQUE IGNORÉ (Flag déjà Y) ---'.
END IF.
CALL RELEASE_GLOBAL_LOCK.* Libération systématique du verrou *.