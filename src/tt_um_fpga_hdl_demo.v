\m5_TLV_version 1d --inlineGen --noDirectiveComments --noline --clkAlways --bestsv --debugSigsYosys: tl-x.org
\m5
   use(m5-1.0)
   

   // #################################################################
   // #                                                               #
   // #  Starting-Point Code for MEST Course Tiny Tapeout Calculator  #
   // #                                                               #
   // #################################################################
   
   // ========
   // Settings
   // ========
   
   //-------------------------------------------------------
   // Build Target Configuration
   //
   // To build within Makerchip for the FPGA or ASIC:
   //   o Use first line of file: \m5_TLV_version 1d --inlineGen --noDirectiveComments --noline --clkAlways --bestsv --debugSigsYosys: tl-x.org
   //   o set(MAKERCHIP, 0)  // (below)
   //   o For ASIC, set my_design (below) to match the configuration of your repositoy: tt_um_template
   //       - tt_um_fpga_hdl_demo for tt_fpga_hdl_demo repo
   //       - tt_um_example for tt06_verilog_template repo
   //   o var(target, FPGA)  // or ASIC (below)
   set(MAKERCHIP, 0)   /// 1 for simulating in Makerchip.
   var(my_design, tt06_verilog_template)   /// The name of your top-level TT module, to match your info.yml.
   var(target, ASIC)  /// FPGA or ASIC
   //-------------------------------------------------------
   
   var(debounce_inputs, 0)         /// 1: Provide synchronization and debouncing on all input signals.
                                   /// 0: Don't provide synchronization and debouncing.
                                   /// m5_neq(m5_MAKERCHIP, 1): Debounce unless in Makerchip.
   
   // ======================
   // Computed From Settings
   // ======================
   
   // If debouncing, a user's module is within a wrapper, so it has a different name.
   var(user_module_name, m5_if(m5_debounce_inputs, my_design, m5_my_design))
   var(debounce_cnt, m5_if_eq(m5_MAKERCHIP, 1, 8'h03, 8'hff))

\SV
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/tlv_lib/calculator_shell_lib.tlv)
   // Include Tiny Tapeout Lab.
   m4_include_lib(https:/['']/raw.githubusercontent.com/os-fpga/Virtual-FPGA-Lab/35e36bd144fddd75495d4cbc01c4fc50ac5bde6f/tlv_lib/tiny_tapeout_lib.tlv)
   m4_include_lib(https:/['']/raw.githubusercontent.com/efabless/chipcraft---mest-course/main/reference_designs/PmodKYPD.tlv)

