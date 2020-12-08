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
signal Pix_per_line_cam                             : STD_LOGIC_VECTOR(Bitness_camera.bit_pix       - 1 downto 0);
signal Pix_per_line_interface                       : STD_LOGIC_VECTOR(Bitness_interface.bit_pix    - 1 downto 0);
signal Line_per_frame_cam                           : STD_LOGIC_VECTOR(Bitness_camera.bit_strok     - 1 downto 0);
signal Line_per_frame_interface                     : STD_LOGIC_VECTOR(Bitness_interface.bit_strok  - 1 downto 0);
signal frame_interface_flag, frame_cam_flag         : STD_LOGIC;
signal stroka_cam_flag, stroka_interface_flag       : STD_LOGIC;
signal enable_for_pix_cam, enable_for_pix_interface : STD_LOGIC;
--Частоты
signal clk_pix_in, PCLK_in                  : STD_LOGIC;
signal clk_pix_cam, clk_pix_interface       : STD_LOGIC;
--Data_gen
signal slwr_in_arch                 : STD_LOGIC;
signal data_8_bit                   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--output_data_interface
signal databus_arch                 : STD_LOGIC_VECTOR(bit_data_out - 1 downto 0);
--JTAG_DEBUG_CONST
signal  debug_8bit_for_output_data_interface,
        Switcher_in_trigg,
        Switcher_in_clk             : STD_LOGIC_VECTOR(7 downto 0);
--Данные с камер
signal  data_cam_1, data_cam_2,
        data_cam_3, data_cam_4      : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal  data_to_output_bus          : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--Формирование кадра
signal  pix_active_cam, 
        str_active_cam              : STD_LOGIC; 
signal  valid_data_cam              : STD_LOGIC; 
signal  pix_active_interface        : STD_LOGIC; 
--from mux
signal data_from_mux                : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--Debug signals
signal trigg_signal_tap, clk_signal_tap     : std_logic;
signal  debug_0, debug_1,
        debug_2, debug_3,                              
        debug_4, debug_5,                              
        debug_6, debug_7,
        debug_8, debug_9,
        debug_10                     : std_logic_vector(7 downto 0);



