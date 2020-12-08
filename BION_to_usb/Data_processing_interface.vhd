library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 





entity Data_processing_interface is
Port(
   clk_cam                  : in        STD_LOGIC;
   clk_interface            : in        STD_LOGIC;
   reset                    : in        STD_LOGIC;
   data_ch_1                : in        STD_LOGIC_VECTOR(bit_data                       - 1 downto 0);
   data_ch_2                : in        STD_LOGIC_VECTOR(bit_data                       - 1 downto 0);
   data_ch_3                : in        STD_LOGIC_VECTOR(bit_data                       - 1 downto 0);
   data_ch_4                : in        STD_LOGIC_VECTOR(bit_data                       - 1 downto 0);
   Pix_per_line_interface   : in        STD_LOGIC_VECTOR(Bitness_interface.bit_pix      - 1 downto 0);
   Line_per_frame_interface : in        STD_LOGIC_VECTOR(Bitness_interface.bit_strok    - 1 downto 0);
   Pix_per_line_cam         : in        STD_LOGIC_VECTOR(Bitness_camera.bit_pix         - 1 downto 0);
   Line_per_frame_cam       : in        STD_LOGIC_VECTOR(Bitness_camera.bit_strok       - 1 downto 0);
   pix_active_cam           : in        STD_LOGIC;
   pix_active_interface     : in        STD_LOGIC;
   frame_in_interface       : in        STD_LOGIC;
   data_out                 : out       STD_LOGIC_VECTOR(7 downto 0)
);
end Data_processing_interface;
---------------------------------------------------------
---------------------------------------------------------
architecture Data_processing_interface_arch of Data_processing_interface is
---------------------------------------------------------
---------------------------------------------------------
--Работа с блоками памяти
signal  address_write                 : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
signal  address_read                  : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');

signal  en_read                       : STD_LOGIC_VECTOR(7 downto 0);

signal  en_write_1,
        en_write_2                    : STD_LOGIC;

signal  data_from_memory_1,
        data_from_memory_2,
        data_from_memory_3,
        data_from_memory_4,
        data_from_memory_5,
        data_from_memory_6,
        data_from_memory_7,
        data_from_memory_8  : STD_LOGIC_VECTOR(bit_data - 1 downto 0);

signal data_out_signal      : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Выделение памяти для храниния строк от разных камер (по два на каждую)
---------------------------------------------------------
RAM_1_1               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(0),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_1
);
--------------
RAM_2_1               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_2,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(1),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_2
);
--------------
RAM_3_1               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_3,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(2),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_3
);
--------------
RAM_4_1               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_4,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(3),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_4
);
--------------
RAM_1_2               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(4),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_5
);
--------------
RAM_2_2               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_2,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(5),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_6
);
--------------
RAM_3_2               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_3,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(6),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_7
);
--------------
RAM_4_2               : Entity work.RAM_2_ports
Port map(
    data        =>  data_ch_4,
    rdaddress   =>  address_read(9 downto 0),
    rdclock     =>  clk_interface,
    rden        =>  en_read(7),
    wraddress   =>  address_write(9 downto 0),
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_8
);

---------------------------------------------------------
--Инкрементирование шин адресов
---------------------------------------------------------
count_address_write             : entity work.count_n_modul
Generic map(11)
Port map(
    clk		    => clk_cam,
    reset	    => '0',
    en		    => pix_active_cam,
    modul	    => std_logic_vector(to_unsigned(1024, 11)),
    qout	    => address_write
);
-------------------------
count_address_read              : entity work.count_n_modul
Generic map(11)
Port map(
    clk		    => clk_interface,
    reset	    => '0',
    en		    => pix_active_interface,
    modul	    => std_logic_vector(to_unsigned(1024, 11)),
    qout	    => address_read
);
---------------------------------------------------------
--Обработка сигналов разрешений записи и чтения для блоков памяти
--Объединение 4-х каналов в одну выходную шину
---------------------------------------------------------
Process(clk_interface)
begin
If rising_edge(clk_interface) then
    en_write_1  <= Line_per_frame_cam(0) and pix_active_cam;
    en_write_2  <= not Line_per_frame_cam(0) and pix_active_cam;
    -- if (pix_active_cam) then
    --     case (Line_per_frame_cam(2 downto 0)) is
    --         when "000" =>   en_read         <= "00000001";
    --                         data_out_signal <= data_from_memory_1; 
    --         when "001" =>   en_read         <= "00000010";
    --                         data_out_signal <= data_from_memory_2;
    --         when "010" =>   en_read         <= "00000100";
    --                         data_out_signal <= data_from_memory_3;
    --         when "011" =>   en_read         <= "00001000";
    --                         data_out_signal <= data_from_memory_4;
    --         when "100" =>   en_read         <= "00010000";
    --                         data_out_signal <= data_from_memory_5;
    --         when "101" =>   en_read         <= "00100000";
    --                         data_out_signal <= data_from_memory_6;
    --         when "110" =>   en_read         <= "01000000";
    --                         data_out_signal <= data_from_memory_7;
    --         when "111" =>   en_read         <= "10000000";
    --                         data_out_signal <= data_from_memory_8;
    --     end case;
    -- end if;
end if;
end process;

Process(clk_interface)
begin
if rising_edge(clk_interface) then
    if (pix_active_cam = '1') then
        if (en_write_1 = '1') then
            if      (to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine) then
                en_read         <= "00000001";
                data_out_signal <= data_from_memory_1;
            ---------------------
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine and  
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine*2) then
            ---------------------
                en_read         <= "00000010";
                data_out_signal <= data_from_memory_2;
            ---------------------
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine*2 and
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine *3) then
                en_read         <= "00000100";
                data_out_signal <= data_from_memory_3;
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine*3 and
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine*4) then
                en_read         <= "00001000";
                data_out_signal <= data_from_memory_4;
            end if;
        elsif (en_write_2 = '1') then
            if      ( to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine) then
                en_read         <= "00010000";
                data_out_signal <= data_from_memory_5;
            ---------------------
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine and  
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine*2) then
            ---------------------
                en_read         <= "00100000";
                data_out_signal <= data_from_memory_6;
            ---------------------
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine*2 and
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine *3) then
                en_read         <= "01000000";
                data_out_signal <= data_from_memory_7;
            elsif   (to_integer(unsigned(Pix_per_line_interface)) >= KPA_camera_sim.ActivePixPerLine*3 and
                    to_integer(unsigned(Pix_per_line_interface)) < KPA_camera_sim.ActivePixPerLine*4) then
                en_read         <= "10000000";
                data_out_signal <= data_from_memory_8;
            end if;
        end if;
    else
        en_read <= (others => '0');
    end if;
end if;
end process;
---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
data_out        <=  data_out_signal;
---------------------------------------------------------

---------------------------------------------------------
end Data_processing_interface_arch;