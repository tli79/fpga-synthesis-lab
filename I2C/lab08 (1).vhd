library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity lab08 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab08;

architecture arch of lab08 is
	component lab08_gui
		port(
			clk:      in  std_logic;
			rx:       in  std_logic;
			tx:       out std_logic;
			data_in:  out std_logic_vector(7 downto 0);
			data_out: in  std_logic_vector(7 downto 0);
			trig:     out std_logic
		);
	end component;
	signal data_in:     std_logic_vector(7 downto 0);
	signal data_out:    std_logic_vector(7 downto 0);
	signal trig:        std_logic;
	signal scl_in:      std_logic;
	signal scl_out:     std_logic:='1';
	signal sda_in:      std_logic;
	signal sda_out:     std_logic:='1';
	--New added
	signal clk_cnt:     unsigned(5 downto 0):=b"00_0000";
	signal state :      unsigned(7 downto 0) := x"00";
	signal bitcount :  unsigned(3 downto 0) := b"0000";
	signal temp_in:     std_logic_vector(7 downto 0):=b"0000_0000";
    signal temp_out:    std_logic_vector(7 downto 0):=b"0000_0000";
    signal write_address:     std_logic_vector(7 downto 0):=b"10100000";
    signal read_address:     std_logic_vector(7 downto 0):=b"10100001";
    signal buf1:      std_logic;
    signal buf2:      std_logic;
    signal buf3:      std_logic;
    signal buf4:      std_logic;
    signal buf5:      std_logic;
    signal buf6:      std_logic;
begin
	gui: lab08_gui port map(clk=>clk,rx=>rx,tx=>tx,
		data_in=>data_in,data_out=>data_out,trig=>trig);

	scl_pin: IOBUF port map(O=>scl_in,IO=>scl,I=>'0',T=>scl_out);
	sda_pin: IOBUF port map(O=>sda_in,IO=>sda,I=>'0',T=>sda_out);

	srx<='1';
	nss<='1';
	sck<='0';
	sdi<='0';
	--scl<='1';
	--sda<='1';

 
 
process(clk)
begin
		

	if(rising_edge(clk)) then
	  buf1<=scl_in;
	  buf2<=buf1;
	  buf3<=buf2;
	  buf4<=sda_in;
	  buf5<=buf4;
	  buf6<=buf5;
	  if (state=x"00") then
          if (trig='1') then
		        clk_cnt <= b"111100";--50us
          		state <= x"01";
			    temp_in<=data_in;
          end if;
	  elsif (clk_cnt = 0) then
		case state is
--------------------------------------------START CONDITION	
					
		when x"01" =>  
			sda_out <= '0'; 
			if (buf6 = '0') then
			  state <= x"02";
			  clk_cnt <= b"011110"; --wait 25us
			end if;
			
		when x"02" =>
		    scl_out <= '0';
		    bitcount <= b"0111";  
		    if (buf3 = '0') then
			  state <= x"03";
			  clk_cnt <= b"011110"; --wait 25us
			end if;	
			
--------------------------------------------WRITE ADDRESS 
		when x"03" =>  
			sda_out <= write_address(to_integer(bitcount));
			if (buf6 = write_address(to_integer(bitcount))) then
			  state <= x"04";
			  clk_cnt <= b"011110"; --25us
			end if;
			
 		when x"04" =>  
			scl_out <= '1';
			if (buf3 = '1') then
			  state <= x"05";
			  clk_cnt <= b"111100"; --50us
			end if;
			
			
		when x"05" =>  -- write address state prt2
			scl_out <= '0';
			if (buf3 = '0') then
				if bitcount > b"0000" then
					bitcount <= bitcount - 1;
					state <= x"03";
				else
					state <= x"06";
				end if;
				clk_cnt <= b"011110"; --25us
			end if;	
----------------------------------------------SLAVE ACK			
		when x"06" =>  
			sda_out <= '1'; 
			state <= x"07";		
			clk_cnt <= b"011110"; --25us

 
		when x"07" => 
			scl_out <= '1';	
			if (buf3 = '1') then
			    state <= x"08";		
			    clk_cnt <= b"111100"; --50us
			end if;
			
        when x"08" =>  -- check for ack here
			if (buf6 = '0') then
			    state <= x"09";		
			else    
			    state <=x"99";
			end if;
			
		when x"09" =>  
			scl_out <= '0';	-- SCL = 1
				if buf3 = '0' then
				    bitcount <= b"0111";
					state <= x"10";
					clk_cnt <= b"011110"; --25us
				end if;
------------------------------------------------WRITE TO REGISTER				
		when x"10" =>  
			sda_out <= temp_in(to_integer(bitcount));
			if (buf6 = temp_in(to_integer(bitcount))) then
			  state <= x"11";
			  clk_cnt <= b"011110"; --25us
			end if;
			
 		when x"11" =>  
			scl_out <= '1';
			if (buf3 = '1') then
			  state <= x"12";
			  clk_cnt <= b"111100"; --50us
			end if;
			
			
		when x"12" =>  -- write address state prt2
			scl_out <= '0';
			if (buf3 = '0') then
				if bitcount > b"0000" then
					bitcount <= bitcount - 1;
					state <= x"10";
				else
					state <= x"13";
				end if;
				clk_cnt <= b"011110"; --25us
			end if;
