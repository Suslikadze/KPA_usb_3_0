library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 

entity Camera_sim is
Port(
    clk_in                  : in    STD_LOGIC;
    reset                   : in    STD_LOGIC;
    Switcher_for_data       : in    STD_LOGIC_VECTOR(3 downto 0);
    data_out_1              : out   STD_LOGIC;
    data_out_2              : out   STD_LOGIC;
    clk_out                 : out   STD_LOGIC  
);
end Camera_sim;
---------------------------------------------------------
---------------------------------------------------------
architecture Camera_sim_arch of Camera_sim is
---------------------------------------------------------
---------------------------------------------------------
--Data_generation
signal Pix_per_line         : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal Line_per_frame       : STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
signal data_out_from_cam    : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_out_ser_1       : STD_LOGIC;
signal data_out_ser_2       : STD_LOGIC;
--Synth
signal frame_flag           :   STD_LOGIC;
signal stroka_flag          :   STD_LOGIC;
signal Frame_counter        :   STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
signal clk_x8,clk_x1        :   STD_LOGIC;
---------------------------------------------------------
component Synth_gen_cam
port(
    clk_in                          : in    STD_LOGIC;
    reset                           : in    STD_LOGIC;
    enable                          : in    STD_LOGIC;
    Pix_per_line                    : out   STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame                  : out   STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    Frame_counter                   : out   STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
    frame_flag                      : out   STD_LOGIC;
    stroka_flag                     : out   STD_LOGIC;
    clk_x8                          : out   STD_LOGIC;
    clk_x1                          : out   STD_LOGIC
);
end component;
---------------------------------------------------------
component Data_generation_cam
port(
    clk_in                              : in    STD_LOGIC;
    reset                               : in    STD_LOGIC;
    Switcher_for_type_of_data           : in    STD_LOGIC_VECTOR(3 downto 0);
    Pix_per_line                        : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame                      : in    STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    frame_flag                          : in    STD_LOGIC;
    data_out_from_cam                   : out   STD_LOGIC_VECTOR(bit_data - 1 downto 0)
);
end component;
---------------------------------------------------------
component two_channel_output_serial
Port(
    clk_fast            : IN    STD_LOGIC;
    clk_slow            : IN    STD_LOGIC;
    Pix_per_line        : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame      : in    STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    reset               : IN    STD_LOGIC;
    enable              : IN    STD_LOGIC;
    data_in             : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    data_out_1          : OUT   STD_LOGIC;
    data_out_2          : OUT   STD_LOGIC
);
end component;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
Synth_gen_camera            : Synth_gen_cam
port map(
    ---------in-----------
    clk_in              => clk_in,
    reset               => '0',
    enable              => '1',
    ---------out----------
    Pix_per_line        => Pix_per_line,
    Line_per_frame      => Line_per_frame,
    Frame_counter       => Frame_counter,
    frame_flag          => frame_flag,
    stroka_flag         => stroka_flag,
    clk_x8              => clk_x8,
    clk_x1              => clk_x1
);
---------------------------------------------------------
Data_generation_camera      : Data_generation_cam
Port map(
    ---------in-----------
    clk_in                      => clk_x1,
    reset                       => '0',
    Switcher_for_type_of_data   => Switcher_for_data,
    Pix_per_line                => Pix_per_line,
    Line_per_frame              => Line_per_frame,
    frame_flag                  => frame_flag,
    ---------out----------
    data_out_from_cam           => data_out_from_cam
);
---------------------------------------------------------
two_channel_output_serial_camera    : two_channel_output_serial
Port map(
    ---------in-----------
    clk_fast        =>  clk_x8,
    clk_slow        =>  clk_x1,
    Pix_per_line    =>  Pix_per_line,
    Line_per_frame  =>  Line_per_frame,
    reset           =>  '0',
    enable          =>  '1',
    data_in         =>  data_out_from_cam,
    ---------out----------
    data_out_1      =>  data_out_ser_1,
    data_out_2      =>  data_out_ser_2
);
---------------------------------------------------------
data_out_1 <= data_out_ser_1;
data_out_2 <= data_out_ser_2;
clk_out    <= clk_x8;
---------------------------------------------------------
---------------------------------------------------------
end Camera_sim_arch;