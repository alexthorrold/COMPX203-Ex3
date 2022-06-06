.global main
.text

main:
    addi $1, $0, 'a'       # Initialises $1 to 'a'
lower:
    lw $2, 0x71003($0)     # Gets value in serial port 2's status register
    andi $2, $2, 0x2       # Isolates the transmit data sent bit
    beqz $2, lower         # Repeats if data has not finished sending
    sw $1, 0x71000($0)     # Sends current value in $1 to serial port 2
    addi $1, $1, 1         # Increments value in $1
    slei $3, $1, 'z'       # Checks if value in $1 is greater than ASCII value 'z'
    bnez $3, lower         # Repeats lower if z has not yet been printed
initupper:
    addi $1, $0, 'A'       # Initialises $1 to 'A'
upper:
    lw $2, 0x71003($0)     # Gets value in serial port 2's status register
    andi $2, $2, 0x2       # Isolates the transmit data sent bit
    beqz $2, upper         # Repeats if data has not finished sending
    sw $1, 0x71000($0)     # Sends current value in $1 to serial port 2
    addi $1, $1, 1         # Increments value in $1
    slei $3, $1, 'Z'       # Checks if value in $1 is greater than ASCII value 'z'
    bnez $3, upper         # Repeats lower if z has not yet been printed
    jr $ra                 # Exits the program