-----------------------------------------------SLAVE ACK
		when x"13" =>  
			sda_out <= '1'; 
			--if (buf6 = '1') then
			state <= x"14";		
			clk_cnt <= b"011110"; --25us
			--end if;
 
		when x"14" => 
			scl_out <= '1';	
			if (buf3 = '1') then
			    state <= x"15";		
			    clk_cnt <= b"111100"; --50us
			end if;
			
        when x"15" =>  -- check for ack here
			if (buf6 = '0') then
			    state <= x"16";		
			else    
			    state <=x"99";
			end if;
			
		when x"16" =>  
			scl_out <= '0';	
			if buf3 = '0' then
				state <= x"17";
				clk_cnt <= b"011110"; --25us
			end if;
-----------------------------------------------STOP CONDITION
        when x"17" =>  
            sda_out <= '1';	
			if buf6 = '1' then
				state <= x"18";
				clk_cnt <= b"011110"; --25us
			end if;
			
        when x"18" =>  
            scl_out <= '1';	
			if buf3 = '1' then
				state <= x"19";
				clk_cnt <= b"011110"; --25us
			end if;		
--------------------------------------------START CONDITION	
					
		when x"19" =>  
			sda_out <= '0'; 
			if (buf6 = '0') then
			  state <= x"20";
			  clk_cnt <= b"011110"; --wait 25us
			end if;
			
		when x"20" =>
		    scl_out <= '0';
		    bitcount <= b"0111";  
		    if (buf3 = '0') then
			  state <= x"21";
			  clk_cnt <= b"011110"; --wait 25us
			end if;	
--------------------------------------------WRITE ADDRESS 
		when x"21" =>  
			sda_out <= read_address(to_integer(bitcount));
			if (buf6 = read_address(to_integer(bitcount))) then
			  state <= x"22";
			  clk_cnt <= b"011110"; --25us
			end if;
			
 		when x"22" =>  
			scl_out <= '1';
			if (buf3 = '1') then
			  state <= x"23";
			  clk_cnt <= b"111100"; --50us
			end if;
			
			
		when x"23" =>  -- write address state prt2
			scl_out <= '0';
			if (buf3 = '0') then
				if bitcount > b"0000" then
					bitcount <= bitcount - 1;
					state <= x"21";
				else
					state <= x"24";
				end if;
				clk_cnt <= b"011110"; --25us
			end if;	
----------------------------------------------SLAVE ACK			
		when x"24" =>  
			sda_out <= '1'; 
			--if (buf6 = '1') then
			state <= x"25";		
			clk_cnt <= b"011110"; --25us
			--end if;
 
		when x"25" => 
			scl_out <= '1';	
			if (buf3 = '1') then
			    state <= x"26";		
			    clk_cnt <= b"111100"; --50us
			end if;
			
        when x"26" =>  -- check for ack here
			if (buf6 = '0') then
			    state <= x"27";		
			else    
			    state <=x"99";
			end if;
			
		when x"27" =>  
			scl_out <= '0';	-- SCL = 1
				if buf3 = '0' then
				    bitcount <= b"0111";
				    data_out<=b"0000_0010";
					state <= x"28";
					clk_cnt <= b"111100"; --50us
				end if;	

------------------------------------------------READ FROM REGISTER				
		when x"28" =>  
			scl_out<='1';
			if (buf3 = '1') then
			  state <= x"29";
			  clk_cnt <= b"111100"; --50us
			end if;
					
		when x"29" =>  
			temp_out(to_integer(bitcount))<=buf6;
			state <= x"30";
			
		when x"30" =>  -- write address state prt2
			scl_out <= '0';
			if (buf3 = '0') then
				if bitcount > b"0000" then
					bitcount <= bitcount - 1;
					state <= x"28";
					clk_cnt <= b"111100"; --50us
				else
					state <= x"31";
					clk_cnt <= b"011110"; --25us
				end if;
			end if;
-----------------------------------------------SLAVE ACK
		when x"31" =>  
		    data_out<=temp_out;
			sda_out <= '1'; 
			if (buf6 = '1') then
			    state <= x"32";		
			    clk_cnt <= b"011110"; --25us
			end if;
 
		when x"32" => 
			scl_out <= '1';	
			if (buf3 = '1') then
			    state <= x"33";		
			    clk_cnt <= b"111100"; --50us
			end if;
			
        when x"33" =>  -- check for ack here
            scl_out<='0';
			if (buf3 = '0') then
			    state <= x"34";	
			    clk_cnt <= b"011110"; --25us	
			end if;
			
-----------------------------------------------STOP CONDITION
        when x"34" =>  
            scl_out <= '1';	
			if buf3 = '1' then
				state <= x"35";
				clk_cnt <= b"011110"; --25us
			end if;
			
        when x"35" =>  
            sda_out <= '1';	
			if buf6 = '1' then
				state <= x"00";
				clk_cnt <= b"011110"; --25us
			end if;									
-----------------------------------------------ACK FAILURE										
		when others => --should not happen	
		  data_out<=b"0000_0001"; -- for debug
		end case;
	  else 
	      clk_cnt <= clk_cnt - 1;
	  end if;
    end if;
end process;		
end arch;