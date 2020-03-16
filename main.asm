section .bss
    stdinptr    resd 1
    stdoutptr   resd 1
    inputbuf    resb 16

section .data
; puts output strings
    greeting    db "Welcome to the x86 calculator!", 0
    greeting2   db "All trigonometric functions are in degrees!", 0
    getoperand  db "Enter second operand: ", 0
    getoptmsg   db "Pick an option between [1-12]: ", 0
    errmsg      db "Invalid input! Must be between [1-12]!", 0
    errmsg2     db "Invalid input! Must be a number!", 0
    errmsg3     db "You tried to divide by 0!", 0
    errcont     db "Press ENTER to continue...", 0
    setopt      db "Set the input", 0
    addopt      db "Add to input", 0
    subopt      db "Subtract from input", 0
    multopt     db "Multiply input", 0
    divopt      db "Divide input", 0
    modopt      db "Mod input", 0
    sinopt      db "Calculate sin of input", 0
    cosopt      db "Calculate cos of input", 0 
    tanopt      db "Calculate tan of input", 0
    sqrtopt     db "Calculate square root of input", 0
    logopt      db "Calculate logarithm (base 10) of input", 0
    exitopt     db "Exit program", 0
    
; printf fmt strings
    outputfmt   db "Current value: %.2f", 0Ah, 0
    optionfmt   db "%2i. %s", 0Ah, 0

; scanf format strings
    getdblfmt   db "%lf ", 0
    getintfmt   db "%i ", 0
    getcharfmt  db "%c ", 0

; misc C-string arguments
    clearscr    db "clear", 0
    pausescr    db "pause", 0
    rwmode      db "w+", 0

; double constants
    DBL_10_0    dq 10.0
    DBL_180_0   dq 180.0

section .text
; C imported functions from libc
    extern      printf
    extern      sscanf
    extern      system
    extern      puts
    extern      getchar
    extern      atof
    extern      stdin
    extern      fflush
    extern      fdopen
    extern      fprintf
    extern      fgets

; Custom functions
    global      GetInput
    global      DisplayMenu

; Entry point
    global      main

; bool __cdecl CheckForDivideByZero(double divisor)
CheckForDivideByZero:
    ; Preserve old stack frame and create a new one
    push        ebp
    mov         ebp, esp

    ; Check if divisor is zero
    fldz
    fld         qword [ebp + 8]
    fcompp
    fstsw       ax
    test        ax, 4000h
    jz          NO_DIVIDE_BY_ZERO
    push        errmsg3
    call        puts
    push        errcont
    call        puts
    add         esp, 8
    call        getchar
    mov         al, 1
    jmp         DIVIDE_BY_ZERO
NO_DIVIDE_BY_ZERO:
    mov         al, 0

DIVIDE_BY_ZERO:
    ; Restore old stack frame and return
    mov         esp, ebp
    pop         ebp
    ret

; double __cdecl DegreesToRadians(double degrees)
DegreesToRadians:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; Convert to radians (degrees * PI / 180)
    fldpi
    fld         qword [DBL_180_0]
    fdivp
    fld         qword [ebp + 8]
    fmulp

    ; Epilogue
    leave
    ret

; double __cdecl RadiansToDegrees(double radians)
RadiansToDegrees:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; Convert to degrees (radians * 180 / PI)
    fld         qword [DBL_180_0]
    fldpi
    fdivp
    fld         qword [ebp + 8]
    fmulp

    ; Epilogue
    leave
    ret

; void __cdecl GetInput(unsigned int opt, double* operand);
GetInput:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; If binary operation, display message and get input
    ; C:    if (opt <= 6)
    ;       {
    ;           printf("Enter second operand: ");
    ;           fgets(inputbuf, 16, *stdinptr);
    ;           sscanf(inputbuf, "%lf ", *operand);
    ;       }
    cmp         dword [ebp + 8], 6
    ja          END
