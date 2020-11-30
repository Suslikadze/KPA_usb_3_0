library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 
use work.My_component_pkg.all;




entity data_generation_cam is
Generic(
    bit_data_cam :  integer := 8
);
Port(
   clk_in                           : in    STD_LOGIC;
   reset                            : in    STD_LOGIC;
   Switcher_for_type_of_data        : in    STD_LOGIC_VECTOR(3 downto 0);
   Pix_per_line                     : in    STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
   Line_per_frame                   : in    STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
   frame_flag                       : in    STD_LOGIC;
   data_out_from_cam                : out   STD_LOGIC_VECTOR(bit_data_cam - 1 downto 0)
);
end data_generation_cam;
---------------------------------------------------------
---------------------------------------------------------
architecture data_generation_cam_arch of data_generation_cam is
---------------------------------------------------------
---------------------------------------------------------
--выделение активной части кадра
signal VALID_DATA                       : STD_LOGIC;
signal data_imx_anc                     : STD_LOGIC_VECTOR(bit_data_cam - 1 downto 0);
signal data_out_from_cam_in             : STD_LOGIC_VECTOR(bit_data_cam - 1 downto 0);
--Выбор типа данных
signal data_from_switcher               : STD_LOGIC_VECTOR(bit_data_cam - 1 downto 0);
--Noise
signal noise_gen_arch		        : std_logic_vector (11 downto 0); 

--TRC коды
signal TRS_F0_V0_H0		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V0_H1		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V1_H0		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_F0_V1_H1		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_SYNC_3FF		: std_logic_vector (bit_data - 1 downto 0);
signal TRS_SYNC_0		: std_logic_vector (bit_data - 1 downto 0);


---------------------------------------------------------
--Объявление компонент
component noise_gen is
port ( 
    data_in                 : in    std_logic_vector (11 downto 0);
	crc_en , rst, clk       : in    std_logic;
	crc_out                 : out   std_logic_vector (11 downto 0));
end component;
---------------------------------------------------------
---------------------------------------------------------
Begin
---------------------------------------------------------
---------------------------------------------------------
--Описание компонент
---------------------------------------------------------
--модуль генерации TRS кодов для IMX

TRS_gen_q           : TRS_gen                    
generic map (bit_data) 
port map (
    CLK			    => clk_in,		
    TRS_SYNC_3FF    => TRS_SYNC_3FF,
    TRS_SYNC_0      => TRS_SYNC_0  ,
    TRS_F0_V0_H0    => TRS_F0_V0_H0,
    TRS_F0_V0_H1    => TRS_F0_V0_H1,
    TRS_F0_V1_H0    => TRS_F0_V1_H0,
    TRS_F0_V1_H1    => TRS_F0_V1_H1
);
---------------------------------------------------------
noise_gen_0: noise_gen                    
port map (
	data_in		=>	Pix_per_line(7 downto 0) & Line_per_frame(3 downto 0),			
	crc_en		=>	'1' ,
	rst			=>	frame_flag,		
	clk			=>	clk_in,
	crc_out		=>	noise_gen_arch
    );
---------------------------------------------------------
--выбор типа данных
Process(clk_in)
begin
   if rising_edge(clk_in) then
        -- if (VALID_DATA) then
            case Switcher_for_type_of_data is
                when "0000" => data_from_switcher <= Pix_per_line(9 downto 2);
                when "0001" => data_from_switcher <= Line_per_frame(7 downto 0);
                when "0010" => data_from_switcher <= noise_gen_arch(10 downto 3);
                when "0100" => data_from_switcher <= Pix_per_line(7 downto 0);
                when others => data_from_switcher <= Pix_per_line(9 downto 2); 
            end case;
        -- else
        --     data_from_switcher <= (others => '0');
        -- end if;
    end if;
end process;
---------------------------------------------------------
--Выделение активной части кадра

---------------------------------------------------------
-- вставка синхро кодов TRS к передаваемую последовательность, выделение активной части
---------------------------------------------------------
--Проверка активной части кадра по вертикали
-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--     if to_integer(unsigned(Line_per_frame)) >= BION_960_960p30.VsyncShift and  to_integer(unsigned(Line_per_frame)) < BION_960_960p30.VsyncShift + BION_960_960p30.ActivePixPerLine then
--         Active_lines_flag <= '1';
--     else 
--         Active_lines_flag <= '0';
--     end if;
-- end if;
-- end process;
-- ---------------------------------------------------------
-- --флаги для синхро кодов в начале строки
-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--                 -------------------
--     if  to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift - 1 * N_channel        and 
--         to_integer(unsigned(Pix_per_line)) <= BION_960_960p30.HsyncShift - 1 * (N_channel - 1)  and 
--         Active_lines_flag = '1'    then
--                 -------------------
--         BION_sync_flag_start_1 <= '1';   else   BION_sync_flag_start_1 <= '0';         end if;
--                 -------------------
--     if  to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift - 2 * N_channel and 
--         to_integer(unsigned(Pix_per_line)) <= BION_960_960p30.HsyncShift - 2 * (N_channel - 1) and
--         Active_lines_flag = '1'      then
--                 -------------------
--         BION_sync_flag_start_2 <= '1';   else   BION_sync_flag_start_2 <= '0';         end if;
--                 -------------------
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift - 3      then     BION_sync_flag_start_3 <= '1';   else   BION_sync_flag_start_3 <= '0';         end if;
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift - 4      then     BION_sync_flag_start_4 <= '1';   else   BION_sync_flag_start_4 <= '0';         end if;
-- end if;
-- end process;
-- ---------------------------------------------------------

