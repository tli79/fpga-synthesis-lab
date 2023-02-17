library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity snake is
	port(
		clk:   in    std_logic;
		tx:    out   std_logic;
		red:   out   std_logic_vector(1 downto 0);
		green: out   std_logic_vector(1 downto 0);
		blue:  out   std_logic_vector(1 downto 0);
		hsync: out   std_logic;
		vsync: out   std_logic;
		u_o:   out   std_logic;
		u_i:   in    std_logic;
		l_o:   out   std_logic;
		l_i:   in    std_logic;
		d_o:   out   std_logic;
		d_i:   in    std_logic;
		r_o:   out   std_logic;
		r_i:   in    std_logic;
		btn0:  in    std_logic;
		btn1:  in    std_logic;
		led0:  out   std_logic;
		led1:  out   std_logic
	);
end snake;

architecture arch of snake is
	signal clkfb:    std_logic;
	signal clkfx:    std_logic;
	signal hcount:   unsigned(9 downto 0);
	signal vcount:   unsigned(9 downto 0);
	signal blank:    std_logic;
	signal frame:    std_logic;
	signal obj1_red: std_logic_vector(1 downto 0);
	signal obj1_grn: std_logic_vector(1 downto 0);
	signal obj1_blu: std_logic_vector(1 downto 0);
	
	type snake_array is array(0 to 49) of integer;
	signal snake_x:  snake_array;
	signal snake_y:  snake_array;
	signal snake_len:integer;
	signal dx:       integer;
	signal dy:       integer;
	signal fsm:      integer:=0;
	signal food_x:   integer;
	signal food_y:   integer;
	signal count:    integer:=0;
	signal prev_dir: integer:=1;
	signal next_dx:  integer;
	signal next_dy:  integer;
	signal disp_game:std_logic:='0';
	signal disp_vict:std_logic:='0';
	signal disp_deft:std_logic:='0';
	signal disp_inst:std_logic:='0';
	signal disp_scor:std_logic:='0';
	
	type food_x_rand_array is array(0 to 9) of integer;
	type food_y_rand_array is array(0 to 10) of integer;
	signal food_x_rand: food_x_rand_array;
	signal food_y_rand: food_y_rand_array;
	signal x_rand:   integer:=0;
	signal y_rand:   integer:=0;
	
	type score_array is array(0 to 6) of integer;
	signal score: score_array;
	signal scorescore: integer;
	
