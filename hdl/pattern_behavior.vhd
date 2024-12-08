library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Common_pkg.all;

entity pattern_behavior is
  port (
    clk		 	: in std_ulogic;
    rst			: in std_ulogic;
    patterns		: in std_ulogic_vector(4 downto 0);
    led			: out std_ulogic_vector(6 downto 0)
  );
end entity pattern_behavior;

architecture pattern_behavior_arch of pattern_behavior is

signal bp_count_pat1	: integer range 0 to 15 := 0;
signal bp_count_pat2	: integer range 0 to 7 := 0;
signal bp_count_pat3	: integer range 0 to 63 := 0;
signal bp_count_pat4	: integer range 0 to 3 := 0;
signal bp_count_pat5	: integer range 0 to 7 := 0;
signal cnt_7bit_up	: unsigned(6 downto 0) := "0000000";
signal cnt_7bit_down	: unsigned(6 downto 0) := "1111111";
signal start_pat1_led	: unsigned(6 downto 0) := "1000000";
signal start_pat2_led	: unsigned(6 downto 0) := "0000011";
signal start_pat5_led	: std_ulogic_vector(6 downto 0) := "1010101";

begin

  process(clk,rst)
    begin
    if rst = '1' then 
        bp_count_pat1 <= 0;
	     bp_count_pat2 <= 0;
	     bp_count_pat4 <= 0;
	     bp_count_pat5 <= 0;
        led <= "0000000";
    else
      if patterns = "00001" then
	     if rising_edge(clk) and bp_count_pat1 = 15 then
	       bp_count_pat1 <= 0; 
	       if start_pat1_led = "0000001" then
	         start_pat1_led <= "1000000";
	       else
	         start_pat1_led <= shift_right(start_pat1_led,1);
	       end if;
	     elsif rising_edge(clk) then
	       bp_count_pat1 <= bp_count_pat1 + 1;
	     end if;
	     led <= std_ulogic_vector(start_pat1_led);
      elsif patterns = "00010" then
	     if rising_edge(clk) and bp_count_pat2 = 7 then
	       bp_count_pat2 <= 0; 
	       if start_pat2_led = "1000001" then
	         start_pat2_led <= "0000011";
	       elsif start_pat2_led = "1100000" then
	         start_pat2_led <= "1000001";
	       else
	         start_pat2_led <= shift_left(start_pat2_led,1);
	       end if;
	     elsif rising_edge(clk) then
	       bp_count_pat2 <= bp_count_pat2 + 1;
	     end if;
	     led <= std_ulogic_vector(start_pat2_led);
      elsif patterns = "00100" then
		  if rising_edge(clk) and bp_count_pat3 = 63 then
		     bp_count_pat3 <= 0;
			  if cnt_7bit_up = "1111111" then
				 cnt_7bit_up <= "0000000";
			  else
				 cnt_7bit_up <= cnt_7bit_up + 1;
			  end if;
		  elsif rising_edge(clk) then
	       bp_count_pat3 <= bp_count_pat3 + 1;
		  end if;
	     led <= std_ulogic_vector(cnt_7bit_up);
      elsif patterns = "01000" then
	     if rising_edge(clk) and bp_count_pat4 = 3 then
	       bp_count_pat4 <= 0; 
	       if cnt_7bit_down = "0000000" then
	         cnt_7bit_down <= "1111111";
	       else
	         cnt_7bit_down <= cnt_7bit_down - 1;
	       end if;
	     elsif rising_edge(clk) then
	       bp_count_pat4 <= bp_count_pat4 + 1;
	     end if;
	     led <= std_ulogic_vector(cnt_7bit_down);
      elsif patterns = "10000" then
	     if rising_edge(clk) and bp_count_pat5 = 7 then
	       bp_count_pat5 <= 0; 
	       start_pat5_led <= not start_pat5_led;
	     elsif rising_edge(clk) then
	       bp_count_pat5 <= bp_count_pat5 + 1;
	     end if;
	     led <= start_pat5_led;
      elsif patterns = "11111" then
		  -- leds controlled by arm hps system
      end if;
    end if;
  end process;

end architecture pattern_behavior_arch;