pro globals, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, $
col1=col1, col2=col2, mag_glob=mag_glob, $
maglim1=maglim1, maglim2=maglim2, collim1=collim1, collim2=collim2, $
glim1=glim1, glim2=glim2, tefflim1=tefflim1, tefflim2=tefflim2, help=help
; 
; - - Procedure to define global variables for use within synthetic population construct,
; - - using input format as required for Grill.f90
; 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
if (keyword_set(help) eq 1) then begin
   Message, 'Usage:',/info
   Message, 'globals, arch_dir=arch_dir, sim1=sim1, sim2=sim2', /info
   Message, '	tag=tag, col1=col1,col2=col2, mag=mag, help=help', /info
   Message, 'Purpose: Read simulation star selection filename', /info
   Message, '         to population synthesis input file', /info
   Message, 'Input:   arch_dir = Directory source for SynCMD', /info
   Message, '	      sim1 = Simulation to be used (MUGS or MaGICC)', /info
   Message, '	      sim2 = Simulation iteration to be used (g1536 or g15784)', /info
   Message, '	      tag = SynCMD tag associated with analysis run', /info
   Message, '	      col1 = Colour #1 used within CMD analysis', /info
   Message, '	      col2 = Colour #2 used within CMD analysis', /info
   Message, '	      mag_glob = Magnitude scale used for CMD analysis', /info
   Message, '	      $i$lim$j$ = Input of global variables as required', /info
   Message, '	      for synthetic population restrictions', /info
   Message, '	      ($i$ = [col, mag, logg])', /info
   Message, '	      ($j$ = [down, up])', /info
   Message, '	      $i$_$j$vec$k$ = Input of base vectors as required', /info
   Message, '	      for synthetic population restrictions', /info
   Message, '	      ($i$ = [col, mag, logg])', /info
   Message, '	      ($j$ = [abs, app])', /info
   Message, '	      ($k$ = [inf (low), sup (high)])', /info 
   Message, 'Outputs: File to which main.pro defined variables will', /info
   Message, '	      be stored in, so that synthetic population tool may read', /info
   Message, '	      in required globals. Output within:', /info
   Message, '	      $arch_dir$/Code/IDL_GLOBALS+$sim1$+$sim2$+$tag$+.dat', /info
   return
endif
;
;		
	; - - - VARIABLE DEFINITIONS - - - ;
;
;
	; - - - MAIN  PROGRAM - - - ;
;
;
cases=intarr(3)
globals=fltarr(8)
;
if (tag eq 'UBVRI') AND (tag ne 'SDSS') then begin
;
	case col1 of
		'U': cases(0)=1
		'B': cases(0)=2
		'V': cases(0)=3
		'R': cases(0)=4
		'I': cases(0)=5
		'J': cases(0)=6
		'H': cases(0)=7
		'K': cases(0)=8
	endcase	
;
	case col2 of
		'U': cases(1)=1
		'B': cases(1)=2
		'V': cases(1)=3
		'R': cases(1)=4
		'I': cases(1)=5
		'J': cases(1)=6
		'H': cases(1)=7
		'K': cases(1)=8
	endcase
;
	case mag_glob of
		'U': cases(2)=1
		'B': cases(2)=2
		'V': cases(2)=3
		'R': cases(2)=4
		'I': cases(2)=5
		'J': cases(2)=6
		'H': cases(2)=7
		'K': cases(2)=8
	endcase
;
endif
;
if (tag eq 'SDSS') AND (tag ne 'UBVRI') then begin
;
	case col1 of
		'ug': BEGIN
			cases(0)=9
			cases(1)=9
		      END
		'gr': BEGIN
			cases(0)=10
			cases(1)=10
		      END
		'ri': BEGIN
			cases(0)=11
			cases(1)=11
		      END
		'rz': BEGIN
			cases(0)=12
			cases(1)=12
		      END
	endcase
;
	case mag_glob of
		'g': cases(2)=9
		'r': cases(2)=10
	endcase
endif
;
globals(0)=maglim1
globals(1)=maglim2
globals(2)=collim1
globals(3)=collim2
globals(4)=glim1
globals(5)=glim2
globals(6)=tefflim1
globals(7)=tefflim2
;
filename1=arch_dir+'Code/IDL_GLOBALS.dat'
openw,lun,filename1,/get_lun
printf,lun, cases, globals
free_lun, lun
;
;
end
