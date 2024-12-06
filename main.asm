INCLUDE Irvine32.inc
INCLUDE Macros.inc

.data

filename BYTE "words.txt", 0
BUFSIZE DWORD 5000
buffer BYTE 5000 DUP(?)
word_array BYTE 100 DUP(?)
filehandle HANDLE ?
word_count DWORD 0

words BYTE "feqwr",0, "qelaw", 0
text BYTE "hello", 0
blank BYTE '     ', 0    
row BYTE 0    
word_lengths DWORD 100 DUP(0)
col_array BYTE 100 DUP(0)
row_array BYTE 100 DUP(0)
word_index BYTE 0
incorrect_char BYTE 0
correct_str BYTE 100 DUP(0)
correct_ind DWORD 0
input BYTE 100 DUP(0)


.code
main PROC

  mov edx, OFFSET filename
  call OpenInputFile
  mov filehandle, eax

   mov eax, filehandle
   mov edx, OFFSET buffer
   mov ecx, BUFSIZE
   call ReadFromFile

   mov esi, OFFSET buffer
   mov edi, OFFSET word_array
   mov ebx, 0
   mov word_count, 0
 
   GET_WORDS:
       mov al, [esi]
       cmp al, 0
       je DONE_GETTING

       cmp al, 0Ah
       je NEW_WORD

       mov [edi + ebx], al
       inc ebx
       inc esi
       jmp GET_WORDS

   NEW_WORD:

       mov BYTE PTR [edi + ebx], 0
       mov eax, word_count
       shl eax, 2
       mov [word_lengths + eax], ebx
       inc word_count
       add edi, ebx
       mov ebx, 0
       inc esi
       jmp GET_WORDS

   DONE_GETTING:
       call CloseFile

 call Randomize
    
 mov edi, OFFSET col_array 
 mov ecx, 1

 RANDOM_COL:
     mov eax, 105
     call RandomRange  
     add eax, 5
     mov [edi], al       
     add edi, 1          
     loop RANDOM_COL

mov esi, OFFSET text        
mov edi, OFFSET col_array   
mov row, 0    

GAME_LOOP:
                 
DISPLAY:

    mov dh, row
    mov dl, [edi]
    call Gotoxy

    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, esi
    call WriteString

    mov eax, 500
    call Delay

    mov dh, row
    mov dl, [edi]
    call Gotoxy
    mov edx, OFFSET blank
    call WriteString

    inc row

    mov eax, green + (black * 16)
    call SetTextColor
    mov edx, OFFSET correct_str
    call WriteString

    call ReadKey
    mov [input], al
    jz DISPLAY

    jmp COMPARISON      ; if there is input, go to comparison

COMPARISON:
    mov ebx, OFFSET correct_str
    mov edx, correct_ind

    cmp al, [esi]
    je CORRECT

    mov [incorrect_char], al
    mov eax, red + (black * 16)
    call SetTextColor
    mov al, [incorrect_char]
    call WriteChar

    jmp DISPLAY
    
    CORRECT:

    mov al, [esi]
    mov [ebx + edx], al

    inc correct_ind
    inc esi

    cmp BYTE PTR [esi], 0
    JE WIN

    jmp DISPLAY

WIN:
    exit

main ENDP

END main