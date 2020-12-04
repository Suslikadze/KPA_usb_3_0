library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all;




entity Data_gen_cam is
Port(
    clk_in          : in        STD_LOGIC;
    reset           : in        STD_LOGIC;
    enable_cam      : in        STD_LOGIC;
    Pix_per_line    : in        STD_LOGIC_VECTOR(Bitness_camera.bit_pix     - 1 downto 0);
    Line_per_frame  : in        STD_LOGIC_VECTOR(Bitness_camera.bit_strok   - 1 downto 0);
    Type_of_data    : in        STD_LOGIC_VECTOR(                             7 downto 0);
    data_out        : out       STD_LOGIC_VECTOR(bit_data                   - 1 downto 0);
    valid_data      : out       STD_LOGIC
);
end Data_gen_cam;
---------------------------------------------------------
---------------------------------------------------------
Architecture Data_gen_cam_arch of Data_gen_cam is
---------------------------------------------------------
---------------------------------------------------------
--выделение активной части кадра
signal str_active, pix_active          : STD_LOGIC;
signal valid_in                        : STD_LOGIC;
--Данные
signal data_from_pattern_gen           : STD_LOGIC_VECTOR(bit_data - 1 downto 0);
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------

------------------------------------------------------------
--Подсоединение экземпляра модуля генератора тестовых сигналов
------------------------------------------------------------
Pattern_generator_cam       : Entity work.PATHERN_GENERATOR 
Port map(
    ---------in-----------
    CLK             => clk_in,
    main_reset      => reset,
    ena_clk         => enable_cam,
    qout_clk        => Pix_per_line,
    qout_V          => Line_per_frame,
    mode_generator  => Type_of_data,
    data_in         => Pix_per_line(7 downto 0),
    ---------out----------
    data_out        => data_from_pattern_gen
);

------------------------------------------------------------
--Выделение активной части кадра
------------------------------------------------------------
Process(clk_in)
BEGIN
If rising_edge(clk_in) then
    if (to_integer(unsigned(Pix_per_line)) >= KPA_camera_sim.HsyncShift) and 
       (to_integer(unsigned(Pix_per_line)) <  KPA_camera_sim.ActivePixPerLine + KPA_camera_sim.HsyncShift) then
        pix_active <= '1';
    else
        pix_active <= '0';
    end if;
------------
    if (to_integer(unsigned(Line_per_frame)) >= KPA_camera_sim.VsyncShift) and 
       (to_integer(unsigned(Line_per_frame)) <  KPA_camera_sim.VsyncShift + KPA_camera_sim.ActiveLine then
        str_active <= '1';
    else
        str_active <= '0';
    end if;
end if;
end process;
------------------------------------------------------------
Process(clk_in)
BEGIN
if rising_edge(clk_in) then
    valid_in <= pix_active and str_active;
end if;
end process;
------------------------------------------------------------
Process(clk_in)
BEGIN
if rising_edge(clk_in) then
    if (valid_in) then
        data_out <= data_from_pattern_gen;
    else 
        data_out <= 0;
    end if;
end if;
end process;
------------------------------------------------------------
valid_data <= valid_in;
------------------------------------------------------------
end Data_gen_cam_arch;