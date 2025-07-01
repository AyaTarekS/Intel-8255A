`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2024 03:36:14 PM
// Design Name: 
// Module Name: 8255
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


module chip8255(DataBus , RESET , CS , RD , WR , PortAddress , PortA , PortB , PortC 
,PortC_upper ,PortC_lower , Vcc , GND );
input RESET , Vcc , GND , RD , CS , WR ;
input [1 : 0]PortAddress ;
inout [7 : 0]DataBus , PortA , PortB , PortC ;
inout [3 : 0]PortC_upper , PortC_lower ;
reg [7 : 0]bufferA , bufferB , bufferC ;
reg [7 : 0]InternalDataBus;
reg [7 : 0]ControlReg;
reg [7:0] PortA_out, PortB_out, PortC_out;
//control register flags 
wire active = ControlReg[7];
wire [1 : 0]OperationModeA = ControlReg[6:5];
wire OperationModeB = ControlReg[2];
wire In_outA = ControlReg[4];
wire In_outB = ControlReg[1];
wire In_outC_B = ControlReg[0];//lower port c
wire In_outC_A = ControlReg[3];
//upper port c
assign PortC = {PortC_upper , PortC_lower};
assign PortA = (RESET) ? 8'bz : PortA_out;
assign PortB = (RESET) ? 8'bz : PortB_out;
assign PortC = (RESET) ? 8'bz : PortC_out;
//instance of controls
wire InterruptA;
wire InterruptB;
controllerGA GroupA(.OperationModeA(OperationModeA),
.RD(RD),.WR(WR),
.In_outA(In_outA),
.In_outC_A(In_outC_A),
.InternalDataBus(InternalDataBus),
.PortA(PortA),
.PortC(PortC),
.DataBus(DataBus),
.InterruptA(InterruptA));
controllerGB GroupB(.OperationModeB(OperationModeB),
.RD(RD),.WR(WR),
.In_outB(In_outB),
.In_outC_B(In_outC_A),
.InternalDataBus(InternalDataBus),
.PortB(PortB),
.PortC(PortC),
.DataBus(DataBus),
.InterruptB(interruptB));
always @(*) begin
    //active high reset
    if(RESET)begin
        PortA_out = 8'bz;
        PortB_out = 8'bz;
        PortC_out = 8'bz;
        InternalDataBus = 8'bzzzzzzzz;
        ControlReg = 8'b0;
    end
    else
    begin
        if(!CS)
        begin
            //active mode
            if(active)begin
                //selection of the port
                case (PortAddress)
                //portA
                2'b00 : begin
                    if(In_outA)
                    begin
                        InternalDataBus = PortA;
                    end
                    else
                    begin
                        bufferA = DataBus; 
                    end
                end 
                //PortB
                2'b01 : begin
                    if(In_outB)
                        InternalDataBus = PortB;
                    else if(!WR)
                    begin
                        bufferB = DataBus; 
                    end
                end
                2'b10 : begin
                    if(In_outC_A)
                        InternalDataBus [7 : 4] = PortC_upper; 
                    else
                        bufferC[7 : 4] = DataBus[7 : 4]; 
                    if(In_outC_B)
                        InternalDataBus [3 : 0] = PortC_lower ;
                    else
                        bufferC[3 : 0] = DataBus [3 : 0];
                end
                2'b11 : begin
                    //filling the control reg from processor
                    if (RD && !WR) begin
                        ControlReg = DataBus;
                    end
                end
                endcase           
                end
                //Bitsetreset mode
                else begin
                
                end
        end 
    end

end 

endmodule
