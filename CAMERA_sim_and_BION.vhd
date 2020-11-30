library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 


entity Camera_and_BION_top  is
PORT(
    clk_in                  : in    STD_LOGIC;
    reset                   : in    STD_LOGIC;
    FLAGA                   : IN    STD_LOGIC;
    FLAGB                   : IN    STD_LOGIC;
    FLAGC                   : IN    STD_LOGIC;
    FLAGD                   : IN    STD_LOGIC;
    PCLK                    : out   STD_LOGIC;
    slwr                    : out   STD_LOGIC;
    slcs                    : out   STD_LOGIC;
    sloe                    : out   STD_LOGIC;
    slrd                    : out   STD_LOGIC;
    pktend                  : out   STD_LOGIC;
    A                       : out   STD_LOGIC_VECTOR(1 downto 0);
    Switcher                : in   STD_LOGIC_VECTOR(3 downto 0);
    reset_FX                : out   STD_LOGIC;
    out1                    : out   std_logic;
    out2                    : out   std_logic;
    out3                    : out   std_logic;
    out4                    : out   std_logic;
    databus                 : out   STD_LOGIC_VECTOR(bit_data_out - 1 downto 0)
);
END Camera_and_BION_top;
---------------------------------------------------------
---------------------------------------------------------
architecture Camera_and_BION_top_arch of Camera_and_BION_top is
---------------------------------------------------------
---------------------------------------------------------
--BION TOP      
signal PCLK_in             :    std_logic;
signal A_in                :    std_logic_vector(1 downto 0);
signal slrd_in             :    std_logic;
signal slwr_in             :    std_logic;     
signal sloe_in             :    std_logic;
signal pktend_in           :    std_logic; 		
signal reset_FX_in         :    std_logic; 
signal slcs_in             :    std_logic;
signal out1_in             :    std_logic;
signal out2_in             :    std_logic;
signal out3_in             :    std_logic;
signal out4_in             :    std_logic;
signal databus_in          :    std_logic_vector(bit_data_out - 1 downto 0);
--Camera_sim
signal data_to_BION_1, data_to_BION_2     : STD_LOGIC;
signal clk_to_BION                        : STD_LOGIC;
--машинный автомат
type State_type is(
	idle,
	FLAGB_on,
	FLAGA_on,
	FLAGB_off,
	FLAGA_off
);
signal state						: State_type := idle;
signal reset_tsb					: std_logic := '0';
--------
signal clk_for_arch					: STD_LOGIC;
constant	size_FIFO_FX	: integer := 4096;
---------------------------------------------------------
component Camera_sim
Port(
    clk_in              : in    STD_LOGIC;
    reset               : in    STD_LOGIC;
    Switcher_for_data   : IN    STD_LOGIC_VECTOR(3 downto 0);
    data_out_1              : out   STD_LOGIC;
    data_out_2              : out   STD_LOGIC;
    clk_out                 : out   STD_LOGIC 
);
end component;
---------------------------------------------------------
component BION_TOP
Port(
    clk_in      :in     std_logic; 
    FLAGA       :IN     std_logic;
    FLAGB       :IN     std_logic;
    FLAGC       :IN     std_logic;
    FLAGD       :IN     std_logic;     
    reset       :in     std_logic;
    data_in_1   :in     std_logic;
    data_in_2   :in     std_logic;
    PCLK        :out    std_logic;
    A           :out    std_logic_vector(1 downto 0);
    slrd        :out    std_logic;
    slwr        :out    std_logic;     
    sloe        :out    std_logic;
    pktend      :out    std_logic; 		
    reset_FX    :out    std_logic; 
    slcs        :out    std_logic;
    out1        :out    std_logic;
    out2        :out    std_logic;
    out3        :out    std_logic;
    out4        :out    std_logic;
    databus     :out    std_logic_vector(bit_data_out - 1 downto 0)
);
end component;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
Camera_simulation       : Camera_sim
Port map(
    ---------in-----------
    clk_in              => clk_in,
    reset               => reset,
    Switcher_for_data   => Switcher,
    --------out----------
    data_out_1          => data_to_BION_1,
    data_out_2          => data_to_BION_2,
    clk_out             => clk_to_BION
);
---------------------------------------------------------
BION_component          : BION_TOP
Port map(
    ---------in-----------
    clk_in          =>  clk_to_BION,
    FLAGA           =>  FLAGA,
    FLAGB           =>  FLAGB,
    FLAGC           =>  FLAGC,
    FLAGD           =>  FLAGD,
    reset           =>  reset,
    data_in_1       =>  data_to_BION_1,
    data_in_2       =>  data_to_BION_2,
    --------out----------
    PCLK            =>  PCLK,
    A               =>  A,
    slrd            =>  slrd,
    slwr            =>  slwr,
    sloe            =>  sloe,
    pktend          =>  pktend,
    reset_FX        =>  reset_FX,
    slcs            =>  slcs,
    out1            =>  out1,
    out2            =>  out2,
    out3            =>  out3,
    out4            =>  out4,
    databus         =>  databus_in
);
---------------------------------------------------------
databus <= databus_in;
--PCLK    <= PCLK_in;
---------------------------------------------------------
-- Process(PCLK_in, reset_tsb) 
-- variable counter, counter_in_FLAGB_on		: integer;
-- BEGIN

-- 	If (reset_tsb) then
-- 		state <= idle;
-- 	end if;
-- 	if rising_edge(PCLK_in) then
-- 		case state is
-- 			when idle => 
-- 				FLAGA <= '0';
-- 				FLAGB <= '0';
-- 				state <= FLAGB_on;
-- 				counter := 0;
-- 				counter_in_FLAGB_on := 0;
-- 			when FLAGB_on =>
-- 				FLAGB <= '1';
-- 				if counter_in_FLAGB_on < 2 then
-- 					counter_in_FLAGB_on := counter_in_FLAGB_on + 1;
-- 				else
-- 					counter_in_FLAGB_on := 0;
-- 					state <= FLAGA_on;
-- 				end if;
-- 			When FLAGA_on =>
-- 				FLAGA <= '1';
-- 				if (slwr = '0') then
-- 					if (counter < size_FIFO_FX - 3) then
-- 						counter := counter + 1;
-- 					else
-- 						state <= FLAGB_off;
-- 						counter := counter + 1;
-- 					end if;----
-- 				end if; 
-- 			when FLAGB_off =>
-- 				FLAGB <= '0';
-- 				if (slwr = '0') then
-- 					if (counter < size_FIFO_FX) then
-- 						counter := counter + 1;
-- 					else
-- 						state <= FLAGA_off;
-- 						counter := counter + 1;
-- 					end if;
-- 				end if;
-- 			when FLAGA_off =>
-- 				FLAGA <= '0';
-- 				if (counter <= size_FIFO_FX + 25) then
-- 					counter := counter + 1;
-- 				else
-- 					state <= idle;
-- 				end if;
-- 		end case;
-- 	end if;
-- end process;
---------------------------------------------------------
---------------------------------------------------------
end Camera_and_BION_top_arch;