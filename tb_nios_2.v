module tb_nios_2;

reg         clk,rst,enable;
reg  [31:0] inst_mem_o;
reg  [31:0] inst_mem [255:0];
wire  [7:0]prog_count;

always #5 clk = ~clk;

always @ (posedge clk)
begin
  if (enable)
  begin
    inst_mem_o <= #1 inst_mem[prog_count];
  end
  else
  begin
    inst_mem_o <= #1 inst_mem_o;
  end
end

initial
begin
 $dumpfile("nios2.vcd");
 $dumpvars("0");
end


initial
begin
clk = 0;
rst = 1;
enable = 0;
inst_mem[3] = 32'b00000000100000000000000000110100;
inst_mem[4] = 32'b00010000100000000000010100010100;
inst_mem[2] = 32'b00010001100000000010000000010111;
inst_mem[0] = 32'b00110001110100010011100000111010;
inst_mem[1] = 32'b00101010000010111000100000110001;
inst_mem[5] = 32'b00010000100000000000000100000100;
inst_mem[6] = 32'b00000001000000000000100000010110;
inst_mem[7] = 32'b00000001010000000001100100010101;
inst_mem_o = 32'h00;
#5 rst = 0;
#20 rst = 1;
#5 enable = 1;
#80 enable = 0;

#100 $finish;
end

nios_2 nios_2_inst ( .clk(clk),
                     .rst(rst),
                     .enable(enable),
                     .inst_fetch(inst_mem_o),
                     .prog_count_o(prog_count) );


endmodule

