	AREA interrupts, CODE, READWRITE
	EXPORT lab6
	EXPORT FIQ_Handler
	EXPORT compare_digit
	IMPORT output_string
	IMPORT pin_connect_block_setup_for_gpio
	IMPORT pin_connect_block_setup_for_uart0
	IMPORT uart_init
	IMPORT display_digit_on_7_seg
	IMPORT output_character
	IMPORT input_character
	IMPORT multiplication
	
prompt = "Lab #6 Working with Timers\n\rEnter 4 hexadecimal numbers and press enter\n\r",0
exitmsg = "\n\rTerminating program...\n\r",0

QUIT_PROMPT EQU 0x40000F04


TIMER0 EQU 0xE0004008
TICKS_PER_MS EQU 1843200
T0TCR  EQU 0xE0004004
IO0DIR  EQU	0xE0028008
IO1DIR  EQU 0xE0028018
IO0SET  EQU 0xE0028004
IO0CLR  EQU 0xE002800C
IO1SET  EQU 0xE0028014
IO1CLR  EQU 0xE002801C
IO0PIN  EQU 0xE0028000
IO1PIN  EQU 0xE0028010
T1TCR  EQU 0xE0008004

IO0CFG   EQU 0x26B784
IO1CFG   EQU 0xF0000
TURN_ON_FIRST_DIGIT  EQU 0x0026B784
TURN_OFF_FIRST_DIGIT  EQU 0x0026B780
TURN_ON_SECOND_DIGIT  EQU 0x0026B788
TURN_OFF_SECOND_DIGIT  EQU 0x0026B780
TURN_ON_THIRD_DIGIT  EQU 0x0026B790
TURN_OFF_THIRD_DIGIT  EQU 0x0026B780
TURN_ON_FOURTH_DIGIT  EQU 0x0026B7A0
TURN_OFF_FOURTH_DIGIT  EQU 0x0026B780
STRING_BASE_ADDRESS 	DCD 0x00000000

lab6	 	
	STMFD sp!, {lr}

		BL pin_connect_block_setup_for_gpio
		BL pin_connect_block_setup_for_uart0
		BL uart_init
		BL setup_gpios
		BL enable_timers
		LDR r4, =prompt
		BL output_string
	        LDR r0, =STRING_BASE_ADDRESS
		BL input_character
		BL output_character
		BL compare_digit
		MOV r6,r2;
		LDR r0, =STRING_BASE_ADDRESS
		BL input_character
		BL output_character
		BL compare_digit
		MOV r7,r2;
		LDR r0, =STRING_BASE_ADDRESS
		BL input_character
		BL output_character
		BL compare_digit
		MOV r8,r2;
		LDR r0, =STRING_BASE_ADDRESS
		BL input_character
		BL output_character
		BL compare_digit
		MOV r9,r2;
		LDR r0, =STRING_BASE_ADDRESS
		BL input_character
		BL output_character
		MOV r10,r0;
		CMP r10, #0x0D
		BEQ SEVENSEG
                LDMFD sp!,{lr}
		BX lr

compare_digit
	
		
		CMP r0, #0x30	; checking for '0'
		BNE NOTZERO
		MOV r2, #0

NOTZERO
		CMP r0, #0x31	; checking for '1'
		BNE NOTONE
		MOV r2, #1
NOTONE
		CMP r0, #0x32	; checking for '2'
		BNE NOTTWO
		MOV r2, #2
NOTTWO
		CMP r0, #0x33	; checking for '3'
		BNE NOTTHREE
		MOV r2, #3
NOTTHREE
		CMP r0, #0x34	; checking for '4'
		BNE NOTFOUR
		MOV r2, #4
NOTFOUR	
		CMP r0, #0x35	; checking for '5'
		BNE NOTFIVE
		MOV r2, #5
NOTFIVE	
		CMP r0, #0x36	; checking for '6'
		BNE NOTSIX
		MOV r2, #6
NOTSIX	
		CMP r0, #0x37	; checking for '7'
		BNE NOTSEVEN
		MOV r2, #7
NOTSEVEN	
		CMP r0, #0x38	; checking for '8'
		BNE NOTEIGHT
		MOV r2, #8
NOTEIGHT	
		CMP r0, #0x39	; checking for '9'
		BNE NOTNINE
		MOV r2, #9
NOTNINE	
		CMP r0, #0x61	; checking for 'a'
		BNE NOTA
		MOV r2, #10
NOTA	
		CMP r0, #0x62	; checking for 'b'
		BNE NOTB
		MOV r2, #11
NOTB	
		CMP r0, #0x63	; checking for 'c'
		BNE NOTC
		MOV r2, #12
NOTC	
		CMP r0, #0x64	; checking for 'd'
		BNE NOTD
		MOV r2, #13
NOTD	
		CMP r0, #0x65	; checking for 'e'
		BNE NOTE
		MOV r2, #14
NOTE	
		CMP r0, #0x66	; checking for 'f'
		BNE NOTF
		MOV r2, #15