-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--     if acvive Line_per_frame then
--         case to_integer(unsigned(Pix_per_line)) is
--             when BION_960_960p30.HsyncShift - 1	=>	BION_sync_flag_start_1 <= '1';
--             when BION_960_960p30.HsyncShift - 2	=>	BION_sync_flag_start_1 <= '1';
-- 		    when others 		=>	DATA_IMX_OUT_in <= data_imx_anc;	VALID_DATA<='0';
-- 	end case ;

-- end if;

-- end if;
-- end process;

-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 0 then BION_sync_flag_end_1 <= '1'; else BION_sync_flag_end_1 <= '0'; end if;
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 1 then BION_sync_flag_end_2 <= '1'; else BION_sync_flag_end_2 <= '0'; end if;
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 2 then BION_sync_flag_end_3 <= '1'; else BION_sync_flag_end_3 <= '0'; end if;
--     if to_integer(unsigned(Pix_per_line)) = BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 3 then BION_sync_flag_end_4 <= '1'; else BION_sync_flag_end_4 <= '0'; end if;
-- end if;
-- end process;
-- ---------------------------------------------------------
-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--     if to_integer(unsigned(Pix_per_line)) >= BION_960_960p30.HsyncShift and to_integer(unsigned(Pix_per_line)) < BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine then

--     end if;
-- end if;
-- end process;

-- Process(clk_in)
-- begin
-- if rising_edge(clk_in) then
--     data_imx_anc	<= std_logic_vector(to_unsigned(0,bit_data_CSI));

-- end if;
-- end process;
---------------------------------------------------------
-- вставка синхро кодов TRS к передаваемую последовательность, выделение активной части
---------------------------------------------------------
Process(clk_in)
begin
if rising_edge(clk_in) then
	data_imx_anc	<=std_logic_vector(to_unsigned(2, bit_data_cam));
    if (to_integer(unsigned (Line_per_frame)) >= BION_960_960p30.VsyncShift) and 
        (to_integer(unsigned (Line_per_frame)) < BION_960_960p30.ActiveLine + BION_960_960p30.VsyncShift) then
                --------------------
        if      to_integer(unsigned (Pix_per_line)) = BION_960_960p30.HsyncShift - 1  or
                to_integer(unsigned (Pix_per_line)) = BION_960_960p30.HsyncShift - 2 then
                -------------------
            data_out_from_cam_in <= TRS_F0_V0_H0;
            VALID_DATA  <='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 3 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 4 then
                -------------------
            data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA  <='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 5 or
            	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 6 then
                -------------------
        	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA  <='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 7 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 8 then
                -------------------
        	data_out_from_cam_in <= TRS_SYNC_3FF;
            VALID_DATA  <='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	>= BION_960_960p30.HsyncShift and 
                to_integer(unsigned (Pix_per_line)) < BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine	then
                -------------------
        	data_out_from_cam_in <= data_from_switcher;
            VALID_DATA<='1';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine 	or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 1 then
                -------------------
        	data_out_from_cam_in <= TRS_SYNC_3FF;
            VALID_DATA  <='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 2 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 3 then
                -------------------
        	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA  <='0';
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 4 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 5 then
                -------------------
        	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA  <='0';
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 6 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 7 then
                -------------------
        	data_out_from_cam_in <= TRS_F0_V0_H1;
            VALID_DATA<='0';
        else
            data_out_from_cam_in <= data_imx_anc;
            VALID_DATA<='0';
        end if;
    else	
                -------------------
        if 	    to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 1 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 2 then
                -------------------
         	data_out_from_cam_in <= TRS_F0_V1_H0;
            VALID_DATA<='0';
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 3 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 4 then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA<='0';
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 5 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 6 then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA<='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 7 or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift - 8 then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_3FF;			
            VALID_DATA<='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 1	or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 2	then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_3FF;
            VALID_DATA<='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 3	or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 4	then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA<='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 5	or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 6	then
                -------------------
         	data_out_from_cam_in <= TRS_SYNC_0;
            VALID_DATA<='0';
                -------------------
        elsif	to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 7	or
                to_integer(unsigned (Pix_per_line))	= BION_960_960p30.HsyncShift + BION_960_960p30.ActivePixPerLine + 8	then
                -------------------
         	data_out_from_cam_in <= TRS_F0_V1_H1;
            VALID_DATA<='0';
        else
            data_out_from_cam_in <= data_imx_anc;
            VALID_DATA<='0';
        end if;
    end if;
end if;
end process;
---------------------------------------------------------
--Разложение пакетов на две линии
-- Process(clk_in)
-- begin
--     if rising_edge(clk_in) then
--         databus_buffer <= data_from_switcher;
--     end if;
-- end process;
---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
data_out_from_cam <= data_out_from_cam_in;
---------------------------------------------------------
---------------------------------------------------------
end data_generation_cam_arch;

