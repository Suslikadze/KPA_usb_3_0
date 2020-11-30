library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 


entity BION_TOP is
PORT(
    clk_in      :in     std_logic; 
    FLAGA       :IN     std_logic;
    FLAGB       :IN     std_logic;
    FLAGC       :IN     std_logic;
    FLAGD       :IN     std_logic;     
    reset       :in     std_logic;
    PCLK        :out    std_logic;
    A           :out    std_logic_vector(1 downto 0);
    slrd        :out    std_logic;
    slwr        :out    std_logic;     
    sloe        :out    std_logic;
    pktend      :out    std_logic; 		
    reset_FX    :out    std_logic; 
    slcs        :out    std_logic;
    out1        :out    std_logic;
    out2        :out    std_logic;
    out3        :out    std_logic;
    out4        :out    std_logic;
    databus     :out    std_logic_vector(bit_data_out - 1 downto 0)
);
end BION_TOP;
---------------------------------------------------------
---------------------------------------------------------
architecture BION_TOP_arch of BION_TOP is
---------------------------------------------------------
---------------------------------------------------------
--Synth_gen
signal Pix_per_line                 : STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
signal Line_per_frame               : STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
signal frame_flag                   : STD_LOGIC;
signal stroka_flag                  : STD_LOGIC;
signal enable_for_pix               : STD_LOGIC;
--signal reset                        : STD_LOGIC;
signal clk_pix_in, PCLK_in          : STD_LOGIC;
signal clk_to_switcher              : STD_LOGIC;
--Data_gen
signal slwr_in_arch                 : STD_LOGIC;
signal data_8_bit                   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--output_data_interface
signal databus_arch                 : STD_LOGIC_VECTOR(bit_data_out - 1 downto 0);
--JTAG_DEBUG_CONST
signal  treshhold_FIFO,
        debug_8bit_for_output_data_interface,
        Switcher_in_trigg,
        Switcher_in_clk             : STD_LOGIC_VECTOR(7 downto 0);
