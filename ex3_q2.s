.global main
.text

main:
    lw $1, 0x70003($0)    # Gets value in serial port 1's status register
    andi $1, $1, 0x1      # Isolates the receive data ready bit
    beqz $1, main         # Loops back to start if there is no data ready to be received
    lw $1, 0x70001($0)    # Gets the data from serial port 1
    slti $2, $1, 'a'      # Checks if value received is less than 'a'
    bnez $2, replace      # Jumps to replace with '*' label if it is less than 'a'
    sgti $2, $1, 'z'      # Checks if value received is greater than 'z'
    bnez $2, replace      # Jumps to replace with '*' label if it is greater than 'z'
loop:
    lw $2, 0x70003($0)    # Gets value in serial port 1's status register
    andi $2, $2, 0x2      # Isolates the transmit data sent bit
    beqz $2, loop         # Jumps back to start of loop if data has not finished sending
    sw $1, 0x70000($0)    # Sends current value in $1 (either 'a'-'z' or '*') to serial port 1
    j main                # Jumps back to main to loop
replace:
    addi $1, $0, '*'      # Replaces the value in $1 with '*'
    j loop                # Jumps to loop to send to serial port 1