library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 
use work.My_component_pkg.all;


entity Aligner is
Port(
    clk_in              : in    STD_LOGIC;
    clk_cam             : IN    STD_LOGIC;
    reset               : in    STD_LOGIC;
    Pix_per_line        : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_pix         - 1 downto 0);
    Line_per_frame      : IN    STD_LOGIC_VECTOR(Bitness_camera.bit_strok       - 1 downto 0);
    Flag_8_bit          : in    STD_LOGIC;
    enable              : in    STD_LOGIC;
 --   stroka_in           : in    STD_LOGIC;
    ch_1_par            : in    STD_LOGIC_VECTOR(bit_data                       - 1 downto 0);
    reset_sync_counters : out   STD_LOGIC;
    Align_word          : out   STD_LOGIC_VECTOR(bit_data                       - 1 downto 0)
);
end Aligner;
---------------------------------------------------------
---------------------------------------------------------
architecture Aligner_arch of Aligner is 
---------------------------------------------------------
---------------------------------------------------------
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
        Down_right_of_frame,
        Active_frame_flag       : STD_LOGIC := '0';
-- type array_for_memory is array (natural range <>) of STD_LOGIC_VECTOR;
signal array_of_check_words     : STD_LOGIC_VECTOR(31 downto 0);
signal Sync_word_catched        : std_logic;
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
generic map(4)
Port map(
    clk         => clk_cam,
    reset       => '0',
    en          => increment_Align_word,
    modul       => std_logic_vector(to_unsigned(bit_data, 4)),
    qout        => Align_word_in
);
---------------------------------------------------------
--Проверка синхрослов, выставление флагов
---------------------------------------------------------
Process(clk_cam)
BEGIN
if rising_edge(clk_cam) then
    array_of_check_words(31 downto 8) <= array_of_check_words(23 downto 0);
    array_of_check_words(7 downto 0) <= ch_1_par;

    -- array_of_check_words    <=  ch_1_par & array_of_check_words(31 downto 8);
    -- case array_of_check_words is
    --     when x"FF000080" =>
    --         Up_left_of_frame <= '1';
    --     when x"FF00009D" =>
    --         Up_right_of_frame <= '1';
    --     when x"FF0000AB" =>
    --     -- when x"AB0000FF" =>
    --         Down_left_of_frame <= '1';
    --         reset_sync_counters <= '1';
    --     when x"FF0000B9" =>
    --         Down_right_of_frame <= '1';
    --     when others => 
    --         Up_left_of_frame        <= '0';
    --         Up_right_of_frame       <= '0';
    --         Down_left_of_frame      <= '0';
    --         Down_right_of_frame     <= '0';
    --         reset_sync_counters     <= '0';
    -- end case;
    if (array_of_check_words = X"FF000080") then
        Active_frame_flag <= '1';
    elsif (array_of_check_words = X"FF0000AB") then
        Active_frame_flag <= '0';
    end if;
end if;
end process;
---------------------------------------------------------
Process(Active_frame_flag, clk_cam)
BEGIN
if rising_edge(clk_cam) then
    If Active_frame_flag'event and Active_frame_flag = '0' then
        reset_sync_counters <= '1';
    else
        reset_sync_counters <= '0';
    end if;
end if;
end process;
---------------------------------------------------------
--Проверка нахождения строчного синхрослова
---------------------------------------------------------
Process(clk_cam)
BEGIN
If rising_edge(clk_cam) then
    -- if  (to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift) and 
    --     (to_integer(unsigned(Pix_per_line)) <  BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift) then
    --     if (array_of_check_words = x"FF000080") then
    --         Sync_word_catched <= '1';
    --     end if;
    -- elsif (to_integer(unsigned(Pix_per_line)) = BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift) then
    --     Sync_word_catched <= '0';
    -- end if
    if (to_integer(unsigned(Pix_per_line)) = BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift) then
         Sync_word_catched <= '0';
    else
        if (array_of_check_words = x"FF000080") then
            Sync_word_catched <= '1';
        end if;
    end if;
end if;
end process;

Process(clk_cam)
BEGIN
If rising_edge(clk_cam) then
    If (to_integer(unsigned(Pix_per_line)) = BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift - 1) then
        if Sync_word_catched = '0' then
            increment_Align_word <= '1';
        end if;
    -- elsif (to_integer(unsigned(Pix_per_line)) = BION_960_960p30.ActivePixPerLine + BION_960_960p30.HsyncShift + 1) then
    --     if Sync_word_catched = '0' then
    --         increment_Align_word <= '1';
    --     end if;
    else
        increment_Align_word <= '0';
    end if;
end if;
end process;
---------------------------------------------------------
Process(clk_cam)
BEGIN
if rising_edge(clk_cam) then
    Align_word <= "0000" & Align_word_in;
end if;
end process;

---------------------------------------------------------
---------------------------------------------------------
end Aligner_arch;