NOTF	
		CMP r0, #0x71 ; checking for 'q'
		BX lr


SEVENSEG
	STMFD sp!, {r0,r1,r2,r3,r4}
	MOV r0, r6
	LDR r2, =IO0DIR
	
	LDR r1, =TURN_ON_FIRST_DIGIT	; TURNING ON THE FIRST SEV SEG DISPLAY
	BL display_digit_on_7_seg
        STR r1, [r2]
	
	MOV r0, #5
        BL delay
	LDR r2, =IO0DIR
	
	LDR r1, =TURN_OFF_FIRST_DIGIT	; TURNING OFF THE FIRST SEV SEG DISPLAY
        STR r1, [r2]
	MOV r0, r7
	

        LDR r2, =IO0DIR
	LDR r1, =TURN_ON_SECOND_DIGIT	; TURNING ON THE SECOND SEV SEG DISPLAY
	BL display_digit_on_7_seg
        STR r1, [r2]
	MOV r0, #5
        BL delay
	LDR r2, =IO0DIR
	
	LDR r1, =TURN_OFF_SECOND_DIGIT	; TURNING OFF THE FIRST SEV SEG DISPLAY
        STR r1, [r2]
	MOV r0, r8
	LDR r2, =IO0DIR
	LDR r1, =TURN_ON_THIRD_DIGIT	; TURNING ON THE SECOND SEV SEG DISPLAY
	BL display_digit_on_7_seg
        STR r1, [r2]
	MOV r0, #5
        BL delay
	LDR r2, =IO0DIR
	
	LDR r1, =TURN_OFF_THIRD_DIGIT	; TURNING OFF THE FIRST SEV SEG DISPLAY
        STR r1, [r2]
	MOV r0, r9
	
	LDR r2, =IO0DIR
	LDR r1, =TURN_ON_FOURTH_DIGIT	; TURNING ON THE SECOND SEV SEG DISPLAY
	BL display_digit_on_7_seg
        STR r1, [r2]
	
	MOV r0, #5
        BL delay
	LDR r2, =IO0DIR
	
	LDR r1, =TURN_OFF_FOURTH_DIGIT	; TURNING OFF THE FIRST SEV SEG DISPLAY
        STR r1, [r2]
	B SEVENSEG
        LDMFD sp!, {r0,r1,r2,r3,r4}
	
	
	
	
; enables both timers and resets their values
enable_timers
	STMFD SP!, {r0,r1,r2}

	LDR r0, =T0TCR
	LDR r2, [r0] ; load register
	ORR r2, r2, #1 ; set bits 0,1 to 1
	STR r2, [r0]
	BIC r2, #2 ; clear reset bit
	STR r2, [r0]
	
	LDR r0, =T1TCR
	LDR r2, [r0] ; load register
	ORR r2, r2, #1 ; set bits 0,1 to 1
	STR r2, [r0]
	BIC r2, #2 ; clear reset bit
	STR r2, [r0]
	
	LDMFD SP!, {r0,r1,r2}
	BX lr
	
	
FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Preserving the registers
		MRS r9, CPSR ; preserving the CPSR
		
		; checking if the program is done
		LDR r0, =QUIT_PROMPT
		LDR r1, [r0]
		CMP r1, #0
		BNE FIQ_Exit

; setup_gpios configures GPIO directions for lab4
setup_gpios
    STMFD sp!, {lr,r0,r1,r2}
    
    ; configuring GPIOS on port 0
    LDR r2, =IO0DIR
    LDR r0, [r2]
    LDR r1, =IO0CFG
    ;ORR r0, r0, r1
    STR r1, [r2]

    ; configuring GPIOS on port 1
    LDR r2, =IO1DIR
    LDR r0, [r2]
    LDR r1, =IO1CFG
    STR r1, [r2]

    LDMFD sp!, {lr,r0,r1,r2}
    BX lr	


Stop_Timer
  STMFD SP!, {r0-r12,lr}
  LDR R0,=0xE0004004
  LDR r1,[r0]
  BIC r1,r1,#1
  STR r1,[r0]
  LDMFD SP!, {r0-r12,lr}
  BX lr
    

; pass the number of milliseconds to delay in r0
delay
	STMFD SP!,{lr,r0,r1,r2}
	
	; calculate timer ticks we need
	LDR r1, =TICKS_PER_MS
	BL multiplication ; r0 = r0*r1 = number of ticks to delay
	
	; reset timer
	LDR r1, =T0TCR
	LDR r2, [r1]
	ORR r2, r2, #2 ; set bit 1 to reset timer
	STR r2, [r1]
	BIC r2, #2 ; now clear bit 1 to get rid of reset
	STR r2, [r1]
	
	; wait for timer to become our time
DELAYLOOP
	LDR r1, =TIMER0
	LDR r2, [r1]
	CMP r2, r0
	BLT DELAYLOOP
   	 LDMFD SP!, {lr,r0,r1,r2}
	BX lr

FIQ_Exit
		MSR CPSR_c, r9 ; restoring the CPSR
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4

	END
