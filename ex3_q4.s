.global main
.text

main:
serial_job:
    lw $1, 0x70003($0)       # Gets value in serial port 1's status register
    andi $1, $1, 0x1         # Isolates the receive data ready bit
    beqz $1, parallel_job    # Loops back to start if there is no data ready to be received
    lw $1, 0x70001($0)       # Gets the data from serial port 1
    slti $2, $1, 'a'         # Checks if value received is less than 'a'
    bnez $2, replace         # Jumps to replace with '*' label if it is less than 'a'
    sgti $2, $1, 'z'         # Checks if value received is greater than 'z'
    bnez $2, replace         # Jumps to replace with '*' label if it is greater than 'z'
loop:
    lw $2, 0x70003($0)       # Gets value in serial port 1's status register
    andi $2, $2, 0x2         # Isolates the transmit data sent bit
    beqz $2, loop            # Jumps back to start of loop if data has not finished sending
    sw $1, 0x70000($0)       # Sends current value in $1 (either 'a'-'z' or '*') to serial port 1
    j parallel_job           # Jumps back to main to loop
replace:
    addi $1, $0, '*'         # Replaces the value in $1 with '*'
    j loop                   # Jumps to loop to send to serial port 1

parallel_job:
    lw $1, 0x73000($0)       # Stores data from switch register in $1
    lw $2, 0x73001($0)       # Stores data from push-button register in $2
    andi $3, $2, 0x1         # Checks if push button 0 is pressed
    bnez $3, display         # If push button 0 is pressed, display the switch values
    andi $3, $2, 0x2         # Checks if push button 1 is pressed
    bnez $3, invert          # If push button 1 is pressed, invert the bits then display
    andi $3, $2, 0x4         # Checks if push button 2 is pressed
    bnez $3, exit            # If push button 2 is pressed, exit the program
    j serial_job             # Loops back to start if no buttons are pressed
display:
    andi $2, $1, 0xF000      # Isolates the most significant 4 bits
    srli $2, $2, 12          # Shifts the most significant 4 bits into the least significant 4 bits position
    sw $2, 0x73006($0)       # Sends the value of the most significant 4 bits to the upper left SSD register
    andi $2, $1, 0xF00       # Isolates the second most significant 4 bits
    srli $2, $2, 8           # Shifts the second most significant 4 bits into the least significant 4 bits position
    sw $2, 0x73007($0)       # Sends the value of the second most significant 4 bits to the upper right SSD register
    andi $2, $1, 0xF0        # Isolates the second least significant 4 bits
    srli $2, $2, 4           # Shifts the second least significant 4 bits into the least significant 4 bits position
    sw $2, 0x73008($0)       # Sends the value of the second least significant 4 bits to the lower left SSD register
    andi $2, $1, 0xF         # Isolates the least significant 4 bits
    sw $2, 0x73009($0)       # Sends the value of the least significant 4 bits to the lower right SSD register
    remi $1, $1, 4           # Stores the remainder of the switches value and 4 in $1
    seqi $1, $1, 0           # Checks if the switches value is a multiple of 4
    multi $1, $1, 0xFFFF     # Will set $1 to 0xFFFF if the switches value is a multiple of 4, otherwise will remain as 0
    sw $1, 0x7300A($0)       # Turns all LEDs on if switches value is a multiple of 4, otherwise turns all off
    j serial_job             # Jumps to main to loop again
invert:
    xori $1, $1, 0xFFFF      # Flips the bits of the value from switches
    j display                # Displays the flipped value to the SSDs
exit:
    jr $ra                   # Exits the program