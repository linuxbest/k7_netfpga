`timescale  1 ns / 10 ps
//
//                           QDR2+ - Burst-of-4, x36
//                         Simulation of Verilog model
//
// --------------------------------------------------------------

module rw_test;

`define num_vectors 111
`define inp {dummy,A[17:16],A[15:13],A[12:8],A[7:0],RPSb,WPSb,BWSb[1],BWSb[0],testout[17:9],testout[8:0],testin[17:9],testin[8:0]}

reg     [60:1]  lsim_vectors    [1:`num_vectors];

reg     [35:0]  dIn;
wire    [35:0]  dOut;
reg     [17:0]  A;
reg     [35:0]  testin;
reg     [35:0]  testout;
reg            noti3;
reg            strb,j;
integer        vector,i,k;
wire		CQ, CQb, TDO;
reg       	TCK, TMS, TDI, K, Kb, RPSb, WPSb, ZQ, DOFF, ODT;
reg     [3:0]   BWSb;
reg       	C1,K_delayed, K_delayed_b;
real     half_tcyc;
real     offset, tx01, tx02;
wire      QVLD; 
reg dummy;

cyqdr2_b4 test_file (TCK, TMS, TDI, TDO, dIn, dOut, A, K, Kb, RPSb, WPSb, BWSb[0], BWSb[1] ,BWSb[2], BWSb[3] ,CQ, CQb, ZQ, DOFF, QVLD, ODT);

//Create a dump file for the outputs

initial
begin
  $dumpfile("vectors.dump");
  $dumpvars(0,rw_test);
end

//specify cycle time of operation

initial
begin

   half_tcyc = 0.905; 
   offset = 0.6; 
   tx01 = 0.01;
   tx02 = ((2 * half_tcyc) * 9);

end 

//Variable Initialization

initial
  begin

	j           =        1'b0;
   strb        =        1'b0 ;
	dIn         =        36'b000000000000000000000000000000000000;
	BWSb        =        4'b0000;
	C1 	    =	     1'b0;
	K	    =        1'b0;
	K_delayed   =        1'b0;
	Kb	    =        1'b1;
	K_delayed_b =        1'b1;
	RPSb	    =	     1;
	WPSb	    =	     1;
	DOFF	    =	     1;
	A	=	18'b000000000000000000;
  end

//JTAG Variable Initialization

initial
begin
	TCK = 0;
	TMS = 1;
	TDI = 1'bx;
end

//Initialization of TCK signal
/*
initial
begin
	#0.1;
	forever #5 TCK = ~TCK;
end
*/

initial
begin
	for(k = 0; k <= 1000; k=k+1)
	begin
		#10 TCK = 0;
		#90 TCK = 1;
	end
end

// Initialization
initial
  begin

	#0.55;
	forever #half_tcyc strb = ~strb;
  end

// All the four clocks are generated here.
initial
  begin
	forever #half_tcyc K =~K;
  end

initial
  begin
	forever #half_tcyc Kb = ~Kb;
  end

initial
begin
	#offset;
	forever #half_tcyc K_delayed = ~K_delayed;
end

//----------------------------------------------------------------------------------
initial
begin
	#100	TMS = 1;	
	#10	TMS = 1;	
	#10	TMS = 0;	// Go to idle (on next TCLK)
	#10	TMS = 0;
	#10	TMS = 0;
	#10	TMS = 1;	// Go to Sel-DR Scan
	TDI = 0;
   	#10	TMS = 0;	// Go to Capture-DR (should load bsr, all I/O)
	#10	TMS = 0;	// Go to Shift-DR
	#100	TMS = 1;
	#100	TMS = 0;
	#10000	$finish;
end

initial
begin

$readmemb("qdr2_vectors.txt", lsim_vectors);     //load input vector file
 for (vector = 1; vector <= `num_vectors; vector = vector + 1)
   @(strb)
    begin
         `inp = lsim_vectors[vector];
          dIn[35:27] = testout[17:9];
          dIn[26:18] = testout[8:0];
          dIn[17:9] = testout[17:9];
          dIn[8:0] = testout[8:0];
          testout[35:27] = testout[17:9];
          testout[26:18] = testout[8:0];
          testin[35:27] = testin[17:9];
          testin[26:18] = testin[8:0];
          BWSb[3:2] = BWSb[1:0];        
    end
   #1000 $finish; // This prevents simulation beyond end of test patterns

end

always @(K_delayed) 
begin
if (vector > 1 && vector <= `num_vectors)
begin
     if (dOut[35:0] === testin[35:0])
	$display("Line:%d OK  data = %h test = %h",vector -1, dOut,testin);
     else
        $display("Line:%d ERROR data = %h test = %h",vector -1,dOut,testin);
end
end 

endmodule

