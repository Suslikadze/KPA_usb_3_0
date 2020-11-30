library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all; 

entity two_channel_output_serial is
Port(
    clk_fast            : IN    STD_LOGIC;
    clk_slow            : IN    STD_LOGIC;
    Pix_per_line        : IN     STD_LOGIC_VECTOR(bit_pix - 1 downto 0);
    Line_per_frame      : IN     STD_LOGIC_VECTOR(bit_strok - 1 downto 0);
    reset               : IN    STD_LOGIC;
    enable              : IN    STD_LOGIC;
    data_in             : IN    STD_LOGIC_VECTOR(bit_data - 1 downto 0);
    data_out_1          : OUT   STD_LOGIC;
    data_out_2          : OUT   STD_LOGIC
);
end two_channel_output_serial;
---------------------------------------------------------
---------------------------------------------------------
architecture two_channel_output_serial_arch of two_channel_output_serial is
---------------------------------------------------------
---------------------------------------------------------
--Распараллеливание на два канала
signal data_channel_1_par, data_channel_2_par   : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_buffer                              : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
signal data_channel_1_ser, data_channel_2_ser   : STD_LOGIC;
--Сериализатор
signal load                                     : STD_LOGIC;
signal counter                                  : STD_LOGIC_VECTOR(4 downto 0);
---------------------------------------------------------
--Объявление компонент
component parall_to_serial
generic( bit_data   : integer);
PORT(
    dir        : in STD_LOGIC;
    ena        : in STD_LOGIC;
    clk        : in STD_LOGIC;
    data       : in std_logic_vector(bit_data-1 downto 0);
    load       : in STD_LOGIC;
    shiftout   : out STD_LOGIC
);
end component;
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
--Задержка данных для первого канала на один такт, асинхронное присвоение значений сигналам на вход сериализатора
Process(clk_slow)
BEGIN
If rising_edge(clk_slow) then
    data_buffer <= data_in;
    IF Pix_per_line(0)='0' then
        data_channel_1_par  <= data_buffer;
        data_channel_2_par  <= data_in;
    -- else
    --     data_channel_1_par  <= data_in;
    --     data_channel_2_par  <= data_buffer; 
    end if;



    -- if (to_integer(unsigned (counter)) = 14) then
    --     data_channel_1_par <= data_buffer;
    --     data_channel_2_par <= data_in;
    -- elsif (to_integer(unsigned(counter)) = 0 or to_integer(unsigned(counter)) = 8) then
    --     data_buffer <= data_in;
    -- end if;
end if;
end process;
---------------------------------------------------------
--Описание компонент
count_for_load              : count_n_modul
generic map(4)
port map(
---------in-----------
   clk          => clk_fast,
   reset        => reset,
   en           => enable,
   modul        => std_logic_vector(to_unsigned(8,4)),  
---------out----------
   cout         => load
);
---------------------------------------------------------
-- count_for_two_chanel              : count_n_modul
-- generic map(5)
-- port map(
-- ---------in-----------
--    clk          => clk_fast,
--    reset        => reset,
--    en           => enable,
--    modul        => std_logic_vector(to_unsigned(16,5)),  
-- ---------out----------
--    qout         => counter
-- );
---------------------------------------------------------
parall_to_serial_1          : parall_to_serial
generic map(bit_data)
port map(
---------in-----------
    dir         =>  '1',
    ena         =>  enable,
    clk         =>  clk_fast,
    data        =>  data_channel_1_par,
    load        =>  load,
---------out----------  
    shiftout    =>  data_channel_1_ser
);
---------------------------------------------------------
parall_to_serial_2          : parall_to_serial
generic map(bit_data)
port map(
---------in-----------
    dir         =>  '1',
    ena         =>  enable,
    clk         =>  clk_fast,
    data        =>  data_channel_2_par,
    load        =>  load,
---------out----------  
    shiftout    =>  data_channel_2_ser
);
---------------------------------------------------------
--Асинхронное присвоение сигналам на выход
data_out_1 <= data_channel_1_ser;
data_out_2 <= data_channel_2_ser;
---------------------------------------------------------
---------------------------------------------------------
end two_channel_output_serial_arch;