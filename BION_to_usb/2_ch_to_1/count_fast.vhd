LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Параметризируемый N разрядный счетчик
-- qout |0  ||1  ||x  |____________|m-1||0  |....   m - это модуль (modul)
-- cout ___________________________|```|_________   сигнал переполнения

ENTITY count_fast IS
GENERIC (
   n     : INTEGER;
   modul : INTEGER
);
PORT (
clk, reset: IN std_logic;
qout : OUT std_logic_vector (n - 1 DOWNTO 0));

END;

ARCHITECTURE beh OF count_fast IS
SIGNAL qint : std_logic_vector (n - 1 DOWNTO 0);
SIGNAL cin : std_logic;


BEGIN

PROCESS (clk, reset)
BEGIN

IF reset='1' THEN
   qint <= (OTHERS => '0');
elsif rising_edge(clk)  THEN

   if qint = conv_std_logic_vector(modul, n) THEN
      qint <= conv_std_logic_vector(0, n);
   ELSE
      qint <= qint + conv_std_logic_vector(1, n);
   END IF;
END IF;

END PROCESS;

PROCESS (clk)
BEGIN
if rising_edge(clk)  THEN
   qout <= qint;
END IF;
END PROCESS;


END;