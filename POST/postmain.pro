; postmain.pro
;
; Procedure written to use post analyse the synthetic populations as constructed with 
; simulation cuts of premain.pro and observational cuts of main.pro
;
; Author: Benjamin MacFarlane
; Date: 31/10/2014
; Contact: bmacfarlane@uclan.ac.uk
;
;	 NOTE:
;		- For 10^6 < n_synth < 10^8 numerical issues may arise with moment() array
;		  defined (partially resolved: 31/10/2014 - very spooky!)
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;		
	; - - - VARIABLE DEFINITIONS - - - ;
;
;
	stat_q=1
	logg_q=0
;
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;
		; - - - First read the architecture and global information 
		; - - - for the SynCMD run from premain.pro
;
	arch_dir=strarr(1)
	sim1=strarr(1)
	sim2=strarr(1)
	tag=strarr(1)
	hist_up=fltarr(1)
	hist_down=fltarr(1)
	hist_int=fltarr(1)
	count_stars=fltarr(1)
	globals='../../../ARCH_GLOBALS.dat'
	openr, lun, globals, /get_lun
	readf, lun, arch_dir
	readf, lun, sim1
	readf, lun, sim2
	readf, lun, tag
	readf, lun, hist_up
	readf, lun, hist_down
	readf, lun, hist_int
	readf, lun, chem_gridup
	readf, lun, chem_griddown
	readf, lun, chem_gridint
	readf, lun, count_stars
	free_lun, lun
	
;
		; - - - Same, but Color + Magnitude selection as per main.pro
;
	col1=strarr(1)
	col2=strarr(1)
	mag_glob=strarr(1)
	globals2='../../../ARCH_GLOBALS2.dat'
	openr, lun, globals2, /get_lun
	readf, lun, col1
	readf, lun, col2
	readf, lun, mag_glob
	free_lun, lun
;
		; - - - Plot the comparison MDF for the synthetic vs. composite MDF
		; - - - with determination of MDF statistics
;
grid_plot, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, hist_up=hist_up, $
	hist_down=hist_down, hist_int=hist_int, col1=col1, col2=col2, mag_glob=mag_glob, $
	logg_q=logg_q, stat_q=stat_q, help=0
;
sim_hist, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, hist_up=hist_up, $
	hist_down=hist_down, hist_int=hist_int, count_stars=count_stars, simhist_dat, stat_sim, help=0
;
synth_hist, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, hist_up=hist_up, $
	hist_down=hist_down, hist_int=hist_int, col1=col1, col2=col2, mag_glob=mag_glob, $
	synhist_dat, stat_synthGLOBAL, synhistMS_dat, stat_synthMS, synhistSGP_dat, stat_synthSGP, $
	logg_q=logg_q, help=0
;
mdf_plot, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, hist_up=hist_up, $
	hist_down=hist_down, hist_int=hist_int, col1=col1, col2=col2, mag_glob=mag_glob, $
	synhist_dat=synhist_dat, simhist_dat=simhist_dat, stat_sim=stat_sim, stat_synthGLOBAL=stat_synthGLOBAL, $
	stats=stats, synhistMS_dat=synhistMS_dat, stat_synthMS=stat_synthMS, $
	synhistSGP_dat=synhistSGP_dat, stat_synthSGP=stat_synthSGP, logg_q=logg_q, stat_q=stat_q, help=0
;
end
