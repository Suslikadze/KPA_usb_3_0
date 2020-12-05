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
   Line_per_frame_cam       : in        STD_LOGIC_VECTOR(Bitness_camera_sim             - 1 downto 0);
   pix_active_cam           : in        STD_LOGIC;
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
signal  address_write,
        address_read                  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');

signal  en_read                       : STD_LOGIC_VECTOR(7 downto 0);

signal  en_write_1,
        en_write_2`         : STD_LOGIC;

signal  data_from_memory_1,
        data_from_memory_2,
        data_from_memory_3,
        data_from_memory_4,
        data_from_memory_5,
        data_from_memory_6,
        data_from_memory_7,
        data_from_memory_8  : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

---------------------------------------------------------
--Выделение памяти для храниния строк от разных камер (по два на каждую)
---------------------------------------------------------
RAM_1_1               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(0),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_1
);
--------------
RAM_2_1               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_2,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(1),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_2
);
--------------
RAM_3_1               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_3,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(2),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_3
);
--------------
RAM_4_1               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_4,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(3),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_1,
    q           =>  data_from_memory_4
);
--------------
RAM_1_2               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(4),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_5
);
--------------
RAM_2_2               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(5),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_6
);
--------------
RAM_3_2               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(6),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_7
);
--------------
RAM_4_2               : Entity work.RAM_2_port
Port map(
    data        =>  data_ch_1,
    rdaddress   =>  address_read,
    rdclock     =>  clk_interface,
    rden        =>  en_read(7),
    wraddress   =>  address_write,
    wrclock     =>  clk_cam,
    wren        =>  en_write_2,
    q           =>  data_from_memory_8
);

---------------------------------------------------------
--Инкрементирование шин адресов
---------------------------------------------------------
Process(clk_cam)
begin
If rising_edge(clk_cam) then
    if (address_write < 1024) then
        address_write <= address_write + 1;
    else
        address_write <= 0;
    end if;
end if;
end process;
------------------
Process(clk_interface)
BEGIN
If rising_edge(clk_interface) then
    If (address_read < 1024) then
        address_read <= address_read + 1;
    else
        address_read <= 0;
    end if;  
end if;
end process;
---------------------------------------------------------
--Обработка сигналов разрешений записи и чтения для блоков памяти
--Объединение 4-х каналов в одну выходную шину
---------------------------------------------------------
Process(clk_interface)
begin
If rising_edge(clk_interface) then
    en_write_1  <= Line_per_frame_cam(2) and pix_active_cam;
    en_write_2  <= not Line_per_frame_cam(2) and pix_active_cam;
    if (str_active_cam) then
        case (Line_per_frame_cam(2 downto 0)) is
            when "000" =>   en_read         <= "00000001";
                            data_out_signal <= data_from_memory_1; 
            when "001" =>   en_read         <= "00000010";
                            data_out_signal <= data_from_memory_2;
            when "010" =>   en_read         <= "00000100";
                            data_out_signal <= data_from_memory_3;
            when "011" =>   en_read         <= "00001000";
                            data_out_signal <= data_from_memory_4;
            when "100" =>   en_read         <= "00010000";
                            data_out_signal <= data_from_memory_5;
            when "101" =>   en_read         <= "00100000";
                            data_out_signal <= data_from_memory_6;
            when "110" =>   en_read         <= "01000000";
                            data_out_signal <= data_from_memory_7;
            when "111" =>   en_read         <= "10000000";
                            data_out_signal <= data_from_memory_8;
        end case;
    end if;
end if;
end process;

---------------------------------------------------------
--Асинхронное присвоение сигналов выходным шинам
---------------------------------------------------------
data_out        <=  data_out;
---------------------------------------------------------

---------------------------------------------------------
end Data_processing_interface_arch;