---------------------------------------------------------
signal clk_bit     : std_logic;
signal clk_pix     : std_logic;
signal data_to_framing_interface        : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
---------------------------------------------------------
---------------------------------------------------------
Begin
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
JTAG_DEBUG_CONST_arch       : entity work.JTAG_DEBUG_CONST
Port map(
    ---------out----------
    reg_8bit_0              => debug_0,         -- Aligner в 8-битном слове
    reg_8bit_1              => debug_1,         -- Выбор типа паттерна с камеры 1
    reg_8bit_2              => debug_2,         -- Выбор типа паттерна с камеры 2
    reg_8bit_3              => debug_3,         -- Выбор типа паттерна с камеры 3
    reg_8bit_4              => debug_4,         -- Выбор типа паттерна с камеры 4
    reg_8bit_5              => debug_5,         -- treshhold_FIFO 
    reg_8bit_6              => debug_6,         -- line_with_sync_word
    reg_8bit_7              => debug_7,         -- pix_with_sync_word
    reg_8bit_8              => debug_8,         -- Aligner в 32-битном слове
    reg_8bit_9              => Switcher_in_clk,
    reg_8bit_10             => Switcher_in_trigg      
);
---------------------------------------------------------
---------------------------------------------------------
PLL_input                   : entity work.PLL
Port map(
    inclk0      => clk_in,
    c0          => clk_bit,
    c1	        => clk_pix_interface,
    c2          => clk_pix_cam
);
---------------------------------------------------------
---------------------------------------------------------
--Описание компонентов
---------------------------------------------------------
---------------------------------------------------------
two_ch_to_one_comp          : entity work.two_ch_to_one_top
port map(
    clk_in_0            => clk_bit,
    clk_in_1            => clk_pix,
    reset               => '0',
    enable              => '1',
    Pix_per_line        => Pix_per_line_interface,
    Line_per_frame      => Line_per_frame_interface,
    data_in_ch_1        => data_in_1,
    data_in_ch_2        => data_in_2,
    align_num           => debug_0,
    --align_num           => x"06",
    clk_pix             => clk_pix_in,
    data_out            => data_from_mux    
);
---------------------------------------------------------
---------------------------------------------------------
Sync_gen_mult_top           : entity work.Synth_gen_mult
Port map(
    clk_pix_interface           => clk_pix_interface,
    clk_pix_cam                 => clk_pix_cam,
    main_reset                  => '0',
    enable_for_pix_cam          => '1',
    enable_for_pix_interface    => '1',
    --frame_modul                 => x"01",
    Pix_per_line_cam            => Pix_per_line_cam,
    Pix_per_line_interface      => Pix_per_line_interface,
    Line_per_frame_cam          => Line_per_frame_cam,
    Line_per_frame_interface    => Line_per_frame_interface,
    clk_for_PCLK                => PCLK_in,
    stroka_cam_flag             => stroka_cam_flag,
    stroka_interface_flag       => stroka_interface_flag,
    frame_cam_flag              => frame_cam_flag,
    frame_interface_flag        => frame_interface_flag
);
---------------------------------------------------------
---------------------------------------------------------
Data_gen_cam_1              : entity work.Data_gen_cam
Port map(
    clk_in                      => clk_pix_cam,
    reset                       => '0',
    enable_cam                  => '1',
    Pix_per_line                => Pix_per_line_cam,
    Line_per_frame              => Line_per_frame_cam,
    Type_of_data                => debug_1,
    data_out                    => data_cam_1,
    pix_active                  => pix_active_cam,
    str_active                  => str_active_cam,
    valid_data                  => valid_data_cam
);
---------------------------------------------------------
Data_gen_cam_2              : entity work.Data_gen_cam
Port map(
    clk_in                      => clk_pix_cam,
    reset                       => '0',
    enable_cam                  => '1',
    Pix_per_line                => Pix_per_line_cam,
    Line_per_frame              => Line_per_frame_cam,
    Type_of_data                => debug_2,
    data_out                    => data_cam_2
);
---------------------------------------------------------
Data_gen_cam_3              : entity work.Data_gen_cam
Port map(
    clk_in                      => clk_pix_cam,
    reset                       => '0',
    enable_cam                  => '1',
    Pix_per_line                => Pix_per_line_cam,
    Line_per_frame              => Line_per_frame_cam,
    Type_of_data                => debug_3,
    data_out                    => data_cam_3
);
---------------------------------------------------------
Data_gen_cam_4              : entity work.Data_gen_cam
Port map(
    clk_in                      => clk_pix_cam,
    reset                       => '0',
    enable_cam                  => '1',
    Pix_per_line                => Pix_per_line_cam,
    Line_per_frame              => Line_per_frame_cam,
    Type_of_data                => debug_4,
    data_out                    => data_cam_4
);
---------------------------------------------------------
---------------------------------------------------------
Data_processing_interface_top           : entity work.Data_processing_interface
Port map(
    clk_cam                            =>   clk_pix_cam,
    clk_interface                      =>   clk_pix_interface,
    reset                              =>   '0',
    data_ch_1                          =>   data_cam_1,
    data_ch_2                          =>   data_cam_2,
    data_ch_3                          =>   data_cam_3,
    data_ch_4                          =>   data_cam_4,
    Pix_per_line_interface             =>   Pix_per_line_interface,
    Line_per_frame_interface           =>   Line_per_frame_interface,
    Pix_per_line_cam                   =>   Pix_per_line_cam,
    Line_per_frame_cam                 =>   Line_per_frame_cam,
    pix_active_cam                     =>   pix_active_cam,
    pix_active_interface               =>   pix_active_interface,
    frame_in_interface                 =>   frame_interface_flag,
    data_out                           =>   data_to_framing_interface
);
---------------------------------------------------------
---------------------------------------------------------
Framing_interface_top               : entity work.Framing_interface
Port map(
    clk_in                      =>  clk_pix_interface,
    reset                       =>  '0',
    Pix_per_line                =>  Pix_per_line_interface,
    Line_per_frame              =>  Line_per_frame_interface,
    frame_in                    =>  frame_interface_flag,
    FLAGA                       =>  FLAGA,
    FLAGB                       =>  FLAGB,
    treshhold_FIFO              =>  debug_5,
    data_in                     =>  data_to_framing_interface,
    line_with_sync_word         =>  debug_6,
    pix_with_sync_word          =>  debug_7,
    slwr_in_arch                =>  slwr_in_arch,
    pix_active_out              =>  pix_active_interface,
    data_out                    =>  data_to_output_bus     
);
---------------------------------------------------------
---------------------------------------------------------
output_data_interface_arch  : entity work.output_data_interface
Port map(
    ---------in-----------
    clk_in                  => clk_pix_interface,
    reset                   => '0',
    pix                     => Pix_per_line_interface,
    --debug_8bit              => debug_8,
    debug_8bit              => x"03",
    data_8_bit              => data_to_output_bus,
    ---------out----------
    databus                 => databus_arch
);  
---------------------------------------------------------
---------------------------------------------------------
--Асинхронное присвоение выходным шинам
slwr                <= not(slwr_in_arch); 
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
---------------------------------------------------------
--debug
-- Process(Switcher_in_clk(3 downto 0))
-- begin
--    case (Switcher_in_clk(3 downto 0)) is
--       when X"0" =>     clk_signal_tap <= clk_pix_in;
--       when X"1" =>     clk_signal_tap <= Pix_per_line_interface(0);
--       when X"2" =>     clk_signal_tap <= stroka_interface_flag;
--       when X"3" =>     clk_signal_tap <= Pix_per_line_interface(2);
--      -- when X"4" =>     clk_signal_tap <= clk_bit;
--       when X"5" =>     clk_signal_tap <= mode_switcher;
--       when X"6" =>     clk_signal_tap <= button_left;
--       when X"7" =>     clk_signal_tap <= button_right;
--       when X"8" =>     clk_signal_tap <= Pix_per_line_interface(7);
--       when X"9" =>     clk_signal_tap <= Pix_per_line_interface(8);
--       when X"a" =>     clk_signal_tap <= Pix_per_line_interface(9);
--       when X"b" =>     clk_signal_tap <= Line_per_frame_interface(0);
--       when X"c" =>     clk_signal_tap <= Line_per_frame_interface(1);
--      when others =>    clk_signal_tap <= clk_pix_in;   
--    end case;
-- end process;

-- Process(Switcher_in_trigg(3 downto 0))
-- begin
--    case (Switcher_in_trigg(3 downto 0)) is
--     when X"0" =>     trigg_signal_tap <= stroka_flag;
--     when X"1" =>     trigg_signal_tap <= frame_flag;
--     when X"2" =>     trigg_signal_tap <= FLAGB;
--     when X"3" =>     trigg_signal_tap <= FLAGA;
--     when X"4" =>     trigg_signal_tap <= slwr; 
--     when X"5" =>     trigg_signal_tap <= mode_switcher;
--     when X"6" =>     trigg_signal_tap <= button_left;
--     when X"7" =>     trigg_signal_tap <= button_right;
--     when others =>   trigg_signal_tap <= stroka_flag;   
-- end case;
-- end process;
---------------------------------------------------------
---------------------------------------------------------
end BION_TOP_arch;