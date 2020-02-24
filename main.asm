section .bss

section .data
; printf format strings
    ofmt        db "Enter a digit: ", 0

; misc C-string arguments
    clearscr    db "clear", 0
    greeting    db "Welcome to the x86 calculator!", 0
    getoptmsg   db "Pick an option [1-9]: ", 0
    errmsg      db "Input invalid! [1-9] only!", 0
    setopt      db "1. Set the input", 0
    sinopt      db "2. Calculate sin of input", 0
    cosopt      db "3. Calculate cos of input", 0 
    tanopt      db "4. Calculate tan of input", 0
    addopt      db "5. Add to input", 0
    subopt      db "6. Subtract from input", 0
    multopt     db "7. Multiply input", 0
    divopt      db "8. Divide input", 0
    modopt      db "9. Mod input", 0

; scanf format strings
    getinputfmt db "%lf", 0
    getoptfmt   db "%i", 0
    testfmt     db "%.2f, %.2f %i", 0Ah, 0

section .text
; C imported functions from libc
    extern      printf
    extern      scanf
    extern      system
    extern      puts

; Custom functions
    global      GetInput
    global      DisplayMenu

; Entry point
    global      main

; void __cdecl GetInput(double* arg1, double* arg2);
GetInput:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; Display message and get input
    mov         ecx, 0
PROMPTLOOP:
    push        ecx
    push        ofmt  
    call        printf
    add         esp, 4
    pop         ecx
    push        ecx
    push        dword [ebp + 8 + 4 * ecx]
    push        getinputfmt
    call        scanf
    add         esp, 8
    pop         ecx
    inc         ecx
    cmp         ecx, 2
    jb          PROMPTLOOP

    ; Epilogue
    pop         ebp
    ret

; int __cdecl DisplayMenu()
DisplayMenu:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; C: const char* options[9] = 
    ; { 
    ;   "1. Set the input",
    ;   "2. Calculate sin of input",
    ;   "3. Calculate cos of input",     
    ;   "4. Calculate tan of input",
    ;   "5. Add to input",
    ;   "6. Subtract from input",
    ;   "7. Multiply input",
    ;   "8. Divide input",
    ;   "9. Mod input"
    ; };
    sub         esp, 24h
    mov         eax, setopt 
    mov         dword [esp], eax
    mov         eax, sinopt
    mov         dword [esp + 4], eax 
    mov         eax, cosopt
    mov         dword [esp + 8], eax
    mov         eax, tanopt 
    mov         dword [esp + 0Ch], eax 
    mov         eax, addopt 
    mov         dword [esp + 10h], eax 
    mov         eax, subopt 
    mov         dword [esp + 14h], eax
    mov         eax, multopt
    mov         dword [esp + 18h], eax 
    mov         eax, divopt 
    mov         dword [esp + 1Ch], eax 
    mov         eax, modopt 
    mov         dword [esp + 20h], eax 

    ; Clear screen
    ; C: system("clear");
    push        clearscr
    call        system
    add         esp, 4

    ; Greet User
    ; C: printf("Welcome to x86 calculator!")
    push        greeting
    call        puts
    add         esp, 4

    ; Output options
    mov         ecx, 0
OUTPUTOPTS:
    push        ecx
    push        dword [esp + 4 + ecx * 4]
    call        puts
    add         esp, 4
    pop         ecx
    inc         ecx
    cmp         ecx, 9
    jb          OUTPUTOPTS
    
    ; Get user option choice
VALID_INPUT_LOOP:
    sub         esp, 4
    push        getoptmsg
    call        printf
    add         esp, 4
    lea         eax, [esp]
    push        eax
    push        getoptfmt
    call        scanf
    add         esp, 8
    pop         eax
    cmp         eax, 1
    jb          INVALID_INPUT
    cmp         eax, 9
    jbe         VALID_INPUT
INVALID_INPUT:
    push        errmsg
    call        puts
    add         esp, 4
    jmp         VALID_INPUT_LOOP

VALID_INPUT:
    ; Epilogue
    add         esp, 24h
    pop         ebp
    ret

; int main()
main:
    ; Set up stack frame
    push        ebp
    mov         ebp, esp
    ; C: double input[2];
    ;    int menuChoice;
    sub         esp, 14h

    ; Show menu
    ; C: DisplayMenu();
    call        DisplayMenu
    mov         dword [esp], eax

    ; Get user input
    ; C: GetInput(&input[0], &input[1]);
    lea         eax, [ebp - 8]
    push        eax
    lea         eax, [ebp - 10h]
    push        eax
    call        GetInput
    add         esp, 8

    ; Test Input
    ; C: printf("%lf, %lf %i\n", input[0], input[1], menuChoice);
    push        dword [ebp - 14h]
    sub         esp, 10h
    fld         qword [ebp - 8]
    fstp        qword [esp + 8]
    fld         qword [ebp - 10h]
    fstp        qword [esp]
    push        testfmt 
    call        printf
    add         esp, 18h

    ; Clean up stack frame and exit
    add         esp, 14h
    mov         eax, 0
    pop         ebp
    ret
