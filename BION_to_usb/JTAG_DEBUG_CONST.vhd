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
	reg_8bit_0				: out std_logic_vector (7 downto 0);  			
	reg_8bit_1				: out std_logic_vector (7 downto 0);  			
	reg_8bit_2				: out std_logic_vector (7 downto 0);  			
	reg_8bit_3				: out std_logic_vector (7 downto 0);  			
	reg_8bit_4				: out std_logic_vector (7 downto 0);			
	reg_8bit_5				: out std_logic_vector (7 downto 0);			
	reg_8bit_6				: out std_logic_vector (7 downto 0);
	reg_8bit_7				: out std_logic_vector (7 downto 0);
	reg_8bit_8				: out std_logic_vector (7 downto 0);
	reg_8bit_9				: out std_logic_vector (7 downto 0);
	reg_8bit_10				: out std_logic_vector (7 downto 0)
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
const_8bit_8	:const port map( result => reg_8bit_8	);
const_8bit_9	:const port map( result => reg_8bit_9	);
const_8bit_10	:const port map( result => reg_8bit_10	);

end beh;