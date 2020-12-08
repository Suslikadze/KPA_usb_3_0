library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all;




entity Synth_gen_mult is
Port(
    clk_pix_interface               : in    STD_LOGIC;
    clk_pix_cam                     : in    STD_LOGIC;
    main_reset                      : in    STD_LOGIC;
    enable_for_pix_cam              : in    STD_LOGIC;
    enable_for_pix_interface        : in    STD_LOGIC;
    --frame_modul                     : in    STD_LOGIC_VECTOR(Bitness_camera.bit_frame              - 1 downto 0);
    Pix_per_line_cam                : out   STD_LOGIC_VECTOR(Bitness_camera.bit_pix             - 1 downto 0);
    Pix_per_line_interface          : out   STD_LOGIC_VECTOR(Bitness_interface.bit_pix          - 1 downto 0);
    Line_per_frame_interface        : out   STD_LOGIC_VECTOR(Bitness_interface.bit_strok        - 1 downto 0);
    Line_per_frame_cam              : out   STD_LOGIC_VECTOR(Bitness_camera.bit_strok           - 1 downto 0);
    frame_number_interface          : out   STD_LOGIC_VECTOR(Bitness_interface.bit_frame        - 1 downto 0);
    clk_for_PCLK                    : out   STD_LOGIC;
    stroka_cam_flag                 : out   STD_LOGIC;
    stroka_interface_flag           : out   STD_LOGIC;
    frame_cam_flag                  : out   STD_LOGIC;
    frame_interface_flag            : out   STD_LOGIC
);
end Synth_gen_mult;
---------------------------------------------------------
---------------------------------------------------------
architecture Synth_gen_mult_arch of Synth_gen_mult is
---------------------------------------------------------
---------------------------------------------------------
--Частоты
signal clk_four_less_in             : STD_LOGIC;
--Счетчики
signal pix_cam                      : STD_LOGIC_VECTOR(Bitness_camera.bit_pix       - 1 downto 0);
signal pix_interface                : STD_LOGIC_VECTOR(Bitness_interface.bit_pix    - 1 downto 0);
signal lines_cam                    : STD_LOGIC_VECTOR(Bitness_camera.bit_strok     - 1 downto 0);
signal lines_interface              : STD_LOGIC_VECTOR(Bitness_interface.bit_strok  - 1 downto 0);
signal stroka_cam_in                : STD_LOGIC;
signal stroka_interface_in          : STD_LOGIC;
signal frame_interface_in           : STD_LOGIC;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Подключение эксземпляров модулей синхрогенераторов
---------------------------------------------------------
--Синхрогенератор для камер
Sync_gen_cam            : Entity work.Sync_gen
Generic map(
    Pix_Per_Line_modul      => KPA_camera_sim.PixPerLine,
    Line_Per_Frame_modul    => KPA_camera_sim.LinePerFrame,
    bit_pix                 => Bitness_camera.bit_pix,
    bit_strok               => Bitness_camera.bit_strok,
    bit_frame               => Bitness_camera.bit_frame
)
Port map(
    ---------in-----------
    clk_pix                 => clk_pix_cam,
    reset                   => main_reset,
    enable_for_pix          => enable_for_pix_cam,
    frame_modul             => "001",
    ---------out----------
    Pix_per_line            => pix_cam,
    Line_per_frame          => lines_cam,
    stroka_flag             => stroka_cam_in   
);
---------------------------------------------------------
--Синхрогенератор для интерфейса с cypress
Sync_gen_interface      : Entity work.Sync_gen
Generic map(
    Pix_Per_Line_modul      => BION_960_960p30.PixPerLine,
    Line_Per_Frame_modul    => BION_960_960p30.LinePerFrame, 
    bit_pix                 => Bitness_interface.bit_pix, 
    bit_strok               => Bitness_interface.bit_strok, 
    bit_frame               => Bitness_interface.bit_frame
)
Port map(
    ---------in-----------
    clk_pix                 => clk_pix_interface,
    reset                   => main_reset,
    enable_for_pix          => enable_for_pix_interface,
    frame_modul             => "001",
    ---------out----------
    Pix_per_line            => Pix_interface,
    Line_per_frame          => lines_interface, 
    clk_four_less           => clk_four_less_in,
    frame_flag              => frame_interface_in,
    stroka_flag             => stroka_interface_in    
);

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
--Частоты
clk_for_PCLK                <=      clk_four_less_in;
--Счетчики  
Pix_per_line_interface      <=      Pix_interface;
Pix_per_line_cam            <=      pix_cam;
Line_per_frame_interface    <=      lines_interface;
Line_per_frame_cam          <=      lines_cam;
--Флаги 
stroka_interface_flag       <=      stroka_interface_in;
stroka_cam_flag             <=      stroka_cam_in;
frame_interface_flag        <=      frame_interface_in;
---------------------------------------------------------
end Synth_gen_mult_arch;