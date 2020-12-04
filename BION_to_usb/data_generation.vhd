library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Framing_for_interface is
Port(
   clk_in            : in     STD_LOGIC;
   reset             : in     STD_LOGIC;
   data_in           : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_1         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_2         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_3         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   data_ch_4         : in     STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   Pix_per_line      : in     STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame    : in     STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   frame_in          : in     STD_LOGIC;
   slwr_in_arch      : out    STD_LOGIC;
   data_8_bit        : out    STD_LOGIC_VECTOR(7 downto 0)
);
end Framing_for_interface;
---------------------------------------------------------
---------------------------------------------------------
architecture Framing_for_interface_arch of Framing_for_interface is
---------------------------------------------------------
---------------------------------------------------------
--ФИФО

signal data_from_buffer                 : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_in_sync_header             : STD_LOGIC_VECTOR(bit_data - 1 downto 0);


--выделение активной части кадра
signal str_active, pix_active          : STD_LOGIC;
signal window                          : STD_LOGIC;

---------------------------------------------------------
--Объявление компонент
--ФИФО
component FIFO
PORT
(
   data            : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
   rdclk           : IN    STD_LOGIC;
   rdreq           : IN    STD_LOGIC;
   wrclk           : IN    STD_LOGIC;
   wrreq           : IN    STD_LOGIC;
   q               : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
   rdempty         : OUT   STD_LOGIC;
   rdfull          : OUT   STD_LOGIC;
   rdusedw         : OUT   STD_LOGIC_VECTOR (14 DOWNTO 0);
   wrempty         : OUT   STD_LOGIC;
   wrfull          : OUT   STD_LOGIC;
   wrusedw         : OUT   STD_LOGIC_VECTOR (14 DOWNTO 0)
);
END component;
---------------------------------------------------------
---------------------------------------------------------


---------------------------------------------------
-- генератор тестовых сигналов
---------------------------------------------------
component PATHERN_GENERATOR is
	port (
		CLK					: in std_logic; 												--	тактовый сигнал данных	
		main_reset			: in std_logic;  												-- main_reset
		ena_clk				: in std_logic;  												-- разрешение по частоте
		qout_clk				: in std_logic_vector (bit_pix-1 downto 0); 			--	счетчик пикселей
		qout_V				: in std_logic_vector (bit_strok-1 downto 0);		--	счетчик строк
		mode_generator		: in std_logic_vector (7 downto 0); 					--	задание режима
		data_in				: in std_logic_vector (bit_data-1 downto 0) ;	--	входной сигнал
		data_out				: out std_logic_vector (bit_data-1 downto 0) 	--	выходной сигнал							--сигнал валидных данных	
			);	
end component;
signal data_generator_out	   : std_logic_vector (bit_data-1 downto 0);
signal data_generator_blanc	: std_logic_vector (bit_data-1 downto 0);
signal position               : std_logic_vector (7 downto 0) := "00000001";
signal debug_1_signal,
       debug_2_signal,
       debug_3_signal         : std_logic_vector(7 downto 0) := "00000001";
signal type_of_button_control : std_logic_vector(1 downto 0) := "00";
signal resolution_x,
       resolution_y           : integer;


Begin



------------------------------------------------------------
-- генератор тестовых сигналов
------------------------------------------------------------
PATHERN_GENERATOR_q: PATHERN_GENERATOR                    
port map (
			--IN
	CLK				=>	clk_in,	
	main_reset		=>	'0' ,
	ena_clk			=>	'1',		
	qout_clk			=>	Pix_per_line,		
	qout_V			=>	Line_per_frame,
	--mode_generator	=>	debug_2,
   mode_generator	=>	debug_2_signal,
	data_in			=>	data_in(7 downto 0),
			--OUT
	data_out			=>	data_generator_out 
      );
      

Process(clk_in)
begin
   if rising_edge(clk_in) then
      if (window) then
         data_generator_blanc <= data_generator_out;
      else 
         data_generator_blanc <= (others => '0');
      end if;
   end if;
end process;
------------------------------------------------------------
Process(clk_in)
BEGIN
    if rising_edge(clk_in) then
        if (to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift + 50 ) and (to_integer(unsigned(Pix_per_line)) < std_logic_vector(to_unsigned(resolution_x, bit_pix)) + BION_960_960p30.HsyncShift - 50) and
      (to_integer(unsigned(Line_per_frame)) >= BION_960_960p30.VsyncShift + 50) and (to_integer(unsigned(Line_per_frame)) < BION_960_960p30.VsyncShift + std_logic_vector(to_unsigned(resolution_y, bit_strok)) - 50) then
            window <= '1';
        else
            window <= '0';
        end if;
    end if;
end Process;
---------------------------------------------------------
---------------------------------------------------------
--Запись в ФИФО
Process(clk_in)
begin
if rising_edge(clk_in) then
      if (str_active and pix_active) then
         enable_for_write_buffer <= '1';
      else 
         enable_for_write_buffer <= '0';
      end if; 
end if;
end process;
---------------------------------------------------------
--Выделение активной части кадра
Process(clk_in)
BEGIN
    if rising_edge(clk_in) then
        if (to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift ) and (to_integer(unsigned(Pix_per_line)) < std_logic_vector(to_unsigned(resolution_x, bit_pix)) + BION_960_960p30.HsyncShift) then
            pix_active <= '1';
        else
            pix_active <= '0';
        end if;
   ------------
        if (to_integer(unsigned(Line_per_frame)) >= BION_960_960p30.VsyncShift) and (to_integer(unsigned(Line_per_frame)) <BION_960_960p30.VsyncShift + std_logic_vector(to_unsigned(resolution_y, bit_strok))) then
            str_active <= '1';
        else
            str_active <= '0';
        end if;
    end if;
end Process;
---------------------------------------------------------
Process(clk_in)
begin
if rising_edge(clk_in) then
         resolution_x <= debug 1;
         resolution_y <= debug 2;
   -- case (debug_4(2 downto 0)) is
   --    when "000" =>
   --       resolution_x <= 1024;
   --       resolution_y <= 1024;
   --    when "001" =>
   --       resolution_x <= 2048;
   --       resolution_y <= 1024;
   --    when "010" =>
   --       resolution_x <= 512;
   --       resolution_y <= 256;
   --    when "011" =>
   --       resolution_x <= 960;
   --       resolution_y <= 960;
   --    when "100" =>
   --       resolution_x <= 2048;
   --       resolution_y <= 2048;
   --    when "101" =>
   --       resolution_x <= 1024;
   --       resolution_y <= 2048;
   --    when others => 
   --       resolution_x <= 1024;
   --       resolution_y <= 1024;
   -- end case;
end if;
end process;
---------------------------------------------------------

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
---------------------------------------------------------
end data_generation_arch;