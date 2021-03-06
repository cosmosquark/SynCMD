pro GLOBAL_fileread, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, col1=col1, col2=col2, $
mag_glob=mag_glob, help=help
; 
; - - Procedure written to use read star data filename into required file such that population
; - - synthesis may take place
; 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
if (keyword_set(help) eq 1) then begin
   Message, 'Usage:',/info
   Message, 'GLOBAL_fileread, arch_dir=arch_dir, sim1=sim1, sim2=sim2', /info
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
   Message, 'Outputs: Star particle filename allocated to population', /info
   Message, '	      synthesis reference:', /info
   Message, '	      $arch_dir$/Code/Input_ListFilesNbodyStarParticles_Num_Loc.dat', /info
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
filename=arch_dir+'Code/Input_ListFilesNbodyStarParticles_Num_Loc.dat'
openw,lun,filename,/get_lun, width=100
printf,lun, '1'
printf,lun, '../Inputs/CMDSTARS'+sim1+sim2+'_'+tag+'.dat'
free_lun, lun
;
filename=arch_dir+'Code/Ouput_NomefilesCMDgrilled.dat'
openw,lun,filename,/get_lun
printf,lun,'1'
printf,lun, '../Outputs/CMDOut/'+col1+col2+'_'+mag_glob+'_CMDOUT'+sim1+sim2+'_'+tag
free_lun, lun
;
; - - - Run the population synthesis tool for the global population
;
cd, arch_dir+'Code/'
spawn, 'ifort nrtype.f90 nrutil.f90 Globals.f90 Grill.f90 Interpo.f90 Normale_S.f90 Bracket_age.f90 Bracket_col.f90 Bracket_mag.f90 Bracket_metal.f90 -o Glob_SynCMD.exe'
spawn, './Glob_SynCMD.exe'
cd, arch_dir+'Code/ANALYSES/MAIN/'
;
end