begin
	tx<='1';
	
	food_x_rand(0)<=11;food_x_rand(1)<=4;food_x_rand(2)<=6;
	food_x_rand(3)<=10;food_x_rand(4)<=1;food_x_rand(5)<=11;
	food_x_rand(6)<=13;food_x_rand(7)<=3;food_x_rand(8)<=9;
	food_x_rand(9)<=7;
	
	food_y_rand(0)<=2;food_y_rand(1)<=7;food_y_rand(2)<=9;
	food_y_rand(3)<=1;food_y_rand(4)<=2;food_y_rand(5)<=8;
	food_y_rand(6)<=7;food_y_rand(7)<=9;food_y_rand(8)<=5;
	food_y_rand(9)<=4;food_y_rand(10)<=3;

	------------------------------------------------------------------
	-- Clock management tile
	--
	-- Input clock: 12 MHz
	-- Output clock: 25.2 MHz
	--
	-- CLKFBOUT_MULT_F: 50.875
	-- CLKOUT0_DIVIDE_F: 24.250
	-- DIVCLK_DIVIDE: 1
	------------------------------------------------------------------
	cmt: MMCME2_BASE generic map (
		-- Jitter programming (OPTIMIZED, HIGH, LOW)
		BANDWIDTH=>"OPTIMIZED",
		-- Multiply value for all CLKOUT (2.000-64.000).
		CLKFBOUT_MULT_F=>50.875,
		-- Phase offset in degrees of CLKFB (-360.000-360.000).
		CLKFBOUT_PHASE=>0.0,
		-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
		CLKIN1_PERIOD=>83.333,
		-- Divide amount for each CLKOUT (1-128)
		CLKOUT1_DIVIDE=>1,
		CLKOUT2_DIVIDE=>1,
		CLKOUT3_DIVIDE=>1,
		CLKOUT4_DIVIDE=>1,
		CLKOUT5_DIVIDE=>1,
		CLKOUT6_DIVIDE=>1,
		-- Divide amount for CLKOUT0 (1.000-128.000):
		CLKOUT0_DIVIDE_F=>24.250,
		-- Duty cycle for each CLKOUT (0.01-0.99):
		CLKOUT0_DUTY_CYCLE=>0.5,
		CLKOUT1_DUTY_CYCLE=>0.5,
		CLKOUT2_DUTY_CYCLE=>0.5,
		CLKOUT3_DUTY_CYCLE=>0.5,
		CLKOUT4_DUTY_CYCLE=>0.5,
		CLKOUT5_DUTY_CYCLE=>0.5,
		CLKOUT6_DUTY_CYCLE=>0.5,
		-- Phase offset for each CLKOUT (-360.000-360.000):
		CLKOUT0_PHASE=>0.0,
		CLKOUT1_PHASE=>0.0,
		CLKOUT2_PHASE=>0.0,
		CLKOUT3_PHASE=>0.0,
		CLKOUT4_PHASE=>0.0,
		CLKOUT5_PHASE=>0.0,
		CLKOUT6_PHASE=>0.0,
		-- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
		CLKOUT4_CASCADE=>FALSE,
		-- Master division value (1-106)
		DIVCLK_DIVIDE=>1,
		-- Reference input jitter in UI (0.000-0.999).
		REF_JITTER1=>0.0,
		-- Delays DONE until MMCM is locked (FALSE, TRUE)
		STARTUP_WAIT=>FALSE
	) port map (
		-- User Configurable Clock Outputs:
		CLKOUT0=>clkfx,  -- 1-bit output: CLKOUT0
		CLKOUT0B=>open,  -- 1-bit output: Inverted CLKOUT0
		CLKOUT1=>open,   -- 1-bit output: CLKOUT1
		CLKOUT1B=>open,  -- 1-bit output: Inverted CLKOUT1
		CLKOUT2=>open,   -- 1-bit output: CLKOUT2
		CLKOUT2B=>open,  -- 1-bit output: Inverted CLKOUT2
		CLKOUT3=>open,   -- 1-bit output: CLKOUT3
		CLKOUT3B=>open,  -- 1-bit output: Inverted CLKOUT3
		CLKOUT4=>open,   -- 1-bit output: CLKOUT4
		CLKOUT5=>open,   -- 1-bit output: CLKOUT5
		CLKOUT6=>open,   -- 1-bit output: CLKOUT6
		-- Clock Feedback Output Ports:
		CLKFBOUT=>clkfb,-- 1-bit output: Feedback clock
		CLKFBOUTB=>open, -- 1-bit output: Inverted CLKFBOUT
		-- MMCM Status Ports:
		LOCKED=>open,    -- 1-bit output: LOCK
		-- Clock Input:
		CLKIN1=>clk,   -- 1-bit input: Clock
		-- MMCM Control Ports:
		PWRDWN=>'0',     -- 1-bit input: Power-down
		RST=>'0',        -- 1-bit input: Reset
		-- Clock Feedback Input Port:
		CLKFBIN=>clkfb  -- 1-bit input: Feedback clock
	);

	------------------------------------------------------------------
	-- VGA display counters
	--
	-- Pixel clock: 25.175 MHz (actual: 25.2 MHz)
	-- Horizontal count (active low sync):
	--     0 to 639: Active video
	--     640 to 799: Horizontal blank
	--     656 to 751: Horizontal sync (active low)
	-- Vertical count (active low sync):
	--     0 to 479: Active video
	--     480 to 524: Vertical blank
	--     490 to 491: Vertical sync (active low)
	------------------------------------------------------------------
	process(clkfx)
	begin
		if rising_edge(clkfx) then
			-- Pixel position counters
			if (hcount>=to_unsigned(799,10)) then
				hcount<=(others=>'0');
				if (vcount>=to_unsigned(524,10)) then
					vcount<=(others=>'0');
				else
					vcount<=vcount+1;
				end if;
			else
				hcount<=hcount+1;
			end if;
			-- Sync, blank and frame
			if (hcount>=to_unsigned(656,10)) and
				(hcount<=to_unsigned(751,10)) then
				hsync<='0';
			else
				hsync<='1';
			end if;
			if (vcount>=to_unsigned(490,10)) and
				(vcount<=to_unsigned(491,10)) then
				vsync<='0';
			else
				vsync<='1';
			end if;
			if (hcount>=to_unsigned(640,10)) or
				(vcount>=to_unsigned(480,10)) then
				blank<='1';
			else
				blank<='0';
			end if;
			if (hcount=to_unsigned(640,10)) and
				(vcount=to_unsigned(479,10)) then
				frame<='1';
			else
				frame<='0';
			end if;
		end if;
	end process;

	------------------------------------------------------------------
	-- VGA output with blanking
	------------------------------------------------------------------
	red<=b"00" when blank='1' else obj1_red;
	green<=b"00" when blank='1' else obj1_grn;
	blue<=b"00" when blank='1' else obj1_blu;
	
	u_o<='1';
	l_o<='1';
	d_o<='1';
	r_o<='1';
	
