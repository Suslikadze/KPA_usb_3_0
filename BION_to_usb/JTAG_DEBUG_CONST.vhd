library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
----------------------------------------------------------------------
-- JTAG_DEBUG_CONST
----------------------------------------------------------------------
entity JTAG_DEBUG_CONST is
port (
------------------------------------входные сигналы-----------------------------------------------------

------------------------------------выходные сигналы-----------------------------------------------------
	reg_8bit_0				: out std_logic_vector (7 downto 0);  				-- treshhold_FIFO
	reg_8bit_1				: out std_logic_vector (7 downto 0);  				-- debug_8bit_for_output_data_interface
	reg_8bit_2				: out std_logic_vector (7 downto 0);  				-- Switcher_in_trigg
	reg_8bit_3				: out std_logic_vector (7 downto 0);  				-- Switcher_in_clk
	reg_8bit_4				: out std_logic_vector (7 downto 0);				-- для переключения slwr
	reg_8bit_5				: out std_logic_vector (7 downto 0);				-- для сдвига первого бита в пакете
	reg_8bit_6				: out std_logic_vector (7 downto 0);
	reg_8bit_7				: out std_logic_vector (7 downto 0)					-- для 
	);
end JTAG_DEBUG_CONST;

architecture beh of JTAG_DEBUG_CONST is 

component const
Port(
   result      :  OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
end component;

begin

const_8bit_0	:const port map( result => reg_8bit_0	);
const_8bit_1	:const port map( result => reg_8bit_1	);
const_8bit_2	:const port map( result => reg_8bit_2	);
const_8bit_3	:const port map( result => reg_8bit_3	);
const_8bit_4	:const port map( result => reg_8bit_4	);
const_8bit_5	:const port map( result => reg_8bit_5	);
const_8bit_6	:const port map( result => reg_8bit_6	);
const_8bit_7	:const port map( result => reg_8bit_7	);

end beh;