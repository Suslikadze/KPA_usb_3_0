library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 


entity output_data_interface is
PORT(
    clk_in              : in    STD_LOGIC;
    reset               : in    STD_LOGIC;
    pix                 : in    STD_LOGIC_VECTOR(Bitness_interface.bit_pix - 1 downto 0);
    debug_8bit          : in    std_logic_vector(7 downto 0);
    data_8_bit          : in    STD_LOGIC_VECTOR(7 downto 0);
    databus             :out std_logic_vector(31 downto 0)
);
end output_data_interface;
---------------------------------------------------------
---------------------------------------------------------
architecture output_data_interface_arch of output_data_interface is
---------------------------------------------------------
---------------------------------------------------------
--объединение в 32-битную шину
signal Flag_for_databus      : STD_LOGIC;
signal output_buffer        : STD_LOGIC_VECTOR(31 downto 0);

---------------------------------------------------------
---------------------------------------------------------
Begin
---------------------------------------------------------
---------------------------------------------------------
Process(clk_in)
begin
   if rising_edge(clk_in) then
         case pix(1 downto 0) is
            when "11" =>       output_buffer(31 downto 24)  <= data_8_bit;
            when "10" =>       output_buffer(23 downto 16)  <= data_8_bit;
            when "01" =>       output_buffer(15 downto 8)   <= data_8_bit;
            when "00" =>       output_buffer(7 downto 0)    <= data_8_bit;
            when others =>     output_buffer                <= (others => '0');
         end case;

       --  if pix(1 downto 0) = debug_8bit (1 downto 0) then
         --   databus <= output_buffer;
       --  end if;
       if pix(1 downto 0) = debug_8bit  (1 downto 0) then
         Flag_for_databus <= '1';
      else
         Flag_for_databus <= '0';
      end if;
   end if;
end process;
---------------------------------------------------------
Process(clk_in)
begin
   if rising_edge(clk_in) then
      if (Flag_for_databus = '1') then
         databus <= output_buffer;
      end if;
   end if;
end process;

---------------------------------------------------------
end output_data_interface_arch;