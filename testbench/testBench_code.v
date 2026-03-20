module tb_note_sorting_controller;
reg clk, rst;
reg note_present;
reg [2:0] note_code;
reg counterfeit_detected;
reg operator_reset;
reg operator_maint_mode;
reg operator_exit_maint;
reg serial_read;
wire [15:0] serial_data;
wire [6:0] bin_select;
wire alarm;
wire [15:0] count_10, count_20, count_50, count_100, count_200, count_500;
wire [31:0] total_amount;
project_vlsi dut (
.clk(clk),
.rst(rst),
.note_present(note_present),

.note_code(note_code),
.counterfeit_detected(counterfeit_detected),
.operator_reset(operator_reset),
.operator_maint_mode(operator_maint_mode),
.operator_exit_maint(operator_exit_maint),
.serial_read(serial_read),
.serial_data(serial_data),
.bin_select(bin_select),
.alarm(alarm),
.count_10(count_10),
.count_20(count_20),
.count_50(count_50),
.count_100(count_100),
.count_200(count_200),
.count_500(count_500),
.total_amount(total_amount)
);

always #5 clk = ~clk;
task process_note(input [2:0] code, input is_counterfeit);
begin
note_code = code;
counterfeit_detected = is_counterfeit;
note_present = 1;
#10;
note_present = 0;
counterfeit_detected = 0;
#20;
end
endtask
initial begin
clk = 0;
rst = 1;
note_present = 0;
note_code = 3'b000;
counterfeit_detected = 0;
operator_reset = 0;
operator_maint_mode = 0;
operator_exit_maint = 0;
serial_read = 0;
#15 rst = 0;

#10 process_note(3'b001, 0); // 10
#10 process_note(3'b011, 0); // 50
#10 process_note(3'b011, 0); // 50
#10 process_note(3'b011, 0); // 50
#10 process_note(3'b100, 0); // 100

// Counterfeit note
#10 process_note(3'b010, 1); // Should trigger alarm
// Unreadable note
#10 process_note(3'b000, 0); // Should be rejected
// Enter maintenance
#10 operator_maint_mode = 1;
#10;
// Try to insert note in maintenance
process_note(3'b001, 0);
// Reset counters
operator_reset = 1;
#10 operator_reset = 0;
// Exit maintenance
operator_maint_mode = 0;
operator_exit_maint = 1;
#10 operator_exit_maint = 0;
// Process one more note
process_note(3'b101, 0); // 200
// Read serial data
serial_read = 1;
#10 serial_read = 0;
#10;
$display("Final total_amount (from serial_data): %d", serial_data);
// Finish simulation
#50;
$finish;
end
endmodule
