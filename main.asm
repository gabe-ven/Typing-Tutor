INCLUDE Irvine32.inc
INCLUDE Macros.inc
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD

.data

;============================
;   FILE STUFF
;============================
filename BYTE "words.txt", 0
BUFSIZE DWORD 5000
buffer BYTE 5000 DUP(?)
word_array DWORD 100 DUP(?)
word_lengths DWORD 100 DUP(?)
filehandle HANDLE ?
word_count DWORD 0

;===============================
;   MENU STUFF
;===============================
menuTitle BYTE "Typing Test Menu", 0
menuOption1 BYTE "1. Basic Typing Game", 0
menuOption2 BYTE "2. Falling Typing Game", 0
menuOption3 BYTE "3. Show Statistics", 0
menuOption4 BYTE "4. Exit Program", 0
menuPrompt BYTE "Choose an option: ", 0
invalidOption BYTE "Invalid option. Try again.", 0
noStats BYTE "No statistics to be shown!", 0

;===================================
;        MAIN STUFF
;===================================
text BYTE "The sun sets behind the mountains, painting the sky orange.", 0,
            "The cat chased a mouse through the tall, grassy field.", 0,
            "The early bird catches the worm, but the night owl enjoys the quiet of the dark.", 0
text_lengths DWORD 60, 115
text_index DWORD 0
words BYTE "flask", 0, "brake", 0, "quilt", 0, "beach", 0, "pizza", 0, "apple", 0, "tiger", 0, "chair", 0, "dance", 0, "lemon", 0, "water", 0, "music", 0, 
"stone", 0, "grape", 0, "chair", 0, "plane", 0, "house", 0

blank BYTE '       ', 0   
outMessage BYTE "Press esc to continue.", 0
startMessage BYTE "Press any key to begin typing test.", 0
row BYTE 0               
col_array BYTE 100 DUP(0)  
row_array BYTE 100 DUP(0)  
word_index DWORD 0        
incorrect_char BYTE 0     
correct_str BYTE 100 DUP(0)
correct_ind DWORD 0        
input BYTE 100 DUP(0)     

;=========================
;   SCORE STUFF
;=========================
correctWords DWORD 0
correctChars DWORD 0
totalChars DWORD 0
accuracy DWORD 0
wpm DWORD 0
highestAccuracy DWORD 0
highestWpm DWORD 0
accuracyMessage BYTE "Accuracy: ", 0
wpmMessage BYTE "WPM: ", 0
highestAccuracyMessage BYTE "Highest Accuracy: ", 0
highestWpmMessage BYTE "Highest WPM: ", 0
msec DWORD 0

.code
main PROC

call Randomize              
call LoadFromFile                       ; load words from file 
call RandomCols                         ; get random columns
call InitRows                           ; initalize positions

call MainMenu                           ; start 

exit
main ENDP

;======================
; Main menu
;======================
MainMenu PROC

MENU:                                       ; main menu
    mov dh, 0
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuTitle
    call WriteString
    call Crlf

    mov dh, 1
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuOption1
    call WriteString
    call Crlf

    mov dh, 2
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuOption2
    call WriteString
    call Crlf

    mov dh, 3
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuOption3
    call WriteString
    call Crlf

    mov dh, 4
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuOption4
    call WriteString
    call Crlf

    mov dh, 5
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET menuPrompt
    call WriteString
    call ReadChar 

    cmp al, '1'
    je START_BASIC

    cmp al, '2'
    je START_FALLING

    cmp al, '3' 
    je SHOW_STATISTICS

    cmp al, '4' 
    je EXIT_PROGRAM

    mov dh, 5
    mov dl, 50
    call Gotoxy

    call Crlf
    mov dh, 6
    mov dl, 50
    call Gotoxy

    mov edx, OFFSET invalidOption
    call WriteString
    jmp MENU

START_BASIC:
    call Clrscr                   
    mov edx, OFFSET startMessage  
    call WriteString               
    call Crlf                    
    call ReadChar                               ; read any key
    call GetMseconds                            ; starting time    
    mov msec, eax
    call Clrscr                    
    call BasicGame 
    ret
START_FALLING:
    call Clrscr                   
    mov edx, OFFSET startMessage  
    call WriteString               
    call Crlf                    
    call ReadChar                               ; read any key
    call GetMseconds                            ; starting time
    mov msec, eax
    call Clrscr                    
    call FallingGame 
    ret
SHOW_STATISTICS:
    call Score
    ret
EXIT_PROGRAM:
    exit
MainMenu ENDP

; BASIC MAIN
;======================
BasicGame PROC
    mov totalChars, 0
    mov correctChars, 0
    mov correctWords, 0
    mov text_index, 0

    mov esi, OFFSET text

    PLAY:
    mov eax, text_index
    mov ebx, OFFSET text_lengths        
    mov ecx, [ebx + eax * 4]       
    mov edx, esi                        ; text based on index
    call WriteString

    mov dh, 0                           ; set position to start
    mov dl, 0
    call Gotoxy

    mov edi, OFFSET input 

