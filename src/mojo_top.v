module mojo_top(
    // 50MHz clock input
    input clk,
    // Input from reset button (active low)
    input rst_n,
    // cclk input from AVR, high when AVR is ready
    input cclk,
    // Outputs to the 8 onboard LEDs
    output[7:0]led,
    // AVR SPI connections
    output spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    // AVR ADC channel select
    output [3:0] spi_channel,
    // Serial connections
    input avr_tx, // AVR Tx => FPGA Rx
    output avr_rx, // AVR Rx => FPGA Tx
    input avr_rx_busy, // AVR Rx buffer full
	 
	 output R0,
	 output G0,
	 output B0,
	 output R1,
	 output G1,
	 output B1,
	 output A,
	 output B,
	 output C,
	 output D,
	 output MATCLK,
	 output MATLAT,
	 output MATOE
    );

wire rst = ~rst_n; // make reset active high

// these signals should be high-z when not used
assign spi_miso = 1'bz;
assign avr_rx = 1'bz;
assign spi_channel = 4'bzzzz;

assign led[6:0] = 7'b0;


wire [7:0] tx_data;
wire new_tx_data;
wire tx_busy;
wire [7:0] rx_data;
wire new_rx_data;

reg [23:0] counter10;

always @ (posedge clk or posedge rst)
begin
	if (rst)
	begin
		counter10 <= 0;
	end
	else
	begin
		counter10 <= counter10 + 1;
	end
end

assign led[7] = counter10[23];
 
avr_interface avr_interface (
    .clk(clk),
    .rst(rst),
    .cclk(cclk),
    .spi_miso(spi_miso),
    .spi_mosi(spi_mosi),
    .spi_sck(spi_sck),
    .spi_ss(spi_ss),
    .spi_channel(spi_channel),
    .tx(avr_rx), // FPGA tx goes to AVR rx
    .rx(avr_tx),
    .channel(4'd15), // invalid channel disables the ADC
    .new_sample(),
    .sample(),
    .sample_channel(),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .tx_block(avr_rx_busy),
    .rx_data(rx_data),
    .new_rx_data(new_rx_data)
);
 
message_printer helloWorldPrinter (
    .clk(clk),
    .rst(rst),
    .tx_data(tx_data),
    .new_tx_data(new_tx_data),
    .tx_busy(tx_busy),
    .rx_data(rx_data),
    .new_rx_data(new_rx_data)
);

rgbmatrix rgbmatrix (
    .clk(clk),
    .rst(rst),
    .R0(R0),
	 .G0(G0),
	 .B0(B0),
    .R1(R1),
	 .G1(G1),
	 .B1(B1),
	 .A(A),
	 .B(B),
	 .C(C),
	 .D(D),
	 .MATCLK(MATCLK),
	 .MATLAT(MATLAT),
	 .MATOE(MATOE)
);
endmodule