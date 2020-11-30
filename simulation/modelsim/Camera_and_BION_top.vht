-- Copyright (C) 2019  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "10/19/2020 13:56:39"
                                                            
-- Vhdl Test Bench template for design  :  Camera_and_BION_top
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Camera_and_BION_top_vhd_tst IS
END Camera_and_BION_top_vhd_tst;
ARCHITECTURE Camera_and_BION_top_arch OF Camera_and_BION_top_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk_in : STD_LOGIC := '0';
SIGNAL databus : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL Switcher      : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL reset : STD_LOGIC := '0';
SIGNAL A : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL FLAGA : STD_LOGIC := '0';
SIGNAL FLAGB : STD_LOGIC := '0';
SIGNAL FLAGC : STD_LOGIC;
SIGNAL FLAGD : STD_LOGIC;
SIGNAL out1 : STD_LOGIC;
SIGNAL out2 : STD_LOGIC;
SIGNAL out3 : STD_LOGIC;
SIGNAL out4 : STD_LOGIC;
SIGNAL PCLK : STD_LOGIC;
SIGNAL pktend : STD_LOGIC;
SIGNAL reset_FX : STD_LOGIC;
SIGNAL slcs : STD_LOGIC;
SIGNAL sloe : STD_LOGIC;
SIGNAL slrd : STD_LOGIC;
SIGNAL slwr : STD_LOGIC;
--машинный автомат
type State_type is(
	idle,
	FLAGB_on,
	FLAGA_on,
	FLAGB_off,
	FLAGA_off
);
signal state						: State_type;
signal reset_tsb					: std_logic := '0';
--------
signal clk_for_arch					: STD_LOGIC;
constant	size_FIFO_FX	: integer := 4096;
---------------------------------------------------------
COMPONENT Camera_and_BION_top
	PORT (
	clk_in 					: IN STD_LOGIC;
	reset 					: IN STD_LOGIC;
	FLAGA                   : IN    STD_LOGIC;
    FLAGB                   : IN    STD_LOGIC;
    FLAGC                   : IN    STD_LOGIC;
    FLAGD                   : IN    STD_LOGIC;
    PCLK                    : out   STD_LOGIC;
    slwr                    : out   STD_LOGIC;
    slcs                    : out   STD_LOGIC;
    sloe                    : out   STD_LOGIC;
    slrd                    : out   STD_LOGIC;
    pktend                  : out   STD_LOGIC;
    A                       : out   STD_LOGIC_VECTOR(1 downto 0);
    Switcher                : in	STD_LOGIC_VECTOR(3 downto 0);
    reset_FX                : out   STD_LOGIC;
    out1                    : out   std_logic;
    out2                    : out   std_logic;
    out3                    : out   std_logic;
    out4                    : out   std_logic;
	databus 				: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
---------------------------------------------------------
---------------------------------------------------------
BEGIN
---------------------------------------------------------
---------------------------------------------------------
i1 : Camera_and_BION_top
PORT MAP (
	clk_in 	=> clk_in,
	databus => databus,
	reset 	=> reset,
	A => A,
	FLAGA => FLAGA,
	FLAGB => FLAGB,
	FLAGC => FLAGC,
	FLAGD => FLAGD,
	out1 => out1,
	out2 => out2,
	out3 => out3,
	out4 => out4,
	PCLK => PCLK,
	Switcher => Switcher,
	pktend => pktend,
	reset_FX => reset_FX,
	slcs => slcs,
	sloe => sloe,
	slrd => slrd,
	slwr => slwr
);
---------------------------------------------------------
---------------------------------------------------------
init : process
BEGIN
	reset_tsb <= '1' after 5 ns;
	reset_tsb <= '0' after 5 ns;
	wait;
end process;
---------------------------------------------------------
Process(PCLK, reset_tsb) 
variable counter, counter_in_FLAGB_on		: integer;
BEGIN

	If (reset_tsb) then
		state <= idle;
	end if;
	if rising_edge(PCLK) then
		case state is
			when idle => 
				FLAGA <= '0';
				FLAGB <= '0';
				state <= FLAGB_on;
				counter := 0;
				counter_in_FLAGB_on := 0;
			when FLAGB_on =>
				FLAGB <= '1';
				if counter_in_FLAGB_on < 2 then
					counter_in_FLAGB_on := counter_in_FLAGB_on + 1;
				else
					counter_in_FLAGB_on := 0;
					state <= FLAGA_on;
				end if;
			When FLAGA_on =>
				FLAGA <= '1';
				if (slwr = '0') then
					if (counter < size_FIFO_FX - 3) then
						counter := counter + 1;
					else
						state <= FLAGB_off;
						counter := counter + 1;
					end if;----
				end if; 
			when FLAGB_off =>
				FLAGB <= '0';
				if (slwr = '0') then
					if (counter < size_FIFO_FX) then
						counter := counter + 1;
					else
						state <= FLAGA_off;
						counter := counter + 1;
					end if;
				end if;
			when FLAGA_off =>
				FLAGA <= '0';
				if (counter <= size_FIFO_FX + 25) then
					counter := counter + 1;
				else
					state <= idle;
				end if;
		end case;
	end if;
end process;
---------------------------------------------------------
reset <= '0';
clk_in <= not clk_in after 5 ns;
Switcher <= "0100";  -- code executes for every event on sensitivity list  
---------------------------------------------------------                                    
END Camera_and_BION_top_arch;
