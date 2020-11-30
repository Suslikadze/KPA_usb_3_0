library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.VIDEO_CONSTANTS.all;


entity synth is
port(
    clk_in           :in std_logic;
    FLAG             :in std_logic_vector(3 downto 0);
    clk_out_high     :out std_logic;
    clk_out_low      :out std_logic;
    clk_fast_rd      :out std_logic  
);
end synth;
---------------------------------------------------------
architecture arch of synth is
---------------------------------------------------------
signal counter              : std_logic_vector(6 downto 0);
signal clk_high             : std_logic;

signal divider1, divider2   : std_logic;
signal gate_open            : std_logic;
---------------------------------------------------------
component PLL
   PORT
      (
         inclk0		: IN STD_LOGIC  ;
         c0		    : OUT STD_LOGIC ;
         c1         : OUT std_logic ;
         locked		: OUT STD_LOGIC 
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
begin
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
PLL_01                  : PLL
Port map(
   inclk0   => clk_in,
   c0       => clk_high,
   c1       => clk_fast_rd
);
---------------------------------------------------------
counter_for_pix      : count_n_modul
generic map(7)
Port map(
   clk      => clk_high,
   reset    => '0',
   en       => '1',
   modul    => std_logic_vector(to_unsigned(64, 7)),
   qout     => counter
);
---------------------------------------------------------
process(clk_high) 
begin
    if rising_edge(clk_high) then
        case FLAG is
            when "0001" =>      divider1 <= counter(0);     divider2 <= counter(1);      gate_open <= '0'; 
            when "0010" =>      divider1 <= counter(1);     divider2 <= counter(2);      gate_open <= '0';
            when "0100" =>      divider1 <= counter(2);     divider2 <= counter(3);      gate_open <= '0';
            when "1000" =>      divider1 <= counter(3);     divider2 <= counter(4);      gate_open <= '0';
            when others =>      gate_open <= '1';
        end case;
    end if;
end process;
---------------------------------------------------------
process(gate_open, divider1, divider2, clk_high, counter)
begin
--     if rising_edge(clk_high) then
        if (gate_open = '0') then
            clk_out_high <= divider1;
            clk_out_low <=  divider2;
        else 
            clk_out_high <= clk_high;
            clk_out_low  <= not counter(1);
        end if;
    -- end if;
end process;
---------------------------------------------------------
end arch;