--	process(clkfx,scorescore)
--	begin
--	   if rising_edge(clkfx) then
--	       if scorescore >= 9999 then
--               score(0)<=9;
--               score(1)<=9;
--               score(2)<=9;
--               score(3)<=9;
--	       else
--               score(0)<=scorescore mod 10;
--               score(1)<=scorescore mod 100;
--               score(2)<=scorescore mod 1000;
--               score(3)<=scorescore mod 10000;
--	       end if;
--	   end if;
--	end process;

    process(clkfx, snake_len)
    begin
        if rising_edge(clkfx) then
            score(0)<=0;
            score(1)<=0;
            score(2)<=0;
            score(5)<=0;
            if snake_len > 2 and snake_len < 13 then
                score(3)<=snake_len-3;
                score(4)<=0;
            elsif snake_len > 12 and snake_len < 23 then
                score(3)<=snake_len-13;
                score(4)<=1;
            elsif snake_len > 22 and snake_len < 33 then
                score(3)<=snake_len-23;
                score(4)<=2;
            elsif snake_len > 32 and snake_len < 43 then
                score(3)<=snake_len-33;
                score(4)<=3;
            elsif snake_len > 42 then
                score(3)<=snake_len-43;
                score(4)<=4;
            else
                score(3)<=0;
                score(4)<=0;
            end if;
        end if;
    end process;
	
	process(clkfx)
	begin
	   if rising_edge(clkfx) then
           if u_i='1' and (prev_dir=1 or prev_dir=3) then
               next_dx<=0;
               next_dy<=-1;
           elsif l_i='1' and (prev_dir=0 or prev_dir=2) then
               next_dx<=-1;
               next_dy<=0;
           elsif d_i='1' and (prev_dir=1 or prev_dir=3) then
               next_dx<=0;
               next_dy<=1;
           elsif r_i='1' and (prev_dir=0 or prev_dir=2) then
               next_dx<=1;
               next_dy<=0;
           end if;
	       if btn0='1' or btn1='1' then
               fsm<=0;
           end if;
		   if frame='1' and count=0 then
		       case fsm is
			       when 0 => -- idle state, with instructions
				       disp_game<='0';
					   disp_deft<='0';
					   disp_vict<='0';
					   disp_inst<='1';
					   disp_scor<='0';
					   if u_i='1' or l_i='1' or d_i='1' or r_i='1' then
					       fsm<=1;
					   end if;
				   when 1 => -- game set-up
				       disp_game<='1';
					   disp_inst<='0';
					   disp_deft<='0';
					   disp_vict<='0';
					   disp_scor<='1';
					   snake_x(0)<=18; snake_y(0)<=14;
					   snake_x(1)<=19; snake_y(1)<=14;
					   snake_x(2)<=20; snake_y(2)<=14;
					   snake_len<=3;
					   dx<=1; dy<=0;
					   prev_dir<=1;
					   food_x<=8; food_y<=8;
					   x_rand<=0; y_rand<=0;
