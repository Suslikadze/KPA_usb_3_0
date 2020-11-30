library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package   VIDEO_CONSTANTS	is

constant bit_pix				: integer := 12;	--разрядность счетчика пикселей		
constant bit_strok				: integer := 12;	--разрядность счетчика строк
constant bit_frame				: integer := 8;
constant bit_data				: integer := 8;
constant bit_data_out			: integer := 32;
constant bit_counter_data		: integer := 4;

---------------------------------------------------------------------------------
type VideoStandartType is record
	PixPerLine,
	ActivePixPerLine,
	InActivePixPerLine,
	HsyncWidth,
	HsyncWidthGapLeft,
	HsyncWidthGapRight,
	HsyncShift,
	LinePerFrame,
	ActiveLine,
	InActiveLine,
	VsyncWidth,
	VsyncShift	:integer;
end record;
							

							------------------------------------------
							-------------CUSTOM RESOLUTION------------
							------------------------------------------
constant BION_960_960p30 :	VideoStandartType:=	(	
													PixPerLine				=>	700,
													ActivePixPerLine		=>	512,	
													InActivePixPerLine		=>	40,	
													HsyncWidth				=>	10,	
													HsyncWidthGapLeft		=>	15,	
													HsyncWidthGapRight		=>	15,	
													HsyncShift				=>	24,
													LinePerFrame			=>	500,
													ActiveLine				=>	256,
													InActiveLine			=>	65,
													VsyncWidth				=>	5,	
													VsyncShift				=>	1);	

end package ;
