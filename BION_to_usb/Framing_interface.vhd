library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Framing_interface is
Port(
   clk_in               : in    STD_LOGIC;
   reset                : in    STD_LOGIC;
   Pix_per_line         : in    STD_LOGIC_VECTOR(Bitness_interface.bit_pix - 1 downto 0);
   Line_per_frame       : in    STD_LOGIC_VECTOR(Bitness_interface.bit_strok - 1 downto 0);
   frame_in             : in    STD_LOGIC;
   FLAGA                : in    STD_LOGIC;
   FLAGB                : in    STD_LOGIC;
   treshhold_FIFO       : in    STD_LOGIC_VECTOR(7 downto 0);
   data_in              : in    STD_LOGIC_VECTOR(7 downto 0);
   line_with_sync_word  : in    STD_LOGIC_VECTOR(7 downto 0);
   pix_with_sync_word   : in    STD_LOGIC_VECTOR(7 downto 0);
   pix_active_out       : out   STD_LOGIC;
   slwr_in_arch         : out   STD_LOGIC;
   data_out             : out   STD_LOGIC_VECTOR(7 downto 0)                      
);
end Framing_interface;
---------------------------------------------------------
---------------------------------------------------------
architecture Framing_interface_arch of Framing_interface is
---------------------------------------------------------
---------------------------------------------------------
--ФИФО
signal enable_for_write_buffer          : STD_LOGIC;
signal enable_for_read_buffer           : STD_LOGIC;
signal data_from_buffer                 : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_to_buffer                   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);

--машинный автомат
type State_type is(
	stream_in_idle,
	stream_in_wait_flagb,
	stream_in_write,
	stream_in_write_wr_delay
);
signal state						: State_type;

--Активная часть кадра
signal pix_active, str_active            : STD_LOGIC;

--работа с синхрокодами
-- signal line_with_sync_word          : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
-- signal pix_with_sync_word           : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Подключение кадрового синхрокода
---------------------------------------------------------
Process(clk_in)
BEGIN
if rising_edge(clk_in) then
  -- if to_integer(unsigned(Line_per_frame)) =to_integer(unsigned(debug_1))*4 then 
   if to_integer(unsigned(Line_per_frame)) =to_integer(unsigned(line_with_sync_word))*4 then 
        if    to_integer(unsigned(Pix_per_line)) = to_integer(unsigned(pix_with_sync_word))             then   data_to_buffer  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 1)        then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 2)        then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 3)        then   data_to_buffer  <=x"80";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 4)        then   data_to_buffer  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 5)        then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 6)        then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 7)        then   data_to_buffer  <=x"ab";

      elsif   to_integer(unsigned(Pix_per_line)) = to_integer(unsigned(pix_with_sync_word))     + 256   then   data_to_buffer   <=x"ab";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 1 + 256)  then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 2 + 256)  then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 3 + 256)  then   data_to_buffer  <=x"ff";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 4 + 256)  then   data_to_buffer  <=x"80";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 5 + 256)  then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 6 + 256)  then   data_to_buffer  <=x"00";
      elsif   to_integer(unsigned(Pix_per_line)) =(to_integer(unsigned(pix_with_sync_word)) + 7 + 256)  then   data_to_buffer  <=x"ff";
      else                                                      data_to_buffer  <= data_in;
      end if;
   else
      data_to_buffer  <= data_in;
   end if;   
end if;
end Process;

---------------------------------------------------------
--Выделение активной части кадра
---------------------------------------------------------
Process(clk_in)
BEGIN
    if rising_edge(clk_in) then
        if  (to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift) and 
            (to_integer(unsigned(Pix_per_line)) <  BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift) then
            pix_active <= '1';
        else
            pix_active <= '0';
        end if;
   ------------
        if  (to_integer(unsigned(Line_per_frame)) >= BION_960_960p30.VsyncShift) and 
            (to_integer(unsigned(Line_per_frame)) <  BION_960_960p30.VsyncShift + BION_960_960p30.ActiveLine) then
            str_active <= '1';
        else
            str_active <= '0';
        end if;
    end if;
end Process;
---------------------
Process(clk_in)
begin
if rising_edge(clk_in) then
      if (str_active = '1' and pix_active = '1') then
         enable_for_write_buffer <= '1';
      else 
         enable_for_write_buffer <= '0';
      end if; 
end if;
end process;

---------------------------------------------------------
--Подключение экземпляра модуля FIFO
---------------------------------------------------------
Buffer_data                 : entity work.FIFO
Port map(
---------in-----------
   data           => data_to_buffer,
   rdclk          => clk_in,
   rdreq          => enable_for_read_buffer,
   wrclk          => clk_in,
   wrreq          => enable_for_write_buffer,
---------out----------
   q              => data_from_buffer
);

---------------------------------------------------------
--Обработка входящих от Cypress флагов
---------------------------------------------------------
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
            if (pix_active = '1' and str_active = '1') then
               enable_for_read_buffer <= '1';
            else
               enable_for_read_buffer <= '0';

            end if;
            If FLAGB = '0' then
               state <= stream_in_write_wr_delay;
            end if;
			when stream_in_write_wr_delay =>
            if counter_in_FLAGB_on <= to_integer(unsigned(treshhold_FIFO)) * 8 then
               counter_in_FLAGB_on := counter_in_FLAGB_on + 1;
               enable_for_read_buffer <= '1';
            else
				   enable_for_read_buffer <= '0';
				   state <= stream_in_idle;
               counter_in_FLAGB_on := 0;
            end if;
		end case;
	end if;
end process;

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
slwr_in_arch      <= enable_for_read_buffer;
data_out          <= data_from_buffer;
pix_active_out    <= pix_active;
---------------------------------------------------------
end Framing_interface_arch;