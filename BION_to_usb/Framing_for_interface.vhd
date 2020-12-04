library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Framing_for_interface is
Port(
   clk_in            : in     STD_LOGIC;
   reset             : in     STD_LOGIC;
   data_ch_1         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_2         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_3         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_4         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   Pix_per_line      : in     STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame    : in     STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   frame_in          : in     STD_LOGIC;
   data_out          : out    STD_LOGIC_VECTOR(7 downto 0)
);
end Framing_for_interface;
---------------------------------------------------------
---------------------------------------------------------
architecture Framing_for_interface_arch of Framing_for_interface is
---------------------------------------------------------
---------------------------------------------------------


---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Выделение памяти для храниния строк от разных камер (по два на каждую)
---------------------------------------------------------







Process(clk_in)
begin
if rising_edge(clk_in) then
      if (str_active and pix_active) then
         enable_for_write_buffer <= '1';
      else 
         enable_for_write_buffer <= '0';
      end if; 
end if;
end process;
---------------------------------------------------------
--Выделение активной части кадра
Process(clk_in)
BEGIN
    if rising_edge(clk_in) then
        if (to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift ) and (to_integer(unsigned(Pix_per_line)) < std_logic_vector(to_unsigned(resolution_x, bit_pix)) + BION_960_960p30.HsyncShift) then
            pix_active <= '1';
        else
            pix_active <= '0';
        end if;
   ------------
        if (to_integer(unsigned(Line_per_frame)) >= BION_960_960p30.VsyncShift) and (to_integer(unsigned(Line_per_frame)) <BION_960_960p30.VsyncShift + std_logic_vector(to_unsigned(resolution_y, bit_strok))) then
            str_active <= '1';
        else
            str_active <= '0';
        end if;
    end if;
end Process;
---------------------------------------------------------
Process(clk_in)
begin
if rising_edge(clk_in) then
         resolution_x <= debug 1;
         resolution_y <= debug 2;
   -- case (debug_4(2 downto 0)) is
   --    when "000" =>
   --       resolution_x <= 1024;
   --       resolution_y <= 1024;
   --    when "001" =>
   --       resolution_x <= 2048;
   --       resolution_y <= 1024;
   --    when "010" =>
   --       resolution_x <= 512;
   --       resolution_y <= 256;
   --    when "011" =>
   --       resolution_x <= 960;
   --       resolution_y <= 960;
   --    when "100" =>
   --       resolution_x <= 2048;
   --       resolution_y <= 2048;
   --    when "101" =>
   --       resolution_x <= 1024;
   --       resolution_y <= 2048;
   --    when others => 
   --       resolution_x <= 1024;
   --       resolution_y <= 1024;
   -- end case;
end if;
end process;
---------------------------------------------------------

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
---------------------------------------------------------
end data_generation_arch;