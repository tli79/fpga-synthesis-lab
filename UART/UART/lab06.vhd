library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab06 is
	port(
		clk: in  std_logic;
		rx:  in  std_logic;
		tx:  out std_logic:='1'
	);
end lab06;

architecture arch of lab06 is
	type rom_type is array (0 to 255) of std_logic_vector(7 downto 0);
	constant rom: rom_type:=(
		"00000000","00100001","01001111","10101010",
		"11100000","11000101","01100110","01011111",
		"10111100","11011101","11001010","10010100",
		"01001011","01000110","01110011","11000110",
		"11000010","00101110","10111101","10111110",
		"00011010","01101011","01101010","00001001",
		"11011001","00100110","00000111","01001000",
		"11100010","00000010","11000111","10100001",
		"11111110","01000010","10011111","01010101",
		"11000001","10001010","11001100","10111111",
		"01111001","10111011","10010101","00101000",
		"10010110","10001100","11100111","10001101",
		"10000100","01011101","01111011","01111100",
		"00110100","11010110","11010100","00010011",
		"10110010","01001100","00001110","10010001",
		"11000100","00000101","10001111","01000011",
		"11111100","10000101","00111110","10101011",
		"10000011","00010101","10011001","01111110",
		"11110011","01110111","00101010","01010001",
		"00101101","00011001","11001111","00011011",
		"00001000","10111010","11110110","11111000",
		"01101001","10101101","10101000","00100111",
		"01100100","10011000","00011101","00100011",
		"10001000","00001011","00011110","10000111",
		"11111001","00001010","01111101","01010111",
		"00000110","00101011","00110010","11111101",
		"11100110","11101110","01010100","10100010",
		"01011010","00110011","10011110","00110110",
		"00010001","01110101","11101101","11110000",
		"11010011","01011011","01010000","01001110",
		"11001001","00110000","00111010","01000111",
		"00010000","00010110","00111101","00001111",
		"11110010","00010100","11111010","10101110",
		"00001100","01010110","01100101","11111011",
		"11001101","11011100","10101001","01000100",
		"10110100","01100111","00111100","01101100",
		"00100010","11101011","11011011","11100001",
		"10100110","10110110","10100000","10011101",
		"10010010","01100000","01110100","10001110",
		"00100000","00101100","01111010","00011111",
		"11100100","00101001","11110101","01011100",
		"00011000","10101100","11001011","11110111",
		"10011011","10111001","01010010","10001001",
		"01101000","11001110","01111000","11011000",
		"01000101","11010111","10110111","11000011",
		"01001101","01101101","01000001","00111011",
		"00100100","11000000","11101001","00011100",
		"01000000","01011000","11110100","00111111",
		"11001000","01010011","11101010","10111000",
		"00110001","01011001","10010111","11101111",
		"00110111","01110010","10100101","00010010",
		"11010001","10011100","11110001","10110000",
		"10001011","10101111","01101111","10000110",
		"10011010","11011010","10000010","01110110",
		"01001001","10000001","11010010","00111000",
		"10000000","10110001","11101000","01111111",
		"10010000","10100111","11010101","01110000",
		"01100010","10110011","00101111","11011110",
		"01101110","11100101","01001010","00100101",
		"10100011","00111001","11100011","01100001",
		"00010111","01011110","11011111","00001101",
		"00110101","10110101","00000100","11101100",
		"10010011","00000011","10100100","01110001",
		"00000001","01100011","11010000","11111111");
    signal rx_d1:  std_logic:='1';
    signal rx_d2:  std_logic:='1';
    signal rx_d3:  std_logic:='0';
	signal rx_trg: std_logic:='0';
	signal rx_dat: std_logic_vector(7 downto 0);
	signal tx_dat: std_logic_vector(7 downto 0);
	signal tx_trg: std_logic:='0';
	type FSM_R is (R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10);
	type FSM_T is (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10);
	signal fr: FSM_R := R0;
	signal ft: FSM_T := T0;
	signal cnt_r: unsigned(6 downto 0):=b"000_0000";
	signal cnt_t: unsigned(6 downto 0):=b"0000_0000";
	signal trx: std_logic_vector(7 downto 0):=b"0000_0000";
	signal ttx: std_logic_vector(7 downto 0):=b"0000_0000";
begin
	process(clk)
	begin
		if rising_edge(clk) then
		      rx_d1<=rx;
		      rx_d2<=rx_d1;
		      rx_d3<=rx_d2;
		      if (rx_trg = '0') then
		          case fr is 
		              when R0 => 
		                  if (rx_d3 = '0') then
		                      fr<=R1;
		                  elsif (rx_d3='1') then
		                      fr<=R0;
		                  end if;
		              when R1 => 
		                   if (cnt_r=b"0001101") then
		                      trx(0)<=rx_d3;
		                      fr<=R2;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R2 => 
		                   if (cnt_r=b"0011010") then 
		                      trx(1)<=rx_d3;
		                      fr<=R3;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R3 =>  
		                   if (cnt_r=b"0100111") then
		                      trx(2)<=rx_d3;
		                      fr<=R4;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R4 =>  
		                   if (cnt_r=b"0110100") then
		                      trx(3)<=rx_d3;
		                      fr<=R5;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R5 => 
		                   if (cnt_r=b"1000001") then 
		                      trx(4)<=rx_d3;
		                      fr<=R6;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R6 => 
		                   if (cnt_r=b"1001110") then 
		                      trx(5)<=rx_d3;
		                      fr<=R7;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R7 => 
		                   if (cnt_r=b"1101011") then 
		                      trx(6)<=rx_d3;
		                      fr<=R8;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R8 => 
		                   if (cnt_r=b"1101000") then 
		                      trx(7)<=rx_d3;
		                      fr<=R9;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R9 => 
		                   if (cnt_r=b"1110101") then 
		                      if (rx_d3='1') then
		                          fr<=R10;
		                      elsif (rx_d3='1') then 
		                          fr<=R9;
		                      end if;
		                   else 
		                      cnt_r<=cnt_r+1;
		                   end if;
		              when R10 => -- Check 2nd stop bit 
                        if (cnt_r = b"100_00010") then
                            if (rx_d3 = '1') then
                                rx_trg <= '1';
                                fr <= R0;
                            elsif (rx_d3 = '1') then
                                fr <= R10;
                            end if;
                        else
                            cnt_r <= cnt_r + 1;
                        end if;
                   
               end case;
               end if;
            end if;
      end process;
      
      process(clk)
      begin
			if (rx_trg='1') then
				tx_trg<='1';
				tx_dat<=rom(to_integer(unsigned(rx_dat)));
			else
				tx_trg<='0';
			end if;
		end if;
	end process;
end arch;
