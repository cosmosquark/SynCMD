pro params, arch_dir=arch_dir, help=help
;
; - - Procedure written to write parameters for cross directory analysis scripts
; 
; Author: Benjamin MacFarlane
; Date: 13/02/2016
; Contact: bmacfarlane@uclan.ac.uk
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
if (keyword_set(help) eq 1) then begin
   Message, 'Usage:',/info
   Message, 'params, arch_dir, help=help', /info
   Message, 'Purpose: Write cross-directory parameters ', /info
   Message, '         file to ANALYSES/params.dat', /info
   Message, 'Input:   arch_dir = Directory source for SynCMD', /info
   Message, 'Outputs: Dimensional data for DFs in ANALYSES/params.dat', /info
   return
endif
;
;
	; - - - VARIABLE DEFINITIONS - - - ;
;
	; Dimension splitting for 2D gridded data
;
dim1 = ['ofe', 'mgfe', 'feh']
dim2 = ['feh', 'age', 'r']
dim1point = [11, 17, 19]
dim2point = [19, 8, 4]
;
	; Dimension splitting for 1D gridded data
;
df = ['ofe','mgfe','feh','age']
dfpoint = [11,17,19,8]
;
	; Dimension limits for dimensional data [start, end, step]
	; If additional data array added that isn't indicated below, appendage to number
	; of steps is needed.
;
ofe_l = [-2., 1., 0.2]
mgfe_l = [-2., 1., 0.2]
feh_l = [-2., 1., 0.2]
r_l = [15., 0., 0.5]
age_l = [0., 14., 0.5]
;
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;
; - - - MAIN  PROGRAM - - - ;
;
;
	; Calculate number of steps in each dimension range
;
n_step = abs((ofe_l(1)-ofe_l(0))/ofe_l(2))
ofe_l = ofe_l + n_step
n_step = abs((mgfe_l(1)-mgfe_l(0))/mgfe_l(2))
mgfe_l = mgfe_l + n_step
n_step = abs((feh_l(1)-feh_l(0))/feh_l(2))
feh_l = feh_l + n_step
n_step = abs((r_l(1)-r_l(0))/r_l(2))
r_l = r_l + n_step
n_step = abs((age_l(1)-age_l(0))/age_l(2))
age_l = age_l + n_step
;
	; Print data into text file in ANALYSES/ directory
;
filename = arch_dir+'Code/ANALYSES/params.dat'
openw, lun, filename, /get_lun
printf, lun, dim1
printf, lun, dim1point
printf, lun, dim2
printf, lun, dim2point
printf, lun, df
printf, lun, dfpoint
free_lun, lun

return
end
