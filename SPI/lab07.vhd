library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab07 is
 port(
  clk: in    std_logic;
  rx:  in    std_logic;
  tx:  out   std_logic;
  srx: out   std_logic;-- PIC pin 9 RS-232
  stx: in    std_logic;-- PIC pin 10 RS-232
  nss: out   std_logic:= '1';-- PIC pin 11 SPI
  sck: out   std_logic:= '0';-- PIC pin 12 SPI
  sdi: out   std_logic:= '0';-- PIC pin 4 SPI
  sdo: in    std_logic;-- PIC pin 3 SPI
  scl: inout std_logic;-- PIC pin 6 I2C
  sda: inout std_logic -- PIC pin 5 I2C
 );
end lab07;


architecture arch of lab07 is
 component lab07_gui
  port(
   clk:      in  std_logic;
   rx:       in  std_logic;
   tx:       out std_logic;
   data_in:  out std_logic_vector(7 downto 0);
   data_out: in  std_logic_vector(7 downto 0);
   trig:     out std_logic
  );
 end component;
 signal data_in:   std_logic_vector(7 downto 0);
 signal data_out:  std_logic_vector(7 downto 0);
 signal trig:      std_logic;

 signal count:     unsigned(6 downto 0):=b"000_0000";
 signal temp_in:  std_logic_vector(7 downto 0):=b"0000_0000";
 signal temp_out: std_logic_vector(7 downto 0):=b"0000_0000";
begin
  gui: lab07_gui port map(clk=>clk,rx=>rx,tx=>tx,
  data_in=>data_in,data_out=>data_out,trig=>trig);

 -- Example default state of FPGA outputs
 srx<='1';
 --nss<='1';
 --sck<='0';
 --sdi<='0';
 scl<='Z';
 sda<='Z';
 
 process(clk)
 begin
    if rising_edge(clk) then
      if (count=b"000_0000") then
           if (trig = '1') then
             count<=b"000_0001";
             temp_in<=data_in; --let the data input flow into temp in
           end if; 
      elsif (count=b"111_1000") then --120 12Million (1.2*10^7)/120 = 100k input clock
        nss<='1';
        sdi<='0';
        count<=b"000_0000";
        data_out<=temp_out;  --let the data temp out flow into data out                                                     
      else 
        count<=count+1;
      end if; 
        

    --Transfer and receive  
    if (count=b"000_0001") then
        nss<='0';
    elsif (count=b"001_1001") then --25
        sdi<=temp_in(7);  --Send the most MSB first
        --sdi<='0';
    elsif (count=b"001_1101") then --29, set sck and sco
        sck<='1'; 
        temp_out(7)<=sdo;
    elsif (count=b"010_0011") then --35
        sdi<=temp_in(6);
        sck<='0';
    elsif (count=b"010_1000") then --40
        sck<='1';
        temp_out(6)<=sdo;
    elsif (count=b"010_1101") then  --45
        sdi<=temp_in(5);
        sck<='0';
    elsif (count=b"011_0010") then --50
        sck<='1';
        temp_out(5)<=sdo;
    elsif (count=b"011_0111") then --55
        sdi<=temp_in(4);
        sck<='0';
    elsif (count=b"011_1100") then --60
        sck<='1';
        temp_out(4)<=sdo;
    elsif (count=b"100_0001") then --65
        sdi<=temp_in(3);
        sck<='0';
    elsif (count=b"100_0110") then --70
        sck<='1';
        temp_out(3)<=sdo;
    elsif (count=b"100_1011") then --75
        sdi<=temp_in(2);
        sck<='0';
    elsif (count=b"101_0000") then --80
        sck<='1';
        temp_out(2)<=sdo; 
    elsif (count=b"101_0101") then --85
        sdi<=temp_in(1);
        sck<='0';
    elsif (count=b"101_1010") then --90
        sck<='1';
        temp_out(1)<=sdo;
    elsif (count=b"101_1111") then --95
        sdi<=temp_in(0);
        sck<='0'; 
    elsif (count=b"110_0100") then --100
        sck<='1';
        temp_out(0)<=sdo;
    elsif (count=b"110_1001") then --105
        sck<='0';
        end if; 
    end if;

    end process;     
 end arch;