section .bss

section .data
; puts output strings
    greeting    db "Welcome to the x86 calculator!", 0
    getoptmsg   db "Pick an option [1-9]: ", 0
    errmsg      db "Input invalid! [1-9] only!", 0
    errcont     db "Press ENTER to continue...", 0
    setopt      db "1. Set the input", 0
    addopt      db "2. Add to input", 0
    subopt      db "3. Subtract from input", 0
    multopt     db "4. Multiply input", 0
    divopt      db "5. Divide input", 0
    modopt      db "6. Mod input", 0
    sinopt      db "7. Calculate sin of input", 0
    cosopt      db "8. Calculate cos of input", 0 
    tanopt      db "9. Calculate tan of input", 0
    
; printf fmt strings
    outputfmt   db "Current value: %.2f", 0Ah, 0

; scanf format strings
    getdblfmt   db "%lf", 0
    getintfmt   db "%i", 0
    getcharfmt  db "%c", 0
; misc C-string arguments
    clearscr    db "clear", 0

; double constants
    DBL_0_0     dq 0.0

section .text
; C imported functions from libc
    extern      printf
    extern      scanf
    extern      system
    extern      puts
    extern      read
    extern      STDIN_FILENO
    extern      atof

; Custom functions
    global      GetInput
    global      DisplayMenu

; Entry point
    global      main

; void __cdecl GetInput(unsigned int opt, double* arg1);
GetInput:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; If binary operation, display message and get input
    cmp         dword [ebp + 8], 6
    jbe         END
    push        getoptmsg  
    call        printf
    add         esp, 4
    push        dword [ebp + 0Ch]
    push        getintfmt
    call        scanf
    add         esp, 8

END:
    ; Epilogue
    pop         ebp
    ret

; int __cdecl DisplayMenu(double value)
DisplayMenu:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; C:    const char* options[9] =            dword [esp]             
    ;       { 
    ;           "1. Set the input",
    ;           "2. Add to input",
    ;           "3. Subtract from input",
    ;           "4. Multiply input",
    ;           "5. Divide input",
    ;           "6. Mod input",
    ;           "7. Calculate sin of input",
    ;           "8. Calculate cos of input",     
    ;           "9. Calculate tan of input",
    ;       };
    sub         esp, 24h 
    mov         eax, setopt
    mov         dword [esp], eax
    mov         eax, addopt
    mov         dword [esp + 4], eax 
    mov         eax, subopt 
    mov         dword [esp + 8], eax
    mov         eax, multopt 
    mov         dword [esp + 0Ch], eax 
    mov         eax, divopt 
    mov         dword [esp + 10h], eax 
    mov         eax, modopt
    mov         dword [esp + 14h], eax
    mov         eax, sinopt 
    mov         dword [esp + 18h], eax 
    mov         eax, cosopt 
    mov         dword [esp + 1Ch], eax
    mov         eax, tanopt 
    mov         dword [esp + 20h], eax 

VALID_INPUT_LOOP:
    ; Clear screen
    ; C:    system("clear");
    push        clearscr
    call        system
    add         esp, 4

    ; Greet User
    ; C:    puts("Welcome to x86 calculator!");
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

    ; Output current value
    ; C:    printf("Current result = %lf\n", value);
    sub         esp, 8h
    fld         qword [ebp + 8]
    fstp        qword [esp]
    push        outputfmt 
    call        printf
    add         esp, 0Ch

    ; Get user option choice
    ; C:    int tmp;
    ;       printf("Pick an option [1-9]: ");
    sub         esp, 4
    push        getoptmsg
    call        printf
    add         esp, 4
    ; C:    scanf("%i", &tmp);
    lea         eax, [esp]
    push        eax
    push        getintfmt
    call        scanf
    add         esp, 8
    pop         eax
    cmp         eax, 1
    jb          INVALID_INPUT
    cmp         eax, 9
    jbe         VALID_INPUT
INVALID_INPUT:
    ; Output error message. For some reason I need to use
    ; read to input the character as scanf is not blocking
    ; and only read is blocking like it should.
    ; C:    puts("Input invalid" [1-9] only!");
    ;       puts("Press ENTER to continue...");
    ;       read(STDIN_FILENO, &local_var, 1);
    push        errmsg
    call        puts
    push        errcont
    call        puts
    add         esp, 4
    push        1
    lea         eax, [esp]
    push        eax
    push        0
    call        read
    add         esp, 10h
    jmp         VALID_INPUT_LOOP

VALID_INPUT:
    ; Epilogue
    add         esp, 24h
    pop         ebp
    ret

; int main(int argc, const char** argv)
main:
    ; Set up stack frame
    push        ebp
    mov         ebp, esp

    ; C:    double input = 0.0;                 qword [ebp - 8]
    ;       double result = 0.0;                qword [ebp - 10h]
    ;       unsigned int menuChoice;            dword [ebp - 14h]
    sub         esp, 14h
    movsd       xmm0, qword [DBL_0_0]
    movsd       qword [ebp - 8], xmm0
    movsd       qword [ebp - 10h], xmm0

    ; C:    if (argc == 2)
    ;           result = atof(argv[1]);
    cmp         dword [ebp + 8], 2
    jne         NO_CMD_ARG       
    mov         eax, dword [ebp + 0Ch]
    push        dword [eax + 4]
    call        atof
    add         esp, 4
    fstp        qword [ebp - 10h]

    ; Show menu
    ; C:    DisplayMenu(result);
NO_CMD_ARG:
    sub         esp, 8
    fld         qword [ebp - 10h]
    fstp        qword [esp]
    call        DisplayMenu
    add         esp, 8
    mov         dword [esp], eax

    ; Get user input
    ; C:    GetInput(menuChoice, &input);
    lea         eax, [ebp - 8]
    push        eax
    push        dword [ebp - 14h]
    call        GetInput
    add         esp, 8

    ; Clean up stack frame and exit
    add         esp, 14h
    mov         eax, 0
    pop         ebp
    ret
