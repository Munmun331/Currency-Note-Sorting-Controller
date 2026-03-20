module note_sorting_controller (
input wire clk,
input wire rst,
input wire note_present,
input wire [2:0] note_code, // 3'b001 = 10, ..., 3'b110 = 500
input wire counterfeit_detected,

input wire operator_reset,
input wire operator_maint_mode,
input wire operator_exit_maint,

input wire serial_read,
output reg [15:0] serial_data,
output reg [6:0] bin_select, // 7 bins (10–500 and reject)

output reg alarm,
// Counters
output reg [15:0] count_10,
output reg [15:0] count_20,
output reg [15:0] count_50,
output reg [15:0] count_100,
output reg [15:0] count_200,
output reg [15:0] count_500,
output reg [31:0] total_amount
);
// FSM states
parameter IDLE = 3'b000;
parameter CHECK = 3'b001;
parameter SORT = 3'b010;
parameter REJECT = 3'b011;
parameter ALARM_STATE = 3'b100;
parameter MAINTENANCE = 3'b101;
reg [2:0] state, next_state;
// Control signals
reg count_en;
reg reset_counters;
// FSM
always @(posedge clk or posedge rst) begin
if (rst)
state <= IDLE;
else
state <= next_state;
end
// FSM Combinational
always @(*) begin
// values
count_en = 0;
reset_counters = 0;
alarm = 0;
bin_select = 7'b0000000;
next_state = state;
case (state)
IDLE: begin
if (operator_maint_mode)
next_state = MAINTENANCE;
else if (note_present)
next_state = CHECK;
end
CHECK: begin
if (counterfeit_detected) begin

next_state = ALARM_STATE;
alarm = 1;
bin_select = 7'b1000000; // Reject bin end else if
(note_code == 3'b000) begin next_state =
REJECT;
bin_select = 7'b1000000; // Reject bin end else
begin
next_state = SORT;
count_en = 1;
case (note_code)
3'b001: bin_select = 7'b0000001; // Bin 0: 10 3'b010:
bin_select = 7'b0000010; // Bin 1: 20 3'b011: bin_select =
7'b0000100; // Bin 2: 50 3'b100: bin_select = 7'b0001000; //
Bin 3: 100
3'b101: bin_select = 7'b0010000; // Bin 4: 200 3'b110:
bin_select = 7'b0100000; // Bin 5: 500 default: bin_select =
7'b1000000; // reject endcase
end
end
SORT: begin
next_state = IDLE;
end
REJECT: begin
next_state = IDLE;
end
ALARM_STATE: begin
alarm = 1;
next_state = IDLE;
end
MAINTENANCE: begin
if (operator_reset)
reset_counters = 1;
if (operator_exit_maint)
next_state = IDLE;
end
default: next_state = IDLE;
endcase
end
// Datapath: Counters
always @(posedge clk) begin
if (rst || reset_counters) begin
count_10 <= 0;
count_20 <= 0;
count_50 <= 0;
count_100 <= 0;
count_200 <= 0;
count_500 <= 0;

total_amount <= 0;
end else if (count_en) begin
case (note_code)
3'b001: begin count_10 <= count_10 + 1; total_amount <= total_amount + 10; end 3'b010: begin
count_20 <= count_20 + 1; total_amount <= total_amount + 20; end 3'b011: begin count_50 <=
count_50 + 1; total_amount <= total_amount + 50; end 3'b100: begin count_100 <= count_100 +
1; total_amount <= total_amount + 100; end
3'b101: begin count_200 <= count_200 + 1; total_amount <= total_amount + 200; end 3'b110:
begin count_500 <= count_500 + 1; total_amount <= total_amount + 500; end default: ;
endcase
end
end
// Serial Read
always @(posedge clk) begin
if (serial_read)
serial_data <= total_amount[15:0];
end
endmodule
