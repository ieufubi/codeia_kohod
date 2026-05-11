IDENTIFICATION DIVISION.
       PROGRAM-ID. CHAOS-AGENT-SIMULATOR.
       AUTHOR. COBOL-DEV-LINUXFR.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NODES.
           NODE CHAOS-CONTROLLER.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  AGENT-STATUS          PIC X(20) VALUE 'RUNNING'.
       01  INJECTED-LATENCY      PIC 9(4) VALUE 0.
       01  PACKET-LOSS-RATE      PIC 9(2) VALUE 0.
       01  ITERATION-COUNT       PIC 9(4) VALUE 0.
       01  MAX-ITERATIONS        PIC 9(4) VALUE 10.
       01  ERROR-FOUND           PIC X(01) VALUE 'N'.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "--- V2RAY CORE CHAOS AGENT SIMULATOR ---"
           PERFORM EXECUTE-CHAOS-STEP UNTIL ITERATION-COUNT >= MAX-ITERATIONS
               OR ERROR-FOUND = 'Y'.
           DISPLAY "--- SIMULATION FINISHED ---"
           DISPLAY "FINAL STATUS: " AGENT-STATUS
           DISPLAY "TOTAL STEPS: " ITERATION-COUNT
           STOP RUN.

       EXECUTE-CHAOS-STEP.
           ADD 1 TO ITERATION-COUNT.
           DISPLAY "STEP " ITERATION-COUNT ": TESTING NETWORK RESILIENCE..."
           
           *> Simulate random latency increase
           ADD 50 TO INJECTED-LATENCY.
           
           *> Simulate random packet loss
           IF ITERATION-COUNT > 5
               SET PACKET-LOSS-RATE TO 10
               DISPLAY "WARNING: HIGH PACKET LOSS DETECTED!"
           END-IF.

           *> Check for critical threshold (Simulated Crash)
           IF INJECTED-LATENCY > 400
               SET ERROR-FOUND TO 'Y'
               SET AGENT-STATUS TO 'CRASHED'
               DISPLAY "CRITICAL: LATENCY EXCEEDED THRESHOLD!"
           END-IF.

           DISPLAY "   CURRENT LATENCY: " INJECTED-LATENCY "MS"
           DISPLAY "   CURRENT LOSS:   " PACKET-LOSS-RATE "%"
           DISPLAY "------------------------------------------".