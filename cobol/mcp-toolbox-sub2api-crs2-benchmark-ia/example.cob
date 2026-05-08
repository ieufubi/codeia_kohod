IDENTIFICATION DIVISION.
PROGRAM-ID   BATCH_AI_JOB.
DATA DIVISION.
WORKING-STORAGE SECTION.
01 WS-BATCH-INPUT       PIC X(50).
01 WS-AI-RESULT         PIC X(1000).
01 WS-STATUS            PIC X(10).

PROCEDURE DIVISION.
MAIN-PROGRAM.
* Simulation d'un job batch qui appelle le mcp toolbox : Sub2API-CRS2.
MOVE 'Analyse des 500 enregistrements de facturation.' TO WS-BATCH-INPUT.

CALL 'HTTP_CLIENT_CALL' USING 'https://mcp-toolbox.com/sub2api-crs2/v1/batch', 'Bearer <TOKEN_MCP>', WS-BATCH-INPUT, WS-AI-RESULT.

IF WS-STATUS = 'SUCCESS'
  MOVE WS-AI-RESULT TO OUTPUT-DATA
ELSE
  MOVE 'Échec de l''appel au mcp toolbox : Sub2API-CRS2.' TO OUTPUT-DATA
END-IF.

STOP RUN.