--Выбор входных данных
signal data_from_switcher           : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--from mux
signal data_from_mux                : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
--Debug signals
signal trigg_signal_tap, clk_signal_tap     : std_logic;
signal debug_slwr, debug_ser_shift          : std_logic_vector(7 downto 0);
---------------------------------------------------------
--Объявление компонент
--PLL
component PLL
PORT(
    inclk0		: IN STD_LOGIC  := '0';
    c0		    : OUT STD_LOGIC ;
    locked		: OUT STD_LOGIC 
);
END component;
---------------------------------------------------------
--синхрогенератор
component Synth_gen
Port(
    clk_pix                         : in    STD_LOGIC;
    reset                           : in    STD_LOGIC;
    enable_for_pix                  : in    STD_LOGIC;
    Pix_per_line                    : out   STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame                  : out   STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    clk_for_PCLK                    : out   STD_LOGIC;
    frame_flag                      : out   STD_LOGIC;
    stroka_flag                     : out   STD_LOGIC
);
end component;
---------------------------------------------------------
--логика обмена данным с usb_3.0
component data_generation
Port(
    clk_in          : in    STD_LOGIC;
    reset           : in    STD_LOGIC;
    data_in         : in    STD_LOGIC_VECTOR(7 downto 0);
    treshhold_FIFO  : in    STD_LOGIC_VECTOR(7 downto 0);
    Pix_per_line    : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame  : in    STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    frame_in        : in    STD_LOGIC;
    FLAGA           : in    STD_LOGIC;
    FLAGB           : in    STD_LOGIC;
    slwr_in_arch    : out   STD_LOGIC;
    data_8_bit      : out   STD_LOGIC_VECTOR(7 downto 0)
);
end component;
---------------------------------------------------------
component output_data_interface
Port(
    clk_in              : in    STD_LOGIC;
    reset               : in    STD_LOGIC;
    pix                 : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    debug_8bit          : in    std_logic_vector(7 downto 0);
    data_8_bit          : in    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    databus             : out   std_logic_vector(31 downto 0)
);
end component;
---------------------------------------------------------
component JTAG_DEBUG_CONST
Port(
    reg_8bit_0				: out std_logic_vector (7 downto 0);  				-- treshhold_FIFO
	reg_8bit_1				: out std_logic_vector (7 downto 0);  				-- debug_8bit_for_output_data_interface
	reg_8bit_2				: out std_logic_vector (7 downto 0);  				-- Switcher_in_trigg
	reg_8bit_3				: out std_logic_vector (7 downto 0);  				-- Switcher_in_clk
    reg_8bit_4				: out std_logic_vector (7 downto 0);                -- для переключения slwr
    reg_8bit_5				: out std_logic_vector (7 downto 0)                 -- для переключения флага захвата 8-битных слов
);
end component;
---------------------------------------------------------
---------------------------------------------------------
Begin
---------------------------------------------------------
---------------------------------------------------------
--Описание компонентов
---------------------------------------------------------
---------------------------------------------------------
PLL_input                   : PLL
Port map(
    inclk0      => clk_in,
    c0	        => clk_pix_in
);
---------------------------------------------------------
Synth_gen_top               : Synth_gen
Port map(
    ---------in-----------
    clk_pix                 => clk_pix_in,
    reset                   => '0',
    enable_for_pix          => '1',
    ---------out----------
    Pix_per_line            => Pix_per_line,
    Line_per_frame          => Line_per_frame,
    clk_for_PCLK            => PCLK_in,
    frame_flag              => frame_flag,
    stroka_flag             => stroka_flag
);
---------------------------------------------------------
-- Process(clk_to_switcher)
-- variable counter            : integer range 0 to 255;
-- begin
--     if rising_edge(clk_to_switcher) then
--         if (counter < 255) then
--             counter := counter + 1;
--         else
--             counter := 0;
--         end if;
--         case debug_slwr(2 downto 0) is
--             when "000" => clk_pix_in <= std_logic_vector(to_unsigned(counter, 8))(0);
--             when "001" => clk_pix_in <= std_logic_vector(to_unsigned(counter, 8))(1);
--             when "010" => clk_pix_in <= std_logic_vector(to_unsigned(counter, 8))(2);
--             when "011" => clk_pix_in <= std_logic_vector(to_unsigned(counter, 8))(3);
--             when others => clk_pix_in <= std_logic_vector(to_unsigned(counter, 8))(0);
--         end case;
--     end if;
-- end process;
---------------------------------------------------------
data_generation_top         : data_generation
PORT map(
    ---------in-----------
    clk_in                  => clk_pix_in,
    reset                   => reset,
    --data_in                 => data_in,
    data_in                 => "00011100",
    --treshhold_FIFO          => treshhold_FIFO,
    treshhold_FIFO          => x"30",
    Pix_per_line            => Pix_per_line,
    Line_per_frame          => Line_per_frame,
    frame_in                => frame_flag,
    FLAGA                   => FLAGA,
    FLAGB                   => FLAGB,
    ---------out----------
    slwr_in_arch            => slwr_in_arch,
    data_8_bit              => data_8_bit
);
---------------------------------------------------------
output_data_interface_arch  : output_data_interface
Port map(
    ---------in-----------
    clk_in                  => PCLK_in,
    reset                   => reset,
    pix                     => Pix_per_line,
    -- debug_8bit              => debug_8bit_for_output_data_interface,
    debug_8bit              => x"00",
    data_8_bit              => data_8_bit,
    ---------out----------
    databus                 => databus_arch
);  
---------------------------------------------------------
JTAG_DEBUG_CONST_arch       : JTAG_DEBUG_CONST
Port map(
    ---------out----------
    reg_8bit_0              => treshhold_FIFO,
    reg_8bit_1              => debug_8bit_for_output_data_interface,
    reg_8bit_2              => Switcher_in_trigg,
    reg_8bit_3              => Switcher_in_clk,
    reg_8bit_4              => debug_slwr,
    reg_8bit_5              => debug_ser_shift
);
---------------------------------------------------------
---------------------------------------------------------
--выбор входных данных
-- Process(clk_for_arch)
-- begin
--    if rising_edge(clk_for_arch) then
--          case Switcher_in_clk(7 downto 4) is
--             when "0000" => data_from_switcher <= data_in;
--             when "0001" => data_from_switcher <= Pix_per_line(9 downto 2);
--             when "0010" => data_from_switcher <= Line_per_frame(7 downto 0);
--             when "0100" => data_from_switcher <= noise_gen_arch(10 downto 3);
--             when others => data_from_switcher <= Pix_per_line(9 downto 2); 
--          end case;
--     end if;
-- end process;
---------------------------------------------------------
--Асинхронное присвоение выходным шинам
slwr                <= not(slwr_in_arch); 
--and debug_slwr(0);
slrd                <= '1'; 
sloe                <= '1';	
pktend              <= '1';
slcs                <= '0';
databus             <= databus_arch;
A(1 downto 0)       <= "00";
-- FIFO_write_volume_0	<=FIFO_write_volume;
out1                <= trigg_signal_tap;
out2                <= clk_signal_tap;
out3                <= FLAGA;
out4                <= FLAGB;
PCLK                <= PCLK_in;
---------------------------------------------------------
--debug
Process(Switcher_in_clk(3 downto 0))
begin
   case (Switcher_in_clk(3 downto 0)) is
      when X"0" =>     clk_signal_tap <= clk_pix_in;
      when X"1" =>     clk_signal_tap <= Pix_per_line(0);
      when X"2" =>     clk_signal_tap <= stroka_flag;
      when X"3" =>     clk_signal_tap <= Pix_per_line(2);
      when X"4" =>     clk_signal_tap <= clk_in;
      when X"5" =>     clk_signal_tap <= Pix_per_line(4);
      when X"6" =>     clk_signal_tap <= Pix_per_line(5);
      when X"7" =>     clk_signal_tap <= Pix_per_line(6);
      when X"8" =>     clk_signal_tap <= Pix_per_line(7);
      when X"9" =>     clk_signal_tap <= Pix_per_line(8);
      when X"a" =>     clk_signal_tap <= Pix_per_line(9);
      when X"b" =>     clk_signal_tap <= Line_per_frame(0);
      when X"c" =>     clk_signal_tap <= Line_per_frame(1);
     when others =>    clk_signal_tap <= clk_pix_in;   
   end case;
end process;

Process(Switcher_in_trigg(3 downto 0))
begin
   case (Switcher_in_trigg(3 downto 0)) is
    when X"0" =>     trigg_signal_tap <= stroka_flag;
    when X"1" =>     trigg_signal_tap <= frame_flag;
    when X"2" =>     trigg_signal_tap <= FLAGB;
    when X"3" =>     trigg_signal_tap <= FLAGA;
    when X"4" =>     trigg_signal_tap <= slwr; 
    when X"5" =>     trigg_signal_tap <= databus(12);
    when others =>   trigg_signal_tap <= stroka_flag;   
end case;
end process;
---------------------------------------------------------
---------------------------------------------------------
end BION_TOP_arch;