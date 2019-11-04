%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .data
    

section .bss
    expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp

    GET_STRING expr, MAX_INPUT_SIZE
    
    xor ecx, ecx ;pozitia curenta in string
    xor esi, esi ;1-e negativ, 0-e pozitiv
    
general_loop:
    xor edx, edx
    ; se analizeaza fiecare caracter
    mov dl, byte[expr + ecx]
    
    ; ma aflu pe caracterul terminator?
    cmp dl, 0
    je exit
    
    ; este vorba despre un nr. negativ?
    cmp dl, '-'
    je is_neg?
    
    ; este vorba de un alt operator?
    cmp dl, '0'
    jb sign
    
    ; altfel este nr. pozitiv
    mov eax, edx
    ; obtin cifra din cod ASCII
    sub eax, '0'
    ; conditie nr. pozitiv
    xor esi, esi 
    jmp get_nr
    
is_neg?:
    inc ecx
    ; verific daca urmeaza cifra, spatiu sau terminator
    mov dl, byte[expr + ecx]
    cmp dl, ' '
    je sub_sign
    cmp dl, 0
    je sub_sign
    ; altfel e nr. negativ
    mov eax, edx
    ; obtin cifra din cod ASCII
    sub eax, '0'
    ; conditie nr. negativ
    mov esi, 1
    
    ; obtin restul nr. 
get_nr:
    inc ecx
    xor edx, edx
    mov dl, byte[expr + ecx]
    
    ; verific daca am terminat citirea nr.
    cmp dl, 0
    je add_sign
    cmp dl, ' '
    je add_sign
    
    ; altfel adaug noua cifra
    imul eax, 10
    sub edx, '0'
    add eax, edx
    jmp get_nr
add_sign:
    ; adaug semnul daca e necesar
    cmp esi, 1
    jne push_to_stack
    neg eax
    jmp push_to_stack 
    
sub_sign:
    ; scadere
    pop ebx
    pop eax
    sub eax, ebx
    jmp push_to_stack
    
sign: 
    ; celelalte semne
    ; incrementez pozitia
    inc ecx
    cmp dl, '+'
    je sum_sign
    cmp dl, '*'
    je mul_sign
    cmp dl, '/'
    je div_sign

sum_sign:
    ; adunare
    pop ebx
    pop eax
    add eax, ebx
    jmp push_to_stack
    
mul_sign:
    ; inmultire
    pop ebx
    pop eax
    imul ebx
    jmp push_to_stack

div_sign:
    ; impartire
    pop ebx
    pop edx
    xor eax, eax
    mov eax, edx
    ; extindem semnul si in edx
    cdq
    idiv ebx
    jmp push_to_stack
    
push_to_stack:
    ; adaugarea rezultatului in stiva
    push eax 
    ; verific daca ma aflu pe spatiu sau pe terminator
    xor edx, edx
    mov dl, byte[expr + ecx]
    cmp dl, ' '
    jne next
    ; daca sunt pe spatiu, incrementez pozitia
    inc ecx
next:
    jmp general_loop
       
exit:    
    ; afisez rezultatul
    pop eax
    PRINT_DEC 4, eax
    NEWLINE
    
    xor eax, eax
    pop ebp
    ret
