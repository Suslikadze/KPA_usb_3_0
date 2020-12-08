library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
entity mux_2_ch is
port(
    clk_in              : IN    STD_LOGIC;
    enable              : IN    STD_LOGIC;
    reset               : IN    STD_LOGIC;
    Pix_per_line        : IN    STD_LOGIC_VECTOR(Bitness_interface.bit_pix - 1 downto 0);
    Line_per_frame      : IN    STD_LOGIC_VECTOR(Bitness_interface.bit_strok - 1 downto 0);
    data_in_ch_1        : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    data_in_ch_2        : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    data_out            : OUT   STD_LOGIC_VECTOR(bit_data - 1 downto 0)
);
end mux_2_ch;
---------------------------------------------------------
---------------------------------------------------------
architecture mux_2_ch_arch of mux_2_ch is
---------------------------------------------------------
---------------------------------------------------------
signal data_out_buffer          : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal counter                  : STD_LOGIC_VECTOR(3 downto 0);
signal flag                     : STD_LOGIC := '0';
---------------------------------------------------------
--Объявление компонент
component count_n_modul
   generic (n		: integer);
   port(
      clk,
      reset,
      en		:	in std_logic;
      modul		: 	in std_logic_vector (n-1 downto 0);
      qout		: 	out std_logic_vector (n-1 downto 0);
      cout		:	out std_logic
   );
end component;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
--Описание компонент
counter_for_2_ch            :count_n_modul
generic map(4)
port map(
    clk         =>  clk_in,      
    reset       =>  reset,
    en	        =>  enable,
    modul	    =>  std_logic_vector(to_unsigned(8,4)),
    qout	    =>  counter    
);
---------------------------------------------------------
Process(clk_in)
BEGIN
if rising_edge(clk_in) then
    if (enable = '1') then
        -- if (Pix_per_line(0) = '0') then
        --     data_out <= data_in_ch_2;
        -- elsif (Pix_per_line(0)= '1') then
        --     data_out <= data_in_ch_1;
        -- end if;
        if (flag = '1') then
            data_out <= data_in_ch_1;
            flag <= not flag;
        else 
            data_out <= data_in_ch_2;
            flag <= not flag;
        end if;
    end if;
end if;
end process;
---------------------------------------------------------
end mux_2_ch_arch;