TYPING_LOOP:

    call ReadChar
    jz TYPING_LOOP                      ; keep reading char if no input
    
    cmp al, 8                           ; delete key
    je BACKSPACE

    cmp al, ' '                         ; space key
    je SPACE

    cmp al, 27                          ; esc key
    je SHOW_SCORE

    mov [edi], al                       ; move typed key into input
    mov al, [esi]                       

    cmp al, [edi]                       
    je CORRECT      

    jne INCORRECT

BACKSPACE:
    cmp edi, OFFSET input
    jz TYPING_LOOP

    dec dl                              ; go back one for everything
    mGotoxy dl, dh

    dec edi                             ; decrement both input buffer and actual text
    dec esi

    mov eax, white + (black * 16)                          
    call SetTextColor
    mov al, [esi]
    call WriteChar
   
    mGotoxy dl, dh
  
    jmp TYPING_LOOP  

SPACE: 
    mov al, [esi]                 
    cmp al, ' '                         
    je VALID_SPACE                  
    jmp TYPING_LOOP                  

VALID_SPACE:                            ; check if actually a space there
    mov [edi], al   
    
    inc dl
    mGotoxy dl, dh

    inc edi                        
    inc esi    

    inc totalChars                     ; need for stats
    inc correctChars
    inc correctWords      

    jmp TYPING_LOOP
    
CORRECT:
    inc correctChars
    inc totalChars

    mov eax, green + (black * 16)                          
    call SetTextColor
    mov al, [esi]         
    call WriteChar

    inc dl

    inc edi                 
    inc esi                 

    cmp BYTE PTR [esi], 0   
    je FINISH
    jmp TYPING_LOOP

INCORRECT:
    inc totalChars

    mov eax, red + (black * 16)             
    call SetTextColor
    mov al, [edi]          
    call WriteChar

    inc dl

    inc edi
    inc esi

    jmp TYPING_LOOP

FINISH:
    Call Clrscr
    mov eax, white + (black * 16)                          
    call SetTextColor
    inc text_index
    mov esi, OFFSET text
    
    add esi, ecx
    cmp text_index, 3                       ; keep playing until all text blocks are completed
    jl Play

    SHOW_SCORE:

    call GetMseconds                        ; get the time elapsed
    sub eax, msec
    mov msec, eax
    call Score
    ret
BasicGame ENDP
;=======================
;  FALLING MAIN
;=======================
FallingGame PROC

mov ecx, word_count        
mov word_index, 0           
mov row, 0
mov totalChars, 0
mov correctChars, 0
mov correctWords, 0
GAME_LOOP:
    mov eax, word_index
    cmp eax, word_count
    jge GAME_END

    mov esi, OFFSET words
    mov edi, OFFSET col_array

    mov eax, word_index
    imul eax, 6                          ; move to next word
    add esi, eax  
    
    mov edi, OFFSET col_array
    add edi, word_index                  ; move to next col by adding index

    DISPLAY:
    call CurrentWord

    call ReadKey                       ; wait for user input
    mov [input], al  
    jz DISPLAY

    call CompareWords 
    
    cmp BYTE PTR [esi], 0   
    je NEXT

    jmp DISPLAY             

NEXT:    
    sub row, 9                          ; move back spaces if word was correct
    cmp row, 0
    jge VALID_ROW                       ; make sure it doesn't go below row 0
    mov row, 0
VALID_ROW:
    inc word_index                      ; move to next word
    jmp GAME_LOOP
       
loop GAME_LOOP

GAME_END:
    call GetMseconds                    ; get end time
    sub eax, msec
    mov msec, eax
    call Score
    ret
FallingGame ENDP

;===========================
; Display word
;===========================
DisplayWord PROC
    mov dh, row     
    mov dl, [edi]     
    call Gotoxy
    mov edx, OFFSET words            
    call WriteString
DisplayWord ENDP

;===========================
; Track current word
;===========================
CurrentWord PROC

    cmp row, 30                             ; end if row pasts 30
    je OUT_OF_BOUNDS

    mov dh, row     
    mov dl, [edi]     
    call Gotoxy

    mov eax, white + (black * 16) 
    call SetTextColor
    mov eax, word_index                     
    imul eax, 6                            ; add based on index for next word
    mov edx, OFFSET words 
    add edx, eax             
    call WriteString

    mov dh, row     
    mov dl, [edi]     
    call Gotoxy

    mov eax, green + (black * 16) 
    call SetTextColor
    mWriteString OFFSET correct_str

    mov eax, red + (black * 16) 
    call SetTextColor
    mov al, [incorrect_char]
    call WriteChar

    call BlankSpaces

    inc row
   
    ret

OUT_OF_BOUNDS:
    call GetMseconds                                ; end time
    sub eax, msec
    mov msec, eax
    call Score                                      ; show score
    exit

CurrentWord ENDP

;========================
; Blank spaces over word
;========================

BlankSpaces PROC

    mov eax, 120                                    ; create delay between blanks
    call Delay

    mov dh, row
    mov dl, [edi]
    call Gotoxy

    mov edx, OFFSET blank
    call WriteString

    ret
BlankSpaces ENDP


