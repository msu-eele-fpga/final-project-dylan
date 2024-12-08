library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Common_pkg.all;

entity led_patterns is
  generic (
    system_clock_period : time := 20 ns
  );
  port (
    clk		 	: in std_ulogic;
    rst			: in std_ulogic;
    push_button		: in std_ulogic;
    switches		: in std_ulogic_vector(3 downto 0);
    hps_led_control	: in boolean;
    base_period		: in unsigned(7 downto 0);
    led_reg		: in std_ulogic_vector(7 downto 0);
    led			: out std_ulogic_vector(7 downto 0)
  );
end entity led_patterns;

architecture led_patterns_arch of led_patterns is

signal current_state 	: led_state;
-- with clk = 20 ns -> 50 MHz
constant CLK_FREQ	: integer := 50000000;
signal bp_timer		: unsigned(35 downto 0);
signal count		: unsigned(31 downto 0);

component async_conditioner is
	port (
		clk	: in	std_ulogic;
		rst	: in	std_ulogic;
		async	: in	std_ulogic;
		sync	: out	std_ulogic
	);
end component async_conditioner;

component pattern_SM is
	port (
		clk		: in	std_ulogic;
		rst		: in	std_ulogic;
		hps_led_control	: in 	boolean;
		switches	: in	std_ulogic_vector(3 downto 0);
		trans_done	: in	std_ulogic;
		pulse		: in std_ulogic;
		state		: out	led_state
	);
end component pattern_SM;

component clk_gen is
  generic (
    system_clock_period : time := 20 ns
  );
  port (
    clk		 	: in std_ulogic;
    bp_timer		: in unsigned(35 downto 0);
    rst			: in std_ulogic;
	 clk_32_out	: out std_ulogic;
    clk_out		: out std_ulogic
  );
end component clk_gen;

component pattern_behavior is
  port (
    clk		 	: in std_ulogic;
    rst			: in std_ulogic;
    patterns		: in std_ulogic_vector(4 downto 0);
    led			: out std_ulogic_vector(6 downto 0)
  );
end component pattern_behavior;

component one_pulse is
	port (
		clk	: in	std_ulogic;
		rst	: in	std_ulogic;
		input	: in	std_ulogic;
		pulse	: out	std_ulogic
	);
end component one_pulse;

signal sync_push_button : std_ulogic;
signal clk_div	: std_ulogic;
signal cstate	: led_state;
signal S0_clk, S1_clk, S2_clk, S3_clk, S4_clk	: std_ulogic;
signal trans_done : std_ulogic := '1';
signal CNT_int : integer range 0 to 50000000;
signal start_trans : std_ulogic;
signal patterns : std_ulogic_vector(4 downto 0);
signal led_from_pb	: std_ulogic_vector(6 downto 0);
signal pulse	: std_ulogic;
signal clk_div_cnt	: integer range 0 to 31;
signal clk_div_32	: std_ulogic;

begin

  bp_timer <= (shift_left(to_unsigned(CLK_FREQ,36),4) / base_period);
  
  

  pm_cg : component clk_gen
    port map (
      clk   		=> clk,
      bp_timer		=> bp_timer,
      rst   		=> rst,
		clk_32_out 	=> clk_div_32,
      clk_out		=> clk_div
    );
	  
  
  pm_op : component one_pulse
    port map (
      clk   	=> clk,
      rst   	=> rst,
		input		=> trans_done,
      pulse		=> pulse
    );

  pm_ac : component async_conditioner
    port map (
      clk   => clk,
      rst   => rst,
      async => push_button,
      sync  => sync_push_button
    );

  pm_pSM : component pattern_SM
    port map (
	clk		=> clk,
	rst		=> rst,
	hps_led_control	=> hps_led_control,
	switches	=> switches,
	trans_done	=> trans_done,
	pulse		=> pulse,
	state		=> cstate
    );

  pm_pb : component pattern_behavior
    port map (
      clk   	=> clk_div_32,
      rst   	=> rst,
      patterns	=> patterns,
      led	=> led_from_pb
    );

	 
  trans_counter : process(clk,rst,sync_push_button)

  begin

  if hps_led_control then
    trans_done <= '1';
    led <= led_reg;
  else
	  if rst = '1' then
		 CNT_int <= 0;
	  elsif rising_edge(clk) and sync_push_button = '1' and trans_done = '1' then 
			trans_done <= '0';
	  elsif rising_edge(clk) and trans_done = '0' then
		 led(6 downto 0) <= "000" & switches;
			if CNT_int = 50000000 then
			  CNT_int <= 0;
			  trans_done <= '1';
			else
			  CNT_int <= CNT_int + 1;
			end if;
	  elsif rising_edge(clk) and trans_done = '1' then
		 led(6 downto 0) <= led_from_pb;
	  end if;
	  led(7) <= clk_div;
  end if;

  end process;

  led_output_logic : process(cstate)

  begin

  if trans_done = '1' then
    if cstate = State0 then
	     patterns <= "00001";
	 elsif cstate = State1 then
	     patterns <= "00010";
	 elsif cstate = State2 then
	     patterns <= "00100";
	 elsif cstate = State3 then
	     patterns <= "01000";
	 elsif cstate = State4 then
	     patterns <= "10000";
	 elsif cstate = HPS_Control then
	 -- controlled by hps
		  patterns <= "11111";
    end if;
  else
    patterns <= "00000";
  end if;

  end process;
  
  


    
end architecture led_patterns_arch;
