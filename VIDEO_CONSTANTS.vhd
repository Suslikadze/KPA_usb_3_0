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
---------------------------------------------------------------------------------
type Bitness_of_counters is record
	bit_pix,
	bit_strok,
	bit_frame	: integer;
end record;
---------------------------------------------------------------------------------
							------------------------------------------
							----------RESOLUTION TO CYPRESS-----------
							------------------------------------------
constant BION_960_960p30 :	VideoStandartType:=	(	
													PixPerLine				=>	2200,
													ActivePixPerLine		=>	2048,	
													InActivePixPerLine		=>	40,	
													HsyncWidth				=>	10,	
													HsyncWidthGapLeft		=>	15,	
													HsyncWidthGapRight		=>	15,	
													HsyncShift				=>	0,
													LinePerFrame			=>	2100,
													ActiveLine				=>	2048,
													InActiveLine			=>	65,
													VsyncWidth				=>	5,	
													VsyncShift				=>	1);	
							------------------------------------------
							------------BITNESS TO CYPRESS------------
							------------------------------------------
constant Bitness_camera : Bitness_of_counters:= (
	bit_pix			=> 12,
	bit_strok		=> 12,
	bit_frame		=> 3
);
							------------------------------------------
							----------RESOLUTION FROM CAMERA----------
							------------------------------------------
Constant KPA_camera_sim :	VideoStandartType:= (
													PixPerLine				=> 1200,
													ActivePixPerLine		=> 1024,
													InActivePixPerLine		=> 40,
													HsyncWidth				=> 10,
													HsyncWidthGapLeft		=> 15,
													HsyncWidthGapRight		=> 15,
													HsyncShift				=> 0,
													LinePerFrame			=> 1125,
													ActiveLine				=> 1024,
													InActiveLine			=> 65,
													VsyncWidth				=> 5,
													VsyncShift				=> 1);
end package;
							------------------------------------------
							------------BITNESS FROM CAMERA-----------
							------------------------------------------
constant Bitness_interface : Bitness_of_counters:= (
	bit_pix			=> 11,
	bit_strok		=> 11,
	bit_frame		=> 3
);