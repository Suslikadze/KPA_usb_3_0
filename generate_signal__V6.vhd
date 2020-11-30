library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 

--Проект генерит и передает пилообразный сигнал по 32 битной выходной шине данных.
--Сигналом Switcher дается возможность управлять входной частотой с помощью свитчеров на отладочной плате ПЛИС
--Переключение одного разряда Switcher в '1' (логику см. в файле synth.vhd) уменьшает clk_high в два раза
--Частота clk_high в начальной положении свитчера ("0000") равна 33.75 МГц
--clk_low всегда в 2 раза меньше clk_high
--Флаги FLAG(A,B,C,D) не используются
--PCLK является обратным сигналом clk_low, по которому на USB 3.0 передаются данные
--На флаги А [1:0] подается сигнал активной части строки и строк соответственно
--На флаг slwr передается активная часть кадра
--Флаги slrd, sloe, pktend, reset_FX и slcs всегда выставлены в одно положение    

entity generate_signal is
port(
   clk_in      :in std_logic; 
   FLAGA       :IN std_logic;
   FLAGB       :IN std_logic;
   FLAGC       :IN std_logic;
   FLAGD       :IN std_logic;     
   reset       :out std_logic;
   PCLK        :out std_logic;
   A           :out std_logic_vector(1 downto 0);
   slrd        :out std_logic;
   slwr        :out std_logic;     
   sloe        :out std_logic;
   pktend      :out std_logic; 		
   reset_FX    :out std_logic; 
   slcs        :out std_logic;
   out1        :out std_logic;
   out2        :out std_logic;
   out3        :out std_logic;
   out4        :out std_logic;
	FIFO_write_volume_0: out std_logic_vector(14 downto 0);
   databus     :out std_logic_vector(31 downto 0)
);
end generate_signal;
---------------------------------------------------------
architecture top of generate_signal is
---------------------------------------------------------
constant	size_FIFO_FX	: integer := 4096;


signal count                                : integer := 0;
signal clk_low, clk_high, rdclk              : std_logic;   
signal wrempty                               : std_logic; 
signal x                                     : std_logic_vector(bit_pix - 1 downto 0);
signal x_2                                   : std_logic_vector(bit_pix downto 0);
signal data_from_switcher                    : std_logic_vector(7 downto 0);
signal flag_latence_counter                  : integer := 0;
signal flag_latence                          : std_logic := '0';
signal Pause_length                          : integer := 256;
signal y                                     : std_logic_vector(bit_strok - 1 downto 0);
signal stroka_in                             : std_logic;
signal buffer_for_data                       : std_logic_vector(7 downto 0);
signal str_active, pix_active                : std_logic;
signal enable_for_read_buffer                : std_logic := '0';
signal enable_for_read_buffer_1                : std_logic := '0';
signal enable_for_read_buffer_2                : std_logic := '0';
signal enable_for_read_buffer_3                : std_logic := '0';
signal enable_for_write_buffer               : std_logic := '0';
signal Flag_for_databus                      : std_logic;
signal output_buffer                         : std_logic_vector(31 downto 0);
signal FIFO_write_volume                     : std_logic_vector(14 downto 0);
attribute noprune: boolean;
attribute noprune of FIFO_write_volume: signal is true;
signal FLAGB_in ,FLAGB_in_0                             : std_logic;
signal counter     : integer := 0;
signal counter2    : integer := 0;
signal frame_in                              :std_logic;
signal Switcher_in_trigg, Switcher_in_clk    : std_logic_vector (7 downto 0);
signal trigg_signal_tap, clk_signal_tap      : std_logic;
--машинный автомат
type State_type is(
	stream_in_idle,
	stream_in_wait_flagb,
	stream_in_write,
	stream_in_write_wr_delay
);
signal state						: State_type;
signal treshhold_FIFO         : integer := 1;
---------------------------------------------------------
component count_n_modul
   generic (n		: integer);
   port(
      clk,
      reset,
      en			:	in std_logic;
      modul		: 	in std_logic_vector (n-1 downto 0);
      qout		: 	out std_logic_vector (n-1 downto 0);
      cout		:	out std_logic
   );
end component;
---------------------------------------------------------
component synth
   PORT(
	   clk_in           :in std_logic;
      FLAG             :in std_logic_vector(3 downto 0);
      clk_out_high     :out std_logic;
      clk_out_low      :out std_logic;
      clk_fast_rd      :out std_logic  
   );
