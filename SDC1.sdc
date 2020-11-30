derive_pll_clocks


create_clock -name clk_in 		-period 50.0MHz  	[get_ports clk_in]
    create_generated_clock -source {synth_clk|PLL_01|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 2 -duty_cycle 50.00 -name {synth_clk|PLL_01|altpll_component|auto_generated|pll1|clk[0]} {synth_clk|PLL_01|altpll_component|auto_generated|pll1|clk[0]}
    create_generated_clock -source {synth_clk|PLL_01|altpll_component|auto_generated|pll1|inclk[0]} -duty_cycle 50.00 -name {synth_clk|PLL_01|altpll_component|auto_generated|pll1|clk[1]} {synth_clk|PLL_01|altpll_component|auto_generated|pll1|clk[1]}