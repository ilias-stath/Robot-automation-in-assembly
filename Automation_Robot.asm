;Ilias Stathakos 2017
;Orientation: 1-right, 2-up, 3-left, 4-down
;Rows 0-10(11 thesis), Columns 0-7(8 thesis) 
;Row1,8 ejw apo grid, Column1,11 ejw apo grid
;Panta prin apo entoli na eimais sgrs oti exv midenisei to command
;Path meaning: 0-outside, 1-Unknown, 2-Path, 3-PathThatWasWalked, 4-Lamp, 5-Wall
 
 
#start=robot.exe#

TITLE RobotNav
 
DATA SEGMENT
    Menu DB "Please place the robot to a place of your choosing and then select the orientation...",10,13,"$"
    OrChoice DB "Please type the orientation of the robot(1-right, 2-up, 3-left, 4-down):",10,13,"$"
    PlaceChoice DB 10,13,"Please type the start of the robot based on the number on the grid:",10,13,"$"
    PlaceMap DB "|00|01|02|03|04|05|06|07|08|",10,13,"|09|10|11|12|13|14|15|16|17|",10,13,"|18|19|20|21|22|23|24|25|26|",10,13,"|27|28|29|30|31|32|33|34|35|",10,13,"|36|37|38|39|40|41|42|43|44|",10,13,"|45|46|47|48|49|50|51|52|53|",10,13,"$"
    EndMessage DB 10,13,"THE GAME HAS ENDED!!!",10,13,"$"
    row DB 88 dup(1)
    orientation DB 0
    currentPlace DB 0
    pointer DB 0
    prevPlace DB 54 dup(0)
    moves DB 5 dup(0)
    object DB 0
    endGame DB 0
    PlaceToGo DB 0
    minPath DB 0
    movesPointer DB 0 
    currentPointer DB 0 
DATA ENDS

