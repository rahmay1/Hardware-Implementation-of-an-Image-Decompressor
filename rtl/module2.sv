`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// Initialized Module Input and Output registers
module m2(

input logic Clock,
input logic StartBit,
input logic Resetn,
input logic [15:0] ReadData,

output logic [15:0] WriteData,
output logic [17:0] SRAM_Address,
output logic Wen,
output logic StopBit
);

// Initialized Registers for lead in, and common case
M2_state_type state;
logic [31:0] M1a, M1b, M2a, M2b, M3a, M3b, M4a, M4b, M1Result, M2Result, M3Result, M4Result, T0Acc, T1Acc, T2Acc, T3Acc, T0, T1, T2, T3, T0T, T1T, T0S, T1S, T2S, T3S, S0Acc, S1Acc, S2Acc, S3Acc, S0, S1, S2, S3, S0T, S1T, S0Shift, S1Shift, S2Shift, S3Shift, SE1, SE2, SE3, SE4, E1, E2, E3, E4, SEReadData;
logic [63:0] M1ResultLong, M2ResultLong, M3ResultLong, M4ResultLong;
logic flag, firstTime;
logic [1:0] flag2;
logic [5:0] SWriteAddress, SReadAddress;
logic [17:0] S_Address;
logic [8:0] counter1;
logic [7:0] S0C, S1C, S2C, S3C;

// Initialized registers for the address generator
logic en;
logic [5:0] sc, cb;
logic [4:0] rb;
logic [7:0] ra;
logic [8:0] ca;
logic [17:0] increment, Y_Address;

// Assign statement for address generator
assign ca = {cb,sc[2:0]};
assign ra = {rb,sc[5:3]};

assign increment = {ra,{8{1'd0}}} + {ra,{6{1'd0}}};
assign Y_Address = increment + 18'd76800 + ca;

// Sign Extenders
assign SE1 = { {16{E1[15]}}, E1[15:0] };
assign SE2 = { {16{E2[15]}}, E2[15:0] };
assign SE3 = { {16{E3[15]}}, E3[15:0] };
assign SE4 = { {16{E4[15]}}, E4[15:0] };
assign SEReadData = { {16{ReadData[15]}}, ReadData[15:0] };

// Shifting by 2^16
assign S0Shift = {{16{S0T[31]}}, S0T[31:16]};
assign S1Shift = {{16{S1T[31]}}, S1T[31:16]};
assign S2Shift = {{16{S2[31]}}, S2[31:16]};
assign S3Shift = {{16{S3[31]}}, S3[31:16]};

// Clipping
assign S0C = S0Shift[31]? 8'd0:|S0Shift[15:8]? 8'd255:S0Shift[7:0];
assign S1C = S1Shift[31]? 8'd0:|S1Shift[15:8]? 8'd255:S1Shift[7:0];
assign S2C = S2Shift[31]? 8'd0:|S2Shift[15:8]? 8'd255:S2Shift[7:0];
assign S3C = S3Shift[31]? 8'd0:|S3Shift[15:8]? 8'd255:S3Shift[7:0];

// Shifting by 2^8
assign T0S = {{8{T0T[31]}}, T0T[31:8]};
assign T1S = {{8{T1T[31]}}, T1T[31:8]};
assign T2S = {{8{T2[31]}}, T2[31:8]};
assign T3S = {{8{T3[31]}}, T3[31:8]};

// Initialized registers for the dual port rams
logic [6:0] address_0a, address_0b, address_1a, address_1b, address_2a, address_2b;
logic [31:0] write_data_a [2:0];
logic [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];

// instantiate RAM0
dual_port_RAM RAM_inst0 (
	.address_a ( address_0a ),
	.address_b ( address_0b ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( write_enable_a[0]),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

// instantiate RAM1
dual_port_RAM RAM_inst1 (
	.address_a ( address_1a ),
	.address_b ( address_1b ),
	.clock ( Clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( write_enable_a[1] ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);
	
// instantiate RAM2
dual_port_RAM RAM_inst2 (
	.address_a ( address_2a ),
	.address_b ( address_2b ),
	.clock ( Clock ),
	.data_a ( write_data_a[2] ),
	.data_b ( write_data_b[2] ),
	.wren_a ( write_enable_a[2] ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);

// Instantiating 4 multipliers for use 
assign M1ResultLong = M1a * M1b;
assign M1Result = M1ResultLong[31:0];

assign M2ResultLong = M2a * M2b;
assign M2Result = M2ResultLong[31:0];

assign M3ResultLong = M3a * M3b;
assign M3Result = M3ResultLong[31:0];

assign M4ResultLong = M4a * M4b;
assign M4Result = M4ResultLong[31:0];

always_comb begin
	// Initialized registers
	M1a = 32'd0;
	M1b = 32'd0;
	M2a = 32'd0;
	M2b = 32'd0;
	M3a = 32'd0;
	M3b = 32'd0;
	M4a = 32'd0;
	M4b = 32'd0;
	E1 = 32'd0;
	E2 = 32'd0;
	E3 = 32'd0;
	E4 = 32'd0;
	T0T = 32'd0;
	T1T = 32'd0;
	S0T = 32'd0;
	S1T = 32'd0;
	WriteData = 16'd0;
	
	// Writing and reading for various common cases
	if (state == S_M2_COMMONCASE0) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
		
		// Writing T2 and T3 to Ram 2 (after shifting)
		write_data_a[2] = T2S;
		write_data_b[2] = T3S;
		
	end else if(state == S_M2_COMMONCASE1) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
		
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE2) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE3) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE4) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE5) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE6) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
	
	end else if(state == S_M2_COMMONCASE7) begin
		if (flag == 1'b0) begin
			// Writing the Y values into ram for temp storage
			write_data_a[0] = SEReadData;
			
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for first 4 columns of C matrix
			M1a = SEReadData;
			M1b = SE1;
			M2a = SEReadData;
			M2b = SE2;
			M3a = SEReadData;
			M3b = SE3;
			M4a = SEReadData;
			M4b = SE4;
			
		end else begin
		
			// Sign Extending for C Matrix
			E1 = read_data_a[1][31:16];
			E2 = read_data_a[1][15:0];
			E3 = read_data_b[1][31:16];
			E4 = read_data_b[1][15:0];
			
			// Setting Up Multiplication for last 4 columns of C matrix
			M1a = read_data_b[0];
			M1b = SE1;
			M2a = read_data_b[0];
			M2b = SE2;
			M3a = read_data_b[0];
			M3b = SE3;
			M4a = read_data_b[0];
			M4b = SE4;
			
		end
		
		// Writing T0 and T1 to Ram 2 (after shifting)
		T0T = T0Acc + M1Result;
		T1T = T1Acc + M2Result;
		write_data_a[2] = T0S;
		write_data_b[2] = T1S;
	
	
	// Second MEGA Common Case State
	end else if(state == S_M2_COMMONCASE8) begin
		
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
		
		// Clipping and storing the values of S to ram 0
		if (flag2 < 2'd2) begin
			write_data_a[0] = S2C;
			write_data_b[0] = S3C;
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd2) begin
			S1T = S1;
			
			WriteData = {read_data_a[0][7:0],S1C};
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd3) begin
			S1T = S1;
			
			WriteData = {read_data_a[0][7:0],S1C};
		end
		
	
	end else if(state == S_M2_COMMONCASE9) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd3) begin
			
			WriteData = {read_data_a[0][7:0],S2C};
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'b0) begin
			
			WriteData = {read_data_a[0][7:0],S2C};
		end
	
	end else if(state == S_M2_COMMONCASE10) begin
		
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd3) begin
			
			WriteData = {read_data_a[0][7:0],S3C};
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'b0) begin
			
			WriteData = {read_data_a[0][7:0],S3C};
		end
	
	end else if(state == S_M2_COMMONCASE11) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
	
	end else if(state == S_M2_COMMONCASE12) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
	
	end else if(state == S_M2_COMMONCASE13) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
	
	end else if(state == S_M2_COMMONCASE14) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
	
	end else if(state == S_M2_COMMONCASE15) begin
	
		// Sign Extending for C Matrix
		E1 = read_data_a[1][31:16];
		E2 = read_data_a[1][15:0];
		E3 = read_data_b[1][31:16];
		E4 = read_data_b[1][15:0];
		
		// Setting Up Multiplication for C and T matrixes
		M1a = read_data_a[2];
		M1b = SE1;
		M2a = read_data_a[2];
		M2b = SE2;
		M3a = read_data_a[2];
		M3b = SE3;
		M4a = read_data_a[2];
		M4b = SE4;
		
		// Clipping and storing the values of S to ram 0
		if (flag2 < 2'd2) begin
		
			S0T = S0Acc + M1Result;
			S1T = S1Acc + M2Result;
			write_data_a[0] = S0C;
			write_data_b[0] = S1C;
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd2) begin
			S0T = S0Acc + M1Result;
		
			WriteData = {read_data_a[0][7:0],S0C};
		end
		
		// Writing the values of S sets to SRAM
		if (flag2 == 2'd3) begin
			S0T = S0Acc + M1Result;
		
			WriteData = {read_data_a[0][7:0],S0C};
		end
		
	
	end
	
end

always_ff@(posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	
		// Initialized Registers
		state <= S_M2_IDLE;
		write_enable_a[0] <= 1'b0;
		write_enable_a[1] <= 1'b0;	
		write_enable_a[2] <= 1'b0;	
		write_enable_b[0] <= 1'b0;
		write_enable_b[1] <= 1'b0;
		write_enable_b[2] <= 1'b0;
		address_0a <= 7'b0;
		address_0b <= 7'b0;
		address_1a <= 7'b0;
		address_1b <= 7'b0;
		address_2a <= 7'b0;
		address_2b <= 7'b0;
		SRAM_Address <= 18'd0;
		Wen <= 1'b1;
		StopBit <= 1'b0;
		en <= 1'b0;
		sc <= 6'b0;
		cb <= 6'b0;
		rb <= 5'b0;
		flag <= 1'b0;
		flag2 <= 1'b0;
		counter1 <= 8'b0;
		T0Acc <= 32'b0;
		T1Acc <= 32'b0;
		T2Acc <= 32'b0;
		T3Acc <= 32'b0;
		T0 <= 32'b0;
		T1 <= 32'b0;
		T2 <= 32'b0;
		T3 <= 32'b0;
		S0Acc <= 32'b0;
		S1Acc <= 32'b0;
		S2Acc <= 32'b0;
		S3Acc <= 32'b0;
		S0 <= 32'b0;
		S1 <= 32'b0;
		S2 <= 32'b0;
		S3 <= 32'b0;
		firstTime <= 1'b1;
		S_Address <= 18'b0;
		SWriteAddress <= 6'b0;
		SReadAddress <= 6'b0;
		
	end else begin
	
		// Address generator for y,u and v values:
		if (en != 1'b0) begin
			sc <= sc + 6'b1;
		end
		
		if (sc == 6'd63 && en != 1'b0) begin
			if (cb == 6'd39) begin
				cb <= 6'b0;
			end else begin
				cb <= cb + 6'b1;
			end
			
		end
		
		if (sc == 6'd63 && en != 1'b0 && cb == 6'd39) begin
			if (rb == 5'd29) begin
				rb <= 5'b0;
			end else begin
				rb <= rb + 5'b1;
			end
		end
		
		// M2 Idle
	
		case (state)
			S_M2_IDLE: begin
				if (StartBit == 1'b1) begin
					// ReInitializing registers for multiple iterations
					firstTime <= 1'b1;
					SWriteAddress <= 6'b0;
					SReadAddress <= 6'b0;
					en <= 1'b1;
					write_enable_a[0] <= 1'b0;
					write_enable_a[1] <= 1'b0;	
					write_enable_a[2] <= 1'b0;	
					write_enable_b[0] <= 1'b0;
					write_enable_b[1] <= 1'b0;
					write_enable_b[2] <= 1'b0;
					T0Acc <= 32'b0;
					T1Acc <= 32'b0;
					T2Acc <= 32'b0;
					T3Acc <= 32'b0;
					T0 <= 32'b0;
					T1 <= 32'b0;
					T2 <= 32'b0;
					T3 <= 32'b0;
					S0Acc <= 32'b0;
					S1Acc <= 32'b0;
					S2Acc <= 32'b0;
					S3Acc <= 32'b0;
					S0 <= 32'b0;
					S1 <= 32'b0;
					S2 <= 32'b0;
					S3 <= 32'b0;
					address_0a <= 7'b0;
					address_0b <= 7'b0;
					address_1a <= 7'b0;
					address_1b <= 7'b0;
					address_2a <= 7'b0;
					address_2b <= 7'b0;
					flag <= 1'b0;
					SRAM_Address <= Y_Address;
					state <= S_M2_LEADINDELAY;
				end
			end
			
			// Lead In Cases
			
			S_M2_LEADINDELAY: begin
				SRAM_Address <= Y_Address;
				
				state <= S_M2_LEADIN0;
			end
			
			S_M2_LEADIN0: begin
				SRAM_Address <= Y_Address;
				
				// Initializing the address of ram 1 for C reads
				address_1a <= 7'd0;
				address_1b <= 7'd1;
				
				state <= S_M2_LEADIN1;
			end
			
			S_M2_LEADIN1: begin
				SRAM_Address <= Y_Address;
				
				// Enabling port a for ram 1 to writing, and port b for reading.
				write_enable_a[0] <= 1'b1; // Writing
				write_enable_b[0] <= 1'b0; // Reading
				
				// Initializing the address of ram 1 for C reads
				address_1a <= 7'd4;
				address_1b <= 7'd5;
				
				// Initializing the address of ram 2 for T writes
				address_2a <= 7'b0;
				address_2b <= 7'b1;
				
				// Initialzing firstTime to 1
				firstTime <= 1'b1;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE0;
				
			end
			
			// Common Cases
			
			// Fetch S' and Compute T
			
			S_M2_COMMONCASE0: begin
				if (flag == 1'b0) begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd8;
					address_1b <= 7'd9;
					
				end else begin
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd10;
					address_1b <= 7'd11;
					
				end
				
				// Checking if the 
				if (firstTime == 1'b0) begin
					
					// Disabling both ram 2 ports for writing
					write_enable_a[2] <= 1'b0;
					write_enable_b[2] <= 1'b0;
					
					// Setting the address for writing T values for ram 2 for the next iteration
					address_2a <= address_2a + 7'd2;
					address_2b <= address_2b + 7'd2;
					
				end else begin
				
					firstTime <= 1'b0;
					
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
								
				counter1 <= counter1 + 8'b1;
				
				// Exit Common Case 1 iteration
				if (counter1 == 8'd129) begin
					
					// Initializing the address of ram 1 for C reads
					address_1a <= 7'd0;
					address_1b <= 7'd1;
					
					// Initializing the address of ram 2 for T reads
					address_2a <= 7'd0;
					
					write_enable_a[2] <= 1'b0;
					write_enable_b[2] <= 1'b0;
					
					state <= S_M2_COMMONCASEDELAY;
				end else begin
					state <= S_M2_COMMONCASE1;
				end
			end
			
			S_M2_COMMONCASE1: begin
				if (flag == 1'b0) begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd12;
					address_1b <= 7'd13;
					
				end else begin
				
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd14;
					address_1b <= 7'd15;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE2;
			end
			
			S_M2_COMMONCASE2: begin
				if (flag == 1'b0) begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd16;
					address_1b <= 7'd17;
					
				end else begin
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd18;
					address_1b <= 7'd19;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE3;
			end
			
			S_M2_COMMONCASE3: begin
				if (flag == 1'b0) begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd20;
					address_1b <= 7'd21;
					
				end else begin
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd22;
					address_1b <= 7'd23;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE4;
			end
			
			S_M2_COMMONCASE4: begin
				if (flag == 1'b0) begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd24;
					address_1b <= 7'd25;
					en <= 1'b0;
					
				end else begin
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd26;
					address_1b <= 7'd27;
					en <= 1'b1;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				if (counter1 == 125) begin
					en <= 1'b0;
				end
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE5;
			end
			
			S_M2_COMMONCASE5: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd28;
					address_1b <= 7'd29;
					
				end else begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd30;
					address_1b <= 7'd31;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE6;
			end
			
			S_M2_COMMONCASE6: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_1a <= 7'd2;
					address_1b <= 7'd3;
				end else begin
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd0;
					address_1b <= 7'd1;
				end
				
				// Multiplication Accumulation
				T0Acc <= T0Acc + M1Result;
				T1Acc <= T1Acc + M2Result;
				T2Acc <= T2Acc + M3Result;
				T3Acc <= T3Acc + M4Result;
				
				// Enabling both ram 2 ports for writing
				write_enable_a[2] <= 1'b1;
				write_enable_b[2] <= 1'b1;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE7;
			end
			
			S_M2_COMMONCASE7: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					address_0b <= address_0b + 7'b1;
					address_1a <= 7'd6;
					address_1b <= 7'd7;
					
				end else begin
				
					SRAM_Address <= Y_Address;
					
					// Incrementing Addresses
					address_1a <= 7'd4;
					address_1b <= 7'd5;
					
				end
				
				
				flag <= ~flag;
				
				// Turning off writing for ram 1 port 1 every other common case iteration
				write_enable_a[0] <= ~write_enable_a[0];
				
				// Multiplication Accumulation (finished)
				T0 <= T0Acc + M1Result;
				T1 <= T1Acc + M2Result;
				T2 <= T2Acc + M3Result;
				T3 <= T3Acc + M4Result;
				
				// Resetting Accumulation register to zero for next iteration
				T0Acc <= 32'b0;
				T1Acc <= 32'b0;
				T2Acc <= 32'b0;
				T3Acc <= 32'b0;
				
				// Setting the address for writing T values into ram 2
				address_2a <= address_2a + 7'd2;
				address_2b <= address_2b + 7'd2;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE0;
				
				
			end
			
			// Delay Inbetween common cases for syncing:
			S_M2_COMMONCASEDELAY: begin
			
				// Initializing the address of ram 0 for S writes
				address_0a <= 7'd0;
				address_0b <= 7'd1;
				
				// Initializing the address of ram 1 for C reads
				address_1a <= 7'd4;
				address_1b <= 7'd5;
					
				// Initializing the address of ram 2 for T reads
				address_2a <= 7'd8;
					
				flag <= 1'b0;
				flag2 <= 1'b0;
					
				firstTime <= 1'b1;
				
				SRAM_Address <= S_Address;
				
				counter1 <= 8'b1;
				state <= S_M2_COMMONCASE8;
				
			end
			
			// Compute S and Write S MEGA States
			
			S_M2_COMMONCASE8: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd8;
					address_1b <= 7'd9;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd10;
					address_1b <= 7'd11;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				if (firstTime == 1'b0) begin
				
					flag2 <= flag2 + 1'd1;
					
					// Preparing the storage of s values if s sets are not calculated yet.
					if (flag2 < 2'd2) begin
					
						write_enable_a[0] <= 1'b0;
						write_enable_b[0] <= 1'b0;
						
						// Incrementing Addresses
						address_0a <= address_0a + 7'd2;
						address_0b <= address_0b + 7'd2;
						
						// Save the S write address for port a
						SWriteAddress <= address_0a + 7'd2;
						
					end
				
				end 
				
				// Preparing for writing S sets to SRAM
				if (flag2 > 2'd1) begin
					address_0a <= address_0a + 7'b1;
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd2) begin
					SRAM_Address <= SRAM_Address + 18'd160;
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd3) begin
					SRAM_Address <= SRAM_Address + 18'd160;
				end
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE9;
			end
			
			S_M2_COMMONCASE9: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd12;
					address_1b <= 7'd13;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd14;
					address_1b <= 7'd15;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				if (flag2 == 2'd3) begin
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'b1;
					
				end
				
				if (firstTime == 1'b0) begin
					if (flag2 == 2'd0) begin
						
						// Incrementing Addresses
						SReadAddress <= address_0a + 7'b1;
						address_0a <= SWriteAddress;
						SRAM_Address <= SRAM_Address + 18'd160;
					end
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd3) begin
					SRAM_Address <= SRAM_Address + 18'd160;
				end
				
				// Incrementing Addresses
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE10;
			end
			
			S_M2_COMMONCASE10: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd16;
					address_1b <= 7'd17;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd18;
					address_1b <= 7'd19;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				if (firstTime == 1'b0) begin
					if (flag2 == 2'd0) begin
						
						SRAM_Address <= SRAM_Address - 18'd1119;
						Wen <= 1'b1;
					end
				end else begin
				
					firstTime = 1'b0;
					
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd3) begin
					SRAM_Address <= SRAM_Address + 18'd160;
					Wen <= 1'b1;
				end
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				
				
				// Exit Condition
				if (counter1 == 8'd131) begin
				
					// Resetting Accumulation register to zero for next iteration
					S0Acc <= 32'b0;
					S1Acc <= 32'b0;
					S2Acc <= 32'b0;
					S3Acc <= 32'b0;
					
					
					S_Address <= S_Address + 18'd4;
					counter1 <= 8'd0;
					
					// Go to M2_Idle again
					state <= S_M2_IDLE;
				end else begin
					state <= S_M2_COMMONCASE11;
				end
			end
			
			S_M2_COMMONCASE11: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd20;
					address_1b <= 7'd21;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd22;
					address_1b <= 7'd23;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE12;
			end
			
			S_M2_COMMONCASE12: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd24;
					address_1b <= 7'd25;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd26;
					address_1b <= 7'd27;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE13;
			end
			
			S_M2_COMMONCASE13: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd28;
					address_1b <= 7'd29;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd30;
					address_1b <= 7'd31;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				if (flag2 == 2'd2) begin
					address_0a <= SReadAddress;
				end
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE14;
			end
			
			S_M2_COMMONCASE14: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd2;
					address_1b <= 7'd3;
					address_2a <= address_2a - 7'd56;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd0;
					address_1b <= 7'd1;
					address_2a <= address_2a - 7'd55;
					
				end
				
				// Multiplication Accumulation
				S0Acc <= S0Acc + M1Result;
				S1Acc <= S1Acc + M2Result;
				S2Acc <= S2Acc + M3Result;
				S3Acc <= S3Acc + M4Result;
				
				// Preparing the storage of s values if s sets are not calculated yet.
				if (flag2 < 2'd2) begin
					
					write_enable_a[0] <= 1'b1;
					write_enable_b[0] <= 1'b1;
					
				end
				
				// Preparing for writing S sets to SRAM
				if (flag2 > 2'd1) begin
					address_0a <= address_0a + 7'b1;
				end
				
				// Updating Wen of Sram for writing S-set
				if (flag2 == 2'd2) begin
					Wen <= 1'b0;
				end
				
				if (flag2 == 2'd3) begin
					Wen <= 1'b0;
				end
				
				counter1 <= counter1 + 8'b1;
				state <= S_M2_COMMONCASE15;
			end
			
			S_M2_COMMONCASE15: begin
				if (flag == 1'b0) begin
					
					// Incrementing Addresses
					address_1a <= 7'd6;
					address_1b <= 7'd7;
					
				end else begin
					
					// Incrementing Addresses
					address_1a <= 7'd4;
					address_1b <= 7'd5;
					
				end
				
				// Multiplication Accumulation (finished)
				S0 <= S0Acc + M1Result;
				S1 <= S1Acc + M2Result;
				S2 <= S2Acc + M3Result;
				S3 <= S3Acc + M4Result;
				
				// Resetting Accumulation register to zero for next iteration
				S0Acc <= 32'b0;
				S1Acc <= 32'b0;
				S2Acc <= 32'b0;
				S3Acc <= 32'b0;
				
				// Preparing the storage of s values if s sets are not calculated yet.
				if (flag2 < 2'd2) begin
					
					// Incrementing Addresses
					address_0a <= address_0a + 7'd2;
					address_0b <= address_0b + 7'd2;
					
				end
				
				// Preparing for writing S sets to SRAM
				if (flag2 > 2'd1) begin
					address_0a <= address_0a + 7'b1;
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd2) begin
					SRAM_Address <= SRAM_Address + 18'd160;
				end
				
				// Updating the address of Sram for writing S-set
				if (flag2 == 2'd3) begin
					SRAM_Address <= SRAM_Address + 18'd160;
				end
				
				flag <= ~flag;
				
				// Incrementing Address
				address_2a <= address_2a + 7'd8;
				
				counter1 <= counter1 + 8'b1;
				
				state <= S_M2_COMMONCASE8;
				
			end
			
			// Leadout Cases
			
			S_M2_LEADOUT0: begin
			
				state <= S_M2_LEADOUT1;
			end
			
			S_M2_LEADOUT1: begin
			
				state <= S_M2_LEADOUT2;
			end
			
			S_M2_LEADOUT2: begin
			
				state <= S_M2_LEADOUT3;
			end
			
			S_M2_LEADOUT3: begin
				
				// Enable Stop bit
				StopBit <= 1'b1;
				
				// Go to idle state
				state <= S_M2_IDLE;
			end
			
			default: state <= S_M2_IDLE;
			
		endcase
	end
end

endmodule