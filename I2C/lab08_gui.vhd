library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab08_gui is
	port(
		clk:      in  std_logic;
		rx:       in  std_logic;
		tx:       out std_logic:='1';
		data_in:  out std_logic_vector(7 downto 0):=b"0000_0000";
		data_out: in  std_logic_vector(7 downto 0);
		trig:     out std_logic
	);
end lab08_gui;

architecture arch of lab08_gui is
	signal rx_d1:    std_logic:='1';
	signal rx_d2:    std_logic:='1';
	signal rx_d3:    std_logic:='1';
	signal count:    unsigned(6 downto 0):=b"000_0000";
	signal temp_in:  std_logic_vector(6 downto 0):=b"000_0000";
	signal temp_out: std_logic_vector(7 downto 0):=b"0000_0000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
			-- Metastability shift register
			rx_d1<=rx;
			rx_d2<=rx_d1;
			rx_d3<=rx_d2;
			-- Clock counter
			if (count=b"000_0000") then
				-- Check for start bit
				if (rx_d3='0') then
					count<=b"000_0001";
				end if;
			elsif (count=b"111_1100") then
				-- Check for stop bit
				if (rx_d3='1') then
					count<=b"000_0000";
				end if;
			else
				-- Increment counter
				count<=count+1;
			end if;
			-- Receive data
			if (count=b"001_0100") then
				temp_in(0)<=rx_d3;
			end if;
			if (count=b"010_0001") then
				temp_in(1)<=rx_d3;
			end if;
			if (count=b"010_1110") then
				temp_in(2)<=rx_d3;
			end if;
			if (count=b"011_1011") then
				temp_in(3)<=rx_d3;
			end if;
			if (count=b"100_1000") then
				temp_in(4)<=rx_d3;
			end if;
			if (count=b"101_0101") then
				temp_in(5)<=rx_d3;
			end if;
			if (count=b"110_0010") then
				temp_in(6)<=rx_d3;
			end if;
			if (count=b"110_1111") then
				data_in(7)<=rx_d3;
				data_in(6 downto 0)<=temp_in;
				trig<='1';
			else
				trig<='0';
			end if;
			-- Transmit data
			if (count=b"000_0000") then
				if (rx_d3='0') then
					temp_out<=data_out;
					tx<='0';
				end if;
			elsif (count=b"0000_1101") then
				tx<=temp_out(0);
			elsif (count=b"0001_1010") then
				tx<=temp_out(1);
			elsif (count=b"010_0111") then
				tx<=temp_out(2);
			elsif (count=b"011_0100") then
				tx<=temp_out(3);
			elsif (count=b"100_0001") then
				tx<=temp_out(4);
			elsif (count=b"100_1110") then
				tx<=temp_out(5);
			elsif (count=b"101_1011") then
				tx<=temp_out(6);
			elsif (count=b"110_1000") then
				tx<=temp_out(7);
			elsif (count=b"111_0101") then
				tx<='1';
			end if;
		end if;
	end process;
end arch;
