library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Synth_gen is
PORT(
   clk_pix                         : in    STD_LOGIC;
   reset                           : in    STD_LOGIC;
   enable_for_pix                  : in    STD_LOGIC;
   frame_modul                     : in    STD_LOGIC_VECTOR(bit_frame -1 downto 0);
   Pix_per_line                    : out   STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame                  : out   STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   frame_number                    : out   STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
   clk_for_PCLK                    : out   STD_LOGIC; 
   frame_flag                      : out   STD_LOGIC;
   stroka_flag                     : out   STD_LOGIC
);
END Synth_gen;
---------------------------------------------------------
---------------------------------------------------------
architecture Synth_gen_arch of Synth_gen is
---------------------------------------------------------
---------------------------------------------------------
--Частоты
signal clk_for_PCLK_in                  : STD_LOGIC;
--Счетчики  
signal pix                              : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal lines                            : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal frame_number_in                  : STD_LOGIC_VECTOR(bit_frame - 1 downto 0);
signal stroka_in, frame_in              : STD_LOGIC;
---------------------------------------------------------
--Объявление компонент
--Счетчик
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
---------------------------------------------------------
--Счетчик пикселей
counter_for_pix     : count_n_modul
Generic map(bit_pix)
Port map(
---------in-----------
    clk         => clk_pix,
    reset       => reset,
    en          => enable_for_pix,
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
   clk          => clk_pix,
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
   clk          => clk_pix,
   reset        => reset,
   en           => stroka_in,
   modul        => frame_modul,  
---------out----------
   qout         => frame_number_in
);
---------------------------------------------------------
Process(clk_pix)
begin
   if rising_edge(clk_pix) then
      if pix(1 downto 0)="01" or pix(1 downto 0)="10"    then
         clk_for_PCLK_in <= '0';    
      else
         clk_for_PCLK_in <= '1';   
      end if;
   end if;
end process;
---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
clk_for_PCLK    <=      clk_for_PCLK_in;
Pix_per_line    <=      pix;
Line_per_frame  <=      lines;
frame_number    <=      frame_number_in;
frame_flag      <=      frame_in;
stroka_flag     <=      stroka_in;
---------------------------------------------------------
---------------------------------------------------------
end Synth_gen_arch;