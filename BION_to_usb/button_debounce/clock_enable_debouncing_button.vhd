library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clock_enable_debouncing_button is
port(
    clk_in              : in    STD_logic;
    slow_clk_enable     : out   STD_logic
);
end clock_enable_debouncing_button;

Architecture clock_enable_debouncing_button_arch of clock_enable_debouncing_button is
signal counter              : std_logic_vector(27 downto 0):=(others => '0');
begin

process(clk_in)
begin
if(rising_edge(clk_in)) then
    counter <= counter + x"0000001"; 
    if(counter>=x"003D08F") then 
        counter <=  (others => '0');
    end if;
end if;
end process;

slow_clk_enable <= '1' when counter=x"003D08F" else '0';

end clock_enable_debouncing_button_arch;