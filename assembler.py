import serial

ALU_OPS = {
    "add": 0b000,
    "sub": 0b001,
    "mul": 0b010,
    "div": 0b011,
    "mod": 0b100
}

# returns the only the number part of the register passed in
def reg_num(reg):
    num = int(reg[1:])
    if (num > 7):
        raise ValueError("Invalid Register")
    return num

def assemble(command):
    parts = command.replace(",", " ").split()

    operation = parts[0].lower()

    # ALU
    if operation in ALU_OPS:
        if (len(parts) != 4):
            raise ValueError("Missing Operand")
        dr = reg_num(parts[1])
        sr1 = reg_num(parts[2])
        alu_op = ALU_OPS[operation]
        sr2 = reg_num(parts[3])

        instruction = ((0b0000 << 12) |
                        (dr << 9) |
                        (sr1 << 6) |
                        (alu_op << 3) |
                        (sr2))
    
    #load
    elif (operation == "ld"):
        dr = reg_num(parts[1])

        if ((parts[2][0] == "[") != (parts[2][-1] == "]")):
            raise ValueError("Unknown instruction")
        #load immediate
        elif (parts[2][0] != "["):
            imm = int(parts[2])

            if (imm > 255):
                raise ValueError("Invalid Immediate")
            
            instruction = ((0b0001 << 12) |
                            (dr << 9) |
                            (imm))
        #load from memory
        else:
            address = int(parts[2][1:-1])

            if (address > 255):
                raise ValueError("Invalid Memory Address")

            instruction = ((0b0010 << 12) |
                            (dr << 9) |
                            (address))

    #store
    elif (operation == "st"):
        if (parts[2][0] != "[" or parts[2][-1] != "]"):
            raise ValueError("Unknown instruction")
        
        sr = reg_num(parts[1])
        address = int(parts[2][1:-1])

        if (address > 255):
            raise ValueError("Invalid Memory Address")

        instruction = ((0b0011 << 12) |
                       (sr << 9) |
                       (address))

    #halt
    elif (operation == "halt"):
        instruction = 0xF000

    else:
        raise ValueError("Unknown instruction")

    return instruction

# UART (same as FPGA)
# port = input("COM port (ex. COM4): ")
ser = serial.Serial("COM5", 115200)

while(True):
    command = input("> ")

    try:
        instruction = assemble(command)

        high_byte = (instruction >> 8) & 0xFF
        low_byte = instruction & 0xFF

        ser.write(bytes([high_byte, low_byte]))
    except ValueError as error:
        print("Error:", error)