--					   scorescore<=0;
					   fsm<=2;
				   when 2 => -- collision detection
				       fsm<=5;
					   if snake_x(snake_len-1)+dx=food_x and snake_y(snake_len-1)+dy=food_y then
					       fsm<=3;
					   elsif snake_x(snake_len-1)+dx>=39 or snake_x(snake_len-1)+dx<=0
							   or snake_y(snake_len-1)+dy>=29 or snake_y(snake_len-1)+dy<=1 then
						   fsm<=4;
					   else
					       for index in 49 downto 0 loop
					           if index<snake_len-1 then
					               if snake_x(snake_len-1)=snake_x(index)
					                       and snake_y(snake_len-1)=snake_y(index) then
					                   fsm<=4;
					               end if;
					           end if;
					       end loop;
					   end if;
				   when 3 => -- eat food
					   if snake_len=50 then
					       fsm<=7;
					   else                       
                           if snake_x(1)>13 then -- generate food_x from snake
                               food_x<=snake_x(1)-food_x_rand(x_rand);
                           else
                               food_x<=snake_x(1)+25-food_x_rand(x_rand);
                           end if;
                           if x_rand=9 then -- x_rand index update
                               x_rand<=0;
                           else
                               x_rand<=x_rand+1;
                           end if;
                           if snake_y(2)>10 then -- generate food_y from snake
                               food_y<=snake_y(2)-food_y_rand(y_rand);
                           else
                               food_y<=snake_y(2)+18-food_y_rand(y_rand);
                           end if;
                           if y_rand=10 then -- y_rand index update
                               y_rand<=0;
                           else
                               y_rand<=y_rand+1;
                           end if;
					       snake_x(snake_len)<=snake_x(snake_len-1)+dx;
						   snake_y(snake_len)<=snake_y(snake_len-1)+dy;
						   snake_len<=snake_len+1;
						   fsm<=6;
