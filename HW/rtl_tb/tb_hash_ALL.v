
`timescale 1 ns / 1 ps

module tb_hash_ALL();
    reg clk, rst_n, input_rst_n;
    reg [19:0] args;
    
    wire i_tready, i_tlast, i_tvalid;
    wire o_tready, o_tlast, o_tvalid;
    wire [31:0] i_tdata, o_tdata, din;
    wire [3:0] i_tstrb, o_tstrb;

    wire [31:0] dout;
    wire dout_req, valid, squeeze_start, done;
    /*
        parameter SHA3_256=3'd0, SHA3_512=3'd1;
        parameter SHAKE_128=3'd2, SHAKE_256=3'd3;
        parameter SHA3_224=3'd4, SHA3_384=3'd5;
    */

    reg [31:0] dout0[63:0];
    reg [31:0] dout1[63:0];

    initial begin
        clk = 0;
        rst_n = 0;
        input_rst_n = 0;
        args = 20'h0;
        #100 rst_n = 1; input_rst_n = 1; #100;
        
        #1000 args = 20'h08001; // G_un_mask, SHA3_512
        #1000 args = 20'h40201;
        #100 input_rst_n = 0; #100 input_rst_n = 1; #100;
        #2000;
        #1000 args = 20'h00001;
        #1000 args = 20'h20001;
        #1000;
        #1000 args = 20'h00001;
        #1000 args = 20'h10001;
        #3000;
        #100 args = 20'h00001;
        #1000;
        // [2] SHA3-512 masked
        #1000 args = 20'h08009; // SHA3_512
        #1000 args = 20'h40209;
        #100 input_rst_n = 0; #100 input_rst_n = 1; #100;
        #2000;
        #1000 args = 20'h00009;
        #1000 args = 20'h20009;
        #1000;
        #1000 args = 20'h00009;
        #1000 args = 20'h10009;
        #3000;
        #100 args = 20'h00009;
        #1000;
        
        $stop;
    end 

    always #5 clk = ~clk;
    
    M_AXIS i_master(
        clk,
        input_rst_n,
        i_tvalid,
        i_tdata,
        i_tstrb,
        i_tlast,
        i_tready
    );
    
    HASH_S_AXIS i_slave(
        wen,
        din,
        clk,
        rst_n,
        i_tready,
        i_tdata,
        i_tstrb,
        i_tlast, 
        i_tvalid        
    );
    

    S_AXIS o_slave(
        clk,
        rst_n,
        o_tready,
        o_tdata,
        o_tstrb,
        o_tlast, 
        o_tvalid
    );

    HASH_M_AXIS o_master(
        squeeze_start,
        dout,
        dout_req,
        clk,
        rst_n,
        o_tvalid,
        o_tdata,
        o_tstrb,
        o_tlast,
        o_tready
    );

    hash_core_ykh hash(clk, rst_n, wen, dout_req, args, din, dout, valid, squeeze_start,done);
endmodule
