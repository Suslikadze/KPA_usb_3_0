library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 


entity BION_TOP is
PORT(
    clk_in      :in     std_logic; 
    FLAGA       :IN     std_logic;
    FLAGB       :IN     std_logic;
    FLAGC       :IN     std_logic;
    FLAGD       :IN     std_logic;     
    reset       :in     std_logic;
    data_in_1   :in     std_logic;
    data_in_2   :in     std_logic;
    button_left,
    button_right,
    mode_switcher     : in    STD_LOGIC;
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
end BION_TOP;
---------------------------------------------------------
---------------------------------------------------------
architecture BION_TOP_arch of BION_TOP is
---------------------------------------------------------
---------------------------------------------------------
--Synth_gen
signal Pix_per_line                 : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal Line_per_frame               : STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
signal frame_number                 : STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
signal frame_flag                   : STD_LOGIC;
signal stroka_flag                  : STD_LOGIC;
signal enable_for_pix               : STD_LOGIC;
--signal reset                        : STD_LOGIC;
signal clk_pix_in, PCLK_in          : STD_LOGIC;
--Data_gen
signal slwr_in_arch                 : STD_LOGIC;
signal data_8_bit                   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--output_data_interface
signal databus_arch                 : STD_LOGIC_VECTOR(bit_data_out - 1 downto 0);
--JTAG_DEBUG_CONST
signal  debug_8bit_for_output_data_interface,
        Switcher_in_trigg,
        Switcher_in_clk             : STD_LOGIC_VECTOR(7 downto 0);
--Выбор входных данных
signal data_from_switcher           : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--from mux
signal data_from_mux                : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--Debug signals
signal trigg_signal_tap, clk_signal_tap     : std_logic;
signal debug_3, debug_ser_shift          : std_logic_vector(7 downto 0);
signal debug_1                              : std_logic_vector(7 downto 0);
signal debug_2                              : std_logic_vector(7 downto 0);
signal debug_4, debug_5                     : std_logic_vector(7 downto 0);



---------------------------------------------------------
signal clk_bit     : std_logic;
signal clk_pix     : std_logic;
---------------------------------------------------------

---------------------------------------------------------
---------------------------------------------------------
-- component JTAG_DEBUG_CONST
-- Port(
--     reg_8bit_0				: out std_logic_vector (7 downto 0);  				-- treshhold_FIFO debug1
-- 	reg_8bit_1				: out std_logic_vector (7 downto 0);  				-- debug_8bit_for_output_data_interface
-- 	reg_8bit_2				: out std_logic_vector (7 downto 0);  				-- Switcher_in_trigg
-- 	reg_8bit_3				: out std_logic_vector (7 downto 0);  				-- Switcher_in_clk
--     reg_8bit_4				: out std_logic_vector (7 downto 0);                -- для переключения slwr
-- 	reg_8bit_5				: out std_logic_vector (7 downto 0);				-- для сдвига первого бита в пакете
--     reg_8bit_6				: out std_logic_vector (7 downto 0);
--     reg_8bit_7              : out std_logic_vector (7 downto 0)				    
--     );
-- end component;



---------------------------------------------------------
---------------------------------------------------------
Begin
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
PLL_input                   : entity work.PLL
Port map(
    inclk0      => clk_in,
    c0          => clk_bit,
    c1	        => clk_pix
);
---------------------------------------------------------
---------------------------------------------------------
--Описание компонентов
---------------------------------------------------------
two_ch_to_one_comp          : entity work.two_ch_to_one_top
port map(
    clk_in_0            => clk_bit,
    clk_in_1            => clk_pix,
    reset               => '0',
    enable              => '1',
    Pix_per_line        => Pix_per_line,
    Line_per_frame      => Line_per_frame,
    data_in_ch_1        => data_in_1,
    data_in_ch_2        => data_in_2,
    align_num           => debug_ser_shift,
    --align_num           => x"06",
    clk_pix             => clk_pix_in,
    data_out            => data_from_mux    
);
---------------------------------------------------------
Synth_gen_top               : entity work.Synth_gen
Port map(
    ---------in-----------
    clk_pix                 => clk_pix_in,
    reset                   => '0',
    enable_for_pix          => '1',
    frame_modul             => x"01",
    ---------out----------
    Pix_per_line            => Pix_per_line,
    Line_per_frame          => Line_per_frame,
    frame_number            => frame_number,
    clk_for_PCLK            => PCLK_in,
    frame_flag              => frame_flag,
    stroka_flag             => stroka_flag
);
---------------------------------------------------------


---------------------------------------------------------
data_generation_top         : entity work.data_generation
PORT map(
    ---------in-----------
    clk_in                  => clk_pix_in,
    reset                   => reset,
    --data_in                 => data_in,
    data_in                 => data_from_mux(7 downto 0),
    debug_1                 => debug_1,
    --debug_1                 => x"01",
    debug_2                 => debug_2,
    --debug_2                 => x"01",
    debug_3                 => debug_3,
--    debug_3                 => x"04",
    debug_4                 => debug_4,
    treshhold_FIFO          => debug_5,
    button_left             => button_left,
    button_right            => button_right,
    mode_switcher           => mode_switcher,
    Pix_per_line            => Pix_per_line,
    Line_per_frame          => Line_per_frame,
    frame_in                => frame_flag,
    FLAGA                   => FLAGA,
    FLAGB                   => FLAGB,
    ---------out----------
    slwr_in_arch            => slwr_in_arch,
    data_8_bit              => data_8_bit
);
---------------------------------------------------------
output_data_interface_arch  : entity work.output_data_interface
Port map(
    ---------in-----------
    clk_in                  => clk_pix_in,
    reset                   => reset,
    pix                     => Pix_per_line,
    --debug_8bit              => debug_8bit_for_output_data_interface,
    debug_8bit              => x"03",
    data_8_bit              => data_8_bit,
    ---------out----------
    databus                 => databus_arch
);  
---------------------------------------------------------
JTAG_DEBUG_CONST_arch       : entity work.JTAG_DEBUG_CONST
Port map(
    ---------out----------
    reg_8bit_0              => debug_1,
    reg_8bit_1              => debug_8bit_for_output_data_interface,
    reg_8bit_2              => Switcher_in_trigg,
    reg_8bit_3              => Switcher_in_clk,
    reg_8bit_4              => debug_3,
    reg_8bit_5              => debug_ser_shift,
    reg_8bit_6              => debug_2,
    reg_8bit_7              => debug_4,
    reg_8bit_8              => debug_5      --treshhold FIFO
);
---------------------------------------------------------
---------------------------------------------------------
--Асинхронное присвоение выходным шинам
slwr                <= not(slwr_in_arch); 
--and debug_slwr(0);
slrd                <= '1'; 
sloe                <= '1';	
pktend              <= '1';
slcs                <= '0';
databus             <= databus_arch;
A(1 downto 0)       <= "00";
-- FIFO_write_volume_0	<=FIFO_write_volume;
out1                <= trigg_signal_tap;
out2                <= clk_signal_tap;
out3                <= clk_signal_tap;
out4                <= trigg_signal_tap;
PCLK                <= PCLK_in;
---------------------------------------------------------
--debug
Process(Switcher_in_clk(3 downto 0))
begin
   case (Switcher_in_clk(3 downto 0)) is
      when X"0" =>     clk_signal_tap <= clk_pix_in;
      when X"1" =>     clk_signal_tap <= Pix_per_line(0);
      when X"2" =>     clk_signal_tap <= stroka_flag;
      when X"3" =>     clk_signal_tap <= Pix_per_line(2);
     -- when X"4" =>     clk_signal_tap <= clk_bit;
      when X"5" =>     clk_signal_tap <= mode_switcher;
      when X"6" =>     clk_signal_tap <= button_left;
      when X"7" =>     clk_signal_tap <= button_right;
      when X"8" =>     clk_signal_tap <= Pix_per_line(7);
      when X"9" =>     clk_signal_tap <= Pix_per_line(8);
      when X"a" =>     clk_signal_tap <= Pix_per_line(9);
      when X"b" =>     clk_signal_tap <= Line_per_frame(0);
      when X"c" =>     clk_signal_tap <= Line_per_frame(1);
     when others =>    clk_signal_tap <= clk_pix_in;   
   end case;
end process;

Process(Switcher_in_trigg(3 downto 0))
begin
   case (Switcher_in_trigg(3 downto 0)) is
    when X"0" =>     trigg_signal_tap <= stroka_flag;
    when X"1" =>     trigg_signal_tap <= frame_flag;
    when X"2" =>     trigg_signal_tap <= FLAGB;
    when X"3" =>     trigg_signal_tap <= FLAGA;
    when X"4" =>     trigg_signal_tap <= slwr; 
    when X"5" =>     trigg_signal_tap <= mode_switcher;
    when X"6" =>     trigg_signal_tap <= button_left;
    when X"7" =>     trigg_signal_tap <= button_right;
    when others =>   trigg_signal_tap <= stroka_flag;   
end case;
end process;
---------------------------------------------------------
---------------------------------------------------------
end BION_TOP_arch;