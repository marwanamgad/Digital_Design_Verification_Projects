package ALSU_pkg;

parameter VALID_OP = 6;

typedef enum bit [2:0] {OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7} opcode_e;
typedef enum bit [2:0] {MAXPOS=3'b011, ZERO=3'b000, MAXNEG=3'b100} reg_e;
typedef enum bit {LEFT, RIGHT} direction_e;

endpackage