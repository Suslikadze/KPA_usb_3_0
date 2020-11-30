--------------------------------------------------------------------------------
--
--   FileName:         debounce.vhd
--   Dependencies:     none
--   Design Software:  Quartus Prime Version 17.0.0 Build 595 SJ Lite Edition
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 2.0 6/28/2019 Scott Larson
--     Added asynchronous active-low reset
--     Made stable time higher resolution and simpler to specify
--   Version 1.0 3/26/2012 Scott Larson
--     Initial Public Release
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY debounce IS
  GENERIC(
    clk_freq    : INTEGER := 5000;  --system clock frequency in Hz
    stable_time : INTEGER := 10);         --time button must remain stable in ms
  PORT(
    clk     : IN  STD_LOGIC;  --input clock
    reset_n : IN  STD_LOGIC;  --asynchronous active low reset
    button  : IN  STD_LOGIC;  --input signal to be debounced
    push_out : out STD_LOGIC
    --counter_out     : out STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
  --  result  : OUT STD_LOGIC); --debounced signal
END debounce;

ARCHITECTURE logic OF debounce IS
  SIGNAL flipflops   : STD_LOGIC_VECTOR(1 DOWNTO 0); --input flip flops
  SIGNAL counter_set : STD_LOGIC;                    --sync reset to zero
  signal counter     : STD_LOGIC_VECTOR(3 DOWNTO 0);
   signal prev_result,
         result      : STD_LOGIC;
  signal push_signal  : STD_LOGIC;
BEGIN

  counter_set <= flipflops(0) xor flipflops(1);  --determine when to start/reset counter
  
  PROCESS(clk, reset_n)
    VARIABLE count :  INTEGER RANGE 0 TO clk_freq*stable_time;  --counter for timing
  BEGIN
    IF(reset_n = '0') THEN                        --reset
      flipflops(1 DOWNTO 0) <= "00";                 --clear input flipflops
      prev_result <= '0';  
      -- push_signal <= '0';                               --clear result register
    ELSIF(clk'EVENT and clk = '1') THEN           --rising clock edge
      flipflops(0) <= button;                        --store button value in 1st flipflop
      flipflops(1) <= flipflops(0);                  --store 1st flipflop value in 2nd flipflop
      If(counter_set = '1') THEN                     --reset counter because input is changing
        count := 0;
        -- push_signal <= '0';                                    --clear the counter
      ELSIF(count < clk_freq*stable_time ) THEN  --stable input time is not yet met
        count := count + 1;                            --increment counter
      ELSE                                           --stable input time is met
        prev_result <= flipflops(1);  
        -- push_signal <= '1';                      --output the stable value
      END IF;    
    END IF;
  END PROCESS;



Process(clk)
BEGIN
  if rising_edge(clk) then
    result <= prev_result;
    push_signal <= prev_result and not result;
  end if;
end process;

  push_out <= push_signal;
-- process(push_signal)
-- BEGIN
--   if push_signal'event and push_signal = '1' then
--     push_out <= '1';
  
--     push_out <= '0';  
--   end if;
-- end process;
--  counter_out <= counter;

END logic;