CODE SEGMENT
    START:
        MOV AX,DATA
        MOV DS,AX
        
        
        ;FOR MENU
        MOV AH,09h
        LEA DX,Menu
        INT 21h
        
        MOV AH,09h
        LEA DX,OrChoice
        INT 21h
        
        MOV AH,01
        INT 21h
        SUB AL,30h
        MOV orientation,AL
        
        MOV AH,09h
        LEA DX,PlaceChoice
        INT 21h
        
        MOV AH,09h
        LEA DX,PlaceMap
        INT 21h
        
        MOV AH,01
        INT 21h
        SUB AL,30h
        MOV CH,AL
        
        MOV AH,01
        INT 21h
        SUB AL,30h
        MOV CL,AL
        
        MOV AL,CH
        MOV CH,10
        MUL CH
        
        ADD AL,CL
        
        MOV currentPlace,AL
        
        CALL FindPlace
        
        MOV CX,11
        
        SetMapVer:
        
            MOV DI,CX
            DEC DI
            MOV row[DI],0
            ADD DI,77
            MOV row[DI],0
        
        LOOP SetMapVer
         
         
        MOV CX,8
        MOV DI,0
        
        SetMapHor:
        
            MOV row[DI],0
            ADD DI,10
            MOV row[DI],0
            INC DI   
        
        LOOP SetMapHor
        
        
        MOV AL,0 
        OUT 9,AL
        
        ;AUTO:
        CALL AUTOMATION
            
        
        MOV AH,09h
        LEA DX,EndMessage
        INT 21h
        
        MOV AH,4Ch
        INT 21h
        
        
    FindPlace PROC
        PUSHA
        
        MOV AL,currentPlace
        
        CMP AL,8
        JA row2
        
        ADD AL,12
        MOV currentPlace,AL
        JMP ExitPlace
        
      row2:
        CMP AL,17
        JA row3
        
        ADD AL,14
        MOV currentPlace,AL
        JMP ExitPlace
        
      row3:
        CMP AL,26
        JA row4
        
        ADD AL,16
        MOV currentPlace,AL
        JMP ExitPlace
        
      row4:
        CMP AL,35
        JA row5
        
        ADD AL,18
        MOV currentPlace,AL
        JMP ExitPlace
        
      row5:
        CMP AL,44
        JA row6
        
        ADD AL,20
        MOV currentPlace,AL
        JMP ExitPlace
        
      row6:
        ADD AL,22
        MOV currentPlace,AL    
        
         
      ExitPlace:
        POPA
        RET
    FindPlace ENDP
    
    check_ready PROC
        PUSHA
        againcheck:
            IN AL,11
            AND AL,00000010b
            
            CMP AL,2
            JE againcheck
        
        POPA    
        RET
    check_ready ENDP
    
    
    
    check_command_execution PROC
        PUSHA
        
        CALL check_ready
        IN AL,11
        AND AL,00000100b
        
        CMP AL,4
        JNE EXIT
        
        
        EXIT:       
        POPA    
        RET
    check_command_execution ENDP
    
    examine PROC
        PUSHA
        
        CALL check_ready
        MOV AL,4
        OUT 9,AL 
        
        CALL Delay 
        
        IN AL,10
        
        CMP AL,0
        JE nothing
        
        CMP AL,8
        JE offLamp
        
        
        MOV object,5
        JMP exitExamine
        
        nothing:
            MOV object,2
            JMP exitExamine
        
        offLamp:
            CALL check_ready
            MOV AL,5
            OUT 9,AL
            MOV object,4
            JMP exitExamine
            
            

      exitExamine:
        POPA
        RET
    examine ENDP
        
    AUTOMATION PROC
        PUSHA
        
      Repeat:
      
        CALL check_ready
        
        MOV AL,0
        OUT 9,AL
        
        CALL MAP
        CALL PathFind
        
        INC pointer
                    
        CMP endGame,1
        JNE Repeat
        
        
        POPA
        RET
    AUTOMATION ENDP
    
    MAP PROC
        PUSHA
        
        MOV DL,currentPlace
        MOV DH,0
        MOV DI,DX
        
        MOV row[DI],3 ;Bazw 3 sto meros pou brisketai gia na jerw oti exw perasei apo ekei
        
        CMP orientation,1
        JE continue
        
        CMP orientation,4
        JE FixDownOr
        
        MOV CL,orientation
        DEC CL
        MOV CH,0
        
        FixOrientation:   ;Ftiaxnei to orientation wste na koitaei panta dejia
            CALL check_ready
            
            MOV AL,0 
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,3
            OUT 9,AL
            
        LOOP FixOrientation
        
        JMP Continue
        
        FixDownOr:
            CALL check_ready
            MOV AL,0
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
        
        continue:
            MOV orientation,1
            
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            MOV DL,currentPlace
            MOV DH,0
            MOV DI,DX
            INC DI
            
            CMP row[DI],1    ;thesi mprosta
            JNE next1
            
            CALL check_ready
            
            ;CALL Delay
            
            CALL examine
            
            ;CALL Delay
            
            MOV CL,object
            MOV row[DI],CL
            
          next1:
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            MOV DL,currentPlace
            MOV DH,0
            MOV DI,DX
            SUB DI,11
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CMP row[DI],1  ;thesi panw
            JNE next2
            
            CALL check_ready
            
            ;CALL Delay
            
            CALL examine
            
            ;CALL Delay
            
            MOV CL,object
            MOV row[DI],CL
            
             
          next2:
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            MOV DL,currentPlace
            MOV DH,0
            MOV DI,DX
            DEC DI
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CMP row[DI],1  ; thesi pisw
            JNE next3
            
            CALL check_ready
            
            ;CALL Delay
            
            CALL examine
            
            ;CALL Delay
            
            MOV CL,object
            MOV row[DI],CL
            
            
          next3:
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            
            MOV DL,currentPlace
            MOV DH,0
            MOV DI,DX
            ADD DI,11
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CMP row[DI],1   ; thesi katw
            JNE exitMap
            
            CALL check_ready
            
            ;CALL Delay
            
            CALL examine
            
            ;CALL Delay
            
            MOV CL,object
            MOV row[DI],CL
            
            
           
      exitMap:
      
        CALL check_ready
            
        MOV AL,0
        OUT 9,AL
        
        CALL check_ready
        
        MOV AL,2            ; epistrofi sto na koitaei dejia
        OUT 9,AL
        
        CALL check_ready
        
        MOV AL,0
        OUT 9,AL
        
        
        POPA
        RET
    MAP ENDP
    
    PathFind PROC
        PUSHA
        
        MOV DX,0
        MOV DL,pointer
        MOV SI,DX
        
        MOV DL,currentPlace
        
        MOV prevPlace[SI],DL
        
        
        MOV BL,currentPlace
        MOV BH,0
        
        
        MOV DI,BX
        
        ;CHECK RIGHT
        ADD DI,1
        CMP row[DI],2
        JE RightMove
        
        ;CHECK LEFT
        SUB DI,2
        CMP row[DI],2
        JE LeftMove
        
        ;CHECK UP
        SUB DI,10
        CMP row[DI],2
        JE UpMove
        
        ;CHECK DOWN
        ADD DI,22
        CMP row[DI],2
        JE DownMove
            
        ;Find empty road after stuck
        CALL Algorythm
        
        JMP ExitPath
        
        RightMove:
            CALL check_ready
            
            MOV AL,1
            OUT 9,AL
            
            INC currentPlace
            
            MOV orientation,1
            
            JMP ExitPath
            
        LeftMove:
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,1
            OUT 9,AL
            
            DEC currentPlace
            
            MOV orientation,3
            
            JMP ExitPath
            
        UpMove:
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,1
            OUT 9,AL
            
            SUB currentPlace,11
            
            MOV orientation,2
            
            JMP ExitPath
            
        DownMove:
            CALL check_ready
            
            MOV AL,3
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,1
            OUT 9,AL
            
            ADD currentPlace,11
            
            MOV orientation,4
      
        
      ExitPath:
        CALL check_ready
        
        MOV AL,0
        OUT 9,AL
         
        POPA
        RET
    PathFind ENDP
    
    Algorythm PROC
        PUSHA
        
        ;The algorythm tries checks visited locations from before to see if the have an not visited road next to them
        ;Then it tries to find the shortest path to get there
        
        MOV DX,0
        MOV DL,pointer
        MOV SI,DX
        
      AgainFind:
        
        
        CMP SI,0
        JE END 
        
        DEC SI
        
        MOV BX,0
        MOV BL,prevPlace[SI]
        
        MOV DI,BX
        
        ;CALL Delay
        
        ;CHECK RIGHT
        INC DI
        CMP row[DI],2
        JE CheckRight
        
        ;CHECK LEFT
        SUB DI,2
        CMP row[DI],2
        JE CheckLeft
        
        ;CHECK UP
        SUB DI,10
        CMP row[DI],2
        JE CheckUp
        
        ;CHECK DOWN
        ADD DI,22
        CMP row[DI],2
        JE CheckDown
        
        
        JMP AgainFind
        
        ;CALL Delay
        
        CheckRight:
            MOV AX,DI
            MOV BH,AL
            
            MOV DI,0
            
            MOV moves[DI],1
            INC DI
            
            MOV moves[DI],1
            DEC DI
            
            JMP Path
            
        CheckLeft:
            MOV AX,DI
            MOV BH,AL
            
            MOV DI,0
            
            MOV moves[DI],1
            INC DI
            
            MOV moves[DI],2
            INC DI
            
            MOV moves[DI],2
            INC DI
            
            MOV moves[DI],3
            DEC DI
            
            JMP Path
            
        CheckUp:
            MOV AX,DI
            MOV BH,AL
            
            MOV DI,0
            
            MOV moves[DI],1
            INC DI
            
            MOV moves[DI],2
            INC DI
            
            MOV moves[DI],2
            DEC DI
            
            JMP Path
            
        CheckDown:
            MOV AX,DI
            MOV BH,AL
            
            MOV DI,0
            
            
            MOV moves[DI],1
            INC DI
            
            MOV moves[DI],3
            INC DI
            
            MOV moves[DI],4
            DEC DI
            
            
      
        
        Path:
            ;Store movesPointer
            MOV AX,DI
            MOV movesPointer,AL
            
            
            ;Move previous place to the next place
            DEC DX
            MOV DI,DX
            MOV AL,prevPlace[DI]
            MOV PlaceToGo,AL
            
            ;Calculate steps to reach target position
            INC DX
            SUB DX,SI
            MOV minPath,DL
            
            
            MOV CX,0
            MOV CL,pointer
            MOV currentPointer,CL
            
            DEC CX
            
          Loop1:
            
            MOV DI,0
            
             
            MOV CX,0
            MOV CL,currentPointer
            
            
            CMP minPath,0
            JE Continue2
             
            
            Loop2:
                MOV DX,0
                MOV DL,currentPlace
                
                ;CHECK RIGHT
                INC DL
                CMP DL,prevPlace[DI]
                JNE Left
                
                CMP DI,SI
                JA Above1
                
                MOV AX,SI
                SUB AX,DI
                
                CMP minPath,AL
                JB Left
                
                MOV minPath,AL
                MOV PlaceToGo,DL
                
                JMP Left
                
                Above1:
                    MOV AX,DI
                    SUB AX,SI
                    
                    CMP minPath,AL
                    JB Left
                    
                    MOV minPath,AL
                    MOV PlaceToGo,DL
                    
            
                ;CHECK LEFT
              Left:
                SUB DL,2
                CMP DL,prevPlace[DI]
                JNE Up
                
                CMP DI,SI
                JA Above2
                
                MOV AX,SI
                SUB AX,DI
                
                CMP minPath,AL
                JB Up
                
                MOV minPath,AL
                MOV PlaceToGo,DL
                
                JMP Up
                
                Above2:
                    MOV AX,DI
                    SUB AX,SI
                    
                    CMP minPath,AL
                    JB Up
                    
                    MOV minPath,AL
                    MOV PlaceToGo,DL
                
                ;CHECK UP
              Up:
                SUB DL,10
                CMP DL,prevPlace[DI]
                JNE Down
                
                CMP DI,SI
                JA Above3
                
                MOV AX,SI
                SUB AX,DI
                
                CMP minPath,AL
                JB Down
                
                MOV minPath,AL
                MOV PlaceToGo,DL
                
                JMP Down
                
                Above3:
                    MOV AX,DI
                    SUB AX,SI
                    
                    CMP minPath,AL
                    JB Down
                    
                    MOV minPath,AL
                    MOV PlaceToGo,DL
                
                ;CHECK DOWN
              Down:
                ADD DL,22
                CMP DL,prevPlace[DI]
                JNE NotSeen
                
                CMP DI,SI
                JA Above4
                
                MOV AX,SI
                SUB AX,DI
                
                CMP minPath,AL
                JB NotSeen
                
                MOV minPath,AL
                MOV PlaceToGo,DL
                
                JMP NotSeen
                
                Above4:
                    MOV AX,DI
                    SUB AX,SI
                    
                    CMP minPath,AL
                    JB NotSeen
                    
                    MOV minPath,AL
                    MOV PlaceToGo,DL
                    
                 
                NotSeen:
                    INC DI
                
            LOOP Loop2
            
            
            MOV CH,currentPlace
            MOV CL,PlaceToGo
            
            CMP CH,CL
            JB Below1
            
            MOV CL,currentPlace
            SUB CL,PlaceToGo
            
            CMP CL,11
            JE Up1
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,0
            OUT 9,AL
            
            CALL check_ready
            
            MOV AL,2
            OUT 9,AL
            
            MOV orientation,3
            
            
            JMP Continue1
            
            
            Up1:
                CALL check_ready
                
                MOV AL,2
                OUT 9,AL
                
                MOV orientation,2
                
            
                JMP Continue1
            
            Below1:
                MOV CL,PlaceToGo
                SUB CL,currentPlace
                
                CMP CL,11
                JE Down1
                 
                MOV orientation,1
                
                
                JMP Continue1 
                
                Down1:
                    CALL check_ready
                    
                    MOV AL,3
                    OUT 9,AL
                    
                    
                    MOV orientation,4
                    
                    
 
           
            
            Continue1:
            
                MOV CL,PlaceToGo
                MOV currentPlace,CL
                 
                CALL check_ready
            
                MOV AL,1
                OUT 9,AL
            
                CALL check_ready
            
                MOV AL,0
                OUT 9,AL
                
                CMP orientation,1
                JE ContinueLoop
                
                CMP orientation,4
                JE FixDownOr2 
            
                MOV CX,0
                MOV CL,orientation
                DEC CL
                
                FixOr2:
                    CALL check_ready
                    
                    MOV AL,3
                    OUT 9,AL
                    
                    CALL check_ready
                    
                    MOV AL,0
                    OUT 9,AL
                    
                LOOP FixOr2
                
                JMP ContinueLoop
                
                FixDownOr2:
                    CALL check_ready
                    
                    MOV AL,2
                    OUT 9,AL
                    
                    CALL check_ready
                    
                    MOV AL,0
                    OUT 9,AL
                    
                    
          ContinueLoop:
            CMP currentPointer,0
            JE END
            
            DEC currentPointer
            JMP Loop1
              
          Continue2:
            MOV CX,0
            MOV CL,movesPointer
            MOV DI,CX
            INC CX
            
            ;CALL Delay
                          
            FinalLoop:
                CALL check_ready
                
                MOV AL,moves[DI]
                OUT 9,AL
                
                CALL check_ready
                MOV AL,0
                OUT 9,AL
                
                DEC DI
                
                
            LOOP FinalLoop
            
            MOV CL,movesPointer
            INC CL
            MOV DI,CX
            
            MOV currentPlace,BH
            
            MOV CL,moves[DI]
            MOV orientation,CL
            
            CMP orientation,1
            JE almost
            
            CMP orientation,4
            JE FixDownOr3 
        
            MOV CX,0
            MOV CL,orientation
            DEC CL
            
            FixOr3:
                CALL check_ready
                
                MOV AL,3
                OUT 9,AL
                
                CALL check_ready
                
                MOV AL,0
                OUT 9,AL
                
            LOOP FixOr3
            
            JMP almost
            
            FixDownOr3:
                CALL check_ready
                
                MOV AL,2
                OUT 9,AL
                
                CALL check_ready
                
                MOV AL,0
                OUT 9,AL
            
          almost:
            MOV orientation,1
            
            MOV CX,0
            MOV CL,pointer
            SUB CX,SI
            MOV AX,SI
            MOV pointer,AL
            INC SI
            
            FixPrevPlaces:
                MOV prevPlace[SI],0
                INC SI
                
            LOOP FixPrevPlaces
                
                
            
            JMP AlgExit
      
      END:
        MOV endGame,1
        
      AlgExit:
        POPA
        RET
    Algorythm ENDP
    
    Delay PROC
        PUSHA
        
        MOV CX,10
        
        DelayLoop:
        
        Loop DelayLoop
        
        POPA
        RET
    Delay ENDP
    
CODE ENDS

SOROS SEGMENT STACK
    DB 256 dup(0)
SOROS ENDS 

END START
