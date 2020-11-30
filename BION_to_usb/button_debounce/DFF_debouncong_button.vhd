library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity DFF_debouncing_button is
port(
    clk_in          : in STD_LOGIC;
    clock_enable    : in STD_LOGIC;
    input_signal    : in std_logic;
    output_signal   : out std_logic := '0'
);
end DFF_debouncing_button;


architecture clock_enable_generator_arch of DFF_debouncing_button is
BEGIN

Process(clk_in)
BEGIN
if rising_edge(clk_in) then
    if (clock_enable) then
        output_signal <= input_signal;
    end if;
end if;
end process;

end clock_enable_generator_arch;