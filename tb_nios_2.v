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
inst_mem[3] = 32'h00801922;
inst_mem[4] = 32'b1080320e;
inst_mem[2] = 32'b00c04b22;
inst_mem[0] = 32'b18c0640e;
inst_mem[1] = 32'b18c0640e;
inst_mem[5] = 32'b18c0640e;
inst_mem[6] = 32'18c0640e;
inst_mem[7] = 32'18c0640e;
inst_mem[6] = 32'2100960e ;
inst_mem[6] = 32'21000017;
inst_mem[6] = 32'00c04b22;
inst_mem[6] = 32'18c0640e;
inst_mem[6] = 32'01007d22;
inst_mem[6] = 32'2100960e;
inst_mem[6] = 32'21000017;
inst_mem[6] = 32'000a0031;
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

