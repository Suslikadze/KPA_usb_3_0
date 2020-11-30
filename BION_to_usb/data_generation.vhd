library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity data_generation is
Port(
   clk_in            : in    STD_LOGIC;
   reset             : in    STD_LOGIC;
   data_in           : in    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
   debug_1           : in    STD_LOGIC_VECTOR(7 downto 0);
   debug_2           : in    STD_LOGIC_VECTOR(7 downto 0);
   debug_3           : in    STD_LOGIC_VECTOR(7 downto 0);
   debug_4           : in    STD_LOGIC_VECTOR(7 downto 0);
   button_left,
   button_right,
   mode_switcher     : in    STD_LOGIC;
   Pix_per_line      : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame    : in    STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   frame_in          : in    STD_LOGIC;
   FLAGA             : in    STD_LOGIC;
   FLAGB             : in    STD_LOGIC;
   slwr_in_arch      : out   STD_LOGIC;
   data_8_bit        : out   STD_LOGIC_VECTOR(7 downto 0)
);
end data_generation;
---------------------------------------------------------
---------------------------------------------------------
architecture data_generation_arch of data_generation is
---------------------------------------------------------
---------------------------------------------------------
--ФИФО
signal enable_for_write_buffer          : STD_LOGIC;
signal enable_for_read_buffer           : STD_LOGIC;
signal data_from_buffer                 : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_in_sync_header             : STD_LOGIC_VECTOR(bit_data - 1 downto 0);

--машинный автомат
type State_type is(
	stream_in_idle,
	stream_in_wait_flagb,
	stream_in_write,
	stream_in_write_wr_delay
);
signal state						: State_type;
--выделение активной части кадра
signal str_active, pix_active          : STD_LOGIC;
signal window                          : STD_LOGIC;
--обработка кнопок
signal debounced_button_left,
       debounced_button_right,
       debounced_mode_switcher   : STD_LOGIC;
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
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
--Управление сдвигом строки с синхрословом, позиции синхрослова в строке, а также типо выходных изображений с помощью тактовых кнопок на плате
debounced_switcher: entity work.debounce 
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => mode_switcher,
   push_out       => debounced_mode_switcher
);
debounced_left: entity work.debounce
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => button_left,
   push_out       => debounced_button_left 
);
debounced_right: entity work.debounce
Port map(
   clk            => clk_in,
   reset_n        => reset,
   button         => button_right,
   push_out       => debounced_button_right
);

Process(clk_in)
Begin
---------------
   if rising_edge(clk_in) then
      if (debounced_mode_switcher = '1') then
         if (type_of_button_control < 2) then
            type_of_button_control <= type_of_button_control + 1;
         else
            type_of_button_control <= (others => '0');
         end if;
      end if;
   end if;   
end process;
---------------
Process(clk_in)
begin
if rising_edge(clk_in) then  
---------------
   case (type_of_button_control) is
      when "00" => 
         if (debounced_button_left = '1') then
            if (position /= x"0") then
               position <= position - 1;
            end if;
         elsif (debounced_button_right = '1') then
            if (to_integer(unsigned(position)) /= 256) then
               position <= position + 1;
            end if;
         end if;
         debug_1_signal <= position;
      when "01" => 
         if (debounced_button_left = '1') then
            if (position /= x"0") then
               position <= position - 1;
            end if;
         elsif (debounced_button_right = '1') then
            if (to_integer(unsigned(position)) /= 256) then
               position <= position + 1;
            end if;
         end if;
         debug_2_signal <= position;
      when "10" => 
         if (debounced_button_left = '1') then
            if (position /= x"0") then
               position <= position - 1;
            end if;
         elsif (debounced_button_right = '1') then
            if (position /= x"9") then
               position <= position + 1;
            end if;
         end if;
         debug_3_signal <= position;
      when others => 
         if (debounced_button_left = '1') then
            if (position /= x"0") then
               position <= position - 1;
            end if;
         elsif (debounced_button_right = '1') then
            if (position /= x"9") then
               position <= position + 1;
            end if;
         end if;
         debug_1_signal <= position;
   end case;
