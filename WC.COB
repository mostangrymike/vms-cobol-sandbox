IDENTIFICATION DIVISION.
PROGRAM-ID. WC.
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
SPECIAL-NAMES.
    ARGUMENT-NUMBER IS POS-OF-COMMAND-LINE-ARGUMENT
    ARGUMENT-VALUE IS COMMAND-LINE-ARGUMENT.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INFILE ASSIGN TO "INFILE"
        ORGANIZATION IS SEQUENTIAL
        ACCESS MODE IS SEQUENTIAL
        FILE STATUS IS WS-STATUS.
DATA DIVISION.
FILE SECTION.
FD  INFILE
    VALUE OF ID IS WS-NAME
    RECORD IS VARYING IN SIZE FROM 0 TO 32765 CHARACTERS
    DEPENDING ON WS-RECLEN.
01  INREC                       PIC X(32765).
WORKING-STORAGE SECTION.
01  WS-CMD                      PIC X(1024) VALUE SPACES.
01  WS-CMD-POS                  PIC 9(5) COMP VALUE ZERO.
01  WS-ARGC                     PIC 9(5) COMP VALUE ZERO.
01  WS-ARG-DONE                 PIC X VALUE "N".
01  WS-TOKEN                    PIC X(255) VALUE SPACES.
01  WS-NAME                     PIC X(255) VALUE SPACES.
01  WS-STATUS                   PIC XX VALUE SPACES.
01  WS-RECLEN                   PIC 9(5) COMP VALUE ZERO.
01  WS-I                        PIC 9(5) COMP VALUE ZERO.
01  WS-J                        PIC 9(5) COMP VALUE ZERO.
01  WS-TOKLEN                   PIC 9(3) COMP VALUE ZERO.
01  WS-NAMELEN                  PIC 9(3) COMP VALUE ZERO.
01  WS-FILES                    PIC 9(9) COMP VALUE ZERO.
01  WS-INWORD                   PIC X VALUE "N".
01  WS-OPT-SEEN                 PIC X VALUE "N".
01  WS-LFLAG                    PIC X VALUE "Y".
01  WS-WFLAG                    PIC X VALUE "Y".
01  WS-CFLAG                    PIC X VALUE "Y".
01  WS-WITH-NAME                PIC X VALUE "N".
01  WS-LINES                    PIC 9(18) COMP-3 VALUE ZERO.
01  WS-WORDS                    PIC 9(18) COMP-3 VALUE ZERO.
01  WS-BYTES                    PIC 9(18) COMP-3 VALUE ZERO.
01  WS-TLINES                   PIC 9(18) COMP-3 VALUE ZERO.
01  WS-TWORDS                   PIC 9(18) COMP-3 VALUE ZERO.
01  WS-TBYTES                   PIC 9(18) COMP-3 VALUE ZERO.
01  OUT-LINES                   PIC Z(17)9.
01  OUT-WORDS                   PIC Z(17)9.
01  OUT-BYTES                   PIC Z(17)9.
PROCEDURE DIVISION.
MAIN.
    PERFORM UNTIL WS-ARG-DONE = "Y"
        MOVE SPACES TO WS-TOKEN
        ACCEPT WS-TOKEN FROM COMMAND-LINE-ARGUMENT
            ON EXCEPTION
                MOVE "Y" TO WS-ARG-DONE
            NOT ON EXCEPTION
                MOVE ZERO TO WS-TOKLEN
                PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 255
                    IF WS-TOKEN (WS-I:1) NOT = SPACE
                        MOVE WS-I TO WS-TOKLEN
                    END-IF
                END-PERFORM
                PERFORM HANDLE-TOKEN
        END-ACCEPT
    END-PERFORM
    IF WS-FILES = 0
        MOVE "SYS$INPUT" TO WS-NAME
        MOVE 9 TO WS-NAMELEN
        MOVE "N" TO WS-WITH-NAME
        PERFORM COUNT-FILE
    END-IF
    IF WS-FILES > 1
        MOVE WS-TLINES TO WS-LINES
        MOVE WS-TWORDS TO WS-WORDS
        MOVE WS-TBYTES TO WS-BYTES
        MOVE "N" TO WS-WITH-NAME
        PERFORM PRINT-COUNTS
    END-IF
    STOP RUN.
