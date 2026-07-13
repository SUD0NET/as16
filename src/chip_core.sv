`default_nettype none

module chip_core #(
    parameter NUM_INPUT_PADS,
    parameter NUM_BIDIR_PADS,
    parameter NUM_ANALOG_PADS
    )(
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
    `endif
    
    input  wire clk,
    input  wire rst_n,
    
    input  wire [NUM_INPUT_PADS-1:0]  input_in,
    output wire [NUM_INPUT_PADS-1:0]  input_pu,
    output wire [NUM_INPUT_PADS-1:0]  input_pd,

    input  wire [NUM_BIDIR_PADS-1:0]  bidir_in,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_out,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_oe,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_cs,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_sl,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_ie,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_pu,
    output wire [NUM_BIDIR_PADS-1:0]  bidir_pd,
    
    inout  wire [NUM_ANALOG_PADS-1:0] analog
);

    wire [15:0] cpu_datain;
    wire [15:0] cpu_dataout;
    wire [15:0] cpu_address;
    wire        cpu_rnw;
    wire reset_b = rst_n;

    wire [NUM_INPUT_PADS-1:0] unused_inputs = input_in;
    wire [NUM_BIDIR_PADS-17:0] unused_bidir = bidir_in[NUM_BIDIR_PADS-1:16];

    assign cpu_datain = bidir_in[15:0];

    assign bidir_out[15:0]  = cpu_dataout;
    assign bidir_out[31:16] = cpu_address;
    assign bidir_out[32]    = cpu_rnw;

    assign bidir_oe[15:0]  = {16{!cpu_rnw}};
    assign bidir_oe[31:16] = 16'hFFFF;
    assign bidir_oe[32]    = 1'b1;

    assign bidir_cs = {NUM_BIDIR_PADS{1'b0}};
    assign bidir_sl = {NUM_BIDIR_PADS{1'b0}};
    assign bidir_ie = {NUM_BIDIR_PADS{1'b1}};
    assign bidir_pu = {NUM_BIDIR_PADS{1'b0}};
    assign bidir_pd = {NUM_BIDIR_PADS{1'b0}};

    assign input_pu = {NUM_INPUT_PADS{1'b0}};
    assign input_pd = {NUM_INPUT_PADS{1'b0}};

    assign bidir_out[NUM_BIDIR_PADS-1:33] = {(NUM_BIDIR_PADS-33){1'b0}};
    assign bidir_oe[NUM_BIDIR_PADS-1:33]  = {(NUM_BIDIR_PADS-33){1'b0}};

    wire [7:0] sram_q0, sram_q1;

    (* keep *) gf180mcu_fd_ip_sram__sram512x8m8wm1 sram_0 (
        `ifdef USE_POWER_PINS
        .VDD(VDD), .VSS(VSS),
        `endif
        .CLK(clk), .CEN(1'b1), .GWEN(1'b1), .WEN(8'hFF), 
        .A(9'b0), .D(8'b0), .Q(sram_q0)
    );

    (* keep *) gf180mcu_fd_ip_sram__sram512x8m8wm1 sram_1 (
        `ifdef USE_POWER_PINS
        .VDD(VDD), .VSS(VSS),
        `endif
        .CLK(clk), .CEN(1'b1), .GWEN(1'b1), .WEN(8'hFF), 
        .A(9'b0), .D(8'b0), .Q(sram_q1)
    );

    as16 u_cpu (
        .datain   (cpu_datain),
        .dataout  (cpu_dataout),
        .address  (cpu_address),
        .rnw      (cpu_rnw),
        .clk      (clk),
        .reset_b  (reset_b)
    );

endmodule
`default_nettype wire
