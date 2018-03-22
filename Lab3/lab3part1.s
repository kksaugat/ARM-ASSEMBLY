	AREA	lib, CODE, READWRITE	
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0
	
U0LSR EQU 0x14			; UART0 Line Status Register


lab3
	STMFD SP!,{lr}	; Store register lr on stack
   LDR r2,=0xE000C000
   LDR r3,=0xE000C014
 
Read LDR r0,[r3]
     LDRB r1,[r0]
     AND r1,r1,#1
	 CMP r1,#0
     BEQ Read
     LDRB r1,[r2] 	 
	
Write LDR r0,[r3]
      LDRB r1,[r0,r0,LSL#5]
	  AND r1,r1,#1
	  CMP r1,#0
	  BEQ Write
      STRB r2,[r3]
; Your code is placed here
 
	LDMFD sp!, {lr}
	BX lr

 
pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr

	END
