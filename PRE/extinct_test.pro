; extinct_test.pro
;
; Procedure written to mock n_h and extinction calculation to ensure that consistency is 
; apparent within simple star and gas distributions
; 
; Author: Benjamin MacFarlane
; Date: 11/11/2014
; Contact: bmacfarlane@uclan.ac.uk
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;		
	; - - - VARIABLE DEFINITIONS - - - ;
;
	rad2deg = (180.d)/!dpi
;
	x_0=-8.5
	y_0=0.	
	z_0=0.
;
	gas_dens=0.5
	gas_hy=!dpi/5.
	gas_mass=4.
;	
	stars_x=[0,0,0]
	stars_y=[-8.5,-8.5,-8.5]
	stars_z=0
	gas_x=[-7,-8,-2,-9,1,-10,3]
	gas_y=[-3,-9,-6,1 ,-10,3,-10]
	gas_z=0
;
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
;
;
; - - - MAIN  PROGRAM - - - ;
;
;
numstars=n_elements(stars_x)
stars=fltarr(3,numstars)
stars(0,*)=stars_x
stars(1,*)=stars_y
stars(2,*)=stars_z
;
numgas=n_elements(gas_x)
gas=fltarr(6,numgas)
gas(0,*)=gas_x
gas(1,*)=gas_y
gas(2,*)=gas_z
gas(3,*)=gas_mass
gas(4,*)=gas_dens
gas(5,*)=gas_hy
;
N_H=fltarr(1)
SAv=fltarr(1)
o_s=fltarr(1,numstars)
o_g=fltarr(1,numgas)
s_g=fltarr(1,numgas)
;
ficond=fltarr(1,numgas)
fi=fltarr(1,numgas)
AC_cond=fltarr(1,numgas)
;
L=fltarr(1,numgas)
cond=intarr(1,numgas)
theta=fltarr(1,numgas)
R_SL=dblarr(1,numgas)
N_H_GAS=dblarr(1,numgas)
N_H_CD=dblarr(1,numgas)
;
for i=0, numstars-1 do begin
	N_H_TOT=0
	count=0
		for j=0L, numgas-1 do begin
;
			R_SL(j) = (gas(3,j)/(gas(4,j)))^(1./3.)
			N_H_CD(j) = (gas(5,j)*gas(3,j))/(!dpi*(R_SL(j))^2)
			o_s(i) = sqrt((stars(0,i)-x_0)^2+(stars(1,i)-y_0)^2+(stars(2,i)-z_0)^2)
			o_g(j) = sqrt((gas(0,j)-x_0)^2+(gas(1,j)-y_0)^2+(gas(2,j)-z_0)^2)
			s_g(j) = sqrt((gas(0,j)-stars(0,i))^2+(gas(1,j)-stars(1,i))^2+(gas(2,j)-stars(2,i))^2)
;		
			ficond(j) = (s_g(j)^2+o_s(i)^2-o_g(j)^2)/(2*o_s(i)*s_g(j))
			fi(j) = acos(ficond(j))
			AC_cond(j) = o_s(i) - (cos(fi(j))*(s_g(j)))
;	
			if (ficond(j) gt -1) AND (ficond(j) lt 0) then begin
				print, j+1, ': CONDITION B'
				L(j)=s_g(j)
				cond(j)=2
			endif
;	
			if (ficond(j) gt 0) AND (ficond(j) lt 1) then begin
				if (AC_cond(j) gt 0) then begin
					print, j+1, ': CONDITION C'
					dot_x = (stars(0,i)-x_0)*(gas(0,j)-x_0) + $
					(stars(1,i)-y_0)*(gas(1,j)-y_0) + $
					(stars(2,i)-z_0)*(gas(2,j)-z_0)
					theta(j)=acos(dot_x/(o_g(j)*o_s(i)))
					L(j)=o_g(j)*sin(theta(j))
					cond(j)=3
				endif
				if (AC_cond(j) lt 0) then begin
				print, j+1, ': CONDITION A'
				L(j)=o_g(j)
				cond(j)=1		
				endif		
			endif
;	
			if (L(j) gt R_SL(j)) then begin
				print, j+1, ': Value of L out of kernel range!'
				cond(j)=4
			endif
;	
			if (L(j) lt R_SL(j)) AND (L(j) gt 0) then begin
				count=count+1
;	
				if (L(j) gt 0) AND (L(j) lt R_SL(j)/2.) then begin
				N_H_GAS(j)=N_H_CD(j)
;				N_H_GAS(j) = N_H_CD(j)*(10./(7.*!dpi))*(((1./4.)*(2-((2*L(j))/R_SL(j)))^3.)-(1.-(2*L(j)/R_SL(j)))^3.)
				endif
;	
				if (L(j) ge R_SL(j)/2.) AND (L(j) lt R_SL(j)) then begin
				N_H_GAS(j)=N_H_CD(j)/4
;				N_H_GAS(j) = N_H_CD(j)*(10./(7.*!dpi))*(1./4.)*(2-((2*L(j))/R_SL(j)))^3.
				endif
;	
				if (L(j) gt R_SL(j)) then begin
				N_H_GAS(j)=0
				endif
; 	
			endif
;	
		N_H_TOT=N_H_TOT+N_H_GAS(j)
		endfor
;	
	print, "The column density is", N_H_TOT, " with ", count, " intersecting gas particles 
;
	print, 'theta range: ', minmax(theta)*rad2deg
	print, 'L range: ', minmax(L)
	print, 'Smoothing length range: ', minmax(R_SL)
	print, 'Max. column density range: ', minmax(N_H_CD)
	print, 'Intersecting column density range: ', minmax(N_H_GAS)
endfor
;
set_plot,'ps'
device, /encapsulated, file='/san/cosmic2/bmacfarlane/SynCMD/PLOTS/EXTINCT/extinct_test.eps', xsize=8, $
ysize=8, /inches, /color
!p.multi=0
plot, gas(0,*), gas(1,*), psym=2, xrange=[-15,7.5], yrange=[-15,10], xstyle=1, symsize=2, thick=1.5
oplot, [0,0], [-15,10], thick=0.5, linestyle=3
oplot, [-15,7.5], [0,0], thick=0.5, linestyle=3
oplot, [x_0,stars(0)], [y_0,stars(1)], linestyle=2, thick=5
oplot, [-8.5,-8.5], [0,0], psym=5, symsize=3, thick=5                    
oplot, [0,0], [-8.5,-8.5], psym=6, symsize=3, thick=5
for j=0, numgas-1 do begin
	loadct,39
	tvcircle, 2, gas(0,j), gas(1,j), color=cond(j)*50
endfor
meanings=['Condition A', 'Condition B', 'Condition C', 'Un-Dissected LOS']
linestyle=[0,0,0,0]
color=[50,100,150,200]
thick=[3,3,3,3]
al_legend, meanings, color=color, linestyle=linestyle, thick=thick, charsize=1.25, /top, /right, $
background=255
meanings2=['Observer', 'Star', 'Gas Particle']
psym=[5,6,2]
al_legend, meanings2, psym=psym, symsize=1.5, /left, charsize=1.25, background=255
loadct,0
device,/close
set_plot,'X'
;
end
