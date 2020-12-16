library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 


entity menu_top is
Port(
    clk_in                      : in    STD_LOGIC;
    reset                       : in    STD_LOGIC;
    enable                      : in    STD_LOGIC;
    Pix_per_line                : in    STD_LOGIC_VECTOR(Bitness_interface.bit_pix      - 1 downto 0);
    Line_per_frame              : in    STD_LOGIC_VECTOR(Bitness_interface.bit_strok    - 1 downto 0);
    stroka_interface_flag       : in    STD_LOGIC;
    frame_interface_flag        : in    STD_LOGIC;
    Pix_of_start_menu           : in    STD_LOGIC_VECTOR(Bitness_interface.bit_pix      - 1 downto 0);
    Line_of_start_menu          : in    STD_LOGIC_VECTOR(Bitness_interface.bit_pix      - 1 downto 0);
    menu_window_valid           : out   STD_LOGIC;
    out_data                    : out   STD_LOGIC_VECTOR(bit_data                       - 1 downto 0)
);
end menu_top;

Architecture menu_top_arch of menu_top is


---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
Text_on_screen_module          : entity work.Text_on_screen
generic map(
    bit_pix         => Bitness_interface.bit_pix,
    bit_strok       => Bitness_interface.bit_strok,
    bit_data_out    => 20,
    bit_data_in     => bit_data
)
Port map(
    clk                 => clk_in,
    rst                 => rst,
    newline             => stroka_interface_flag,
    newframe            => frame_interface_flag,
    x                   => Pix_per_line,
    y                   => Line_per_frame,
    x0                  => Pix_of_start_menu,
    y0                  => Line_of_start_menu,
    input_mode          => exit_value,
    input_Type_AGC      => exit_value1,
    input_Set_LVL1      => exit_value,
    input_Set_LVL2      => exit_value1,
    menu_window_valid   => menu_window_valid,
    out_data            => out_data
);
---------------------------------------------------------
Test_signal_1_convert       : entity work.until_99999_conventer
Port map(
    some_value      => std_logic_vector(to_unsigned(counter_value, 12)),
    en              => enable,
    trigger         => frame_interface_flag,
    exit_value      => exit_value
);

Test_signal_2_convert       : entity work.until_99999_conventer
Port map(
    some_value      => std_logic_vector(to_unsigned(counter_value1, 12)),
    en              => enable,
    trigger         => frame_interface_flag,
    exit_value      => exit_value1
);

---------------------------------------------------------
--Тестовые входные данные
---------------------------------------------------------
Process(frame_interface_flag)
BEGIN
if rising_edge(frame_interface_flag) then
    if(counter_clk1 != 1) then
        counter_clk1 <= counter_clk1 + 1;
    elsif (counter_value1 != 200) then
        counter_clk1 <= 0;
        counter_value1 <= counter_value1 + 1;
    else
        counter_value1 <= counter_value1 + 1;
        counter_clk1 <= 0;
    end if;
end if;
end process;

Process(frame_interface_flag)
BEGIN
if rising_edge(frame_interface_flag) then
    if(counter_clk != 1) then
        counter_clk <= counter_clk + 1;
    elsif (counter_value != 77) then
        counter_clk <= 0;
        counter_value <= counter_value + 1;
    else
        counter_value <= counter_value + 1;
        counter_clk <= 0;
    end if;
end if;
end process;
---------------------------------------------------------
---------------------------------------------------------
end menu_top_arch;