--						   scorescore<=scorescore+212;
					   end if;
				   when 4 => -- death collision
				       disp_game<='0';
					   disp_deft<='1';
					   disp_inst<='1';
					   disp_scor<='1';
					   if u_i='1' or l_i='1' or d_i='1' or r_i='1' then
					       fsm<=1;
					   end if;
				   when 5 => -- no collision
				       for index in 48 downto 0 loop
					       if index<snake_len-1 then
						       snake_x(index)<=snake_x(index+1);
							   snake_y(index)<=snake_y(index+1);
						   end if;
					   end loop;
					   snake_x(snake_len-1)<=snake_x(snake_len-1)+dx;
					   snake_y(snake_len-1)<=snake_y(snake_len-1)+dy;
					   fsm<=6;
				   when 6 => -- update direction
				       dx<=next_dx;
					   dy<=next_dy;
					   if next_dx=1 then
					       prev_dir<=1;
					   elsif next_dx=-1 then
					       prev_dir<=3;
					   elsif next_dy=1 then
					       prev_dir<=0;
					   else
					       prev_dir<=2;
					   end if;
					   count<=5;
					   fsm<=2;
				   when 7 => -- winning
				       disp_game<='0';
					   disp_deft<='0';
					   disp_vict<='1';
					   disp_inst<='1';
					   disp_scor<='1';
					   if u_i='1' or l_i='1' or d_i='1' or r_i='1' then
					       fsm<=1;
					   end if;
				   when others =>
				       disp_game<='0';
					   disp_deft<='0';
					   disp_vict<='0';
					   disp_inst<='1';
					   disp_scor<='0';
					   if u_i='1' or l_i='1' or d_i='1' or r_i='1' then
					       fsm<=1;
					   end if;
			   end case;
		   elsif frame='1' then
		       count<=count-1;
		   end if;
	   end if;
	end process;
	
	process(clkfx,disp_game,disp_deft)
	begin
	   if rising_edge(clkfx) then
	       if blank='0' then
               obj1_red<=b"00";
               obj1_grn<=b"00";
               obj1_blu<=b"00";
	           if disp_game='1' and (vcount<32 or vcount>=464 or hcount<16 or hcount>=624) then
	               obj1_red<=b"01";
	               obj1_grn<=b"01";
	               obj1_blu<=b"01";
	           elsif disp_game='1' and (hcount>=(food_x*16) and hcount<(food_x+1)*16
	                   and vcount>=(food_y*16) and vcount<(food_y+1)*16) then
	               obj1_red<=b"11";
	               obj1_grn<=b"00";
	               obj1_blu<=b"00";
	           elsif disp_game='1' then
	               for index in 49 downto 0 loop
	                   if index<snake_len then
                           if hcount>=(snake_x(index)*16) and hcount<(snake_x(index)+1)*16
                               and vcount>=(snake_y(index)*16) and vcount<(snake_y(index)+1)*16 then
                               obj1_red<=b"11";
                               obj1_grn<=b"11";
                               obj1_blu<=b"11";
                           end if;
	                   end if;
	               end loop;
	           end if;
	           if disp_deft='1' and ((hcount>=172 and hcount<180 and vcount>=350 and vcount<406)
	                   or (hcount>=172 and hcount<204 and vcount>=350 and vcount<358)
	                   or (hcount>=172 and hcount<204 and vcount>=398 and vcount<406)
	                   or (hcount>=204 and hcount<212 and vcount>=358 and vcount<398)) then
	                   -- D
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_deft='1' and ((hcount>=220 and hcount<260 and vcount>=350 and vcount<358)
	                   or (hcount>=220 and hcount<252 and vcount>=374 and vcount<382)
	                   or (hcount>=220 and hcount<260 and vcount>=398 and vcount<406)
	                   or (hcount>=220 and hcount<228 and vcount>=350 and vcount<406)) then
	                   -- E
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_deft='1' and ((hcount>=268 and hcount<308 and vcount>=350 and vcount<358)
	                   or (hcount>=268 and hcount<300 and vcount>=374 and vcount<382)
	                   or (hcount>=268 and hcount<276 and vcount>=350 and vcount<406)) then
	                   -- F
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_deft='1' and ((hcount>=316 and hcount<356 and vcount>=350 and vcount<358)
	                   or (hcount>=316 and hcount<348 and vcount>=374 and vcount<382)
	                   or (hcount>=316 and hcount<356 and vcount>=398 and vcount<406)
	                   or (hcount>=316 and hcount<324 and vcount>=350 and vcount<406)) then
	                   -- E
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_deft='1' and ((hcount>=364 and hcount<372 and vcount>=358 and vcount<406)
	                   or (hcount>=372 and hcount<404 and vcount>=350 and vcount<358)
	                   or (hcount>=364 and hcount<404 and vcount>=374 and vcount<382)
	                   or (hcount>=396 and hcount<404 and vcount>=350 and vcount<406)) then
	                   -- A
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_deft='1' and ((hcount>=412 and hcount<452 and vcount>=350 and vcount<358)
	                   or (hcount>=428 and hcount<436 and vcount>=350 and vcount<406)) then
	                   -- T
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           end if;
	           if disp_inst='1' and ((hcount>=4 and hcount<36 and vcount>=190 and vcount<198)
	                   or (hcount>=4 and hcount<12 and vcount>=190 and vcount<246)
	                   or (hcount>=4 and hcount<36 and vcount>=213 and vcount<222)
	                   or (hcount>=35 and hcount<44 and vcount>=197 and vcount<214)) then
	                   -- P
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=52 and hcount<60 and vcount>=206 and vcount<246)
	                   or (hcount>=60 and hcount<68 and vcount>=214 and vcount<222)
	                   or (hcount>=68 and hcount<84 and vcount>=206 and vcount<214)) then
	                   -- r
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=92 and hcount<100 and vcount>=214 and vcount<238)
	                   or (hcount>=100 and hcount<116 and vcount>=206 and vcount<214)
	                   or (hcount>=100 and hcount<116 and vcount>=222 and vcount<230)
	                   or (hcount>=100 and hcount<116 and vcount>=238 and vcount<246)
	                   or (hcount>=116 and hcount<124 and vcount>=214 and vcount<230)) then
	                   -- e
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=132 and hcount<140 and vcount>=214 and vcount<222)
	                   or (hcount>=140 and hcount<164 and vcount>=206 and vcount<214)
	                   or (hcount>=140 and hcount<156 and vcount>=222 and vcount<230)
	                   or (hcount>=156 and hcount<164 and vcount>=230 and vcount<238)
	                   or (hcount>=132 and hcount<156 and vcount>=238 and vcount<246)) then
	                   -- s
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=172 and hcount<180 and vcount>=214 and vcount<222)
	                   or (hcount>=180 and hcount<204 and vcount>=206 and vcount<214)
	                   or (hcount>=180 and hcount<196 and vcount>=222 and vcount<230)
	                   or (hcount>=196 and hcount<204 and vcount>=230 and vcount<238)
	                   or (hcount>=172 and hcount<196 and vcount>=238 and vcount<246)) then
	                   -- s
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=244 and hcount<252 and vcount>=230 and vcount<238)
	                   or (hcount>=252 and hcount<268 and vcount>=206 and vcount<214)
	                   or (hcount>=252 and hcount<268 and vcount>=222 and vcount<230)
	                   or (hcount>=252 and hcount<268 and vcount>=238 and vcount<246)
	                   or (hcount>=268 and hcount<272 and vcount>=214 and vcount<246)) then
	                   -- a
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=280 and hcount<288 and vcount>=206 and vcount<246)
	                   or (hcount>=280 and hcount<300 and vcount>=206 and vcount<214)
	                   or (hcount>=300 and hcount<308 and vcount>=214 and vcount<246)) then
	                   -- n
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=316 and hcount<324 and vcount>=206 and vcount<230)
	                   or (hcount>=324 and hcount<348 and vcount>=230 and vcount<238)
	                   or (hcount>=324 and hcount<340 and vcount>=254 and vcount<262)
	                   or (hcount>=340 and hcount<348 and vcount>=206 and vcount<254)) then
	                   -- y
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=388 and hcount<396 and vcount>=190 and vcount<246)
	                   or (hcount>=396 and hcount<412 and vcount>=214 and vcount<222)
	                   or (hcount>=396 and hcount<412 and vcount>=238 and vcount<246)
	                   or (hcount>=412 and hcount<420 and vcount>=222 and vcount<238)) then
	                   -- b
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=428 and hcount<436 and vcount>=206 and vcount<238)
	                   or (hcount>=436 and hcount<460 and vcount>=238 and vcount<246)
	                   or (hcount>=452 and hcount<460 and vcount>=206 and vcount<246)) then
	                   -- u
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=468 and hcount<500 and vcount>=214 and vcount<222)
	                   or (hcount>=476 and hcount<484 and vcount>=198 and vcount<238)
	                   or (hcount>=484 and hcount<500 and vcount>=238 and vcount<246)) then
	                   -- t
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=508 and hcount<540 and vcount>=214 and vcount<222)
	                   or (hcount>=516 and hcount<524 and vcount>=198 and vcount<238)
	                   or (hcount>=524 and hcount<540 and vcount>=238 and vcount<246)) then
	                   -- t
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=548 and hcount<556 and vcount>=214 and vcount<238)
	                   or (hcount>=556 and hcount<572 and vcount>=206 and vcount<214)
	                   or (hcount>=556 and hcount<572 and vcount>=238 and vcount<246)
	                   or (hcount>=572 and hcount<580 and vcount>=214 and vcount<238)) then
	                   -- o
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=588 and hcount<596 and vcount>=206 and vcount<246)
	                   or (hcount>=588 and hcount<612 and vcount>=206 and vcount<214)
	                   or (hcount>=612 and hcount<620 and vcount>=214 and vcount<246)) then
	                   -- n
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=156 and hcount<188 and vcount>=286 and vcount<294)
	                   or (hcount>=164 and hcount<172 and vcount>=270 and vcount<310)
	                   or (hcount>=172 and hcount<188 and vcount>=310 and vcount<318)) then
	                   -- t
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=196 and hcount<204 and vcount>=286 and vcount<310)
	                   or (hcount>=204 and hcount<220 and vcount>=278 and vcount<286)
	                   or (hcount>=204 and hcount<220 and vcount>=310 and vcount<318)
	                   or (hcount>=220 and hcount<228 and vcount>=286 and vcount<310)) then
	                   -- o
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=268 and hcount<276 and vcount>=286 and vcount<294)
	                   or (hcount>=276 and hcount<300 and vcount>=278 and vcount<286)
	                   or (hcount>=276 and hcount<292 and vcount>=294 and vcount<302)
	                   or (hcount>=292 and hcount<300 and vcount>=302 and vcount<310)
	                   or (hcount>=268 and hcount<292 and vcount>=310 and vcount<318)) then
	                   -- s
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=308 and hcount<340 and vcount>=286 and vcount<294)
	                   or (hcount>=316 and hcount<324 and vcount>=270 and vcount<318)
	                   or (hcount>=324 and hcount<340 and vcount>=310 and vcount<318)) then
	                   -- t
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=348 and hcount<356 and vcount>=302 and vcount<310)
	                   or (hcount>=356 and hcount<372 and vcount>=278 and vcount<286)
	                   or (hcount>=356 and hcount<372 and vcount>=294 and vcount<302)
	                   or (hcount>=356 and hcount<372 and vcount>=310 and vcount<318)
	                   or (hcount>=372 and hcount<380 and vcount>=286 and vcount<318)) then
	                   -- a
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=388 and hcount<396 and vcount>=278 and vcount<318)
	                   or (hcount>=396 and hcount<404 and vcount>=286 and vcount<294)
	                   or (hcount>=404 and hcount<420 and vcount>=278 and vcount<286)) then
	                   -- r
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           elsif disp_inst='1' and ((hcount>=428 and hcount<460 and vcount>=286 and vcount<294)
	                   or (hcount>=436 and hcount<444 and vcount>=270 and vcount<310)
	                   or (hcount>=444 and hcount<460 and vcount>=310 and vcount<318)) then
	                   -- t
	               obj1_red<=b"11";
	               obj1_grn<=b"11";
	               obj1_blu<=b"11";
	           end if;
	           
                if disp_scor='1' and ((hcount>=6 and hcount<10 and vcount>=10 and vcount<14)
                        or (hcount>=10 and hcount<22 and vcount>=6 and vcount<10)
                        or (hcount>=10 and hcount<18 and vcount>=14 and vcount<18)
                        or (hcount>=18 and hcount<22 and vcount>=18 and vcount<22)
                        or (hcount>=6 and hcount<18 and vcount>=22 and vcount<26)) then --s
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' and ((hcount>=26 and hcount<30 and vcount>=10 and vcount<22)
                        or (hcount>=30 and hcount<38 and vcount>=6 and vcount<10)
                        or (hcount>=38 and hcount<42 and vcount>=10 and vcount<14)
                        or (hcount>=30 and hcount<38 and vcount>=22 and vcount<26)
                        or (hcount>=38 and hcount<42 and vcount>=18 and vcount<22)) then --c
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' and ((hcount>=46 and hcount<50 and vcount>=10 and vcount<22)
                        or (hcount>=50 and hcount<58 and vcount>=6 and vcount<10)
                        or (hcount>=50 and hcount<58 and vcount>=22 and vcount<26)
                        or (hcount>=58 and hcount<62 and vcount>=10 and vcount<22)) then --o
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' and ((hcount>=66 and hcount<70 and vcount>=6 and vcount<26)
                        or (hcount>=70 and hcount<74 and vcount>=10 and vcount<14)
                        or (hcount>=74 and hcount<82 and vcount>=6 and vcount<10)) then --r
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' and ((hcount>=86 and hcount<90 and vcount>=10 and vcount<22)
                        or (hcount>=90 and hcount<98 and vcount>=6 and vcount<10)
                        or (hcount>=90 and hcount<98 and vcount>=14 and vcount<18)
                        or (hcount>=90 and hcount<98 and vcount>=22 and vcount<26)
                        or (hcount>=98 and hcount<102 and vcount>=10 and vcount<14)) then --e
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' and ((hcount>=106 and hcount<110 and vcount>=10 and vcount<14)
                        or (hcount>=106 and hcount<110 and vcount>=18 and vcount<22)) then --:
                    obj1_red<=b"00";
                    obj1_grn<=b"11";
                    obj1_blu<=b"11";
                elsif disp_scor='1' then
                    for index in 4 downto 0 loop
                        if score(index)=0
                            and ((hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=10 and vcount<22)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<22)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=1
                            and ((hcount>=(214-(20*index)) and hcount<(218-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(218-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=2
                            and ((hcount>=(210-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<18)
                            or (hcount>=(210-(20*index)) and hcount<(226-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=18 and vcount<22)
                            or (hcount>=(210-(20*index)) and hcount<(226-(20*index)) and vcount>=22 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=3
                            and ((hcount>=(210-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=18 and vcount<22)
                            or (hcount>=(210-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=4
                            and ((hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=6 and vcount<14)
                            or (hcount>=(214-(20*index)) and hcount<(226-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=6 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=5
                            and ((hcount>=(210-(20*index)) and hcount<(226-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=6 and vcount<18)
                            or (hcount>=(210-(20*index)) and hcount<(226-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=18 and vcount<22)
                            or (hcount>=(210-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=6
                            and ((hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=10 and vcount<22)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=18 and vcount<22)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";	
                        elsif score(index)=7
                            and ((hcount>=(210-(20*index)) and hcount<(226-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(218-(20*index)) and hcount<(222-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(214-(20*index)) and hcount<(218-(20*index)) and vcount>=18 and vcount<26)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=8
                            and ((hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)
                            or (hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=18 and vcount<22)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=18 and vcount<22)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        elsif score(index)=9
                            and ((hcount>=(210-(20*index)) and hcount<(214-(20*index)) and vcount>=10 and vcount<14)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=6 and vcount<10)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=14 and vcount<18)
                            or (hcount>=(214-(20*index)) and hcount<(222-(20*index)) and vcount>=22 and vcount<26)
                            or (hcount>=(222-(20*index)) and hcount<(226-(20*index)) and vcount>=10 and vcount<22)) then
                            obj1_red<=b"00";
                            obj1_grn<=b"11";
                            obj1_blu<=b"11";
                        end if;
                    end loop;
                end if;
	       end if;
	   end if;
	end process;

end arch;