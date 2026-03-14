`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 07:53:28 PM
// Design Name: 
// Module Name: IFID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//IF Stage
module ProgramCounter(
    input wire [31:0] npc, 
    input wire clk,
    input wire wpcir,
    output reg [31:0] pc
);
    initial begin
        pc = 32'd0;
    end
    always @ (posedge clk)
        begin
            if(wpcir==0)begin
                pc <= npc;
            end
        end
endmodule

module PCMux(
    input wire [1:0] pcsrc,
    input wire [31:0] pc4,
    input wire [31:0] bpc,
    input wire [31:0] da,
    input wire [31:0] jpccat,
    output reg [31:0] npc
);
    always @(*) begin
        case(pcsrc)
            2'b00: npc = pc4;
            2'b01: npc = bpc;
            2'b10: npc = da;
            2'b11: npc = jpccat;
        endcase
    end
endmodule

module PcAdder(
    input wire [31:0] pc,
    output reg [31:0] pc4
);  
    always @(*)begin
        pc4 = pc + 32'd4;
    end 
endmodule

/*
module InstructionMemory(
    input wire [31:0] pc, 
    output reg [31:0] instOut
);
    
    reg [31:0] memory [0:63];
    //include more instructions that match with lab document
    initial begin
        memory[25] = {6'b100011,5'b00001,5'b00010,5'b00000,5'b00000,6'b000000};
        memory[26] = {6'b100011,5'b00001,5'b00011,5'b00000,5'b00000,6'b000100};
        memory[27] = {6'b100011,5'b00001,5'b00100,5'b00000,5'b00000,6'b001000};
        memory[28] = {6'b100011,5'b00001,5'b00101,5'b00000,5'b00000,6'b001100};
        memory[29] = {6'b000000,5'b00010,5'b01010,5'b00110,5'b00000,6'b100000};
    end
    
    always @(*) begin
        instOut = memory[pc[7:2]];
    end
endmodule
*/

module InstructionMemory ( // instruction memory, rom
    input wire [31:0] pc, // rom address
    output reg [31:0] instOut // rom content = rom[a]
);
    reg [31:0] rom [0:63]; // rom cells: 64 words * 32 bits
    // rom[word_addr] = instruction // (pc) label instruction
    initial begin
        rom[6'h00] = 32'h3c010000; // (00) main: lui $1, 0
        rom[6'h01] = 32'h34240050; // (04) ori $4, $1, 80
        rom[6'h02] = 32'h0c00001b; // (08) call: jal sum
        rom[6'h03] = 32'h20050004; // (0c) dslot1: addi $5, $0, 4
        rom[6'h04] = 32'hac820000; // (10) return: sw $2, 0($4)
        rom[6'h05] = 32'h8c890000; // (14) lw $9, 0($4)
        rom[6'h06] = 32'h01244022; // (18) sub $8, $9, $4
        rom[6'h07] = 32'h20050003; // (1c) addi $5, $0, 3
        rom[6'h08] = 32'h20a5ffff; // (20) loop2: addi $5, $5, -1
        rom[6'h09] = 32'h34a8ffff; // (24) ori $8, $5, 0xffff
        rom[6'h0a] = 32'h39085555; // (28) xori $8, $8, 0x5555
        rom[6'h0b] = 32'h2009ffff; // (2c) addi $9, $0, -1
        rom[6'h0c] = 32'h312affff; // (30) andi $10,$9,0xffff
        rom[6'h0d] = 32'h01493025; // (34) or $6, $10, $9
        rom[6'h0e] = 32'h01494026; // (38) xor $8, $10, $9
        rom[6'h0f] = 32'h01463824; // (3c) and $7, $10, $6
        rom[6'h10] = 32'h10a00003; // (40) beq $5, $0, shift
        rom[6'h11] = 32'h00000000; // (44) dslot2: nop
        rom[6'h12] = 32'h08000008; // (48) j loop2
        rom[6'h13] = 32'h00000000; // (4c) dslot3: nop
        rom[6'h14] = 32'h2005ffff; // (50) shift: addi $5, $0, -1
        rom[6'h15] = 32'h000543c0; // (54) sll $8, $5, 15
        rom[6'h16] = 32'h00084400; // (58) sll $8, $8, 16
        rom[6'h17] = 32'h00084403; // (5c) sra $8, $8, 16
        rom[6'h18] = 32'h000843c2; // (60) srl $8, $8, 15
        rom[6'h19] = 32'h08000019; // (64) finish: j finish
        rom[6'h1a] = 32'h00000000; // (68) dslot4: nop
        rom[6'h1b] = 32'h00004020; // (6c) sum: add $8, $0, $0
        rom[6'h1c] = 32'h8c890000; // (70) loop: lw $9, 0($4)
        rom[6'h1d] = 32'h01094020; // (74) stall: add $8, $8, $9
        rom[6'h1e] = 32'h20a5ffff; // (78) addi $5, $5, -1
        rom[6'h1f] = 32'h14a0fffc; // (7c) bne $5, $0, loop
        rom[6'h20] = 32'h20840004; // (80) dslot5: addi $4, $4, 4
        rom[6'h21] = 32'h03e00008; // (84) jr $31
        rom[6'h22] = 32'h00081000; // (88) dslot6: sll $2, $8, 0
         // use 6-bit word address to read rom
    end
    always @(*) begin
        instOut = rom[pc[7:2]];
    end
endmodule

module IFIDPipelineRegister(
    input wire [31:0] instOut,
    input wire clk, 
    input wire wpcir,
    input wire [31:0] pc4,
    output reg [31:0] dpc4,
    output reg [31:0] dinstOut
);
    
    always @ (posedge clk) begin
        if(wpcir==0) begin
            dpc4 <= pc4;
            dinstOut <= instOut;
        end
    end 
endmodule


//ID stage
module ControlUnit(
    input wire [5:0] op, 
    input wire [5:0] func, 
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] mrn,
    input wire mm2reg,
    input wire mwreg,
    input wire [4:0] ern,
    input wire em2reg,
    input wire ewreg,
    input wire rsrtequ,
    output reg [1:0]pcsrc,
    output reg wpcir,
    output reg wreg, 
    output reg m2reg, 
    output reg wmem,
    output reg jal,
    output reg [3:0] aluc,
    output reg aluimm,
    output reg shift,
    output reg regrt,
    output reg sext,
    output reg [1:0] fwda,
    output reg [1:0] fwdb
 );
    reg i_rs;
    reg i_rt;
    initial wpcir = 0;
    initial pcsrc = 2'b00;
    always @(*) begin    
        case(op)
            6'b000000://r-types
            begin
                case(func)
                    6'b100000://add instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0010;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b0;
                        sext = 1'bx;   
                    end
                    6'b100010://subtract instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0110;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b0;
                        sext = 1'bx;   
                    end
                    6'b100100://AND instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0000;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b0;
                        sext = 1'bx;   
                    end
                    6'b100101://OR instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0001;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b0;
                        sext = 1'bx;   
                    end
                    6'b100110://XOR instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0011;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b0;
                        sext = 1'bx;   
                    end
                    6'b000000://sll instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0100;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b1;
                        sext = 1'bx;   
                    end
                    6'b000010://srl instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b0101;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b1;
                        sext = 1'bx;   
                    end
                    6'b000011://sra instruction
                    begin
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluc = 4'b1000;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        pcsrc = 2'b00;
                        jal =1'b0;
                        shift = 1'b1;
                        sext = 1'bx;   
                    end
                    6'b001000://jr instruction
                    begin
                        wreg = 1'b0;
                        m2reg = 1'bx;
                        wmem = 1'b0;
                        aluc = 4'bxxxx;
                        aluimm = 1'bx;
                        regrt = 1'bx;
                        pcsrc = 2'b10;
                        jal =1'b0;
                        shift = 1'bx;
                        sext = 1'bx;   
                    end
                endcase
            end
            6'b100011://lw
            begin
                wreg = 1'b1;
                m2reg = 1'b1;
                wmem = 1'b0;
                aluc = 4'b0010;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b1;
            end
            6'b101011://sw
            begin
                wreg = 1'b0;
                m2reg = 1'b0;
                wmem = 1'b1;
                aluc = 4'b0010;
                aluimm = 1'b1;
                regrt = 1'bx;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b1;
            end
            6'b001000://addi
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluc = 4'b0010;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b1;
            end
            6'b001100://andi
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluc = 4'b0000;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b0;
            end
            6'b001101://ori
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluc = 4'b0001;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b0;
            end
            6'b001110://xori
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluc = 4'b0011;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b0;
            end
            6'b000100://beq
            begin
                wreg = 1'b0;
                m2reg = 1'bx;
                wmem = 1'b0;
                aluc = 4'b0110;
                aluimm = 1'b0;
                regrt = 1'bx;
                if(rsrtequ==1)
                    pcsrc = 2'b01;
                else
                    pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b1;
            end
            6'b000101://bne
            begin
                wreg = 1'b0;
                m2reg = 1'bx;
                wmem = 1'b0;
                aluc = 4'b0110;
                aluimm = 1'b0;
                regrt = 1'bx;
                if(rsrtequ==0)
                    pcsrc = 2'b01;
                else
                    pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'b0;
                sext = 1'b1;
            end
            6'b001111://lui
            begin
                wreg = 1'b1;
                m2reg = 1'b0;
                wmem = 1'b0;
                aluc = 4'b1001;
                aluimm = 1'b1;
                regrt = 1'b1;
                pcsrc = 2'b00;
                jal = 1'b0;
                shift = 1'bx;
                sext = 1'bx;
            end
            6'b000010://j
            begin
                wreg = 1'b0;
                m2reg = 1'bx;
                wmem = 1'b0;
                aluc = 4'bxxxx;
                aluimm = 1'bx;
                regrt = 1'bx;
                pcsrc = 2'b11;
                jal = 1'b0;
                shift = 1'bx;
                sext = 1'bx;
            end
            6'b000011://jal
            begin
                wreg = 1'b1;
                m2reg = 1'bx;
                wmem = 1'b0;
                aluc = 4'bxxxx;
                aluimm = 1'bx;
                regrt = 1'bx;
                pcsrc = 2'b11;
                jal = 1'b1;
                shift = 1'bx;
                sext = 1'bx;
            end
        endcase
        if (wpcir) begin
            wreg  = 1'b0;
            m2reg = 1'b0;
            wmem  = 1'b0;
            jal   = 1'b0;
        end 

    end
    //stall
    always @(*) begin
        i_rs = (op != 6'b000010) && (op != 6'b000011);
        i_rt = (op == 6'b000000) || (op == 6'b000100) || (op == 6'b000101);
        if (ewreg && em2reg && (ern != 5'd0) &&((i_rs && ern == rs) || (i_rt && ern == rt))) begin
            wpcir = 1'b1;
        end else begin
            wpcir = 1'b0;
        end
    end

    
    //forward a
    always @(*) begin
        if (ewreg && (ern != 0) && (ern == rs))
            fwda = 2'b01;
            
        else if (mwreg && (mrn != 0) && (mrn == rs) && !mm2reg)
            fwda = 2'b10;
            
        else if (mwreg && (mrn != 0) && (mrn == rs) && mm2reg)
            fwda = 2'b11;
            
        else
            fwda = 2'b00;
    end
    
    //forward b
    always @(*) begin
        if (ewreg && (ern != 0) && (ern == rt))
            fwdb = 2'b01;
            
        else if (mwreg && (mrn != 0) && (mrn == rt) && !mm2reg)
            fwdb = 2'b10;
            
        else if (mwreg && (mrn != 0) && (mrn == rt) && mm2reg)
            fwdb = 2'b11;
            
        else
            fwdb = 2'b00;
    end
endmodule

module addrLeftShift(
    input wire [25:0] addr,
    output reg [31:0] jpc
    );
    always @ (*)begin
        jpc = {4'b0000,addr,2'b00};
    end
endmodule

module immLeftShift(
    input wire [15:0] imm,
    output reg [31:0] immShift
    );
    always @ (*)begin
            immShift = {{14{imm[15]}}, imm, 2'b00};
    end
endmodule


module branchAddr(
    input wire [31:0] dpc4,
    input wire [31:0] immShift,
    output reg [31:0] bpc
);
    always @(*) begin
        bpc = dpc4+immShift;
    end
endmodule



module fwdaMux(
    input wire [1:0] fwda,
    input wire [31:0] qa,
    input wire [31:0] ealu,
    input wire [31:0] malu,
    input wire [31:0] mdo,
    output reg [31:0] da
 );
    always @(*) begin
        case(fwda)
            2'b00: da <= qa; 
            2'b01: da <= ealu;
            2'b10: da <= malu;
            2'b11: da <= mdo;
        endcase
    end
 endmodule

module fwdbMux(
    input wire [1:0] fwdb,
    input wire [31:0] qb,
    input wire [31:0] ealu,
    input wire [31:0] malu,
    input wire [31:0] mdo,
    output reg [31:0] db
 );
    always @(*) begin
        case(fwdb)
            2'b00: db <= qb; 
            2'b01: db <= ealu;
            2'b10: db <= malu;
            2'b11: db <= mdo;
        endcase
    end
 endmodule
 
module ImmediateExtender(
    input wire [15:0] imm,
    input wire sext,
    output reg [31:0] dimm
);
    always @(*) begin
        if(sext==1)begin
            dimm = {{16{imm[15]}},imm};
        end
        else begin
            dimm = {16'b0,imm};
        end
    end
    
endmodule

module RsRteq(
    input wire [31:0] da,
    input wire [31:0] db,
    output reg rsrtequ
); 
    always @(*) begin
        if(da==db)begin
            rsrtequ <= 1;
        end
        else begin
            rsrtequ <= 0;
        end
    end
endmodule

module RegrtMultiplexer(
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire regrt,
    output reg [4:0] drn
);
 
    always @(*) begin
        if(regrt == 0)begin
            drn = rd;
        end
        else begin
            drn =rt;
        end
    end
endmodule

module jpcConcat(
    input wire [31:0] jpc,
    input wire [31:0] dpc4,
    output reg [31:0] njpc
);
    always @(*) begin
        njpc = {dpc4[31:28], jpc[27:0]};
    end
endmodule








//EXE Stage
module IDEXEPipelineRegister(
    input wire wreg,
    input wire m2reg,
    input wire wmem,
    input wire jal,
    input wire [3:0] aluc,
    input wire aluimm,
    input wire shift,
    input wire [31:0] dpc4,
    input wire [31:0] da,
    input wire [31:0] db,
    input wire [31:0] dimm,
    input wire [4:0] drn,
    input wire clk,
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg ejal,
    output reg [3:0] ealuc,
    output reg ealuimm,
    output reg eshift,
    output reg [31:0] epc4,
    output reg [31:0] ea,
    output reg [31:0] eb,
    output reg [31:0] eimm,
    output reg [4:0] ern0
);

    always @(posedge clk) begin
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ejal <= jal;
        ealuc <= aluc;
        ealuimm <= aluimm;
        eshift <= shift;
        epc4 <= dpc4;
        ea <= da;
        eb <= db;
        eimm <= dimm;
        ern0 <= drn;
    end

endmodule

module Epc4Addr(
    input wire [31:0] epc4,
    output reg [31:0] epc8
);
    always @(*) begin
        epc8=epc4+4;
    end

endmodule

module ALUMultiplexerA(
    input wire [31:0] sa,
    input wire [31:0] ea,
    input wire eshift,
    output reg [31:0] a
);
    always @(*) begin
        case(eshift)
            1'b1: a = sa;
            1'b0: a = ea;
        endcase
    end

endmodule

module ALUMultiplexerB(
    input wire [31:0] eimm,
    input wire [31:0] eb,
    input wire ealuimm,
    output reg [31:0] b
);
    always @(*) begin
        case(ealuimm)
            1'b1: b = eimm;
            1'b0: b = eb;
        endcase
    end

endmodule

module ALU(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] ealuc,
    output reg [31:0] r
);
    always @(*) begin
        case(ealuc)
            //AND
            4'b0000: r = a & b;
            
            //OR
            4'b0001: r = a | b;
            
            //add
            4'b0010: r = a + b;
            
            //xor
            4'b0011: r = a^b;
            
            //subtract
            4'b0110: r = a - b;
            
            //slt
            4'b0111: begin
                if(a<b)begin
                     r=1;
                end
                else begin
                    r=0;
                end
            end
            
            //NOR
            4'b1100: r = ~(a|b);
            
            //sll
            4'b0100: r = b<<a[4:0];
            
            //srl
            4'b0101: r = b>>a[4:0];
            
            //sra
            4'b1000: r = b>>>a[4:0];
            
            //lui
            4'b1001:r = b<<16;
        endcase
    end
endmodule   

module ALUjalMux(
    input wire ejal,
    input wire [31:0] epc8,
    input wire [31:0] r,
    output reg [31:0] ealu
);
    always @(*) begin
        case(ejal)
            1'b1: ealu = epc8;
            1'b0: ealu = r;
        endcase
    end
endmodule

module forwardingUnit(
    input wire [4:0] ern0,
    input wire ejal,
    output reg [4:0] ern
);
    always @(*) begin
        case(ejal)
            1'b0: ern = ern0;
            1'b1: ern = 5'b11111;
        endcase    
    end
endmodule





//MEM Stage
module EXEMEMPipelineRegister(
    input wire ewreg,
    input wire em2reg,
    input wire ewmem,
    input wire [31:0] ealu,
    input wire [31:0] eb,
    input wire [4:0] ern,
    input wire clk,
    output reg mwreg,
    output reg mm2reg,
    output reg mwmem,
    output reg [31:0] malu,
    output reg [31:0] di,
    output reg [4:0] mrn
);
    always @(posedge clk)begin
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        malu <=ealu;
        di <= eb;
        mrn <= ern;
    end
endmodule

/*
module DataMemory(
    input wire [31:0] mr,
    input wire [31:0] mqb,
    input wire mwmem,
    input wire clk,
    output reg [31:0] mdo
);
    reg [31:0] memory [0:63];
    
    initial begin
        memory[0] = 32'hA00000AA;
        memory[1] = 32'h10000011;
        memory[2] = 32'h20000022;
        memory[3] = 32'h30000033;
        memory[4] = 32'h40000044;
        memory[5] = 32'h50000055;
        memory[6] = 32'h60000066;
        memory[7] = 32'h70000077;
        memory[8] = 32'h80000088;
        memory[9] = 32'h90000099;
    end
    
    
    always @(negedge clk) begin
        if(mwmem==1)begin
            memory[mr[31:2]] <= mqb;
        end
    end
    
    //shift mr by 2 bits if need to by byte addressable
    always @(*) begin            
            mdo <= memory[mr[31:2]];
    end

endmodule
*/
module DataMemory( // data memory, ram
    input wire clk, // clock
    input wire [31:0] malu, // ram address
    input wire [31:0] di, // data in (to memory)
    input wire we, // write enable
    output reg [31:0] mdo // data out (from memory)
);
    reg [31:0] ram [0:31]; // ram cells: 32 words * 32 bits
    integer i;  
    initial begin // ram initialization
        for (i = 0; i < 32; i = i + 1)
        ram[i] = 0;
        // ram[word_addr] = data // (byte_addr) item in data array
        ram[5'h14] = 32'h000000a3; // (50) data[0] 0 + a3 = a3
        ram[5'h15] = 32'h00000027; // (54) data[1] a3 + 27 = ca
        ram[5'h16] = 32'h00000079; // (58) data[2] ca + 79 = 143
        ram[5'h17] = 32'h00000115; // (5c) data[3] 143 + 115 = 258
        // ram[5'h18] should be 0x00000258, the sum stored by sw instruction
    end
    
    always @(*) begin
        mdo = ram[malu[6:2]]; // use 5-bit word address
    end
    always @ (posedge clk) begin
        if (we) ram[malu[6:2]] = di; // write ram
    end
endmodule




//WB Stage
module MEMWBPipelineRegister(
    input wire mwreg,
    input wire mm2reg,
    input wire [4:0] mrn,
    input wire [31:0] malu,
    input wire [31:0] mdo,
    input wire clk,
    output reg wwreg,
    output reg wm2reg,
    output reg [4:0] wrn,
    output reg [31:0] walu,
    output reg [31:0] wdo
);

    always @(posedge clk) begin
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wrn <= mrn;
        walu <= malu;
        wdo <= mdo;
    end

endmodule

module WritebackMultiplexer(
    input wire [31:0] walu,
    input wire [31:0] wdo,
    input wire wm2reg,
    output reg [31:0] wdi
);
    always @(*) begin
        case(wm2reg)
            1'b1: wdi = wdo;
            1'b0: wdi = walu;
        endcase
    end
endmodule

module RegisterFile(
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] wdestReg,
    input wire [31:0] wbData,
    input wire wwreg,
    input wire clk,
    output reg [31:0] qa,
    output reg [31:0] qb
);
    reg [31:0] registers [0:31];
    integer i;
    initial begin
        for(i = 0; i<32; i = i+1) begin
            registers[i] = 32'h0000;
        end
    end
    always @(*) begin
        qa = registers[rs];
        qb = registers[rt];
    end
    
    always @(negedge clk) begin
        if(wwreg==1)begin
            registers[wdestReg] <= wbData;
        end
    end
endmodule




//TODO adjust data path and add wires needed
//TODO read through documentation and figure out what waveform should look like
//TODO write intro and abstract for report

//Data Path
module Datapath(
    input wire clk_dp,
    output wire [7:0] debug    
);
    
    wire [31:0] pc_dp;
    assign debug = pc_dp[7:0];

    wire [31:0] instOut_dp;
    wire [31:0] ealu_dp;
    wire [31:0] malu_dp;
    wire [31:0] wdi_dp;
    
    
    //wire [31:0] pc_dp;
    wire [31:0] pc4_dp;
    wire [31:0] npc_dp;
    
    wire wpcir_dp;

    wire [31:0] dinstOut_dp;
    wire [31:0] dpc4_dp;
    
    wire [5:0] op_dp = dinstOut_dp[31:26];
    wire [4:0] rs_dp = dinstOut_dp[25:21];
    wire [4:0] rt_dp = dinstOut_dp[20:16];
    wire [4:0] rd_dp = dinstOut_dp[15:11];
    wire [5:0] func_dp = dinstOut_dp[5:0];
    wire [15:0] imm_dp = dinstOut_dp[15:0];
    
    
    wire wreg_dp;
    wire m2reg_dp;
    wire wmem_dp;
    wire jal_dp;
    wire aluimm_dp;
    wire shift_dp;
    wire sext_dp;
    wire regrt_dp;
    wire [3:0] aluc_dp;
    wire [1:0] pcsrc_dp;
    
    wire [31:0] qa_dp; 
    wire [31:0] qb_dp;
    wire [31:0] da_dp; 
    wire [31:0] db_dp;
    wire [31:0] dimm_dp;
    
    wire [31:0] immShift_dp;
    wire [31:0] bpc_dp;
    wire [31:0] jpc_dp;
    wire [31:0] jpccat_dp;
    
    wire rsrtequ_dp;
    wire [4:0] drn_dp;
    
    wire [1:0] fwda_dp; 
    wire [1:0] fwdb_dp;
    
    
    wire ewreg_dp;
    wire em2reg_dp;
    wire ewmem_dp;
    wire ejal_dp;
    wire ealuimm_dp;
    wire eshift_dp;
    wire [3:0] ealuc_dp;
    
    wire [31:0] epc4_dp;
    wire [31:0] ea_dp, eb_dp;
    wire [31:0] eimm_dp;
    wire [4:0] ern0_dp;
    
    wire [31:0] epc8_dp;
    wire [31:0] a_dp, b_dp;
    wire [31:0] r_dp;
    
    wire [4:0] ern_dp;
    
    
    wire mwreg_dp;
    wire mm2reg_dp;
    wire mwmem_dp;
    
    wire [31:0] di_dp;
    wire [4:0] mrn_dp;
    
    
    wire [31:0] mdo_dp;
    
    
    wire wwreg_dp;
    wire wm2reg_dp;
    wire [4:0] wrn_dp;
    wire [31:0] walu_dp;
    wire [31:0] wdo_dp;
    

    wire [25:0] addr_dp = dinstOut_dp[25:0];
    wire [31:0] shamt_dp = {16'd0, eimm_dp[31],eimm_dp[14:0]};




    // IF stage
    ProgramCounter PC (
        .npc(npc_dp),
        .clk(clk_dp),
        .wpcir(wpcir_dp),
        .pc(pc_dp)
    );
    
    PCMux PCMUX(
        .pcsrc(pcsrc_dp),
        .pc4(pc4_dp),
        .bpc(bpc_dp),
        .da(da_dp),
        .jpccat(jpccat_dp),
        .npc(npc_dp)
    );

    PcAdder PC_ADD (
        .pc(pc_dp),
        .pc4(pc4_dp)
    );

    InstructionMemory IMEM (
        .pc(pc_dp),
        .instOut(instOut_dp)
    );
    
    
    

    
    
    
    // ID stage
    IFIDPipelineRegister IFID (
        .instOut(instOut_dp),
        .clk(clk_dp),
        .wpcir(wpcir_dp),
        .pc4(pc4_dp),
        .dpc4(dpc4_dp),
        .dinstOut(dinstOut_dp)
    );
   
    ControlUnit CU (
        .op(op_dp),
        .func(func_dp),
        .rs(rs_dp),
        .rt(rt_dp),
        .mrn(mrn_dp),
        .mm2reg(mm2reg_dp),
        .mwreg(mwreg_dp),
        .ern(ern_dp),
        .em2reg(em2reg_dp),
        .ewreg(ewreg_dp),
        .rsrtequ(rsrtequ_dp),
        .pcsrc(pcsrc_dp),
        .wpcir(wpcir_dp),
        .wreg(wreg_dp),
        .m2reg(m2reg_dp),
        .wmem(wmem_dp),
        .jal(jal_dp),
        .aluc(aluc_dp),
        .aluimm(aluimm_dp),
        .shift(shift_dp),
        .sext(sext_dp),
        .regrt(regrt_dp),
        .fwda(fwda_dp),
        .fwdb(fwdb_dp)
    );
    
    addrLeftShift ALS(
        .addr(addr_dp),
        .jpc(jpc_dp)
    );
    immLeftShift ILS(
        .imm(imm_dp),
        .immShift(immShift_dp)
    );
    
    branchAddr BADDR(
        .dpc4(dpc4_dp),
        .immShift(immShift_dp),
        .bpc(bpc_dp)
    );
    
    RegisterFile RF (
        .rs(rs_dp),
        .rt(rt_dp),
        .wdestReg(wrn_dp),
        .wbData(wdi_dp),
        .wwreg(wwreg_dp),
        .clk(clk_dp),
        .qa(qa_dp),
        .qb(qb_dp)
    );

    fwdaMux FWD_A (
        .fwda(fwda_dp),
        .qa(qa_dp),
        .ealu(ealu_dp),
        .malu(malu_dp),
        .mdo(mdo_dp),
        .da(da_dp)
    );

    fwdbMux FWD_B (
        .fwdb(fwdb_dp),
        .qb(qb_dp),
        .ealu(ealu_dp),
        .malu(malu_dp),
        .mdo(mdo_dp),
        .db(db_dp)
    );
    
    ImmediateExtender IMMEXT (
        .sext(sext_dp),
        .imm(imm_dp),
        .dimm(dimm_dp)
    );
    
    RsRteq EQ (
        .da(da_dp),
        .db(db_dp),
        .rsrtequ(rsrtequ_dp)
    );
    
    RegrtMultiplexer REGDST (
        .rt(rt_dp),
        .rd(rd_dp),
        .regrt(regrt_dp),
        .drn(drn_dp)
    );
    
    jpcConcat JPCcc(
        .jpc(jpc_dp),
        .dpc4(dpc4_dp),
        .njpc(jpccat_dp)
    );
    
    
    
    
    
    
    
    // EXE stage
    IDEXEPipelineRegister IDEXE (
        .wreg(wreg_dp),
        .m2reg(m2reg_dp),
        .wmem(wmem_dp),
        .jal(jal_dp),
        .aluc(aluc_dp),
        .aluimm(aluimm_dp),
        .shift(shift_dp),
        .dpc4(dpc4_dp),
        .da(da_dp),
        .db(db_dp),
        .dimm(dimm_dp),
        .drn(drn_dp),
        .clk(clk_dp),
        .ewreg(ewreg_dp),
        .em2reg(em2reg_dp),
        .ewmem(ewmem_dp),
        .ejal(ejal_dp),
        .ealuc(ealuc_dp),
        .ealuimm(ealuimm_dp),
        .eshift(eshift_dp),
        .epc4(epc4_dp),
        .ea(ea_dp),
        .eb(eb_dp),
        .eimm(eimm_dp),
        .ern0(ern0_dp)
    );
    
    Epc4Addr EADDR(
        .epc4(epc4_dp),
        .epc8(epc8_dp)
    );
    
    ALUMultiplexerA ALUMUXA (
        .sa(shamt_dp),
        .ea(ea_dp),
        .eshift(eshift_dp),
        .a(a_dp)
    );

    ALUMultiplexerB ALUMUXB (
        .eimm(eimm_dp),
        .eb(eb_dp),
        .ealuimm(ealuimm_dp),
        .b(b_dp)
    );
    ALU ALU(
        .a(a_dp),
        .b(b_dp),
        .ealuc(ealuc_dp),
        .r(r_dp)
    );
    
    ALUjalMux AJM(
        .ejal(ejal_dp),
        .epc8(epc8_dp),
        .r(r_dp),
        .ealu(ealu_dp)
    );
    
    forwardingUnit F(
        .ern0(ern0_dp),
        .ejal(ejal_dp),
        .ern(ern_dp)
    );
    
    
    // MEM stage
    EXEMEMPipelineRegister EXEMEM (
        .ewreg(ewreg_dp),
        .em2reg(em2reg_dp),
        .ewmem(ewmem_dp),
        .eb(eb_dp),
        .ealu(ealu_dp),
        .ern(ern_dp),
        .clk(clk_dp),
        .mwreg(mwreg_dp),
        .mm2reg(mm2reg_dp),
        .mwmem(mwmem_dp),
        .di(di_dp),
        .malu(malu_dp),
        .mrn(mrn_dp)
    );
    
    DataMemory DMEM (
        .malu(malu_dp),
        .di(di_dp),
        .we(mwmem_dp),
        .clk(clk_dp),
        .mdo(mdo_dp)
    );
    
    // WB stage
    MEMWBPipelineRegister MEMWB (
        .mwreg(mwreg_dp),
        .mm2reg(mm2reg_dp),
        .mrn(mrn_dp),
        .malu(malu_dp),
        .mdo(mdo_dp),
        .clk(clk_dp),
        .wwreg(wwreg_dp),
        .wm2reg(wm2reg_dp),
        .wrn(wrn_dp),
        .walu(walu_dp),
        .wdo(wdo_dp)
    );

    WritebackMultiplexer WBMUX (
        .walu(walu_dp),
        .wdo(wdo_dp),
        .wm2reg(wm2reg_dp),
        .wdi(wdi_dp)
    );
    
endmodule