END component;
---------------------------------------------------------
component FIFO
	PORT
	(
		data		   : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		   : IN STD_LOGIC ;
		rdreq		   : IN STD_LOGIC ;
		wrclk		   : IN STD_LOGIC ;
		wrreq		   : IN STD_LOGIC ;
		q		      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdfull		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
		wrempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (14 DOWNTO 0)
	);
END component;
---------------------------------------------------------
component Write_to_file
   generic(
	Separating_width			: integer
);
	Port(
		clk				: IN std_logic;
		DATA_IN	: IN std_logic_vector((Separating_width - 1) downto 0);
		Enable			: IN std_logic
	);
end component;
---------------------------------------------------------
signal ena_clk_high               : std_logic := '0';
signal ena_x_cnt                 : std_logic := '0';

component const
Port(
   result      :  OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
);
end component;

signal debug_8bit          : std_logic_vector(7 downto 0);
signal treshhold_FIFO_q    : std_logic_vector(7 downto 0);

---------------------------------------------------------
component delay_reg IS
PORT
(
   clock		: IN STD_LOGIC ;
   shiftin  : IN STD_LOGIC ;
   q		   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
);
END component;
signal delay_ena_read_buffer  : std_logic_vector(15 downto 0);
---------------------------------------------------------

signal Pclk_in                 : std_logic := '0';
component noise_gen is
port ( data_in : in std_logic_vector (11 downto 0);
	crc_en , rst, clk : in std_logic;
	crc_out : out std_logic_vector (11 downto 0));
end component;
signal noise_gen_q		: std_logic_vector (11 downto 0);


begin
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------

FIFO_write_volume_0	<=FIFO_write_volume;
out1 <= trigg_signal_tap;
out2 <= clk_signal_tap;
out3 <= FLAGA;
out4 <= FLAGB;
---------------------------------------------------------
--Синхрогенератор
synth_clk            : synth
Port map(
   clk_in            => clk_in,  
   FLAG              => "0000",
   clk_out_high      => clk_high,
   clk_out_low       => clk_low,
   clk_fast_rd       => rdclk
);
---------------------------------------------------------
--Счетчик пикселей в строке (1000)
counter_for_pix      : count_n_modul
generic map(bit_pix)
Port map(
---------in-----------
   clk      => rdclk,
   reset    => '0',
   en       => ena_clk_high,
   modul    => std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine, bit_pix)),
---------out----------
   qout     => x,
   cout     => stroka_in
);
---------------------------------------------------------
const_8bit_trigg                  : const
port map(
   result      => Switcher_in_trigg
);

const_8bit_clk                   :const
port map(
   result      => Switcher_in_clk
);
const_8bit_treshhold_FIFO                  :const
port map(
   result      => treshhold_FIFO_q
);
treshhold_FIFO <=to_integer(unsigned(treshhold_FIFO_q));

debug_8bit_q                  :const
port map(
   result      => debug_8bit
);


---------------------------------------------------------
--Счетчик строк в кадре (1125)
counter_for_line      : count_n_modul
generic map(bit_strok)
Port map(
---------in-----------
   clk      => rdclk,
   reset    => '0',
   en       => ena_x_cnt,
   modul    => std_logic_vector(to_unsigned(BION_960_960p30.LinePerFrame, bit_strok)),  
---------out----------
   qout     => y,
   cout     => frame_in
);
---------------------------------------------------------
--Счетчик пикселей в строке (1000)
counter_for_pix_2      : count_n_modul
generic map(bit_pix + 1)
Port map(
---------in-----------
   clk      => rdclk,
   reset    => '0',
   en       => '1',
   modul    => std_logic_vector(to_unsigned(BION_960_960p30.PixPerLine*2, bit_pix + 1)),  
---------out----------
   qout     => x_2
);
ena_clk_high <=x_2(0);
---------------------------------------------------------
Process(rdclk)
begin
   if rising_edge(rdclk) then
      ena_x_cnt   <= stroka_in and ena_clk_high;
  end if;
end process;

