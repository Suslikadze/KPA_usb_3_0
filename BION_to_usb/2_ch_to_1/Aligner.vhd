library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 
use work.My_component_pkg.all;


entity Aligner is
Port(
    clk_in              : in    STD_LOGIC;
    reset               : in    STD_LOGIC;
    Flag_8_bit          : in    STD_LOGIC;
    enable              : in    STD_LOGIC;
 --   stroka_in           : in    STD_LOGIC;
    ch_1_par            : in    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    reset_each_line     : out   STD_LOGIC;
    Align_word          : out   STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    clk_pix             : out   STD_LOGIC;
    clk_for_mux         : out   STD_LOGIC
);
end Aligner;
---------------------------------------------------------
---------------------------------------------------------
architecture Aligner_arch of Aligner is 
---------------------------------------------------------
---------------------------------------------------------
signal clk_pix_in               : STD_LOGIC := '0';
signal counter_for_data         : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal reset_each_line_in       : STD_LOGIC;
signal increment_Align_word     : STD_LOGIC;
signal Align_word_in            : STD_LOGIC_VECTOR(3 downto 0);
--TRC коды
signal TRS_F0_V0_H0		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V0_H1		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V1_H0		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V1_H1		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_SYNC_3FF		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_SYNC_0		: std_logic_vector (bit_data - 1 downto 0);
--поиск синхрослов
signal  Up_left_of_frame,   
        Up_right_of_frame,  
        Down_left_of_frame, 
        Down_right_of_frame     : STD_LOGIC;
-- type array_for_memory is array (natural range <>) of STD_LOGIC_VECTOR;
signal array_of_check_words     : STD_LOGIC_VECTOR(31 downto 0);
--машинный автомат
-- type State_type is(
-- 	check_1_TRS_word,
-- 	check_2_TRS_word,
-- 	check_3_TRS_word,
-- 	check_4_TRS_word,
--     wait_for_end_of_frame,
--     data_true
-- );
-- signal state						: State_type := idle;
---------------------------------------------------------
--Объявление компонент
---------------------------------------------------------
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
--модуль генерации TRS кодов для IMX
TRS_gen_q           : TRS_gen                    
generic map (bit_data) 
port map (
    CLK			    => clk_in,		
    TRS_SYNC_3FF    => TRS_SYNC_3FF,
    TRS_SYNC_0      => TRS_SYNC_0,
    TRS_F0_V0_H0    => TRS_F0_V0_H0,
    TRS_F0_V0_H1    => TRS_F0_V0_H1,
    TRS_F0_V1_H0    => TRS_F0_V1_H0,
    TRS_F0_V1_H1    => TRS_F0_V1_H1
);
---------------------------------------------------------
--Создание 3-битового счетчика 
counter_for_8_bit_data          : count_n_modul
generic map(bit_counter_data)
Port map(
    clk         => clk_in,
    reset       => '0',
    --Flag_8_bit,
    en          => '1',
    modul       => std_logic_vector(to_unsigned(bit_data, bit_counter_data)),
    qout        => counter_for_data
);
---------------------------------------------------------
--Align_word
counter_for_Align_word          : count_n_modul
generic map(bit_counter_data)
Port map(
    clk         => clk_in,
    reset       => '0',
    en          => increment_Align_word,
    modul       => std_logic_vector(to_unsigned(bit_data, bit_counter_data)),
    qout        => Align_word_in
);
---------------------------------------------------------
--Создание пиксельной частоты
-- Process(clk_in)
-- BEGIN
-- If rising_edge(clk_in) then
--     if  counter_for_data = to_integer(shift_right(to_unsigned(bit_data, bit_counter_data), 1))  
--     --    or counter_for_data = to_integer(shift_right(to_unsigned(bit_data, bit_counter_data), 2))
--     --    or counter_for_data = to_integer(shift_right(to_unsigned(bit_data, bit_counter_data), 3)) 
--         or (counter_for_data = 0) then
--         clk_pix_in <= not clk_pix_in;
--     end if;
-- end if;
-- if rising_edge(clk_in) then
    clk_pix <= counter_for_data(1);
    clk_for_mux <= counter_for_data(2);
-- end if;
    -- if rising_edge(clk_in) then
    --     if (counter_for_data = 3 or counter_for_data = 7)  then
    --         clk_pix <= not clk_pix;
    --     end if;
    --     if (counter_for_data = 7)  then
    --         clk_for_mux <= not clk_for_mux;
    --         counter_for_data <= (others => '0');
    --     else
    --         counter_for_data <= counter_for_data + 1;
    --     end if;
    -- end if;
-- end process;

---------------------------------------------------------
--Проверка синхрослов, выставление флагов
Process(clk_pix_in)
BEGIN
if rising_edge(clk_pix_in) then
    array_of_check_words(31 downto 8) <= array_of_check_words(23 downto 0);
    array_of_check_words(7 downto 0) <= ch_1_par;

    -- array_of_check_words    <=  ch_1_par & array_of_check_words(31 downto 8);
    case array_of_check_words is
        when x"FF000080" =>
            Up_left_of_frame <= '1';
        when x"FF00009D" =>
            Up_right_of_frame <= '1';
        when x"FF0000AB" =>
            Down_left_of_frame <= '1';
        when x"FF0000B9" =>
            Down_right_of_frame <= '1';
        when others => 
            Up_left_of_frame        <= '0';
            Up_right_of_frame       <= '0';
            Down_left_of_frame      <= '0';
            Down_right_of_frame     <= '0';
    end case;
end if;
end process;
---------------------------------------------------------

-- Process(clk_pix_in)
-- BEGIN
-- if rising_edge(clk_pix_in) then
--     case state is
--         when check_1_TRS_word =>
--             reset_each_line <= '0';
--             ------------------------
--             if (stroka_in) then
--                 increment_Align_word < '1';
--             end if;
--             ------------------------
--             if ch_1_par = TRS_SYNC_3FF then
--                 state <= check_2_TRS_word;
--             end if;
--             ------------------------
--         when check_2_TRS_word =>
--             reset_each_line <= '0';
--             ------------------------
--             if (stroka_in) then
--                 increment_Align_word < '1';
--                 state <= check_1_TRS_word;
--             end if;
--             ------------------------
--             if ch_1_par = TRS_SYNC_0;
--                 state <= check_3_TRS_word;
--             end if;
--             ------------------------
--         when check_3_TRS_word =>
--             reset_each_line <= '0';
--             ------------------------
--             if (stroka_in) then
--                 increment_Align_word < '1';
--                 state <= check_1_TRS_word;
--             end if;
--             ------------------------
--             if ch_1_par = TRS_SYNC_0;
--                 state <= check_4_TRS_word;
--             end if;
--             ------------------------
--         when check_4_TRS_word =>
--             reset_each_line <= '0';
--             ------------------------
--             if (stroka_in) then
--                 increment_Align_word < '1';
--                 state <= check_1_TRS_word;
--             end if;
--             ------------------------
--             if ch_1_par = TRS_F0_V0_H0 then
--                 state <= data_true;
--                 reset_each_line <= '1';
--             elsif ch_1_par = TRS_F0_V1_H0 then
--                 state <= wait_for_end_of_frame;
--             end if;
--             ------------------------
--         when wait_for_end_of_frame =>
--             if (frame_in) then
--                 state <= check_1_TRS_word
--             end if;
--         when data_true =>
--             if (stroka_in) then
--                 state <= check_1_TRS_word;
--                 reset_each_line <= '1';
--             end if;
--     end case;
-- end if;
-- end process;
---------------------------------------------------------
end Aligner_arch;