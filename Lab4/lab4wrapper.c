extern int lab4(void);	
extern int pin_connect_block_setup_for_uart0(void);
extern int setup_gpio(void);
extern int uart_init(void);
extern int setup_rgb(void);
extern int setup_LEDS___Pbuttons(void);	
extern int setup_digitset(void);
int main()
{ 	
   pin_connect_block_setup_for_uart0();
  
	uart_init();
  setup_rgb();
	setup_LEDS___Pbuttons();	
	setup_digitset();
	lab4();
}