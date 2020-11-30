library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Synth_gen_cam is
PORT(
   clk_in                          : in      STD_LOGIC;
   reset                           : in      STD_LOGIC;
   enable                          : in      STD_LOGIC;
   Pix_per_line                    : out     STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame                  : out     STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   Frame_counter                   : out     STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
   frame_flag                      : out     STD_LOGIC;
   stroka_flag                     : out     STD_LOGIC;
   clk_x8                          : out     STD_LOGIC;
   clk_x1                          : out     STD_LOGIC
);
END Synth_gen_cam;
---------------------------------------------------------
---------------------------------------------------------
architecture Synth_gen_cam_arch of Synth_gen_cam is
---------------------------------------------------------
---------------------------------------------------------
--Счетчики  
signal pix                                : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal lines                              : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal frames                             : STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
signal stroka_in, frame_in                : STD_LOGIC;
--PLL
signal clk_x8_in, clk_x1_in               : STD_LOGIC;
---------------------------------------------------------
--Объявление компонент
--Счетчик
component count_n_modul
   generic (n		: integer);
   port(
      clk,
      reset,
      en		   :	in std_logic;
      modul		: 	in std_logic_vector (n-1 downto 0);
      qout		: 	out std_logic_vector (n-1 downto 0);
      cout		:	out std_logic
   );
end component;
---------------------------------------------------------
component PLL_for_cam_sim
port(
   inclk0		: IN STD_LOGIC  := '0';
	c0		      : OUT STD_LOGIC ;
   c1          : OUT STD_LOGIC;
	locked		: OUT STD_LOGIC 
);
end component;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
--Описание компонент
PLLx8               : PLL_for_cam_sim
port map(
   inclk0      => clk_in,
   c0          => clk_x8_in,
   c1          => clk_x1_in 
);
---------------------------------------------------------
--Счетчик пикселей
counter_for_pix     : count_n_modul
Generic map(bit_pix)
Port map(
---------in-----------
    clk         => clk_x1_in,
    reset       => reset,
    en          => enable,
    modul       => std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)),
---------out----------
    qout        => pix,
    cout        => stroka_in
);
---------------------------------------------------------
--Счетчик строк
counter_for_line      : count_n_modul
Generic map(bit_strok)
Port map(
---------in-----------
   clk          => clk_x1_in,
   reset        => reset,
   en           => stroka_in,
   modul        => std_logic_vector(to_unsigned(BION_960_960p30.LinePerFrame, bit_strok)),  
---------out----------
   qout         => lines,
   cout         => frame_in
);
---------------------------------------------------------
counter_for_frame      : count_n_modul
Generic map(bit_frame)
Port map(
---------in-----------
   clk          => clk_x1_in,
   reset        => reset,
   en           => frame_in,
   modul        => std_logic_vector(to_unsigned(256, bit_frame)),  
---------out----------
   qout         => frames
);
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
Pix_per_line      <=       pix;
Line_per_frame    <=       lines;
Frame_counter     <=       frames;
frame_flag        <=       frame_in;
stroka_flag       <=       stroka_in;
clk_x8            <=       clk_x8_in;
clk_x1            <=       clk_x1_in;
---------------------------------------------------------
---------------------------------------------------------
end Synth_gen_cam_arch;