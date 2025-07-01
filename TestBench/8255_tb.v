`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for chip8255 module
//////////////////////////////////////////////////////////////////////////////////

module tb_chip8255();

// Inputs
reg RESET;
reg Vcc;
reg GND;
reg RD;
reg CS;
reg WR;
reg [1:0] PortAddress;

// Inouts
wire [7:0] DataBus;
wire [7:0] PortA;
wire [7:0] PortB;
wire [7:0] PortC;
wire [3:0] PortC_upper;
wire [3:0] PortC_lower;

// Bidirectional data bus simulation
reg [7:0] DataBus_in;
assign DataBus = (!RD) ? DataBus_in : 8'bz;

// Outputs from inouts
wire [7:0] DataBus_out = DataBus;

// Instantiate the chip8255 module
chip8255 uut (
    .DataBus(DataBus),
    .RESET(RESET),
    .CS(CS),
    .RD(RD),
    .WR(WR),
    .PortAddress(PortAddress),
    .PortA(PortA),
    .PortB(PortB),
    .PortC(PortC),
    .PortC_upper(PortC_upper),
    .PortC_lower(PortC_lower),
    .Vcc(Vcc),
    .GND(GND)
);

// Clock for simulation
initial begin
    // Initialize inputs
    RESET = 1;
    Vcc = 1;
    GND = 0;
    RD = 1;
    WR = 1;
    CS = 1;
    PortAddress = 2'b00;
    DataBus_in = 8'b00000000;

    // Reset the module
    #10 RESET = 0;
    #10 RESET = 1;

    // Write to PortA
    #10 CS = 0; WR = 0; PortAddress = 2'b00; DataBus_in = 8'b10101010;
    #10 WR = 1; 

    // Read from PortA
    #10 RD = 0; 
    #10 RD = 1;

    // Write to PortB
    #10 WR = 0; PortAddress = 2'b01; DataBus_in = 8'b11001100;
    #10 WR = 1; 

    // Read from PortB
    #10 RD = 0; 
    #10 RD = 1;

    // Write to PortC upper and lower
    #10 WR = 0; PortAddress = 2'b10; DataBus_in = 8'b11110000;
    #10 WR = 1; 

    // Read from PortC upper and lower
    #10 RD = 0; 
    #10 RD = 1;

    // Write to Control Register
    #10 WR = 0; PortAddress = 2'b11; DataBus_in = 8'b11111111;
    #10 WR = 1; 

    // End simulation
    #50 $finish;
end

// Monitor signals
initial begin
    $monitor("Time: %0dns, RESET: %b, CS: %b, RD: %b, WR: %b, PortAddress: %b, DataBus: %b, PortA: %b, PortB: %b, PortC: %b", 
              $time, RESET, CS, RD, WR, PortAddress, DataBus_out, PortA, PortB, PortC);
end

endmodule
