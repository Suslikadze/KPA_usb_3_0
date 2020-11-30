library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
---------------------------------------------------
-- генератор тестовых сигналов
---------------------------------------------------
-- mode_generator определяет тип данных для передачи
-- младшие 4 бита отвечаю за тип сигнала, старшие за кастомизацию
-- 	[7..4]						[3..0]
-- 	сдвиг разрядов				0 градационный клин по горизонтали
-- 	сдвиг разрядов				1 градационный клин по вертикали
-- 	none							2 шумоподобный сигнал на основе полинома SMPTE
-- 	размер клеток				3 шахматное поле
-- 	интенсиыность полос		4 цветные полосы (color bar)
-- 	none							5 сигнал из файла
-- 	none							F сигнал входной транзитом на выход
---------------------------------------------------
---------------------------------------------------
entity PATHERN_GENERATOR is
port (
	CLK					: in std_logic; 												--	тактовый сигнал данных	
	main_reset			: in std_logic;  												-- main_reset
	ena_clk				: in std_logic;  												-- разрешение по частоте
	qout_clk				: in std_logic_vector (bit_pix-1 downto 0); 			--	счетчик пикселей
	qout_V				: in std_logic_vector (bit_strok-1 downto 0);		--	счетчик строк
	mode_generator		: in std_logic_vector (7 downto 0); 					--	задание режима
	data_in				: in std_logic_vector (bit_data-1 downto 0) ;	--	входной сигнал
	data_out				: out std_logic_vector (bit_data-1 downto 0) 	--	выходной сигнал
		);	
end PATHERN_GENERATOR;

architecture beh of PATHERN_GENERATOR is 

signal horizontal_stripe	: std_logic_vector (bit_data-1 downto 0);
signal vertical_stripe		: std_logic_vector (bit_data-1 downto 0);
signal noise					: std_logic_vector (bit_data-1 downto 0);
signal chess_desk				: std_logic_vector (bit_data-1 downto 0);
signal flex_gradient			: std_logic_vector (bit_pix-1 downto 0);


signal pix_flag				: std_logic;
signal line_flag				: std_logic;
signal flag						: std_logic_vector (1 downto 0);

signal sub_mode				: integer range 0 to 15:=0;

component noise_gen is
port ( data_in : in std_logic_vector (11 downto 0);
	crc_en , rst, clk : in std_logic;
	crc_out : out std_logic_vector (11 downto 0));
end component;
signal noise_gen_q		: std_logic_vector (11 downto 0);


begin
---------------------------------------------------
-- генератор градиентов по горизонтали и вертикали
---------------------------------------------------
process(CLK)
begin
if  rising_edge(CLK) then 
	if ena_clk='1'	then
		sub_mode				<=to_integer(unsigned (mode_generator(7 downto 4)));
		vertical_stripe	<=qout_V		(bit_data - 1 + sub_mode downto 0 + sub_mode);
		horizontal_stripe	<=qout_clk	(bit_data - 1 + sub_mode downto 0 + sub_mode);
	end if;
end if;
end process;
---------------------------------------------------
-- генератор шахматной доски
---------------------------------------------------
process(CLK)
begin
if  rising_edge(CLK) then 	
	if ena_clk='1'	then
		pix_flag		<=	qout_clk(sub_mode);
		line_flag	<=	qout_V(sub_mode);
		flag(0)		<=	line_flag;
		flag(1)		<=	pix_flag;
		case( flag) is
			when "00" =>	chess_desk	<=	std_logic_vector(to_unsigned(240, bit_data)) ;
			when "01" =>	chess_desk	<=	std_logic_vector(to_unsigned(0, bit_data))  ;
			when "10" =>	chess_desk	<=	std_logic_vector(to_unsigned(0, bit_data))  ;
			when "11" =>	chess_desk	<=	std_logic_vector(to_unsigned(240, bit_data)) ;
			when others =>	null;
		end case ;
	end if;
end if;
end process;
---------------------------------------------------
-- генератор шума
---------------------------------------------------
noise_gen_0: noise_gen                    
port map (
	data_in		=>	'0' & qout_clk(10 downto 0),			
	crc_en		=>	'1' ,
	rst			=>	main_reset,		
	clk			=>	CLK ,
	crc_out		=>	noise_gen_q);
process(CLK)
begin
if  rising_edge(CLK) then 	
	noise	<=noise_gen_q(bit_data-1 downto 0);
end if;
end process;

---------------------------------------------------
-- генератор шума
---------------------------------------------------
counter_flex_gradient     : count_n_modul
Generic map(bit_pix)
Port map(
---------in-----------
	clk         => CLK,
	reset       => '0',
	en          => '1',
	modul       => std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine - sub_mode*1, bit_pix)),
---------out----------
	qout        => flex_gradient
);





---------------------------------------------------
-- мультиплексов сигналов
---------------------------------------------------
process(CLK)
begin
if  rising_edge(CLK) then 	
	if ena_clk='1'	then
	case( mode_generator(3 downto 0) ) is
		when x"0" =>	data_out	<=	horizontal_stripe;
		when x"1" =>	data_out	<=	vertical_stripe;
		when x"2" =>	data_out	<=	noise;	
		when x"3" =>	data_out	<=	chess_desk;
		when x"4" =>	data_out	<=	flex_gradient(bit_data-1+2 downto 2);
		-- when x"4" =>	data_out	<=	color_bar;			НУЖНО дописать
		-- when x"5" =>	data_out	<=	data_from_file;	НУЖНО дописать
		when x"f" =>	data_out	<=	data_in;	
		when others =>	data_out	<=	data_in;
	end case ;
	end if;
end if;
end process;
--------------------------------------------------------------------
end ;