---------------------------------------------------------
--Запись в файл (для теста)
Write_in             : Write_to_file
generic map(32)
Port map(
   clk      => rdclk,
   DATA_IN  => output_buffer,
   Enable   => enable_for_read_buffer
);
---------------------------------------------------------
--Буфер
Buffer_data                  : FIFO
Port map(
---------in-----------
   data           => data_from_switcher,
   rdclk          => rdclk,
   rdreq          => enable_for_read_buffer,
   wrclk          => rdclk,
   wrreq          => enable_for_write_buffer,
---------out----------
   q              => buffer_for_data,
   wrempty        => wrempty,
   wrusedw        => FIFO_write_volume
   -- rdusedw		   => FIFO_write_volume
);
---------------------------------------------------------
---------------------------------------------------------
noise_gen_0: noise_gen                    
port map (
	data_in		=>	x(7 downto 0) & y(3 downto 0),			
	crc_en		=>	'1' ,
	rst			=>	frame_in,		
	clk			=>	rdclk ,
	crc_out		=>	noise_gen_q);


Process(rdclk)
begin
   if rising_edge(rdclk) then
      if ena_clk_high='1'  then
         case Switcher_in_clk(7 downto 4) is
            when "0000" => data_from_switcher <= x(9 downto 2);
            when "0001" => data_from_switcher <= y(7 downto 0);
            when "0010" => data_from_switcher <= noise_gen_q(10 downto 3);
            when others => data_from_switcher <= x(9 downto 2); 
         end case;
    end if;
  end if;
end process;
---------------------------------------------------------

---------------------------------------------------------
--Работа синхроимпульсов, передача их на флаги
--На флаги А [1:0] подается сигнал активной части строки и строк соответственно
--На флаг slwr передается активная часть кадра
--Флаги slrd, sloe, pktend, reset_FX и slcs всегда выставлены в одно положение 
--активная часть строки и строк с 5 до 965
Process(rdclk)
begin
   if rising_edge(rdclk) then
      if ena_clk_high='1'  then
   ------------
      if (to_integer(unsigned(x)) >= BION_960_960p30.HsyncShift ) and (to_integer(unsigned(x)) < BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift ) then
         pix_active <= '1';
      else
         pix_active <= '0';
      end if;
   ------------
      if (to_integer(unsigned(y)) >= BION_960_960p30.VsyncShift) and (to_integer(unsigned(y)) < BION_960_960p30.ActiveLine + BION_960_960p30.VsyncShift ) then
         str_active <= '1';
      else
         str_active <= '0';
      end if;
      slrd           <= '1'; 
      sloe           <= '1';	
      pktend         <= '1';	
 --     reset_FX       <= '0';	
      slcs           <= '0';
      A(1 downto 0)  <= "00";
   ------------
    end if;
  end if;
end process;
---------------------------------------------------------
--Алгоритм rdclk в ФИФО (активная часть кадра)
Process(rdclk)
begin
if rising_edge(rdclk) then
   if ena_clk_high='1'  then
      if (str_active and pix_active) then
         enable_for_write_buffer <= '1';
      else 
         enable_for_write_buffer <= '0';
      end if; 
   else
      enable_for_write_buffer <= '0';
   end if;
end if;
end process;
---------------------------------------------------------

---------------------------------------------------------
Process(rdclk, frame_in) 
variable counter		            : integer range 0 to 255;
variable counter_in_FLAGB_on		: integer range 0 to 255;
BEGIN
   if rising_edge(rdclk) then
	   If (frame_in = '1') then
	   	state <= stream_in_idle;
	   end if;

		case state is
			when stream_in_idle => 
				enable_for_read_buffer <= '0';
            counter := 0;
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
            if (counter_in_FLAGB_on <= treshhold_FIFO) then
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
slwr <= (not enable_for_read_buffer) and Switcher_in_trigg(7);
---------------------------------------------------------

---------------------------------------------------------
Process(rdclk)
begin
   if rising_edge(rdclk) then
      if (FLAGA = '0') then
         flag_latence_counter <= 0;
         flag_latence <= '1';
      elsif (flag_latence_counter >= 0 and flag_latence_counter < Pause_length) then
         flag_latence_counter <= flag_latence_counter + 1;
         flag_latence <= '1';
      else
         flag_latence <= '0';         
      end if;
   end if;
