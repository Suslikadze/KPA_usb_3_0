library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Debouncing_Button_top is
port(
 button: in std_logic;
 clk: in std_logic;
 debounced_button: out std_logic
);
end Debouncing_Button_top;

architecture Debouncing_Button_top_arch of Debouncing_Button_top is
signal slow_clk_enable      : std_logic;
signal Q1,Q2,Q2_bar,Q0      : std_logic;

BEGIN
clock_enable_generator: entity work.clock_enable_debouncing_button 
Port map(
    clk_in              => clk,
    slow_clk_enable     => slow_clk_enable
);

Debouncing_FF0: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk_in => clk,
        clock_enable => slow_clk_enable,
        input_signal => button,
        output_signal => Q0
      ); 

Debouncing_FF1: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk_in => clk,
        clock_enable => slow_clk_enable,
        input_signal => Q0,
        output_signal => Q1
      );      
Debouncing_FF2: entity work.DFF_Debouncing_Button PORT MAP 
      ( clk_in => clk,
        clock_enable => slow_clk_enable,
        input_signal => Q1,
        output_signal => Q2
      ); 
 Q2_bar <= not Q2;
 debounced_button <= Q1 and Q2_bar;

end Debouncing_Button_top_arch;