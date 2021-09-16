`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// Initialized Module Input and Output registers
module m1(

input logic Clock,
input logic StartBit,
input logic Resetn,
input logic [15:0] ReadData,

output logic [15:0] WriteData,
output logic [17:0] SRAM_Address,
output logic Wen,
output logic StopBit
);

// Initialized Register values
M1_state_type state;
logic [31:0] M1a, M1b, M2a, M2b, M3a, M3b, M4a, M4b, M1Result, M2Result, M3Result, M4Result, RaccE, GaccE, BaccE, RaccO, GaccO, BaccO, RaccEStore, GaccEStore, BaccEStore, RaccOStore, GaccOStore, BaccOStore;
logic [63:0] M1ResultLong, M2ResultLong, M3ResultLong, M4ResultLong;
logic [15:0] UEUO, VEVO, UEUO1, UEUOT1, UEUOT2, VEVO1, VEVOT1, VEVOT2, YEYO, UR [5:0], VR [5:0];
logic [17:0] RGB_Address, U_Address, V_Address, Y_Address;
logic flag1;
logic [16:0] n, m;
logic [31:0] Ueven, Veven, Uodd, Vodd, UoddStore, VoddStore, UoddStoreShifted, VoddStoreShifted, YE, YO, YETemp, YOTemp, VevenShifted, VoddShifted, UevenShifted, UoddShifted, n1;
logic [7:0] RedE, GreenE, BlueE, RedO, GreenO, BlueO;

// Instantiating 4 multipliers for use 
assign M1ResultLong = M1a * M1b;
assign M1Result = M1ResultLong[31:0];

assign M2ResultLong = M2a * M2b;
assign M2Result = M2ResultLong[31:0];

assign M3ResultLong = M3a * M3b;
assign M3Result = M3ResultLong[31:0];

assign M4ResultLong = M4a * M4b;
assign M4Result = M4ResultLong[31:0];

// Shifting by 2^8 bits
assign UoddStoreShifted = {{8{UoddStore[31]}}, UoddStore[31:8]};
assign VoddStoreShifted = {{8{VoddStore[31]}}, VoddStore[31:8]};

// Subtraction before RGB calc
assign YE = YEYO[15:8] - 8'd16;
assign YO = YEYO[7:0] - 8'd16;
assign VevenShifted = {24'd0, Veven[7:0]} - 32'd128;
assign VoddShifted = VoddStoreShifted - 32'd128;
assign UevenShifted = {24'd0, Ueven[7:0]}  - 32'd128;
assign UoddShifted = UoddStoreShifted - 32'd128;

// Making sure RGB values are clipped (shifted by 2^16 bits) before writing into SRAM
assign RedE = RaccE[31]? 8'd0:|RaccE[30:24]? 8'd255:RaccE[23:16];
assign GreenE = GaccE[31]? 8'd0:|GaccE[30:24]? 8'd255:GaccE[23:16];
assign BlueE = BaccE[31]? 8'd0:|BaccE[30:24]? 8'd255:BaccE[23:16];
assign RedO = RaccO[31]? 8'd0:|RaccO[30:24]? 8'd255:RaccO[23:16];
assign GreenO = GaccO[31]? 8'd0:|GaccO[30:24]? 8'd255:GaccO[23:16];

assign BlueO = BaccO[31]? 8'd0:|BaccO[30:24]? 8'd255:BaccO[23:16];

// Always_Comb used to make sure reading and writing happen during the clock cycle for less confusion.
always_comb begin
	UEUO = 16'd0;
   VEVO = 16'd0;
	YEYO = 16'd0;
	WriteData = 16'd0;
	
	if (state == S_LEADIN2) begin
		UEUO = ReadData;
	
	end else if (state == S_LEADIN3) begin
		UEUO = ReadData;
	
	end else if (state == S_LEADIN4) begin
		VEVO = ReadData;
	
	end else if (state == S_LEADIN5) begin
		VEVO = ReadData;
	
	end else if (state == S_LEADIN6) begin
		YEYO = ReadData;
	
	end else if (state == S_LEADIN7) begin
		UEUO = ReadData;
	
	end else if (state == S_LEADIN8) begin
		VEVO = ReadData;
	
	end else if (state == S_COMMONCASE0) begin
		YEYO = ReadData;
	
	end else if (state == S_COMMONCASE1) begin
		WriteData = {RedE, GreenE};
	
	end else if (state == S_COMMONCASE2) begin
		if (flag1 != 1'b0) begin
			UEUO = ReadData;
		end
	
	end else if (state == S_COMMONCASE3) begin
		WriteData = {BlueE, RedO};
	
	end else if (state == S_COMMONCASE4) begin
		if (flag1 != 1'b0) begin
			VEVO = ReadData;
		end
	
	end else if (state == S_COMMONCASE5) begin
		WriteData = {GreenO, BlueO};
		
	end else if (state == S_LEADOUT0) begin
		YEYO = ReadData;
	
	end else if (state == S_LEADOUT1) begin
		WriteData = {RedE, GreenE};
		
	end else if (state == S_LEADOUT2) begin
		WriteData = {BlueE, RedO};
	
	end else if (state == S_LEADOUT3) begin
		WriteData = {GreenO, BlueO};
	
	end
	
end

always_ff@(posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	
		// Initialized Variables
		state <= S_M1_IDLE;
		SRAM_Address <= 18'd0;
		Wen <= 1'b1;
		StopBit <= 1'b0;
		M1a <= 32'd0;
		M1b <= 32'd0;
		M2a <= 32'd0;
		M2b <= 32'd0;
		M3a <= 32'd0;
		M3b <= 32'd0;
		M4a <= 32'd0;
		M4b <= 32'd0;
		UR[0] <= 16'd0; 
		UR[1] <= 16'd0;
		UR[2] <= 16'd0;
		UR[3] <= 16'd0;
		UR[4] <= 16'd0;
		UR[5] <= 16'd0;
		VR[0] <= 16'd0; 
		VR[1] <= 16'd0;
		VR[2] <= 16'd0;
		VR[3] <= 16'd0;
		VR[4] <= 16'd0;
		VR[5] <= 16'd0;
		RGB_Address <= 18'd146944;
		U_Address <= 18'd38400;
		V_Address <= 18'd57600;
		Y_Address <= 18'd0;
		flag1 <= 1'b0;
		Uodd <= 32'd0;
		Vodd <= 32'd0;
		UoddStore <= 32'd0;
		VoddStore <= 32'd0;
		UEUOT1 <= 32'd0;
		UEUOT2 <= 32'd0;
		VEVOT1 <= 32'd0;
		VEVOT2 <= 32'd0;
		YETemp <= 32'd0;
		YOTemp <= 32'd0;
		n <= 17'd5;
		n1 <= 32'd0;
		m <= 17'd0;
		RaccE <= 32'd0;
		GaccE <= 32'd0;
		BaccE <= 32'd0;
		RaccO <= 32'd0;
		GaccO <= 32'd0;
		BaccO <= 32'd0;
		RaccEStore <= 32'd0;
		GaccEStore <= 32'd0;
		BaccEStore <= 32'd0;
		RaccOStore <= 32'd0;
		GaccOStore <= 32'd0;
		BaccOStore <= 32'd0;
		
	end else begin
	
		case (state)
		S_M1_IDLE: begin
			if (StartBit == 1'b1) begin
				// Updating the U address, and SRAM address for the next cc
				U_Address <= U_Address + 18'b1;
				SRAM_Address <= U_Address;
				
				state <= S_LEADIN0;
			end
		end
		
		S_LEADIN0: begin
			// Updating the U address, and SRAM address for the next cc
			U_Address <= U_Address + 18'b1;
			SRAM_Address <= U_Address;
			
			state <= S_LEADIN1;
		end
		
		S_LEADIN1: begin
			// Updating the V address, and SRAM address for the next cc
			V_Address <= V_Address + 18'b1;
			SRAM_Address <= V_Address;
			
			state <= S_LEADIN2;
		end
		
		S_LEADIN2: begin
			// Updating the V address, and SRAM address for the next cc
			V_Address <= V_Address + 18'b1;
			SRAM_Address <= V_Address;
			
			// Storing UEUO in the U registers
			UR[0] <= UEUO[15:8];
			UR[1] <= UEUO[15:8];
			UR[2] <= UEUO[15:8];
			UR[3] <= UEUO[7:0];
			
			state <= S_LEADIN3;
		end
		
		S_LEADIN3: begin
			// Updating the Y address, and SRAM address for the next cc
			Y_Address <= Y_Address + 18'b1;
			SRAM_Address <= Y_Address;
			
			// Storing UEUO in the U registers
			UR[4] <= UEUO[15:8];
			UR[5] <= UEUO[7:0];
			
			// Mulitplication for first Uodd value during the next cc
			M1a <= UR[0]; 
			M1b <= 32'd21;
			M2a <= UR[1];
			M2b <= 32'b11111111111111111111111111001100;
			M3a <= UR[2];
			M3b <= 32'd159;
			M4a <= UR[3];
			M4b <= 32'd159;
			
			// Storing Ueven value
			Ueven <= UR[1];
			
			state <= S_LEADIN4;
		end
		
		S_LEADIN4: begin
			// Updating the U address, and SRAM address for the next cc
			U_Address <= U_Address + 18'b1;
			SRAM_Address <= U_Address;
			
			// Mulitplication for first Uodd value continued during the next cc
			M1a <= UR[4];
			M1b <= -32'd52;
			M2a <= UR[5];
			M2b <= 32'd21;
			
			// Storing Multiplication result from last cc
			Uodd <= M1Result + M2Result + M3Result + M4Result;
			
			// Storing VEVO in the V registers
			VR[0] <= VEVO[15:8];
			VR[1] <= VEVO[15:8];
			VR[2] <= VEVO[15:8];
			VR[3] <= VEVO[7:0];
			
			state <= S_LEADIN5;
		end
		
		S_LEADIN5: begin
			// Updating the V address, and SRAM address for the next cc
			V_Address <= V_Address + 18'b1;
			SRAM_Address <= V_Address;
			
			// Storing the Uodd value for RGB Calculations
			UoddStore <= Uodd + 31'd128 + M1Result + M2Result;
			
			// Storing VEVO in the V registers
			VR[4] <= VEVO[15:8];
			VR[5] <= VEVO[7:0];
			
			// Mulitplication for first Vodd value during the next cc
			M1a <= VR[0];
			M1b <= 32'd21;
			M2a <= VR[1];
			M2b <= -32'd52;
			M3a <= VR[2];
			M3b <= 32'd159;
			M4a <= VR[3];
			M4b <= 32'd159;
			
			// Storing Veven value
			Veven <= VR[1];
			
			state <= S_LEADIN6;
		end
		
		S_LEADIN6: begin
			
			// Storing YEYO
			YETemp <= YE;
			YOTemp <= YO;
			
			// Mulitplication for first Vodd value continued during the next cc
			M1a <= VR[4];
			M1b <= -32'd52;
			M2a <= VR[5];
			M2b <= 32'd21;
			
			// Storing Multiplication result from last cc
			Vodd <= M1Result + M2Result + M3Result + M4Result;
			
			// Shifting U and V Registers
			UR[4] <= UR[5];
			UR[3] <= UR[4];
			UR[2] <= UR[3];
			UR[1] <= UR[2];
			UR[0] <= UR[1];
			
			VR[4] <= VR[5];
			VR[3] <= VR[4];
			VR[2] <= VR[3];
			VR[1] <= VR[2];
			VR[0] <= VR[1];
			
			state <= S_LEADIN7;
		end
		
		S_LEADIN7: begin
			
			// Storing UEUO for next common case Multiplication
			UEUO1 <= UEUO;
			
			// Storing UEUO in the U register
			UR[5] <= UEUO[15:8];
			
			// Storing the Vodd value for RGB Calculations
			VoddStore <= Vodd + 31'd128 + M1Result + M2Result;
			
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[0];
			M1b <= 32'd21;
			M2a <= VR[0];
			M2b <= 32'd21;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= YETemp;
			M3b <= 32'd76284;
			M4a <= YOTemp;
			M4b <= 32'd76284;
			
			// Resetting Vodd and Uodd to use for the next multiplications
			Uodd <= 31'd128;
			Vodd <= 31'd128;
			
			state <= S_LEADIN8;
		end
		
		S_LEADIN8: begin
		
			// Storing VEVO for next common case Multiplication
			VEVO1 <= VEVO;
			
			// Storing VEVO in the V register
			VR[5] <= VEVO[15:8];
			
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[1];
			M1b <= -32'd52;
			M2a <= VR[1];
			M2b <= -32'd52;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= VevenShifted;
			M3b <= 32'd104595;
			M4a <= VoddShifted;
			M4b <= 32'd104595;
			
			// Storing the Uodd values from last multiplication result
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			RaccEStore <= RaccEStore + M3Result;
			RaccOStore <= RaccOStore + M4Result;
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			BaccEStore <= BaccEStore + M3Result;
			BaccOStore <= BaccOStore + M4Result;
			
			state <= S_LEADIN9;
		end
		
		S_LEADIN9: begin
			
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[2];
			M1b <= 32'd159;
			M2a <= VR[2];
			M2b <= 32'd159;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= UevenShifted;
			M3b <= 32'b11111111111111111001101111101000;
			M4a <= UoddShifted;
			M4b <= 32'b11111111111111111001101111101000;
			
			// Storing the Uodd values from last multiplication result
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			RaccEStore <= RaccEStore + M3Result;
			RaccOStore <= RaccOStore + M4Result;
			
			state <= S_LEADIN10;
		end
		
		S_LEADIN10: begin
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[3];
			M1b <= 32'd159;
			M2a <= VR[3];
			M2b <= 32'd159;	
			
			// Setting up multiplication for RGB during the next cc
			M3a <= VevenShifted;
			M3b <= 32'b11111111111111110010111111011111;
			M4a <= VoddShifted;
			M4b <= 32'b11111111111111110010111111011111;
			
			// Storing the Uodd values from last multiplication result
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			
			state <= S_LEADIN11;
		end
		
		S_LEADIN11: begin
			// Updating the Y address, and SRAM address for the next cc
			Y_Address <= Y_Address + 18'b1;
			SRAM_Address <= Y_Address;
			
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[4];
			M1b <= 32'b11111111111111111111111111001100;
			M2a <= VR[4];
			M2b <= 32'b11111111111111111111111111001100;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= UevenShifted;
			M3b <= 32'd132251;
			M4a <= UoddShifted;
			M4b <= 32'd132251;
			
			// Storing the Uodd values from last multiplication result
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			
			state <= S_LEADIN12;
		end
		
		S_LEADIN12: begin
		
			// Mulitplication for second Uodd and Vodd values during the next cc
			M1a <= UR[5];
			M1b <= 32'd21;
			M2a <= VR[5];
			M2b <= 32'd21;
			
			// Storing the Uodd values from last multiplication result
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Storing all the RGB calculations
			RaccE <= RaccEStore;
			RaccO <= RaccOStore;
			GaccE <= GaccEStore;
			GaccO <= GaccOStore;
			BaccE <= BaccEStore + M3Result;
			BaccO <= BaccOStore + M4Result;
			
			// Resetting all Accumulator storage values
			RaccEStore <= 32'd0;
			GaccEStore <= 32'd0;
			BaccEStore <= 32'd0;
			RaccOStore <= 32'd0;
			GaccOStore <= 32'd0;
			BaccOStore <= 32'd0;
			
			state <= S_LEADIN13;
		end
		
		S_LEADIN13: begin	
			// Updating the Y address, SRAM address, and Wen for the next cc
			U_Address <= U_Address + 18'b1;
			SRAM_Address <= U_Address;
			
			// Storing the Uodd and Vodd values for RGB Calculations
			UoddStore <= Uodd + M1Result;
			VoddStore <= Vodd + M2Result;
			
			// Resetting Vodd and Uodd to use for the next multiplications
			Uodd <= 32'd128;
			Vodd <= 32'd128;
			
			// Update U and V Registers most significant Register
			UR[5] <= UEUO1[7:0];
			VR[5] <= VEVO1[7:0];
			
			// Shifting U and V Registers
			UR[4] <= UR[5];
			UR[3] <= UR[4];
			UR[2] <= UR[3];
			UR[1] <= UR[2];
			UR[0] <= UR[1];
			
			VR[4] <= VR[5];
			VR[3] <= VR[4];
			VR[2] <= VR[3];
			VR[1] <= VR[2];
			VR[0] <= VR[1];
		
			state <= S_COMMONCASE0;
		end
		
		// Common Cases
		
		S_COMMONCASE0: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			// Updating the flag1 to make sure UEUO and VEVO is gotten and used properly for every other Common case iteration
			flag1 <= ~flag1;
			
			// Setting up multiplication for Uodd and Vodd during the next cc
			M1a <= UR[4];
			//M1b <= -32'd52;
			M1b <= 32'b11111111111111111111111111001100;
			M2a <= VR[4];
			M2b <= 32'b11111111111111111111111111001100;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= YE;
			M3b <= 32'd76284;
			M4a <= YO;
			M4b <= 32'd76284;
			
			// Getting the even register values for the last border pixel
			if (n != 17'd1) begin
				// Ueven and Veven defined
				Ueven <= UR[1];
				Veven <= VR[1];
			end
			
			// Saving the Uodd and Vodd multiplication results for the last common case state
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			n1 <= n1 + 32'b1;
			state <= S_COMMONCASE1;
		end
		
		S_COMMONCASE1: begin
			// Updating the V address, SRAM address, and Wen for the next cc
			if (flag1 != 1'b0) begin
				V_Address <= V_Address + 18'b1;
				SRAM_Address <= V_Address;
			end
			Wen <= 1'b1;

			// Setting up multiplication for Uodd and Vodd during the next cc
			M1a <= UR[3];
			M1b <= 32'd159;
			M2a <= VR[3];
			M2b <= 32'd159;	
			
			// Setting up multiplication for RGB during the next cc
			M3a <= VevenShifted;
			M3b <= 32'd104595;
			M4a <= VoddShifted;
			M4b <= 32'd104595;
		
			// Saving the Uodd and Vodd multiplication results for the last common case state
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			RaccEStore <= RaccEStore + M3Result;
			RaccOStore <= RaccOStore + M4Result;
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			BaccEStore <= BaccEStore + M3Result;
			BaccOStore <= BaccOStore + M4Result;
			n1 <= n1 + 32'b1;
			state <= S_COMMONCASE2;
		end
		
		S_COMMONCASE2: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			// If border has been detected stop getting the UEUO values and save them for the new border
			if (flag1 != 1'b0 && (n < 17'd313 || n > 17'd319)) begin
				// Saving the Value of UEUO
				UEUO1 <= UEUO;
				
			end else if (n == 313) begin
				UEUOT1 <= UEUO;
			
			end else if (n == 317) begin
				UEUOT2 <= UEUO;
			
			end
			
			// Setting up multiplication for Uodd and Vodd during the next cc
			M1a <= UR[2];
			M1b <= 32'd159;
			M2a <= VR[2];
			M2b <= 32'd159;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= UevenShifted;
			M3b <= 32'b11111111111111111001101111101000;
			M4a <= UoddShifted;
			M4b <= 32'b11111111111111111001101111101000;
			
			// Saving the Uodd and Vodd multiplication results for the last common case state
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			RaccEStore <= RaccEStore + M3Result;
			RaccOStore <= RaccOStore + M4Result;
			n1 <= n1 + 32'b1;
			state <= S_COMMONCASE3;
		end
		
		S_COMMONCASE3: begin
			// Updating the Y address, SRAM address, and Wen for the next cc
			Y_Address <= Y_Address + 18'b1;
			SRAM_Address <= Y_Address;
			Wen <= 1'b1;
			
			// Setting up multiplication for Uodd and Vodd during the next cc
			M1a <= UR[1];
			M1b <= 32'b11111111111111111111111111001100;
			M2a <= VR[1];
			M2b <= 32'b11111111111111111111111111001100;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= VevenShifted;
			M3b <= 32'b11111111111111110010111111011111;
			M4a <= VoddShifted;
			M4b <= 32'b11111111111111110010111111011111;
			
			// Saving the Uodd and Vodd multiplication results for the last common case state
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			n1 <= n1 + 32'b1;
			state <= S_COMMONCASE4;
		end
		
		S_COMMONCASE4: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			// If border has been detected stop getting the VEVO values and save them for the new border
			if (flag1 != 1'b0 && (n < 17'd313 || n > 17'd319)) begin
				// Saving the Value of VEVO
				VEVO1 <= VEVO;
				
			end else if (n == 313) begin
				VEVOT1 <= VEVO;
			
			end else if (n == 317) begin
				VEVOT2 <= VEVO;
			
			end
			
			// Setting up multiplication for Uodd and Vodd during the next cc
			M1a <= UR[0];
			M1b <= 32'd21;
			M2a <= VR[0];
			M2b <= 32'd21;
			
			// Setting up multiplication for RGB during the next cc
			M3a <= UevenShifted;
			M3b <= 32'd132251;
			M4a <= UoddShifted;
			M4b <= 32'd132251;
			
			// Saving the Uodd and Vodd multiplication results for the last common case state
			Uodd <= Uodd + M1Result;
			Vodd <= Vodd + M2Result;
			
			// Saving the RGB multiplication results
			GaccEStore <= GaccEStore + M3Result;
			GaccOStore <= GaccOStore + M4Result;
			n1 <= n1 + 32'b1;
			state <= S_COMMONCASE5;
		end
		
		S_COMMONCASE5: begin
			// Updating the U address, SRAM address, and Wen for the next cc
			if (flag1 == 1'b0) begin
				U_Address <= U_Address + 18'b1;
				SRAM_Address <= U_Address;
			end
			Wen <= 1'b1;
			
			// Multiplexer checks if a border has been reached
			if (n < 17'd313 || n > 17'd319) begin
				
				// Checks if you need the even or odd part of the register
				if (flag1 != 1'b0) begin
					M1a <= UEUO1[15:8];
					M1b <= 32'd21;
					M2a <= VEVO1[15:8];
					M2b <= 32'd21;
					UR[5] <= UEUO1[15:8];
					VR[5] <= VEVO1[15:8];
					
				end else begin
					M1a <= UEUO1[7:0];
					M1b <= 32'd21;
					M2a <= VEVO1[7:0];
					M2b <= 32'd21;
					UR[5] <= UEUO1[7:0];
					VR[5] <= VEVO1[7:0];
				end
				
				// Shifting the U and V registers for the next common case iteration
				UR[4] <= UR[5];
				UR[3] <= UR[4];
				UR[2] <= UR[3];
				UR[1] <= UR[2];
				UR[0] <= UR[1];
				
				VR[4] <= VR[5];
				VR[3] <= VR[4];
				VR[2] <= VR[3];
				VR[1] <= VR[2];
				VR[0] <= VR[1];
			
			end else if (n == 17'd313 || n == 17'd315 || n == 17'd317) begin
				
				// Use old pixel border values for the multiplier
				M1a <= UEUO1[7:0];
				M1b <= 32'd21;
				M2a <= VEVO1[7:0];
				M2b <= 32'd21;
				UR[5] <= UEUO1[7:0];
				VR[5] <= VEVO1[7:0];
				
				// Shifting the U and V registers for the next common case iteration
				UR[4] <= UR[5];
				UR[3] <= UR[4];
				UR[2] <= UR[3];
				UR[1] <= UR[2];
				UR[0] <= UR[1];
				
				VR[4] <= VR[5];
				VR[3] <= VR[4];
				VR[2] <= VR[3];
				VR[1] <= VR[2];
				VR[0] <= VR[1];
			
			end else if (n == 17'd319) begin
			
				// Use new pixel border values for the multiplier
				M1a <= UEUOT2[7:0];
				M1b <= 32'd21;
				M2a <= VEVOT2[7:0];
				M2b <= 32'd21;
				
				// Copy the new border pixel for the first 3 cases
				UR[5] <= UEUOT2[7:0];
				UR[4] <= UEUOT2[15:8];
				UR[3] <= UEUOT1[7:0];
				UR[2] <= UEUOT1[15:8];
				UR[1] <= UEUOT1[15:8];
				UR[0] <= UEUOT1[15:8];
				VR[5] <= VEVOT2[7:0];
				VR[4] <= VEVOT2[15:8];
				VR[3] <= VEVOT1[7:0];
				VR[2] <= VEVOT1[15:8];
				VR[1] <= VEVOT1[15:8];
				VR[0] <= VEVOT1[15:8];
				
				// Grab the even value for the last border case
				Ueven = UR[5];
				Veven = VR[5];
				
			end
			
			// Storing the multiplication results of Uodd an Vodd for the RGB calculations
			UoddStore <= Uodd + M1Result;
			VoddStore <= Vodd + M2Result;
			
			// Resetting the Uodd and Vodd to 128
			Uodd <= 32'd128;
			Vodd <= 32'd128;
			
			// Storing all the RGB calculations
			RaccE <= RaccEStore;
			RaccO <= RaccOStore;
			GaccE <= GaccEStore;
			GaccO <= GaccOStore;
			BaccE <= BaccEStore + M3Result;
			BaccO <= BaccOStore + M4Result;
			
			// Resetting all Accumulator storage values
			RaccEStore <= 32'd0;
			GaccEStore <= 32'd0;
			BaccEStore <= 32'd0;
			RaccOStore <= 32'd0;
			GaccOStore <= 32'd0;
			BaccOStore <= 32'd0;
			
			// Variable for tracking the current iteration values
			if (n == 17'd319) begin
				n <= 17'd1; // Resetting the tracking value
				m <= m + 17'd1; // Updating the row counter
			end else begin
				n <= n + 17'd2; // Updating the column counter
			end
			n1 <= n1 + 32'b1;
			// If column counter has reached the end, go to leadout states, if not go to common case states
			if (m == 17'd240) begin
				state <= S_LEADOUT0;
			end else begin
				state <= S_COMMONCASE0;
			end
		end
		
		S_LEADOUT0: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			state <= S_LEADOUT1;
		end
		
		S_LEADOUT1: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			state <= S_LEADOUT2;
		end
		
		S_LEADOUT2: begin
			// Updating the RGB address, SRAM address, and Wen for the next cc
			RGB_Address <= RGB_Address + 18'b1;
			SRAM_Address <= RGB_Address;
			Wen <= 1'b0;
			
			state <= S_LEADOUT3;
		end
		
		S_LEADOUT3: begin
			// Turn off writing
			Wen <= 1'b1;
			
			// Enable Stop bit
			StopBit <= 1'b1;
			
			// Go to idle state
			state <= S_M1_IDLE;
		end
		
		default: state <= S_M1_IDLE;
		
		endcase
	end
end

endmodule