VALID_INPUT_LOOP2:
    push        getoperand
    call        printf
    add         esp, 4
    push        dword [stdinptr]
    push        16
    push        inputbuf
    call        fgets
    add         esp, 0Ch
    push        dword [ebp + 0Ch]
    push        getdblfmt
    push        inputbuf
    call        sscanf
    add         esp, 0Ch
    cmp         eax, 1
    je          END
    push        errmsg2
    call        puts
    add         esp, 4
    jmp         VALID_INPUT_LOOP2
END:
    ; Epilogue
    mov         esp, ebp
    pop         ebp
    ret

; int __cdecl DisplayMenu(double value)
DisplayMenu:
    ; Prologue
    push        ebp
    mov         ebp, esp

    ; C:    const char* options[15] =          
    ;       { 
    ;           "Set the input",
    ;           "Add to input",
    ;           "Subtract from input",
    ;           "Multiply input",
    ;           "Divide input",
    ;           "Mod input",
    ;           "Calculate sin of input",
    ;           "Calculate cos of input",     
    ;           "Calculate tan of input",
    ;           "Calculate sqrt of input",
    ;           "Calculate logarithm of input",
    ;           "Exit program"
    ;       };
    sub         esp, 30h 
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
    mov         eax, sqrtopt 
    mov         dword [esp + 24h], eax
    mov         eax, logopt 
    mov         dword [esp + 28h], eax
    mov         eax, exitopt
    mov         dword [esp + 2Ch], eax

VALID_INPUT_LOOP:
    ; Clear screen
    ; C:    system("clear");
    push        clearscr
    call        system
    add         esp, 4

    ; Greet User
    ; C:    puts("Welcome to x86 calculator!");
    ;       puts("All trigonometric functions are in degrees!");
    push        greeting
    call        puts
    push        greeting2
    call        puts
    add         esp, 8

    ; Output options
    ; C:    for (int i = 0; i < 12; i++)
    ;           printf("%i %5s", i + 1, options[i]);
    mov         ecx, 0
OUTPUTOPTS:
    push        ecx
    push        dword [esp + 4 + ecx * 4]
    push        ecx
    add         dword [esp], 1 
    push        optionfmt
    call        printf
    add         esp, 0Ch
    pop         ecx
    inc         ecx
    cmp         ecx, 12
    jb          OUTPUTOPTS

    ; Output current value
    ; C:    printf("Current result = %lf\n", value);
    sub         esp, 8
    fld         qword [ebp + 8]
    fstp        qword [esp]
    push        outputfmt
    call        printf
    add         esp, 0Ch

    ; Get user option choice
    ; C:    int tmp;
    ;       printf("Pick an option [1-12]: ");
    ;       fgets(inputbuf, 16, *stdoutptr);
    ;       sscanf(inputbuf, "%i ", &tmp);
    sub         esp, 4
    push        getoptmsg
    call        printf
    add         esp, 4
    push        dword [stdoutptr]
    push        16
    push        inputbuf
    call        fgets
    add         esp, 0Ch
    lea         eax, [ebp - 34h]
    push        eax
    push        getintfmt
    push        inputbuf
    call        sscanf
    add         esp, 0Ch
    pop         eax
    cmp         eax, 1
    jb          INVALID_INPUT
    cmp         eax, 12
    jbe         VALID_INPUT
INVALID_INPUT:
    push        errmsg
    call        puts
    push        errcont
    call        puts
    add         esp, 8
    call        getchar
    jmp         VALID_INPUT_LOOP

VALID_INPUT:
    ; Epilogue
    mov         esp, ebp
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
    fldz
    fst         qword [ebp - 8]
    fstp        qword [ebp - 10h]

    ; Get location of standard stream buffers
    ; C:    *stdinptr  = fdopen( STDIN_FILENO, "w+");
    ;       *stdoutptr = fdopen(STDOUT_FILENO, "w+");
    push        rwmode
    push        0
    call        fdopen
    add         esp, 4
    mov         dword [stdinptr], eax
    push        1
    call        fdopen
    add         esp, 8
    mov         dword [stdoutptr], eax

    ; C:    if (argc == 2)
    ;           result = atof(argv[1]);
    cmp         dword [ebp + 8], 2
    jne         DISPLAYOPTS       
    mov         eax, dword [ebp + 0Ch]
    push        dword [eax + 4]
    call        atof
    add         esp, 4
    fstp        qword [ebp - 10h]

    ; Show menu
    ; C:    DisplayMenu(result);
