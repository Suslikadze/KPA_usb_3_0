library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity count_n_modul is
generic (n: integer);
port (
	clk		:	in std_logic;
	reset	:	in std_logic;
	en		:	in std_logic;
  	modul	: 	in std_logic_vector (n-1 downto 0);
   	qout	: 	out std_logic_vector (n-1 downto 0);
   	cout	: 	out std_logic
	);	
end;

architecture beh of count_n_modul is 
signal qint : std_logic_vector (n-1 downto 0) := (others => '0');
begin



process(clk,en,reset)
begin
	if reset='1' 
		then qint<=(others => '0');
	elsif rising_edge(clk) then
		if  en='1' then 
			if 		to_integer(unsigned (qint))= to_integer(unsigned (modul))-1  then 
				qint<= std_logic_vector(to_unsigned(0,n)) ;	
				cout<='0';
			elsif 	to_integer(unsigned (qint))= to_integer(unsigned (modul))-2  then 
				cout<='1';
				qint<= std_logic_vector(to_unsigned( to_integer(unsigned (qint))+1,n));
			else
				cout<='0';
				qint<= std_logic_vector(to_unsigned( to_integer(unsigned (qint))+1,n));				
			end if;
		end if;
	qout<=qint;

   end if;

end process;
end;