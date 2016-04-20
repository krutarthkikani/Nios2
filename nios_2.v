// ||Shree Ganeshay Namh:||
// || Shree Swaminarayanay Namh:||
module nios_2 (
input clk,
input rst,
input enable,  // Enables Nios2
input  [31:0] inst_fetch,
output wire [7:0] prog_count_o,
output wire        data_mem_wr_o,    // Data memory Write Operation
output wire        data_mem_rd_o,    // Data memory Read Operation
output wire [31:0] data_mem_addr_o,  // Data memory Address
output wire [31:0] data_mem_wdata_o  // Write Data
);

wire  [7:0] prog_count_c;
wire  [5:0] opcode_c;  // Opcode extraction from memory Fetch
wire [31:0] immi_val_c;  // Sign extended immidiate value
wire  [4:0] rega_addr_c; // Address of Register A
wire  [4:0] regb_addr_c; // Address of Register B
wire  [4:0] regc_addr_c; // Address of Register C
wire [31:0] alu_op_c;  // ALU Operation Output
wire  [1:0] alu_opr_c; // ALU Operation 00 -- No Operation
                       //               01 -- Addition
                       //               10 -- Substraction
                       //               11 -- Multiplication
wire        mem_op_c;       // Data Memory Operation

reg [31:0] reg_mem [31:0];
reg  [7:0] prog_count;
reg  [5:0] opcode_ex;   // Opcode for Execution Stage
reg  [5:0] opcode_mem;  // Opcode for Memory Stage
reg [31:0] immi_val;    // Immidiate value for Execution stage
reg [31:0] regA;        // Register to be used in Execution Stage
reg [31:0] regB;        // Register to be used in Execution Stage
reg [31:0] regC;        // Register to be used in Execution Stage
reg [31:0] regA_mem;    // Register to be used in Memory Stage
reg [31:0] regB_mem;    // Register to be used in Memory Stage
reg [31:0] regC_mem;    // Register to be used in Memory Stage
reg [31:0] alu_op;      // ALU Output Registed version
reg        i_type;      // I-Type instruction flag is used for Execution stage
reg        j_type;      // J-Type instruction flag is used for Execution stage
reg        r_type;      // R-Type instruction flag is used for Execution stage
//-------------------------------------------
// Instruction Fetch
//-------------------------------------------

assign prog_count_o = prog_count;

assign prog_count_c = (enable) ? (prog_count + 8'h01) : prog_count;


assign opcode_c = inst_fetch[5:0];

assign i_type_c = ( (opcode_c == 6'h04) |
                    (opcode_c == 6'h15) |
                    (opcode_c == 6'h16) |
                    (opcode_c == 6'h17));
 
assign j_type_c = (opcode_c == 6'h06);

assign r_type_c = ( (opcode_c == 6'h3a) |
                    (opcode_c == 6'h31));

//-------------------------------------------
// Instruction Decode/ Register Fetch
//-------------------------------------------
assign rega_addr_c = {5{(i_type_c | r_type_c)}} & inst_fetch[31:27];

assign regb_addr_c = {5{(i_type_c | r_type_c)}} & inst_fetch[26:22];

assign regc_addr_c = {5{r_type_c}} & inst_fetch[21:17];

assign immi_val_c = {32{i_type_c}} & {inst_fetch[21],15'h00, inst_fetch[21:6]} |
                    {32{j_type_c}} & {5'h00,inst_fetch[31:6]};

assign alu_opr_c = {2{((opcode_ex == 6'h31) | 
                       (opcode_ex == 6'h15) | 
                       (opcode_ex == 6'h17))}} & 2'b01 |
                   {2{(opcode_ex == 6'h3A)}} & 2'b11;

//-------------------------------------------
// ALU Operation
//-------------------------------------------

assign alu_op_c = {31{(alu_opr_c == 2'b01) & i_type}} & (regA + immi_val) |
                  {31{(alu_opr_c == 2'b01) & r_type}} & (regA + regB)     |
                  {31{(alu_opr_c == 2'b11) & i_type}} & (regA * immi_val) |
                  {31{(alu_opr_c == 2'b11) & r_type}} & (regA * regB);

//-------------------------------------------
// Memory Stage
//-------------------------------------------

assign mem_op_c         = (data_mem_rd_o | data_mem_wr_o);
assign data_mem_rd_o    = (opcode_mem == 6'h17);
assign data_mem_wr_o    = (opcode_mem == 6'h15);
assign data_mem_addr_o  = {32{mem_op_c}} & alu_op;
assign data_mem_wdata_o = {32{mem_op_c}} & regB_mem;


always @ (posedge clk or negedge rst)
begin
  if(!rst) 
  begin
    reg_mem[0]    <= #1 'h00;
    reg_mem[1]    <= #1 'h00;
    reg_mem[2]    <= #1 'h02;
    reg_mem[3]    <= #1 'h00;
    reg_mem[4]    <= #1 'h00;
    reg_mem[5]    <= #1 'h08;
    reg_mem[6]    <= #1 'h07;
    reg_mem[7]    <= #1 'h06;
    reg_mem[8]    <= #1 'h05;
    reg_mem[9]    <= #1 'h00;
    prog_count    <= #1 8'h00;
    immi_val      <= #1 32'h00;
    regA          <= #1 32'h00;
    regB          <= #1 32'h00;
    regC          <= #1 32'h00;
    regA_mem      <= #1 32'h00;
    regB_mem      <= #1 32'h00;
    regC_mem      <= #1 32'h00;
    opcode_ex     <= #1 'h00;
    opcode_mem    <= #1 'h00;
    i_type        <= #1 'b0;
    j_type        <= #1 'b0;
    r_type        <= #1 'b0;
    alu_op        <= #1 32'h0000;
  end
  else
  begin
     regA       <= #1 reg_mem[rega_addr_c];
     regB       <= #1 reg_mem[regb_addr_c];
     regC       <= #1 reg_mem[regc_addr_c];
     regA_mem   <= #1 regA;
     regB_mem   <= #1 regB;
     regC_mem   <= #1 regC;
     prog_count <= #1 prog_count_c;
     immi_val   <= #1 immi_val_c;
     opcode_ex  <= #1 opcode_c;
     opcode_mem <= #1 opcode_ex;
     i_type     <= #1 i_type_c;
     j_type     <= #1 j_type_c;
     r_type     <= #1 r_type_c;
     alu_op     <= #1 alu_op_c;
  end
end

endmodule
