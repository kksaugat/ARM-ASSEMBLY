        
		  AREA  GPIO, CODE, READWRITE	     
   		  EXPORT   lab4
          EXTERN   pin_connect_block_setup_for_uart0
          EXTERN   uart_init
          EXTERN   read_character
          EXTERN   output_character
          EXTERN   read_string
          EXTERN   output_string
	      EXTERN illuminate_RGB_LED    
    	  EXTERN   string_to_int
          EXTERN seven_segment      
          EXTERN reverse_bits		
		  EXPORT  setup_rgb
          EXPORT   setup_LEDS___Pbuttons 
          EXPORT setup_digitset			  
			  
PIODATA EQU 0x8         ; Offset to paralle
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

prompt  =   "\n\rWeLcome to Lab4. Choose the options from below.\n\r ",0    ; 
            ALIGN
choose  =   "Press 'd' for 7-seg.\n\rPress'l' for illumniating LED.\n\rPress 'r' for RGB Led.\n\rAfter testing,it will take you back to main menu and press the character again\n\rPress q to quit. Thank you  " ,0 
            ALIGN           
seven_seg = "\n\rEnter a hex number from '0-F' then check the display.\n\rPlease to output from 'A' to 'F' caps on is needed.\n\rPlease press Capslock again to test other options after testing 'A'-'F'\n\r  ",0           
		    ALIGN
colors = "\n\rPress 'r' for red.\n\rPress 'g' for green.\n\rPress 'b' for blue\n\rPress 'p' for purple and 'w' for white.\n\rPress y for yellow\n\rCheck the lights	",0
            ALIGN
				
LEDS  =   "\n\rEnter numbers from 0-15 to be displayed in LED and hit enter ",0			
           ALIGN

Quit =  "\n\rHave a nice day",0
			ALIGN		 

lab4      
         STMFD SP!,{r0,r1,lr} ; Store register
                                                             
         LDR  r4,=prompt
         BL  output_string
         MOV  r0,#0x0A
         BL    output_character
         MOV   r0,#0x0D
         BL    output_character
         LDR   r4,=choose
         BL   output_string
         MOV  r0,#0x0A
         BL   output_character
         MOV  r0,#0x0D
       	 BL   output_character	
		 BL   read_character
		 CMP  r0,#0x64  ; if 'd' then branch to display the digit
		 BEQ  display_digit_on_7_seg
         CMP  r0,#0x71 ; if 'q' then quit the program
		 BEQ  quit
		 CMP r0,#0x6c  ; if 'l' illuminate the led
         BEQ illuminate_LED
         CMP r0,#0x72    ; if 'r' go to rgb
         BEQ rgb_LED
    
         LDMFD  SP!, {r0,r1,lr} ; 
         BX  LR
          
		  
setup_rgb
        STMFD sp!,{lr} 
		LDR r4,=IO0DIR   ; address of IO0DIR to r4;
		LDR r0,[r4]     ; load the value to r0
		ORR r0,r0,#0x260000 ; setting bits pins p0 17,18,21 for rgb (output)
		STR r0,[r4]    ; store it to r0
	    LDMFD sp!, {lr}
		BX lr
setup_LEDS___Pbuttons	
		STMFD sp!,{lr}
		LDR r4,=IO1DIR   ; address of I01DIR for push button and LEDs
		LDR r0,[r4]
		ORR r0,r0,#0xf0000  ; setting bits of port 1 pins 16-19 for LEDs 
		BIC r0,r0,#0xf00000 ; clearing bits of port 1 pins 20-23 for Push Buttons(input)
		STR r0,[r4]; store it to r0
		LDMFD sp!, {lr}
		BX lr
    
setup_digitset
      STMFD sp!,{lr}
       LDR r4,=IO0DIR  ; address of IO0DIR ro r4
       LDR r2,=0x26B784    ; port 0 pin 2 then the segments pins to 1 
	   ORR r0,r0,r2    ; set the bits 
	   STR r0,[r4]  ; store it into r0
	   LDMFD sp!,{lr}
	   BX lr

display_digit_on_7_seg
    STMFD SP!,{lr}    ; Store registers on stack
	LDR r4,= seven_seg     ; load the prompt
	BL output_string
	LDR r4,=stringaddress  
	BL read_character
	BL output_character
	CMP r0,#0x39    ; is the value less than 9?
	BLE sub1 ; if its go to sub1
	BEQ sub1;  if its equal to 9 then go to sub1
sub0
    SUB r0,r0,#0x41; if the values are'A' TO 'F' subtract by its ascii then add 10 to output the ascii
	ADD r0,r0,#10     ;  (A = 0x41) so 0x41-0x41 + 10 = A and so on
	B done_display
sub1	
	SUB r0,r0,#0x30  ; if the values are just 0-9 then just subtract from 0 in ascii 
	
done_display
    LDR r1,=IO0CLR ; load the base address
	LDR r2,=0xB780  ; to clear the display setting 1 to segment pins
	STR r2,[r1]
	BL seven_segment  ; branch to display the digits accordingly
	LDMFD  SP!, {lr} ; Restore regis
    BX LR


rgb_LED
    STMFD  SP!, {lr, r0-r4}
    LDR r1, =IO0SET   ; load the base address 
    LDR r0,[r1]
    ORR r0,r0,#0x00260000   ; 1 to turn on the pin 17,18,21
	STR r0,[r1]
again LDR r4,=colors 
	BL output_string
	MOV r0,#0x0A
	BL output_character
	MOV r0,#0x0D
	BL output_character
	LDR r4,=stringaddress
	BL read_character
	BL illuminate_RGB_LED  ; illumiate according to the color you want
    LDMFD   SP!, {lr, r0-r4}
    BX lr




illuminate_LED
    STMFD SP!, {lr}
    LDR r2,=IO1SET   ; Load the address of I01SET
	LDR r0,[r2]    ; LOAD THE value to r0
	ORR r0,r0,#0xf0000   ; PORT 1 16-19 TO 1
	STR r0,[r2]  ; STORE IT in r0
	
	LDR r4,=LEDS
	BL output_string
	LDR r4,=stringaddress
	BL read_string
	BL string_to_int   ; conver the string to int
	MOV r0,r1
	BL reverse_bits   ; reverse the bits 
	MOV r1,r0
	LDR r2,=IO1CLR   ; load the address of I01CLR
	LDR r0,[r2]
	ORR r0,r0,r1,LSL #16  ; move to get to p1.16
	STR r0,[r2] ; store the value in r0 
    B lab4
  
  LDMFD SP!,{ lr}
    BX LR



quit    
	 LDR r4,=Quit
	 BL output_string
	 END




