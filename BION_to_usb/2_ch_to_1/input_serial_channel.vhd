library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.VIDEO_CONSTANTS.all;
use work.My_component_pkg.all;
----------------------------------------------------------------------
-- модуль приема DDR данных по 1 каналу
-- в зависимости от разрядности данных от фотоприемника 
-- в зависимости от bit_data существует 4/5/6 вариантов для захвата правильность последовательности
-- align_load - перебираются до тех по пока трубеумы условия для синхронизации не выполнятся
----------------------------------------------------------------------
entity input_serial_channel is
port (
	clk_Serial					: in std_logic;  										-- CLK Serial
	main_reset					: in std_logic;  									-- reset
	main_enable					: in std_logic;										-- ENABLE
	data_in_ser				    : in std_logic;				-- видео данные DDR					
	align_load					: in std_logic_vector (7 downto 0);				-- сдвиг момент выборки 
	align_flag					: out std_logic;
	data_out_Parallel			: out std_logic_vector (bit_data-1 downto 0)
);
end input_serial_channel;
---------------------------------------------------------
---------------------------------------------------------
architecture input_serial_channel_arch of input_serial_channel is
--------------------------------------------------------- 
---------------------------------------------------------
--Десериалайзер
signal data_buffer								: std_logic_vector (bit_data-1 downto 0):=(others => '0');
signal pattern_load								: std_logic:='0';
signal load_q									: std_logic_vector (3 downto 0):=(others => '0');
--Выходная шина
signal data_out_buffer                          : STD_LOGIC_VECTOR(bit_data - 1 downto 0);		
--для отладки
signal bit_count								: STD_LOGIC_VECTOR(14 downto 0);
attribute noprune: boolean;
attribute noprune of bit_count: signal is true;							
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
begin
---------------------------------------------------------
----------------------------------------------------------------------
---десериалайзер с двух параллельных последовательных каналов
----------------------------------------------------------------------
Process(clk_Serial)
begin
if rising_edge (clk_Serial) then
	data_buffer		<=	  data_buffer(bit_data-2 downto 0) & data_in_ser;
end if;
end process;
----------------------------------------------------------------------
---счетчик тактов для возможности перебора момента захвата паралелльного слова
----------------------------------------------------------------------
counter_bit					:count_n_modul
generic map(15)
port map(
	clk			=> clk_Serial,
	reset		=> '0',
	en			=> '1',
	modul		=> std_logic_vector(to_unsigned(9600, 15)),
	qout		=> bit_count
);
----------------------------------------------------------------------
counter_for_load            :count_n_modul
generic map(4)
port map(
    clk         =>  clk_Serial,      
    reset       =>  '0',
    en	        =>  '1',
    modul	    =>  std_logic_vector(to_unsigned(8,4)),
    qout	    =>  load_q    
);
-- load_q0: count_fast                    
-- generic map (4,8) 
-- port map (
--    clk      =>	clk_Serial,			
--    reset	=>	main_reset ,
--    qout		=>	load_q);
----------------------------------------------------------------------
---захват параллельного слова на основе 
----------------------------------------------------------------------
-- Process(clk_Serial)
-- begin
--     if rising_edge(clk_Serial) then
--         case state is
--             when wait_for_ff_00 =>
--                 if ((data_buffer_ch_1_1 = x"00" or data_buffer_ch_1_1 = x"FF") and (data_buffer_ch_2_1 = x"00" or data_buffer_ch_2_1 = x"FF")) then
--                     state <= wait_for_00_80;
--                     data_buffer_ch_1_2 <= data_buffer_ch_1_1;
--                     data_buffer_ch_2_2 <= data_buffer_ch_2_1;
--                 end if;
--                 enable_for_mux <= '0';
--             when wait_for_00_80 =>
--                 if ((data_buffer_ch_1_1 = x"00" or data_buffer_ch_1_1 = x"80") and (data_buffer_ch_2_1 = x"00" or data_buffer_ch_2_1 = x"80")) then
--                     state <= start_translation_to_multiplexor;
--                     enable_for_mux <= '1';
--                     data_to_mult_1  <= data_buffer_ch_1_2;
--                     data_to_mult_2  <= data_buffer_ch_2_2;
--                 end if;
--         end case;
--     end if;
-- end process;


Process(clk_Serial)
begin
if rising_edge (clk_Serial) then
	case align_load(2 downto 0) is
		when "000" =>
			if  load_q(2 downto 0)	=	"000" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
		when "001" =>
			if  load_q(2 downto 0)	=	"001" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
		when "010" =>
			if  load_q(2 downto 0)	=	"010" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
		when "011" =>
			if  load_q(2 downto 0)	=	"011" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
        when "100" =>
            if  load_q(2 downto 0)	=	"100" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
        when "101" =>
            if  load_q(2 downto 0)	=	"101" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
        when "110" =>
            if  load_q(2 downto 0)	=	"110" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
        when "111" =>
            if  load_q(2 downto 0)	=	"111" then
				pattern_load	<='1';
			else
				pattern_load	<='0';
			end if;
		when others =>
			null;
	end case;
end if;
end process;
---------------------------------------------------------
Process(clk_Serial)
begin
if rising_edge (clk_Serial) then
	if pattern_load='1' then
		data_out_Parallel	<=	data_buffer;
	end if;
end if;
end process;
---------------------------------------------------------
align_flag <= pattern_load;
---------------------------------------------------------
end input_serial_channel_arch;