DISPLAYOPTS:
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

    ; C:    if (menuChoice == 1)
    ;           result = input; 
    ;       else if (menuChoice == 2)
    ;           result += input;
    ;       else if (menuChoice == 3)
    ;           result -= input;
    ;       else if (menuChoice == 4)
    ;           result *= input;
    ;       else if (menuChoice == 5)
    ;           result /= input;
    ;       else if (menuChoice == 6)
    ;           result %= input;
    ;       else if (menuChoice == 7)
    ;           result = sin(result);
    ;       else if (menuChoice == 8)
    ;           result = cos(result);
    ;       else if (menuChoice == 9)
    ;           result = tan(result);
    ;       else if (menuChoice == 10)
    ;           result = sqrt(result);
    ;       else if (menuChoice == 11)
    ;           result = (1 / log2(10)) * log2(result)
    ;       else if (menuChoice == 12)
    ;           return 0;
    mov         eax, dword [ebp - 14h]
    cmp         eax, 1
    jne         ADD_OP
    movsd       xmm0, qword [ebp - 8]
    movsd       qword [ebp - 10h], xmm0
    jmp         DISPLAYOPTS
ADD_OP:
    cmp         eax, 2
    jne         SUB_OP
    fld         qword [ebp - 10h]
    fld         qword [ebp - 8]
    faddp
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
SUB_OP:
    cmp         eax, 3
    jne         MUL_OP
    fld         qword [ebp - 10h]
    fsub        qword [ebp - 8]
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
MUL_OP:
    cmp         eax, 4
    jne         DIV_OP
    fld         qword [ebp - 10h]
    fld         qword [ebp - 8]
    fmulp       ST1, ST0
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
DIV_OP:
    cmp         eax, 5
    jne         MOD_OP
    sub         esp, 8
    fld         qword [ebp - 8]
    fstp        qword [esp]
    call        CheckForDivideByZero
    add         esp, 8
    test        al, al
    jz          DIV_OK
    jmp         DISPLAYOPTS
DIV_OK:
    fld         qword [ebp - 10h]
    fdiv        qword [ebp - 8]
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
MOD_OP:
    cmp         eax, 6
    jne         SIN_OP
    sub         esp, 8
    fld         qword [ebp - 8]
    fstp        qword [esp]
    call        CheckForDivideByZero
    add         esp, 8
    test        al, al
    jz          MOD_OK
    jmp         DISPLAYOPTS
MOD_OK:
    fld         qword [ebp - 8]        
    fld         qword [ebp - 10h]
    fprem
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
SIN_OP:
    cmp         eax, 7
    jne         COS_OP
    sub         esp, 8   
    fld         qword [ebp - 10h]
    fstp        qword [esp]
    call        DegreesToRadians
    add         esp, 8
    fsin
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
COS_OP:
    cmp         eax, 8
    jne         TAN_OP
    sub         esp, 8
    fld         qword [ebp - 10h]
    fstp        qword [esp]
    call        DegreesToRadians
    add         esp, 8
    fcos
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
TAN_OP:
    cmp         eax, 9
    jne         SQRT_OP
    sub         esp, 8
    fld         qword [ebp - 10h]
    fstp        qword [esp]
    call        DegreesToRadians
    add         esp, 8
    fptan
    fstp        ST0
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
SQRT_OP:
    cmp         eax, 10
    jne         LOG10_OP
    fld         qword [ebp - 10h]
    fsqrt
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
LOG10_OP:
    cmp         eax, 11
    jne         EX_OP
    fld1
    fld         qword [DBL_10_0]
    fyl2x
    fld1
    fdiv        ST0, ST1
    fld1
    fld         qword [ebp - 10h]
    fyl2x
    fmulp
    fstp        qword [ebp - 10h]
    jmp         DISPLAYOPTS
    
EX_OP:
    ; Clean up stack frame and exit
    add         esp, 14h
    mov         eax, 0
    pop         ebp
    ret
