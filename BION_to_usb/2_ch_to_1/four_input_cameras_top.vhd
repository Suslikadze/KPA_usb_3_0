library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;


Entity four_input_cameras_top is
Port(
    clk_in                      : in    STD_LOGIC;
    clk_cam                     : in    STD_LOGIC; 
    reset                       : in    STD_LOGIC;
    enable                      : in    STD_LOGIC;
    data_ch_1_ser               : in    STD_LOGIC;
    data_ch_2_ser               : in    STD_LOGIC;
    data_ch_3_ser               : in    STD_LOGIC;
    data_ch_4_ser               : in    STD_LOGIC;
    align_num_ch_1              : in    STD_LOGIC_VECTOR(7                                      downto 0);
    align_num_ch_2              : in    STD_LOGIC_VECTOR(7                                      downto 0);
    align_num_ch_3              : in    STD_LOGIC_VECTOR(7                                      downto 0);
    align_num_ch_4              : in    STD_LOGIC_VECTOR(7                                      downto 0);
    Camera_channel_switch       : in    STD_LOGIC_VECTOR(7                                      downto 0);
    Pix_per_line_cam            : in    STD_LOGIC_VECTOR(Bitness_camera.bit_pix             - 1 downto 0);
    Line_per_frame_cam          : in    STD_LOGIC_VECTOR(Bitness_camera.bit_strok           - 1 downto 0);
    reset_sync_counters         : out   STD_LOGIC;
    data_ch_1_par               : out   STD_LOGIC_VECTOR(bit_data                           - 1 downto 0);
    data_ch_2_par               : out   STD_LOGIC_VECTOR(bit_data                           - 1 downto 0);
    data_ch_3_par               : out   STD_LOGIC_VECTOR(bit_data                           - 1 downto 0);
    data_ch_4_par               : out   STD_LOGIC_VECTOR(bit_data                           - 1 downto 0)
);
end four_input_cameras_top;

Architecture four_input_cameras_top_arch of four_input_cameras_top is
-- signal  data_ch_1_par,
--         data_ch_2_par,
--         data_ch_3_par,
--         data_ch_4_par           : STD_LOGIC_VECTOR(bit_data - 1 downto 0);

---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Подключение экземпляров модулей
---------------------------------------------------------
ser_to_par_cam_1            : Entity work.two_ch_to_one_top
Port map(
    clk_in_0                => clk_in,
    clk_in_1                => clk_cam,
    reset                   => '0',
    enable_ch1              => '1',
    enable_ch2              => '0',
    Pix_per_line            => Pix_per_line_cam,
    Line_per_frame          => Line_per_frame_cam,
    data_in_ch_1            => data_ch_1_ser,
    data_in_ch_2            => data_ch_1_ser,
    align_num               => align_num_ch_1,
    reset_sync_counters     => reset_sync_counters,
    data_out                => data_ch_1_par
);
---------------------------------------------------------
ser_to_par_cam_2            : Entity work.two_ch_to_one_top
Port map(
    clk_in_0            => clk_in,
    clk_in_1            => clk_cam,
    reset               => '0',
    enable_ch1          => '1',
    enable_ch2          => '0',
    Pix_per_line        => Pix_per_line_cam,
    Line_per_frame      => Line_per_frame_cam,
    data_in_ch_1        => data_ch_2_ser,
    data_in_ch_2        => data_ch_2_ser,
    align_num           => align_num_ch_2,
    data_out            => data_ch_2_par
);
---------------------------------------------------------
ser_to_par_cam_3            : Entity work.two_ch_to_one_top
Port map(
    clk_in_0            => clk_in,
    clk_in_1            => clk_cam,
    reset               => '0',
    enable_ch1          => '1',
    enable_ch2          => '0',
    Pix_per_line        => Pix_per_line_cam,
    Line_per_frame      => Line_per_frame_cam,
    data_in_ch_1        => data_ch_3_ser,
    data_in_ch_2        => data_ch_3_ser,
    align_num           => align_num_ch_3,
    data_out            => data_ch_3_par
);
---------------------------------------------------------
ser_to_par_cam_4            : Entity work.two_ch_to_one_top
Port map(
    clk_in_0            => clk_in,
    clk_in_1            => clk_cam,
    reset               => '0',
    enable_ch1          => '1',
    enable_ch2          => '0',
    Pix_per_line        => Pix_per_line_cam,
    Line_per_frame      => Line_per_frame_cam,
    data_in_ch_1        => data_ch_4_ser,
    data_in_ch_2        => data_ch_4_ser,
    align_num           => align_num_ch_4,
    data_out            => data_ch_4_par
);

---------------------------------------------------------
---------------------------------------------------------
end four_input_cameras_top_arch;