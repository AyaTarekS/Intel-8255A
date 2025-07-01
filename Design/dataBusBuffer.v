module dataBusBuffer(RD , WR , IBF , OBF , DataBus , InternalDataBus ,In_out);
input RD , WR , In_out ; 
//Input = 1 , Output = 0
output reg IBF , OBF; //flags to acknowledge filling the buffer
inout [7 : 0] DataBus , InternalDataBus;
reg [7 : 0] out;
always@(*)
    out = (In_out)? InternalDataBus : DataBus ; 
assign DataBus = (!RD) ? out : 8'bzzzzzzzz ;
assign InternalDataBus = (!In_out)? out : 8'bzzzzzzzz ; 
//flags 
always @(out) begin
    if(out != 8'bzzzzzzzz)begin
        if(!(In_out))
            //output = 0 
            OBF = 0 ;
        else 
            IBF = 1 ;
    end
    else begin
        OBF = 1;
        IBF = 0;
    end
end
endmodule