extern int lab5(void);	
extern int uart_init(void);
extern int pin_connect_block_setup_for_uart0(void);

int main()
{ 	
   pin_connect_block_setup_for_uart0();
   uart_init();
	lab5();
}