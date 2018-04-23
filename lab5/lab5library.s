	AREA   LIBRARY, CODE, READWRITE	
	EXTERN lab5
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT uart_init
   	EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT display_digit_on_7_seg
	EXPORT setup_digitset
        EXPORT 	seven_segment
        EXPORT done_display	
        EXPORT on_or_off 	
	EXPORT clear_digits	
U0LSR EQU 0x14			; UART0 Line Status Register

U0THR EQU 0xE000C000


PIODATA EQU 0x8         
  ;Pin block initialization                                                                      
PINSEL0 EQU 0xE002C000
IO0DIR  EQU 0xE0028008
IO1DIR  EQU  0xE0028018   
IO0SET  EQU 0xE0028004                        
IO1SET  EQU 0xE0028014                        
IO0CLR  EQU  0xE002800C                         
IO1CLR  EQU 0xE002801C                                            
IO0PIN  EQU 0xE0028000    
IO1PIN  EQU 0xE0028010                       
stringaddress DCD  0x000000000
	
digits_SET        
        DCD 0x00003780  ; 0
        DCD 0x00003000  ; 1 
        DCD 0x00009580  ; 2
        DCD 0x00008780  ; 3
        DCD 0x0000A300;   4
	DCD 0x0000A680  ; 5
	DCD 0x0000B680  ; 6
        DCD 0x00000380  ; 7
        DCD 0x0000B780  ; 8
        DCD 0x0000A780  ; 9
        DCD 0x0000B380  ; A
        DCD 0x0000B600  ; b
        DCD 0x00003480  ; C
        DCD 0x00009700  ; d
        DCD 0x0000B480  ; E
        DCD 0x0000B080  ; F   
            
                 ALIGN
Quit =  "\n\rHave a nice day",0
			ALIGN
					 
read_string
		STMFD sp!,{r0,r4, lr}	  	
LOOP1   BL read_character				
		BL output_character				
		CMP r0, #0x0D
		BEQ END
		STRB r0, [r4]
       	        ADD r4,r4,#1		
		B LOOP1	
END		MOV r0, #0x00
		STRB r0, [r4]		
		MOV r0, #0x0A
		BL output_character

		LDMFD sp!,{r0,r4,lr}
		BX lr				

output_string

		STMFD sp!,{r0, lr}
output_loop	LDRB r0,[r4]
        	ADD r4,r4,#1
		CMP r0, #0x00			
		BEQ STOP				
		BL output_character				
		B output_loop
STOP		LDMFD sp!, {r0, lr}
		BX lr


read_character 
		
		STMFD sp!,{r6-r7,lr}
		LDR r6, =U0THR
        	LDR r9,=U0LSR
read_loop	LDRB r7, [r6, r9]
		AND r7, r7, #0x1
		CMP r7, #0
		BEQ read_loop
		LDRB r0, [r6]
		LDMFD sp!,{r6-r7,lr}
		BX lr

		
output_character

		STMFD sp!,{r7-r8,lr}
		LDR r8, =U0THR
        	LDR r9,=U0LSR
LOOP2		LDRB r7, [r8, r9]
		AND r7, r7, #0x20
		CMP r7, #0
		BEQ LOOP2
		STRB r0, [r8]
		LDMFD sp!, {r7-r8,lr}
		BX lr



 
uart_init
		STMFD 	sp!, {lr,r0-r7}
		LDR 	r0, =0xE000C00C ;Load the address to r0
		MOV     r1, #131 ; initialize r1 to 131 			
		STRB 	r1, [r0] ; store 131 from r1 to memory address of r2				
		LDR 	r2,	=0xE000C000   ;load the address to r2
		MOV		r3,	#120  ; initialze r2 to 120
		STRB	r3, [r2]   ;store 120 from r3 to memory address of r3			 
		LDR		r4,	=0xE000C004   ; load the address to r4
		MOV		r5,	#0x00   ; intiialize 0 to r5
		STRB	r5,	[r4] ; store 0 from r5 to memory address of r4				
		LDR		r6,	=0xE000C00C  ;load the address to r6
		MOV		r7, #0x03 ; initialze r7 to 3
		STRB	r7,	[r6]  ;store the value of r7 to memory address of r6 				
		
		LDMFD 	sp!, {lr,r0-r7}
		BX 		lr   
		      


setup_digitset
      	   STMFD sp!,{lr}
       	   LDR r4,=IO0DIR  ; address of IO0DIR ro r4
       	   LDR r2,=0xB784    ; port 0 pin 2 then the segments pins to 1 
	   STR r2,[r4]
	   LDMFD sp!,{lr}
	   BX lr

display_digit_on_7_seg
    	STMFD SP!,{lr}    ; Store registers on stack
	CMP r0,#0x71 ; did user press 'q' to quit
	BEQ quit
	CMP r0,#0x46
	BGT _exit
	CMP r0,#0x30
	BLT _exit
	CMP r0,#0x39    ; is the value less than 9?
	BLE sub1 ; if its go to sub1
    	CMP r0,#0x41
	BGE sub0
	

sub0
    	MOV r3,#0x1
	SUB r0,r0,#0x41; if the values are'A' TO 'F' subtract by its ascii then add 10 to output the ascii
	ADD r0,r0,#10     ;  (A = 0x41) so 0x41-0x41 + 10 = A and so on
	BL done_display
	B _exit
sub1	
	MOV r3,#0x1
	SUB r0,r0,#0x30  ; if the values are just 0-9 then just subtract from 0 in ascii 
	BL done_display
	B _exit
	

_exit	
    LDMFD  SP!, {lr} ; Restore regis
    BX LR


done_display
    	STMFD SP!,{lr,r4,r2}
    	MOV r8,#0
	LDR r4,=IO0CLR ; load the base address
	LDR r2,=0xB784
	STR r2,[r4]
	BL seven_segment  ; branch to display the digits accordingly
	LDMFD  SP!, {lr,r4,r2} ; Restore regis
    	BX LR

clear_digits
    	STMFD SP!,{lr,r1,r2}
    	MOV r8,#0
	LDR r1,=IO0CLR ; load the base address
	LDR r2,=0xB784
	STR r2,[r1]
	LDMFD  SP!, {lr,r1,r2} ; Restore regis
    	BX LR

seven_segment
  STMFD SP!,{lr,r4,r2,r3}
  MOV r8,#1
  LDR r4,=0xE0028000    ; base adress
  LDR r3,=digits_SET   ; load the digits 
  MOV r0,r0,LSL#2    
  LDR r2,[r3,r0]
  STR r2,[r4,#4]
  LDMFD SP!, {lr,r4,r2,r3}
  BX lr


on_or_off
    
	STMFD SP!, {lr,r0}
    	CMP r8, #0			         ; 0 for off ; 1 = 0n is it on?
	BNE turn_off   ; if not go to turn off
turn_on
    	MOV r8, #1		 ; 1 = 0n		
   	MOV r0, r7      
   	BL done_display2		; go to display the digits	
   	B exit

turn_off
	MOV r8, #0				; 0 to turn off
	BL clear_digits			; clear the digits

exit
    	LDMFD SP!, {lr,r0}
	BX lr

done_display2
    	STMFD SP!,{lr,r4,r2}
    	MOV r8,#0
	LDR r4,=IO0CLR ; load the base address
	LDR r2,=0xB784
	STR r2,[r4]
	LDMFD  SP!, {lr,r4,r2} ; Restore regis
    	BX LR

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr

quit    
  
	LDR r4,=Quit
	BL output_string
	END

