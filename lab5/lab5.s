    AREA interrupts, CODE, READWRITE
    EXPORT lab5
    EXPORT FIQ_Handler
    EXTERN pin_connect_block_setup_for_uart0
    EXTERN uart_init
    EXTERN read_character
    EXTERN output_character
    EXTERN read_string
    EXTERN output_string
    EXTERN seven_segment	
    EXTERN setup_digitset
    EXTERN display_digit_on_7_seg		
    EXTERN done_display	
    EXTERN on_or_off	
    EXTERN quit	
    EXTERN clear_digits		
U0IER EQU 0xE000C004
 

prompt = "Welcome to lab #5\n\r",0
	
            ALIGN
interrupt =    "Press the interrupt button to turn on and off the display.\n\r",0 
            ALIGN  
ascii = "Please enter a hex digit from '0'-'F'.\n\rFor 'A' to 'F'Please user capslock or shift\n\r",0 

toquit = "Press 'q' to quit the program\n\r",0
            ALIGN
				
Quit =  "\n\rHave a nice day",0
			ALIGN		 

lab5	 	
	STMFD sp!, {lr}
	BL setup_digitset
	BL interrupt_init   
	MOV r8,#1	
	LDR  r4,=prompt
        BL  output_string
	LDR r4,=ascii
	BL output_string
	LDR r4,=interrupt
	BL output_string
	LDR r4,= toquit
	BL output_string
LOOP 
       	B LOOP
	 
lab5_exit
     	 LDR r4,=Quit
	 BL output_string
	 LDMFD sp!,{lr}
	 BX lr

interrupt_init       
		STMFD SP!, {r0-r2, lr}   ; Save registers 
		
		; Push button setup		 
		LDR r0, =0xE002C000
		LDR r1, [r0]
		ORR r1, r1, #0x20000000
		BIC r1, r1, #0x10000000
		STR r1, [r0]  ; PINSEL0 bits 29:28 = 10
        
		;UART SETUP
		LDR r0,=U0IER ; UART0 Interrupt Enable Register Address
		LDR r1,[r0]
		ORR r1,r1,#0x1
		STR r1,[r0]

 
		; Classify sources as IRQ or FIQ
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0xC]
		LDR r2,=0x8040
		ORR r1, r1, r2; External Interrupt 1
		STR r1, [r0, #0xC]

		; Enable Interrupts
		LDR r0, =0xFFFFF000
		LDR r1, [r0, #0x10] 
		LDR r2,=0x8040
		ORR r1, r1, r2; External Interrupt 1
		STR r1, [r0, #0x10]

		; External Interrupt 1 setup for edge sensitive
		LDR r0, =0xE01FC148
		LDR r1, [r0]
		ORR r1, r1, #2  ; EINT1 = Edge Sensitive
		STR r1, [r0]
		

		; Enable FIQ's, Disable IRQ's
		MRS r0, CPSR
		BIC r0, r0, #0x40
		ORR r0, r0, #0x80
		MSR CPSR_c, r0

		LDMFD SP!, {r0-r2, lr} ; Restore registers
		BX lr             	   ; Return



FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers 

EINT1			; Check for EINT1 interrupt
		
		LDR r0, =0xE01FC140
		LDR r1, [r0]
		TST r1, #2
		BEQ Uart0          
		BL on_or_off
		ORR r1,r1,#2
        	STR r1,[r0] 
		B FIQ_Exit
		
		
Uart0    LDR r0,=0xE000C008
         LDR r1,[r0]
         AND r2,r1,#1
         CMP r2,#0	
         BNE FIQ_Exit
         BL read_character
         BL output_character
         BL display_digit_on_7_seg        
		

FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4

	    	 END   
	
            
        		  






