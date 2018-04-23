# ARM-ASSEMBLY


# Objective 

The objectives of these programs are to communicate with the ARM processor via serial communication using the UART,
write and use assembly language subroutines, and run programs on the ARM microprocessor.  
The board used for this project is LPC2138.

# Description

Each subroutine has its own function. It allows the user to input a string and display in PuTTy via the UART. 
Other subroutines deal with LEDs, momentary push buttons hardwired on the ARM board, 
RGB LED and a four digit seven-segment display that has been wired on the breadboard. 
The use of interrupts and timers allow the users to play with the digits turning on and off.
Strobing is used while displaying the seven segment displays.


# Selecting the Target

In uVision, select project -> Options for Target. Click on the Target tab. Set the Xtal clock speed to 14.7456MHz.
Click on the Linker tab and select Use Memory Layout.
Finally Click on the Debug tab and select ULINK ARM Debugger from the pulldown menu in the upper left.



# Testing

The C program allows the user to test the program.

