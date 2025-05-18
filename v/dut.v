
`include "defines.vh"
//---------------------------------------------------------------------------
// DUT 
//---------------------------------------------------------------------------
module MyDesign(
//---------------------------------------------------------------------------
//System signals
  input wire reset_n                      ,  
  input wire clk                          ,

//---------------------------------------------------------------------------
//Control signals
  input wire dut_valid                    , 
  output wire dut_ready                   ,

//---------------------------------------------------------------------------
//q_state_input SRAM interface
  output wire                                                q_state_input_sram_write_enable  ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0]  q_state_input_sram_write_address ,
  output wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]     q_state_input_sram_write_data    ,
  output wire [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0]  q_state_input_sram_read_address  , 
  input  wire [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]     q_state_input_sram_read_data     ,

//---------------------------------------------------------------------------
//q_state_output SRAM interface
  output wire                                                q_state_output_sram_write_enable  ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address ,
  output wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_write_data    ,
  output wire [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_read_address  , 
  input  wire [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_read_data     ,

//---------------------------------------------------------------------------
//scratchpad SRAM interface                                                       
  output wire                                                scratchpad_sram_write_enable        ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_write_address       ,
  output wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_write_data          ,
  output wire [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_read_address        , 
  input  wire [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_read_data           ,

//---------------------------------------------------------------------------
//q_gates SRAM interface                                                       
  output wire                                                q_gates_sram_write_enable           ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_write_address          ,
  output wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_write_data             ,
  output wire [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_read_address           ,  
  input  wire [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_read_data              
);

  localparam inst_sig_width = 52;
  localparam inst_exp_width = 11;
  localparam inst_ieee_compliance = 1;

  reg  [inst_sig_width+inst_exp_width : 0] inst_a;
  reg  [inst_sig_width+inst_exp_width : 0] inst_b;
  reg  [inst_sig_width+inst_exp_width : 0] inst_c;
  reg  [2 : 0] inst_rnd;
  wire [inst_sig_width+inst_exp_width : 0] z_inst;
  wire [7 : 0] status_inst;
  
  
  
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
// Registers
//q_state_input SRAM interface
  reg                                                q_state_input_sram_write_enable_r  ;
  //reg [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0]  q_state_input_sram_write_address_r ;
  //reg [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]     q_state_input_sram_write_data_r    ;
  reg [`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0]  q_state_input_sram_read_address_r  ; 
  reg [`Q_STATE_INPUT_SRAM_DATA_UPPER_BOUND-1:0]     q_state_input_sram_read_data_r     ;

//---------------------------------------------------------------------------
//q_state_output SRAM interface
  reg                                                q_state_output_sram_write_enable_r  ;
  reg [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_write_address_r ;
  reg [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_write_data_r    ;
  //reg [`Q_STATE_OUTPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] q_state_output_sram_read_address_r  ; 
  //reg [`Q_STATE_OUTPUT_SRAM_DATA_UPPER_BOUND-1:0]    q_state_output_sram_read_data_r     ;

