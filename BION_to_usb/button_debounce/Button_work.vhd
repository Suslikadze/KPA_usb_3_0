library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Button_work is
Port(
    clk_in                  : in    STD_LOGIC;
    reset                     : in  STD_LOGIC;
    button_left,
    button_right,
    mode_switcher           : in    STD_LOGIC;
    control_signal_1_out,
    control_signal_2_out,
    control_signal_3_out    : out   std_logic_vector(7 downto 0)
);
end Button_work;

---------------------------------------------------------
---------------------------------------------------------
architecture Button_work_arch of Button_work is
---------------------------------------------------------
---------------------------------------------------------
--обработка кнопок
signal debounced_button_left,
       debounced_button_right,
       debounced_mode_switcher   : STD_LOGIC;

--Сигналы управления выходными параметрами
signal type_of_button_control   : std_logic_vector(1 downto 0) := "00";
signal position_1               : std_logic_vector (7 downto 0) := "00000001";
signal position_2               : std_logic_vector (7 downto 0) := "00000001";
signal position_3               : std_logic_vector (7 downto 0) := "00000001";
signal   control_signal_1,
         control_signal_2,
         control_signal_3       : std_logic_vector (7 downto 0);
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Подключение экземпляров модулей обработки дребезга кнопки
---------------------------------------------------------
debounced_switcher: entity work.debounce 
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => mode_switcher,
   push_out       => debounced_mode_switcher
);
debounced_left: entity work.debounce
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => button_left,
   push_out       => debounced_button_left 
);
debounced_right: entity work.debounce
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => button_right,
   push_out       => debounced_button_right
);

---------------------------------------------------------
--Логика управления сигналами с помощью кнопок 
---------------------------------------------------------
Process(clk_in)
Begin
---------------
   if rising_edge(clk_in) then
      if (debounced_mode_switcher = '1') then
         if (type_of_button_control <= 2) then
            type_of_button_control <= type_of_button_control + 1;
         else
            type_of_button_control <= (others => '0');
         end if;
      end if;
   end if;   
end process;
---------------
Process(clk_in)
begin
if rising_edge(clk_in) then  
---------------
   case (type_of_button_control) is
      when "00" => 
        if (debounced_button_left = '1') then
            if (position_1 /= x"0") then
                position_1 <= position_1 - 1;
            end if;
        elsif (debounced_button_right = '1') then
            if (to_integer(unsigned(position_1)) /= 256) then
                position_1 <= position_1 + 1;
            end if;
        end if;
        control_signal_1 <= position_1;
      when "01" => 
        if (debounced_button_left = '1') then
            if (position_2 /= x"0") then
               position_2 <= position_2 - 1;
            end if;
        elsif (debounced_button_right = '1') then
            if (position_2 /= x"9") then
               position_2 <= position_2 + 1;
            end if;
        end if;
        control_signal_2 <= position_2;
      when "10" => 
        if (debounced_button_left = '1') then
            if (position_3 /= x"0") then
               position_3 <= position_3 - 1;
            end if;
        elsif (debounced_button_right = '1') then
            if (to_integer(unsigned(position_3)) /= 256) then
               position_3 <= position_3 + 1;
            end if;
        end if;
        control_signal_3 <= position_3;
      when others => 
        if (debounced_button_left = '1') then
            if (position_1 /= x"0") then
               position_1 <= position_1 - 1;
            end if;
        elsif (debounced_button_right = '1') then
            if (position_1 /= x"9") then
               position_1 <= position_1 + 1;
            end if;
        end if;
        control_signal_1 <= position_1;
   end case;
end if;
end process;

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
control_signal_1_out <= control_signal_1;
control_signal_2_out <= control_signal_2;
control_signal_3_out <= control_signal_3;
---------------------------------------------------------
end Button_work_arch;