;===========================================
; Compare the letter typed against the word
;===========================================
CompareWords PROC
    mov ebx, OFFSET correct_str
    mov edx, correct_ind

    cmp al, 27                                          ; esc key
    je CALL_SCORE                                       ; go to score immediately

    cmp al, [esi]       
    je CORRECT             
    jne INCORRECT         

CORRECT:
    mov [incorrect_char], 0
    mov [ebx + edx], al

    inc correct_ind
    inc correctChars
    inc totalChars

    inc esi
   
    cmp BYTE PTR [esi], 0
    je WORD_COMPLETE
    ret

INCORRECT:
    inc totalChars
    mov [incorrect_char], al 
    ret

WORD_COMPLETE:

    inc correctWords
    mov edi, OFFSET correct_str
    mov eax, 100
    mov ecx, 0 
 
RESET:
    mov BYTE PTR [ebx + ecx], 0 
    inc ecx
    cmp ecx, eax
    jl RESET

    mov correct_ind, 0 

    ret

CALL_SCORE:
    call GetMseconds
    sub eax, msec
    mov msec, eax
    call Score
    ret
CompareWords ENDP

;========================
;Generate random columns
;========================
RandomCols PROC

mov edi, OFFSET col_array
mov ecx, word_count
    
RANDOM_COL:
    mov eax, 100
    call RandomRange
    mov [edi], al
    inc edi
    loop RANDOM_COL

RandomCols ENDP

;==========================
;   Position of each word
;==========================
InitRows PROC
    mov ecx, word_count       
    mov eax, 0          
    
INIT_LOOP:
    mov [row_array + eax], 0    
    inc eax                    
    loop INIT_LOOP              

    ret
InitRows ENDP

;======================
; Load words from file
;======================
LoadFromFile PROC
mov edx, OFFSET filename                            ; load filename
call OpenInputFile                                  ; open file
mov filehandle, eax                                 ; move filehandle
    
mov eax, filehandle
mov edx, OFFSET buffer                              ; move buffer
mov ecx, BUFSIZE                                    ; mov bufsize
call ReadFromFile
mov ecx, eax

call CloseFile

mov esi, OFFSET buffer
mov edi, OFFSET word_array
mov ebx, OFFSET word_lengths
mov ecx, 0
mov edx, 0
mov word_count, 0

GET_WORDS:
    mov al, [esi]                                   ; load letter
    inc esi                                         ; move to next letter

    cmp al, 0Ah                                     ; check if newline
    je END_WORD

    cmp al, 0                                       ; check if null terminator
    je END_WORD

    mov [edi + ecx], al                             ; move letter into word array
    inc ecx
    inc edx
    jmp GET_WORDS

END_WORD:                                           ; marks a word
    cmp ecx, 0
    je SKIP_WORD
    mov BYTE PTR [edi + ecx], 0
 
    mov eax, word_count
    mov [ebx + eax * 4], edx                        ; store length
    
    inc word_count                                  ; increase word amount

    mov ecx, 0

SKIP_WORD:
    cmp BYTE PTR [esi], 0
    je DONE
    jmp GET_WORDS

DONE:

    ret
LoadFromFile ENDP

;=========================
; Calculate and show score
;=========================
Score PROC
    call Clrscr
        
    mov eax, white + (black * 16)
    call SetTextColor

    mov edx, OFFSET accuracyMessage
    call WriteString

    mov eax, totalChars
    cmp eax, 0                     
    je NO_ACCURACY               

    mov eax, correctChars       ; (# of correct keys * 100) / (total keys pressed)
    imul eax, 100
    mov ebx, totalChars
    cdq
    idiv ebx

    mov [accuracy], eax
    mov eax, [accuracy]
    call WriteDec
    call Crlf

    mov eax, [accuracy]
    cmp eax, [highestAccuracy]
    jle SKIP_HIGHEST_ACCURACY
    mov [highestAccuracy], eax

SKIP_HIGHEST_ACCURACY:


WPM_CALCULATION:
    mov edx, OFFSET wpmMessage
    call WriteString

    mov eax, correctWords           ; (time passed / # of correct words)
    imul eax, 60000              
    mov ebx, msec                  
    cdq                           
    idiv ebx  
    
    mov [wpm], eax
    mov eax, [wpm]
    call WriteDec
    call Crlf

    mov eax, [wpm]
    cmp eax, [highestWpm]
    jle SKIP_HIGHEST_WPM
    mov [highestWpm], eax

SKIP_HIGHEST_WPM:

    mov edx, OFFSET highestAccuracyMessage
    call WriteString
    mov eax, [highestAccuracy]
    call WriteDec
    call Crlf

    mov edx, OFFSET highestWpmMessage
    call WriteString
    mov eax, [highestWpm]
    call WriteDec
    call Crlf

    mov edx, OFFSET outMessage
    call WriteString

    WAIT_FOR_ESC:
        call ReadChar
        cmp al, 27
        jne WAIT_FOR_ESC

    call Clrscr
    call MainMenu

 NO_ACCURACY:
    mov edx, OFFSET accuracyMessage
    call WriteString

    call Crlf
    jmp WPM_CALCULATION

    ret
Score ENDP

END main
