-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "06/24/2020 23:08:22"
                                                            
-- Vhdl Test Bench template for design  :  generate_signal
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY generate_signal_vhd_tst IS
END generate_signal_vhd_tst;
ARCHITECTURE generate_signal_arch OF generate_signal_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk_in : STD_LOGIC := '0';
SIGNAL databus : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
SIGNAL Dvalid : STD_LOGIC := '0';
SIGNAL Fvalid : STD_LOGIC := '0';
SIGNAL PCLK : STD_LOGIC := '0';
SIGNAL reset : STD_LOGIC := '0';
COMPONENT generate_signal
	PORT (
	clk_in : IN STD_LOGIC;
	databus : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	Dvalid : OUT STD_LOGIC;
	Fvalid : OUT STD_LOGIC;
	PCLK : OUT STD_LOGIC;
	reset : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : generate_signal
	PORT MAP (
-- list connections between master ports and signals
	clk_in => clk_in,
	databus => databus,
	Dvalid => Dvalid,
	Fvalid => Fvalid,
	PCLK => PCLK,
	reset => reset
	);
                                        
                                                       
     clk_in <= not clk_in after 5 ns;  -- code executes for every event on sensitivity list  
                                          
END generate_signal_arch;

