module controllerGA(
input OperationModeB,
input RD , WR , In_outB , In_outC_B,
inout [7 : 0]PortC,
output reg[7 : 0]InternalDataBus,
inout [7 : 0] DataBus,
output reg[7 : 0] bufferB,
input [7 : 0] PortB,
output reg InterruptB
);
//Internal signals
reg [7 : 0]data;
wire in_out ; 
//flags for the operation modes
wire inteB ;
reg STB ;
wire IBF , OBF;
reg AckB ;

assign in_out = In_outB || In_outC_B ;
assign DataBus =(!RD)? data : 8'bzzzzzzzz ;
//External DataBus buffer 
dataBusBuffer dataBusBuffer1(
    .DataBus(DataBus),
    .InternalDataBus(InternalDataBus),
    .In_out(In_out),
    .RD(RD),.WR(WR),
    .IBF(IBF),.OBF(OBF)
);
//assigning the flags to port c
assign PortC[0] = (OperationModeB==2'b01 || OperationModeB==2'b10)?InterruptB:1'bz;
assign PortC[1] = (OperationModeB==2'b01 && !STB)?IBF:OBF;

//Control logic dependig on operation mode
always @(*) begin
    //intial assignment 
    bufferB = 8'bz;
    InterruptB = 0 ;
    AckB = 1;
    data = 8'bzzzzzzzz ;
    //modes 0 , 1 , 2
    case (OperationModeB)
        0: begin
            if (In_outB)
                //Input mode
                    InternalDataBus = PortB ;
            else 
                    bufferB = DataBus;
        end
        1:begin
            if(In_out)
                STB = PortC[2];
           if(!STB) //strobe input 
           begin
            InterruptB = inteB && IBF && !STB ;
            if (InterruptB && !RD) begin
                data = InternalDataBus ;
            end
        
           end
           else begin
            if (!WR) begin
                bufferB = DataBus ;
                AckB = 0 ; 
            end
            else begin
                AckB = 1;
            end
            InterruptB = inteB && !OBF && !AckB ;
           end
        end 
    endcase
end
endmodule