end process;
---------------------------------------------------------
--запись в 32-битный пакет
Process(rdclk)
begin
   if rising_edge(rdclk) then
         case x(1 downto 0) is
            when "00" =>       output_buffer(31 downto 24)  <= buffer_for_data;
            when "01" =>       output_buffer(23 downto 16)  <= buffer_for_data;
            when "10" =>       output_buffer(15 downto 8)   <= buffer_for_data;
            when "11" =>       output_buffer(7 downto 0)    <= buffer_for_data;
            when others =>     output_buffer                <= (others => '0');
         end case;

         if x(1 downto 0) = debug_8bit  (1 downto 0) then
            Flag_for_databus <= '1';
         else
            Flag_for_databus <= '0';
         end if;
     -- else
     --    output_buffer <= (others => '0');
     --    Flag_for_databus <= '0';
     -- end if;
   end if;
end process;
---------------------------------------------------------
--Передача данных на выходную шину
       
---------------------------------------------------------

---------------------------------------------------------
delay_reg_q      : delay_reg
Port map(
---------in-----------
   clock    => rdclk,
   shiftin  => enable_for_read_buffer,
---------out----------
   q        => delay_ena_read_buffer
);



Process(rdclk)
begin
   if rising_edge(rdclk) then
      if x_2(2 downto 1)="01" or x_2(2 downto 1)="10"    then
         Pclk <= '0';   Pclk_in <= '0';   
      else
         Pclk <= '1';   Pclk_in <= '1';   
      end if;
      if (Flag_for_databus = '1') then
         databus <= output_buffer;
      end if;
   end if;
end process;
---------------------------------------------------------
---------------------------------------------------------
PROCESS(Pclk_in)                                                                                     
BEGIN 
	if rising_edge(Pclk_in) then
		if (slwr = '0') then
			if (counter /= size_FIFO_FX-1) then
				counter <= counter + 1;
				FLAGB_in <= '1';
         else 
            FLAGB_in <= '0';
			end if;
		elsif (counter2 /= 99 and counter = size_FIFO_FX-1) then
			counter2 <= counter2 + 1;
			FLAGB_in <= '0';
		elsif (counter2 = 99 and counter = size_FIFO_FX-1) then
			counter <= 0;
			counter2 <= 0;
			FLAGB_in <= '1';
		else
			FLAGB_in <= '1';
		end if;
	end if;
END PROCESS ; 

---------------------------------------------------------
---------------------------------------------------------
Process(Switcher_in_clk(3 downto 0))
begin
   case (Switcher_in_clk(3 downto 0)) is
      when X"0" =>     clk_signal_tap <= rdclk;
      when X"1" =>     clk_signal_tap <= x_2(0);
      when X"2" =>     clk_signal_tap <= x_2(1);
      when X"3" =>     clk_signal_tap <= x_2(2);
      when X"4" =>     clk_signal_tap <= x_2(3);
      when X"5" =>     clk_signal_tap <= x_2(4);
      when X"6" =>     clk_signal_tap <= x_2(5);
      when X"7" =>     clk_signal_tap <= x_2(6);
      when X"8" =>     clk_signal_tap <= x_2(7);
      when X"9" =>     clk_signal_tap <= x_2(8);
      when X"a" =>     clk_signal_tap <= x_2(9);
      when X"b" =>     clk_signal_tap <= y(0);
      when X"c" =>     clk_signal_tap <= y(1);
     when others =>    clk_signal_tap <= rdclk;   
   end case;
end process;

Process(Switcher_in_trigg(3 downto 0))
begin
   case (Switcher_in_trigg(3 downto 0)) is
      when X"0" =>     trigg_signal_tap <= stroka_in;
      when X"1" =>     trigg_signal_tap <= frame_in;
      when X"2" =>     trigg_signal_tap <= FLAGB_in;
      when X"3" =>     trigg_signal_tap <= Flag_for_databus;
      when X"4" =>     trigg_signal_tap <= flag_latence;
      when X"5" =>     trigg_signal_tap <= slwr;
      when X"6" =>     trigg_signal_tap <= enable_for_read_buffer;
      when X"7" =>     trigg_signal_tap <= databus(12);
      when X"8" =>     trigg_signal_tap <= str_active;
      when X"9" =>     trigg_signal_tap <= FLAGB;
      when X"A" =>     trigg_signal_tap <= FLAGA;
      when X"B" =>     trigg_signal_tap <= FLAGB_in_0;
      
      when others =>    trigg_signal_tap <= stroka_in;   
   end case;
end process;
---------------------------------------------------------
---------------------------------------------------------
end top;