end if;
end process;
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------



---------------------------------------------------------
---------------------------------------------------------
--Описание компонент
---------------------------------------------------------
--ФИФО


--Выделение активной части кадра
Process(clk_in)
BEGIN
if rising_edge(clk_in) then
  -- if to_integer(unsigned(Line_per_frame)) =to_integer(unsigned(debug_1))*4 then 
   if to_integer(unsigned(Line_per_frame)) =to_integer(unsigned(debug_1_signal))*4 then 
        if    to_integer(unsigned(Pix_per_line)) = to_integer(unsigned(debug_3_signal)) then   data_in_sync_header  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 1) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 2) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 3) then   data_in_sync_header  <=x"80";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 4) then   data_in_sync_header  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 5) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 6) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 7) then   data_in_sync_header  <=x"ab";

      elsif   to_integer(unsigned(Pix_per_line)) = to_integer(unsigned(debug_3_signal))    + 256 then   data_in_sync_header  <=x"ab";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 1 + 256) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 2 + 256) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 3 + 256) then   data_in_sync_header  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 4 + 256) then   data_in_sync_header  <=x"80";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 5 + 256) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 6 + 256) then   data_in_sync_header  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(debug_3_signal)) + 7 + 256) then   data_in_sync_header  <=x"ff";
      else                                                      data_in_sync_header  <=data_generator_blanc;
      end if;
   else
      data_in_sync_header  <=data_generator_blanc;
   end if;   
end if;
end Process;






Buffer_data                 : FIFO
Port map(
---------in-----------
   data           => data_in_sync_header,
   rdclk          => clk_in,
   rdreq          => enable_for_read_buffer,
   wrclk          => clk_in,
   wrreq          => enable_for_write_buffer,
---------out----------
   q              => data_from_buffer
);
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
   case (debug_4(2 downto 0)) is
      when "000" =>
         resolution_x <= 1024;
         resolution_y <= 1024;
      when "001" =>
         resolution_x <= 2048;
         resolution_y <= 1024;
      when "010" =>
         resolution_x <= 512;
         resolution_y <= 256;
      when "011" =>
         resolution_x <= 960;
         resolution_y <= 960;
      when "100" =>
         resolution_x <= 2048;
         resolution_y <= 2048;
      when others => 
         resolution_x <= 1024;
         resolution_y <= 1024;
   end case;
end if;
end process;
---------------------------------------------------------
--Чтение из ФИФО
Process(clk_in, frame_in) 
variable counter_in_FLAGB_on		: integer range 0 to 255;
BEGIN
   if rising_edge(clk_in) then
	   If (frame_in = '1') then
	   	state <= stream_in_idle;
	   end if;

		case state is
			when stream_in_idle => 
				enable_for_read_buffer <= '0';
            counter_in_FLAGB_on := 0;
            if FLAGA = '1' then
               state <= stream_in_wait_flagb;
            end if;
			when stream_in_wait_flagb =>
            if FLAGB = '1' then
					state <= stream_in_write;
               enable_for_read_buffer  <= '0';

            else 
               enable_for_read_buffer  <= '1';
				end if;
			When stream_in_write =>
            if (pix_active and str_active) then
               enable_for_read_buffer <= '1';
            else
               enable_for_read_buffer <= '0';

            end if;
            If FLAGB = '0' then
               state <= stream_in_write_wr_delay;
            end if;
			when stream_in_write_wr_delay =>
            if counter_in_FLAGB_on <= 48 then
               counter_in_FLAGB_on := counter_in_FLAGB_on + 1;
               enable_for_read_buffer <= '1';
            else
				   enable_for_read_buffer <= '0';
				   state <= stream_in_idle;
               counter_in_FLAGB_on := 0;
            end if;
		end case;
         -- if (pix_active and str_active) then
         --    enable_for_read_buffer <= '1';
         -- else
         --    enable_for_read_buffer <= '0';
         -- end if;
	end if;
end process;
---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
slwr_in_arch <= enable_for_read_buffer;
data_8_bit   <= data_from_buffer;
---------------------------------------------------------
---------------------------------------------------------
end data_generation_arch;