//---------------------------------------------------------------------------
//scratchpad SRAM interface                                                       
  reg                                                scratchpad_sram_write_enable_r  ;
  reg [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_write_address_r ;
  reg [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_write_data_r    ;
  reg [`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0]     scratchpad_sram_read_address_r  ; 
  reg [`SCRATCHPAD_SRAM_DATA_UPPER_BOUND-1:0]        scratchpad_sram_read_data_r     ;

//---------------------------------------------------------------------------
//q_gates SRAM interface                                                       
  reg                                                q_gates_sram_write_enable_r  ;
  //reg [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_write_address_r ;
  //reg [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_write_data_r    ;
  reg [`Q_GATES_SRAM_ADDRESS_UPPER_BOUND-1:0]        q_gates_sram_read_address_r  ;  
  reg [`Q_GATES_SRAM_DATA_UPPER_BOUND-1:0]           q_gates_sram_read_data_r     ;
  
  reg dut_ready_r;
  
  parameter [7:0] //			FSM Diagram States
	S00 = 8'h0,	  // 				S0
	S01 = 8'h1,	  // 				S1
	S02 = 8'h2,   // 				S2
	S03 = 8'h3,   // 				S3
	S46 = 8'h2e,  //				S46
	
	S19 = 8'h13,  // q=1			S4
	S20 = 8'h14,  // q=1			S5
	S21 = 8'h15,  // q=1			S6
	S22 = 8'h16,  // q=1			S7
	S23 = 8'h17,  // q=1			S8
	S24 = 8'h18,  // q=1			S9
	S25 = 8'h19,  // q=1			S10
	S26 = 8'h1a,  // q=1			S11
	S27 = 8'h1b,  // q=1			S12
	S28 = 8'h1c,  // q=1			S13
	S29 = 8'h1d,  // q=1			S14
	S30 = 8'h1e,  // q=1			S15
			
	S16 = 8'h10,  // q=1			S16
	S17 = 8'h11,  // q=1			S17
	
	
	S31 = 8'h1f,  // q>1   S4		S18
	S32 = 8'h20,  // q>1   S5		S19
	S33 = 8'h21,  // q>1   S6       S20
	S34 = 8'h22,  // q>1   S7       S21
	S35 = 8'h23,  // q>1   S8       S22
	S36 = 8'h24,  // q>1   S9       S23
	S37 = 8'h25,  // q>1   S10      S24
	S38 = 8'h26,  // q>1   S11      S25
	S39 = 8'h27,  // q>1   S12      S26
	S40 = 8'h28,  // q>1   S13      S27
	S41 = 8'h29,  // q>1   S14      S28
	S42 = 8'h2a,  // q>1   S15      S29
	S43 = 8'h2b,  // q>1   S16      S30
	S44 = 8'h2c,  // q>1   S17      S31
	S45 = 8'h2d,  // q>1   S18      S32
	
	S47 = 8'h2f;  // 				S47
	

  reg [7:0] current_state, next_state;
  
    // Select Lines
  reg [1:0] r1_sel					,
			r2_sel					,
			m_sel					,
			q_input_read_addr_sel	,
			q_gate_addr_sel			,
			sp_write_addr_sel		,	
			sp_read_addr_sel		,
			q_output_write_addr_sel	;
			
  reg sp_write_enable_sel			,
	  mac_add_sel					,
	  q_output_write_enable_sel		,
	  hold_sel						;
	  
  reg [63:0] r1, r2;
  reg [63:0] q, state_vector_cnt;		// state_vector_cnt -> rows in state vector matrix i.e., 2**q
  reg [63:0] m_cnt;
  reg [63:0] m;
  
  reg [127:0] accum_ip;  		// input for mac for addition
  wire [127:0] mac_temp_op;		// mac output for the next accumulation of updating the matrix product element

  always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		current_state <= S00;
	end

	else begin
		current_state <= next_state;
	end
		
  end  
  
  
  // CONTROL Path
  always @(*) begin
  r1_sel					  <= 0;
  r2_sel					  <= 0;
  m_sel					  <= 0;
  q_input_read_addr_sel	  <= 0;
  q_gate_addr_sel			  <= 0;
  sp_write_addr_sel		  <= 0;
  sp_read_addr_sel		  <= 0;
  q_output_write_addr_sel   <= 0;
  sp_write_enable_sel		  <= 0;
  mac_add_sel				  <= 0;
  q_output_write_enable_sel	  <= 0;
  next_state  <= 0;
  inst_b   <= 64'h3ff0000000000000;
  inst_c   <= 64'b0;
  inst_rnd <= 3'b0;
  dut_ready_r  <= 0;
  q_state_input_sram_write_enable_r <= 0;
  q_gates_sram_write_enable_r <= 0;
  hold_sel <= 0;
  
  
  case (current_state)
	S00: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 1;
		
		inst_b   <= 64'h3ff0000000000000;
		inst_c   <= 64'b0;
		inst_rnd <= 3'b0;
		
		case(dut_valid)
                1'b0: next_state <= S00;
                1'b1: next_state <= S01;
        endcase
	end
	
	S01: begin
		q_input_read_addr_sel		<= 2'd0;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S46;
	end       

	S46: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd0;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S02;
	end
									
	S02: begin                      
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd0;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b1;
		
		dut_ready_r <= 0;
		next_state <= S03;
		
		/*q <= q_state_input_sram_read_data[127:64];
		state_vector_cnt <= 2**q_state_input_sram_read_data[127:64];
		m <= q_state_input_sram_read_data[63:0];*/
	end                             
									
	S03: begin                      
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd0;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd0;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (q==1)
			next_state <= S19;
		else
			next_state <= S31;
		
	end                             
	
	////////////////////////////////////////// Q==1 //////////////////////////////////////////

	S19: begin                      
		q_input_read_addr_sel		<= 2'd3;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (m==1)
			next_state <= S16;
		else
			next_state <= S20;
		end                       
									
	S20: begin                      
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd0;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		
		next_state <= S21;
	end
	
	S21: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (m_cnt==1)
		next_state <= S28;
		else if (m_cnt==m)
		next_state <= S22;
		else
		next_state <= S26;
	end
	
	S22: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd0;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S29;
	end
	
	S23: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd0;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd1;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S24;
	end
	
	S24: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd3;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (m_cnt==1)
		next_state <= S27;
		else
		next_state <= S25;
	end
	
	S25: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S21;
	end
	
	S26: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S30;
	end
	
	S27: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd0;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S21;
	end
	
	S28: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd1;
		
		dut_ready_r <= 0;
		next_state <= S47;
	end
	
	S29: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd0;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S23;
	end
	
	S30: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S23;
	end
	
	S16: begin
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd0;
		
		dut_ready_r <= 0;
		next_state <= S17;
	end
	
	S17: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S28;
	end
	
	
	////////////////////////////////////////// Q!=1 //////////////////////////////////////////
	S31: begin
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (r2!=3)
			next_state <= S31;
		else if (r2==3 & r1!=1)
			next_state <= S32;
		else
			next_state <= S35;
	end
	
	S32: begin
		q_input_read_addr_sel		<= 2'd3;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (r1==state_vector_cnt)
			next_state <= S33;
		else
			next_state <= S34;
	end
	
	S33: begin
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd0;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S31;
	end
	
	S34: begin
		q_input_read_addr_sel		<= 2'd1;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S31;
	end
	
	S35: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (m_cnt==m)
			next_state <= S36;
		else
			next_state <= S41;
	end
	
	S36: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd0;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd1;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd0;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S37;
	end
	
	S37: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S38;
	end
	
	S38: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if (r2!=3)
			next_state <= S38;
		else if (r2==3 & r1!=1)
			next_state <= S39;
		else if (m_cnt!=1 & r2==3 & r1==1)
			next_state <= S35;
		else
			next_state <= S44;
	end
	
	S39: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd3;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		if(m_cnt!=1)
			next_state <= S40;
		else if (m_cnt==1 & r1==state_vector_cnt)
			next_state <= S42;
		else
			next_state <= S43;
	end
	
	S40: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S38;
	end
	
	S41: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd0;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd1;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd1 ;
		sp_write_addr_sel           <= 2'd1;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S37;
	end
	
	S42: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd0;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S38;
	end
	
	S43: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd1;
		r2_sel						<= 2'd0;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd1;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd1;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd1;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S38;
	end
	
	S44: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd1;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd1 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S45;
	end
	
	S45: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd1 ;
		q_output_write_addr_sel     <= 2'd1;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S47;
	end
	
	S47: begin
		q_input_read_addr_sel		<= 2'd2;
		r1_sel						<= 2'd2;
		r2_sel						<= 2'd2;
		m_sel                       <= 2'd2;
		q_gate_addr_sel             <= 2'd2;
		mac_add_sel                 <= 1'd0 ;
		sp_write_enable_sel         <= 1'd0 ;
		sp_write_addr_sel           <= 2'd2;
		sp_read_addr_sel            <= 2'd2;
		q_output_write_enable_sel   <= 1'd0 ;
		q_output_write_addr_sel     <= 2'd2;
		hold_sel <= 1'b0;
		
		dut_ready_r <= 0;
		next_state <= S00;
	end
	
	
	
	endcase
	end
	
	
	reg [63:0] a1, a2, b1, b2;
	
	// DATA Path
	always @(posedge clk) begin
		// r1
		case(r1_sel)
			2'b00: r1 <= state_vector_cnt;
			2'b01: r1 <= r1 - 1;
			default: r1 <= r1;
		endcase
	
		// r2
		case(r2_sel)
			2'b00: r2 <= state_vector_cnt;
			2'b01: r2 <= r2 - 1;
			default: r2 <= r2;
		endcase
	
		// m_cnt
		case(m_sel)
			2'b00: m_cnt <= m;
			2'b01: m_cnt <= m_cnt - 1;
			default: m_cnt <= m_cnt;
		endcase

		// q_input_read_addr
		case(q_input_read_addr_sel)
			2'b00: q_state_input_sram_read_address_r <= 0;
			2'b01: q_state_input_sram_read_address_r <= q_state_input_sram_read_address_r + 1;
			2'b10: q_state_input_sram_read_address_r <= q_state_input_sram_read_address_r;
			2'b11: q_state_input_sram_read_address_r <= q_state_input_sram_read_address_r - (state_vector_cnt[`Q_STATE_INPUT_SRAM_ADDRESS_UPPER_BOUND-1:0] - 1);
		endcase

		// q_gate_addr
		case(q_gate_addr_sel) 
			2'b00: q_gates_sram_read_address_r <= 0;
			2'b01: q_gates_sram_read_address_r <= q_gates_sram_read_address_r + 1;
			default: q_gates_sram_read_address_r <= q_gates_sram_read_address_r;
		endcase

	// scratchpad_write_enable
		case(sp_write_enable_sel)
			1'b0: begin
				scratchpad_sram_write_enable_r <= 0;
				scratchpad_sram_write_data_r <= 0;
			end
			1'b1: begin
				scratchpad_sram_write_enable_r <= 1;
				scratchpad_sram_write_data_r <= mac_temp_op;
			end
		endcase
	
	// scratchpad_write_addr
		case(sp_write_addr_sel)
			2'b00: scratchpad_sram_write_address_r <= 0;
			2'b01: scratchpad_sram_write_address_r <= scratchpad_sram_write_address_r + 1;
			default: scratchpad_sram_write_address_r <= scratchpad_sram_write_address_r;
		endcase

	// scratchpad_read_addr
		case(sp_read_addr_sel)
			2'b00: scratchpad_sram_read_address_r <= 0;
			2'b01: scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r + 1;
			2'b10: scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r;
			2'b11: scratchpad_sram_read_address_r <= scratchpad_sram_read_address_r - (state_vector_cnt[`SCRATCHPAD_SRAM_ADDRESS_UPPER_BOUND-1:0] - 1);
		endcase
	
	// mac_add_sel
		case(mac_add_sel)
			1'b0: accum_ip = 128'b0;
			1'b1: accum_ip = mac_temp_op;
		endcase 

	// q_output_write_enable
		case(q_output_write_enable_sel)
			1'b0: begin
				q_state_output_sram_write_enable_r = 0;
				q_state_output_sram_write_data_r = 0;
			end
			1'b1: begin
				q_state_output_sram_write_enable_r = 1;
				q_state_output_sram_write_data_r = mac_temp_op;
			end
		endcase

	// q_output_write_addr
		case(q_output_write_addr_sel)
			2'b00: q_state_output_sram_write_address_r = 0;
			2'b01: q_state_output_sram_write_address_r = q_state_output_sram_write_address_r + 1;
			default: q_state_output_sram_write_address_r = q_state_output_sram_write_address_r;
		endcase
		
		case(hold_sel)
			1'b0: begin
				q <= q;
				m <= m;
				state_vector_cnt <= state_vector_cnt;
			end
			1'b1: begin
				q <= q_state_input_sram_read_data[127:64];
				state_vector_cnt <= 2**q_state_input_sram_read_data[127:64];
				m <= q_state_input_sram_read_data[63:0];
			end
		endcase		
	end
	
	always @(*) begin
		a1 = q_gates_sram_read_data[127:64];
		b1 = q_gates_sram_read_data[63:0];
		case(m_cnt==m)
			1'b0: begin
				a2 = scratchpad_sram_read_data[127:64];
				b2 = scratchpad_sram_read_data[63:0];
			end
			1'b1: begin
				a2 = q_state_input_sram_read_data[127:64];
				b2 = q_state_input_sram_read_data[63:0];
			end
		endcase
	end
	
	
	wire [63:0] a1a2, b1b2, a1b2, a2b1;
	reg [63:0] a1a2_r, b1b2_r, a1b2_r, a2b1_r;
	wire [63:0] real_part, imag_part;
	reg [63:0] real_part_r, imag_part_r;
	
	DW_fp_mac_inst FP_MAC1 (a1, a2, inst_c, inst_rnd, a1a2, status_inst);
	DW_fp_mac_inst FP_MAC2 (b1, b2, inst_c, inst_rnd, b1b2, status_inst);
	DW_fp_mac_inst FP_MAC3 (a1, b2, inst_c, inst_rnd, a1b2, status_inst);
	DW_fp_mac_inst FP_MAC4 (b1, a2, inst_c, inst_rnd, a2b1, status_inst);
	
	always @(*) begin
		a1a2_r = a1a2;
		b1b2_r[63] = ~b1b2[63];
		b1b2_r[62:0] = b1b2[62:0];
		a1b2_r = a1b2;
		a2b1_r = a2b1;
	end
		
	
	DW_fp_mac_inst FP_MAC5 (a1a2_r, inst_b, b1b2_r, inst_rnd, real_part, status_inst);
	DW_fp_mac_inst FP_MAC6 (a1b2_r, inst_b, a2b1_r, inst_rnd, imag_part, status_inst);
	
	always @(*) begin
		real_part_r = real_part;
		imag_part_r = imag_part;
	end
	
	DW_fp_mac_inst FP_MAC7 (accum_ip[127:64], inst_b, real_part_r, inst_rnd, mac_temp_op[127:64], status_inst);
	DW_fp_mac_inst FP_MAC8 (accum_ip[63:0], inst_b, imag_part_r, inst_rnd, mac_temp_op[63:0], status_inst);
	
	
	assign q_state_input_sram_write_enable    = q_state_input_sram_write_enable_r  ;
	//assign q_state_input_sram_write_address   = q_state_input_sram_write_address_r ;
	//assign q_state_input_sram_write_data      = q_state_input_sram_write_data_r    ;
	assign q_state_input_sram_read_address    = q_state_input_sram_read_address_r  ;
	//assign q_state_input_sram_read_data       = q_state_input_sram_read_data_r     ;
									
	assign q_state_output_sram_write_enable   = q_state_output_sram_write_enable_r ;
	assign q_state_output_sram_write_address  = q_state_output_sram_write_address_r;
	assign q_state_output_sram_write_data     = q_state_output_sram_write_data_r   ;
	//assign q_state_output_sram_read_address   = q_state_output_sram_read_address_r ;
	//assign q_state_output_sram_read_data      = q_state_output_sram_read_data_r    ;
											
	assign scratchpad_sram_write_enable       = scratchpad_sram_write_enable_r     ;
	assign scratchpad_sram_write_address      = scratchpad_sram_write_address_r    ;
	assign scratchpad_sram_write_data         = scratchpad_sram_write_data_r       ;
	assign scratchpad_sram_read_address       = scratchpad_sram_read_address_r     ;           
	//assign scratchpad_sram_read_data          = scratchpad_sram_read_data_r        ;
										
	assign q_gates_sram_write_enable          = q_gates_sram_write_enable_r        ;
	//assign q_gates_sram_write_address         = q_gates_sram_write_address_r       ;
	//assign q_gates_sram_write_data            = q_gates_sram_write_data_r          ;
	assign q_gates_sram_read_address          = q_gates_sram_read_address_r        ;
	//assign q_gates_sram_read_data             = q_gates_sram_read_data_r           ;
											
	assign dut_ready                          = dut_ready_r                        ;
 				  
				  
                  
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/
/****************************************************************************************************/


  // This is test stub for passing input/outputs to a DP_fp_mac, there many
  // more DW macros that you can choose to use
  /*DW_fp_mac_inst FP_MAC1 ( 
    inst_a,
    inst_b,
    inst_c,
    inst_rnd,
    z_inst,
    status_inst
  );*/
  
  

endmodule


module DW_fp_mac_inst #(
  parameter inst_sig_width = 52,
  parameter inst_exp_width = 11,
  parameter inst_ieee_compliance = 1 // These need to be fixed to decrease error
) ( 
  input wire [inst_sig_width+inst_exp_width : 0] inst_a,
  input wire [inst_sig_width+inst_exp_width : 0] inst_b,
  input wire [inst_sig_width+inst_exp_width : 0] inst_c,
  input wire [2 : 0] inst_rnd,
  output wire [inst_sig_width+inst_exp_width : 0] z_inst,
  output wire [7 : 0] status_inst
);

  // Instance of DW_fp_mac
  DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
    .a(inst_a),
    .b(inst_b),
    .c(inst_c),
    .rnd(inst_rnd),
    .z(z_inst),
    .status(status_inst) 
  );

endmodule

