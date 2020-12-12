library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
---------------------------------------------------------
entity two_ch_to_one_top is
port(
    clk_in_0                : in    STD_LOGIC;
    clk_in_1                : in    STD_LOGIC;
    reset                   : in    STD_LOGIC;
    enable_ch1              : in    STD_LOGIC;
    enable_ch2              : in    STD_LOGIC;
    Pix_per_line            : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_pix - 1 downto 0);
    Line_per_frame          : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_strok - 1 downto 0);
    data_in_ch_1            : in    STD_LOGIC;
    data_in_ch_2            : in    STD_LOGIC;
    align_num               : in    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    reset_sync_counters     : out   STD_LOGIC;
    data_out                : out   STD_LOGIC_VECTOR(bit_data - 1 downto 0)    
);
end two_ch_to_one_top;
---------------------------------------------------------
---------------------------------------------------------
architecture two_ch_to_one_top_arch of two_ch_to_one_top is
---------------------------------------------------------
---------------------------------------------------------
signal data_par_1, data_par_2               : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_par_1_delay, data_par_2_delay   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_out_in                          : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal align_flag_in                        : STD_LOGIC;
signal reset_each_line_in                   : STD_LOGIC;
signal clk_pix_in, clk_for_mux              : STD_LOGIC;
---------------------------------------------------------
--Объявление компонент
component input_serial_channel
port(
    clk_Serial					: in std_logic;  										
	main_reset					: in std_logic;  								
	main_enable					: in std_logic;									
	data_in_ser				    : in std_logic;					
	align_load					: in std_logic_vector (7 downto 0);				 
	align_flag					: out std_logic;
	data_out_Parallel			: out std_logic_vector (bit_data-1 downto 0)
);
end component;
---------------------------------------------------------
component mux_2_ch
port(
    clk_in              : IN    STD_LOGIC;
    enable              : IN    STD_LOGIC;
    reset               : IN    STD_LOGIC;
    Pix_per_line        : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_pix - 1 downto 0);
    Line_per_frame      : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_strok - 1 downto 0);
    data_in_ch_1        : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0) := (others => '0');
    data_in_ch_2        : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0) := (others => '0');
    data_out            : OUT   STD_LOGIC_VECTOR(bit_data - 1 downto 0)    
);
end component;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
--Описание компонент
Deserial_1              : input_serial_channel
port map(
    ---------in-----------
    clk_Serial	        =>  clk_in_0,   	
    main_reset		    =>  reset,
    main_enable		    =>  enable_ch1,
    data_in_ser		    =>  data_in_ch_1,
    align_load		    =>  align_num,
    ---------out----------
    align_flag		    =>  align_flag_in,
    data_out_Parallel   =>  data_par_1
);
---------------------------------------------------------
-- Deserial_2              : input_serial_channel 
-- port map(
--     ---------in-----------
--     clk_Serial	        =>  clk_in_0,   	
--     main_reset		    =>  reset,
--     main_enable		    =>  enable_ch2,
--     data_in_ser		    =>  data_in_ch_2,
--     ---------out----------
--     align_load		    =>  align_num,
--     data_out_Parallel   =>  data_par_2
-- );
---------------------------------------------------------
Aligner_comp            : entity    work.Aligner
Port map(
    ---------in-----------
    clk_in                  =>  clk_in_0,
    clk_cam                 =>  clk_in_1,
    reset                   =>  reset,
    Pix_per_line            =>  Pix_per_line,
    Line_per_frame          =>  Line_per_frame,
    Flag_8_bit              =>  align_flag_in,
    enable                  =>  '1',
    ch_1_par                =>  data_par_1,
    ---------out----------
    reset_sync_counters     => reset_sync_counters
    --Align_word              =>  align_num,
);
---------------------------------------------------------
-- mux_2_ch_comp           : mux_2_ch
-- port map(
--     ---------in-----------
--     clk_in              => clk_in_1,
--     enable              => '0',
--     reset               => align_flag_in,
--     Pix_per_line        => Pix_per_line,
--     Line_per_frame      => Line_per_frame,
--     data_in_ch_1        => data_par_1_delay,
--     data_in_ch_2        => data_par_2_delay,
--     ---------out----------
--     data_out            => data_out_in
-- );
---------------------------------------------------------
-- Process(clk_in_1)
-- BEGIN
--     if rising_edge(clk_in_1) then
--         data_par_1_delay <= data_par_1;
--         data_par_2_delay <= data_par_2;
--     end if;
-- end process;
data_out    <=  data_par_1;
---------------------------------------------------------
end two_ch_to_one_top_arch;