\TLV calc()
   
   |calc
      
      
      
      m5+PmodKYPD(|calc, /keypad, @0, $ui_in[3:0], 1'b1, ['left: 40, top: 80, width: 20, height: 20'])
      @0
         $reset = *reset || ($op == 3'b111) ;
         // using switches
         $ui_in[3:0] = *ui_in[3:0];
         
         $op[2:0] = *ui_in[6:4];
         //$op[2:0] = $rand;
         
         $equals_in = *ui_in[7];
         
      @1   
         $val1[7:0] = >>2$out[7:0];
         $val2[7:0] = {4'b0000, /keypad$digit_pressed};
      @2   
         //Counter 
         $valid = (($equals_in == 1) && (>>1$equals_in == 0)); //? 1 : 0;
         //$valid = $reset ? 0 : >>1$valid + 1; 
         //$cnt = $reset ? 0 : >>1$cnt + 1;
         //$valid = $cnt;
         $valid_or_reset = $valid || $reset;
         ?$valid_or_reset
            //MUX input computations
            $sum[7:0] = $val1[7:0] + $val2; // $val1[7:0] could be expressed as $val1
            $diff[7:0] = $val1[7:0] - $val2;
            $prod[7:0] = $val1[7:0] * $val2;
            $quot[7:0] = $val1[7:0] / $val2;
         
         
         
      @3
         //Encoded MUX
         $out[7:0] =
            $reset
               ? 8'b0 :
            !$valid
               ? >>1$out :
            $op[2:0] == 3'b100
               ? >>2$mem[7:0] :
            $op[2:0] == 3'b011
               ? $quot[7:0] :
            $op[2:0] == 3'b010
               ? $prod[7:0] :
            $op[2:0] == 3'b001
               ? $diff[7:0] :
            $op[2:0] == 3'b000
               ? $sum[7:0] :
               //default
               >>1$out[7:0];
         //mem MUX
         $mem[7:0] =
            $reset
               ? 8'b0 :
            !$valid
               ? >>1$mem :
            $op[2:0] == 3'b101
               ? >>2$out :
               //default
               >>1$mem;
         
         
      @4
         //m5+sseg_decoder($segments_n, /keypad$digit_pressed)
         
         
         
         
         
         
         $digit_one[3:0] = $out[3:0];
         $out_digitone[7:0] =
            $digit_one == 4'h0 //2'b0000 
               ? 8'b10111111 ://0
            $digit_one == 4'h1 //2'b0001
               ? 8'b10000110 ://1
            $digit_one == 4'h2
               ? 8'b11011011 ://2
            $digit_one == 4'h3
               ? 8'b11001111 ://3
            $digit_one == 4'h4
               ? 8'b11100110 ://4
            $digit_one == 4'h5
               ? 8'b11101101 ://5
            $digit_one == 4'h6
               ? 8'b11111101 ://6
            $digit_one == 4'h7
               ? 8'b10000111 ://7
            $digit_one == 4'h8
               ? 8'b11111111 ://8
            $digit_one == 4'h9
               ? 8'b11101111 ://9
            $digit_one == 4'ha
               ? 8'b11110111 ://a
            $digit_one == 4'hb
               ? 8'b11111100 ://b
            $digit_one == 4'hc
               ? 8'b10111001 ://c
            $digit_one == 4'hd
               ? 8'b11011110 ://d
            $digit_one == 4'he
               ? 8'b11111001 ://e
            $digit_one == 4'hf
               ? 8'b11110001 ://f
            //default
               8'b00000000;  //.
         
         $digit_ten[3:0] = $out[7:4];
         $out_digitten[7:0] =
            $digit_ten == 4'h0 //2'b0000 
               ? 8'b00111111 ://0
            $digit_ten == 4'h1 //2'b0001
               ? 8'b00000110 ://1
            $digit_ten == 4'h2
               ? 8'b01011011 ://2
            $digit_ten == 4'h3
               ? 8'b01001111 ://3
            $digit_ten == 4'h4
               ? 8'b01100110 ://4
            $digit_ten == 4'h5
               ? 8'b01101101 ://5
            $digit_ten == 4'h6
               ? 8'b01111101 ://6
            $digit_ten == 4'h7
               ? 8'b00000111 ://7
            $digit_ten == 4'h8
               ? 8'b01111111 ://8
            $digit_ten == 4'h9
               ? 8'b01101111 ://9
            $digit_ten == 4'ha
               ? 8'b01110111 ://a
            $digit_ten == 4'hb
               ? 8'b01111100 ://b
            $digit_ten == 4'hc
               ? 8'b00111001 ://c
            $digit_ten == 4'hd
               ? 8'b01011110 ://d
            $digit_ten == 4'he
               ? 8'b01111001 ://e
            $digit_ten == 4'hf
               ? 8'b01110001 ://f
            //default
               8'b00000000;  //nothing
         
         $digit_flash[26:0] = $valid ? 0 : >>1$digit_flash + 1;
         
         
         
         *uo_out = /keypad$sampling ? {2{/keypad$sample_row_mask[3:0]}} :
                   $digit_flash[25]
                      ? $out_digitone :
         
                        $out_digitten;
         
   
   // Note that pipesignals assigned here can be found under /fpga_pins/fpga.
   
   

   //m5+cal_viz(@3, /fpga) // un-comment for markerchip comment out for FPGA programming 
   
   // Connect Tiny Tapeout outputs. Note that uio_ outputs are not available in the Tiny-Tapeout-3-based FPGA boards.
   m5_if_neq(m5_target, FPGA, ['*uio_out = 8'b0;'])
   m5_if_neq(m5_target, FPGA, ['*uio_oe = 8'b0;'])
   
\SV

// ================================================
// A simple Makerchip Verilog test bench driving random stimulus.
// Modify the module contents to your needs.
// ================================================

module top(input logic clk, input logic reset, input logic [31:0] cyc_cnt, output logic passed, output logic failed);
   // Tiny tapeout I/O signals.
   logic [7:0] ui_in, uo_out;
   m5_if_neq(m5_target, FPGA, ['logic [7:0]uio_in,  uio_out, uio_oe;'])
   logic [31:0] r;
   always @(posedge clk) r <= m5_if(m5_MAKERCHIP, ['$urandom()'], ['0']);
   assign ui_in = r[7:0];
   m5_if_neq(m5_target, FPGA, ['assign uio_in = 8'b0;'])
   logic ena = 1'b0;
   logic rst_n = ! reset;
   
   // Instantiate the Tiny Tapeout module.
   m5_user_module_name tt(.*);
   
   assign passed = top.cyc_cnt > 400;
   assign failed = 1'b0;
endmodule


// Provide a wrapper module to debounce input signals if requested.
m5_if(m5_debounce_inputs, ['m5_tt_top(m5_my_design)'])
\SV



// =======================
// The Tiny Tapeout module
// =======================

module m5_user_module_name (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    m5_if_eq(m5_target, FPGA, ['/']['*'])   // The FPGA is based on TinyTapeout 3 which has no bidirectional I/Os (vs. TT6 for the ASIC).
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    m5_if_eq(m5_target, FPGA, ['*']['/'])
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
   wire reset = ! rst_n;
   
\TLV
   /* verilator lint_off UNOPTFLAT */
   // Connect Tiny Tapeout I/Os to Virtual FPGA Lab.
   m5+tt_connections()
   
   // Instantiate the Virtual FPGA Lab.
   m5+board(/top, /fpga, 7, $, , calc)
   // Label the switch inputs [0..7] (1..8 on the physical switch panel) (top-to-bottom).
   m5+tt_input_labels_viz(['"Value[0]", "Value[1]", "Value[2]", "Value[3]", "Op[0]", "Op[1]", "Op[2]", "="'])//switches
   //m5+tt_input_labels_viz(['"KYPD row0", "KYPD row1", "KYPD row2", "KYPD row3", "D:Mask", "D:High/Dbg", "D:Reported", "Reset"'])

\SV
endmodule

