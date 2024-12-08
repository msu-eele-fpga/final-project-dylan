library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Common_pkg.all;

entity pattern_SM is
  port (
    clk					: in std_ulogic;
    rst					: in std_ulogic;
    hps_led_control	: in boolean;
    switches			: in std_ulogic_vector(3 downto 0);
    trans_done			: in std_ulogic;
	 pulse				: in std_ulogic;
    state				: out led_state
  );
end entity;

architecture pattern_SM_arch of pattern_SM is

signal current_state 	: led_state;

begin

  -- combinational
  state_logic : process(clk,rst)
  begin
    if (hps_led_control) then
      -- controlled by arm hps (HPS_Control)
		current_state <= HPS_Control;
    else
      -- controlled by state machine 
      if rst = '1' then
		  current_state <= State0;
      elsif rising_edge(clk) and pulse = '1' then
		  if (current_state = State0 and switches = "0001") then
		    current_state <= State1;
		  elsif (current_state = State0 and switches = "0010") then
			 current_state <= State2;
		  elsif (current_state = State0 and switches = "0011") then
		    current_state <= State3;
		  elsif (current_state = State0 and switches = "0100") then
		    current_state <= State4;
		  elsif current_State = State0 and switches > "0100" then
		    current_state <= State0;
		  end if;
		  
		  if (current_state = State1 and switches = "0000") then
		    current_state <= State0;
		  elsif (current_state = State1 and switches = "0010") then
			 current_state <= State2;
		  elsif (current_state = State1 and switches = "0011") then
		    current_state <= State3;
		  elsif (current_state = State1 and switches = "0100") then
		    current_state <= State4;
		  elsif current_State = State1 and switches > "0100" then
		    current_state <= State1;
		  end if;
		  
		  if (current_state = State2 and switches = "0001") then
		    current_state <= State1;
		  elsif (current_state = State2 and switches = "0000") then
			 current_state <= State0;
		  elsif (current_state = State2 and switches = "0011") then
		    current_state <= State3;
		  elsif (current_state = State2 and switches = "0100") then
		    current_state <= State4;
		  elsif current_State = State2 and switches > "0100" then
		    current_state <= State2;
		  end if;
		  
		  if (current_state = State3 and switches = "0001") then
		    current_state <= State1;
		  elsif (current_state = State3 and switches = "0010") then
			 current_state <= State2;
		  elsif (current_state = State3 and switches = "0000") then
		    current_state <= State0;
		  elsif (current_state = State3 and switches = "0100") then
		    current_state <= State4;
		  elsif current_State = State3 and switches > "0100" then
		    current_state <= State3;
		  end if;
		  
		  if (current_state = State4 and switches = "0001") then
		    current_state <= State1;
		  elsif (current_state = State4 and switches = "0010") then
			 current_state <= State2;
		  elsif (current_state = State4 and switches = "0011") then
		    current_state <= State3;
		  elsif (current_state = State4 and switches = "0000") then
		    current_state <= State0;
		  elsif current_State = State4 and switches > "0100" then
		    current_state <= State4;
		  end if;
		  
		  if (current_state = HPS_Control and switches = "0000") then
		    current_state <= State0;
		  elsif (current_state = HPS_Control and switches = "0001") then
		    current_state <= State1;
		  elsif (current_state = HPS_Control and switches = "0010") then
		    current_state <= State2;
		  elsif (current_state = HPS_Control and switches = "0011") then
		    current_state <= State3;
		  elsif (current_state = HPS_Control and switches = "0100") then
		    current_state <= State4;
		  elsif (current_state = HPS_Control and switches > "0100") then
		    current_state <= State0;
		  end if;
      end if;
    end if;
  end process;

state <= current_state;

end architecture pattern_SM_arch;