HANDLE-TOKEN.
    IF WS-TOKEN (1:1) = "-"
        IF WS-OPT-SEEN = "N"
            MOVE "Y" TO WS-OPT-SEEN
            MOVE "N" TO WS-LFLAG WS-WFLAG WS-CFLAG
        END-IF
        PERFORM VARYING WS-J FROM 2 BY 1
            UNTIL WS-J > WS-TOKLEN
            EVALUATE WS-TOKEN (WS-J:1)
                WHEN "l"
                    MOVE "Y" TO WS-LFLAG
                WHEN "w"
                    MOVE "Y" TO WS-WFLAG
                WHEN "c"
                    MOVE "Y" TO WS-CFLAG
            END-EVALUATE
        END-PERFORM
    ELSE
        ADD 1 TO WS-FILES
        MOVE WS-TOKEN TO WS-NAME
        MOVE WS-TOKLEN TO WS-NAMELEN
        MOVE "Y" TO WS-WITH-NAME
        PERFORM COUNT-FILE
    END-IF.
COUNT-FILE.
    MOVE ZERO TO WS-LINES WS-WORDS WS-BYTES
    MOVE "N" TO WS-INWORD
    OPEN INPUT INFILE
    IF WS-STATUS = "00"
        PERFORM UNTIL WS-STATUS = "10"
            READ INFILE
                AT END
                    CONTINUE
                NOT AT END
                    PERFORM COUNT-RECORD
            END-READ
        END-PERFORM
        CLOSE INFILE
        ADD WS-LINES TO WS-TLINES
        ADD WS-WORDS TO WS-TWORDS
        ADD WS-BYTES TO WS-TBYTES
        PERFORM PRINT-COUNTS
    ELSE
        DISPLAY "wc: cannot open " WS-NAME (1:WS-NAMELEN)
    END-IF.
COUNT-RECORD.
    ADD 1 TO WS-LINES
    ADD WS-RECLEN TO WS-BYTES
    ADD 1 TO WS-BYTES
    PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-RECLEN
        IF INREC (WS-J:1) = SPACE
            MOVE "N" TO WS-INWORD
        ELSE
            IF INREC (WS-J:1) = X"09"
                MOVE "N" TO WS-INWORD
            ELSE
                IF INREC (WS-J:1) = X"0B"
                    MOVE "N" TO WS-INWORD
                ELSE
                    IF INREC (WS-J:1) = X"0C"
                        MOVE "N" TO WS-INWORD
                    ELSE
                        IF INREC (WS-J:1) = X"0D"
                            MOVE "N" TO WS-INWORD
                        ELSE
                            IF WS-INWORD = "N"
                                ADD 1 TO WS-WORDS
                                MOVE "Y" TO WS-INWORD
                            END-IF
                        END-IF
                    END-IF
                END-IF
            END-IF
        END-IF
    END-PERFORM
    MOVE "N" TO WS-INWORD.
PRINT-COUNTS.
    MOVE WS-LINES TO OUT-LINES
    MOVE WS-WORDS TO OUT-WORDS
    MOVE WS-BYTES TO OUT-BYTES
    IF WS-LFLAG = "Y"
        DISPLAY OUT-LINES WITH NO ADVANCING
        DISPLAY SPACE WITH NO ADVANCING
    END-IF
    IF WS-WFLAG = "Y"
        DISPLAY OUT-WORDS WITH NO ADVANCING
        DISPLAY SPACE WITH NO ADVANCING
    END-IF
    IF WS-CFLAG = "Y"
        DISPLAY OUT-BYTES WITH NO ADVANCING
        DISPLAY SPACE WITH NO ADVANCING
    END-IF
    IF WS-WITH-NAME = "Y"
        DISPLAY WS-NAME (1:WS-NAMELEN)
    ELSE
        DISPLAY "total"
    END-IF.
