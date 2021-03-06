pro extinct, arch_dir=arch_dir, sim1=sim1, sim2=sim2, tag=tag, stars=stars, gas=gas, $
	x_0=x_0, y_0=y_0, z_0=z_0, N_H, SAv, help=help
;
; - - Procedure written to calculate extinction from observers line of sight, using gas distr.
; - - impeding on observation of star
;
; NOTES:
;	- R_SL defined as 0.5*smoothing length to adhere to kernel distribution properties
;	- 
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
if (keyword_set(help) eq 1) then begin
   Message, 'Usage:',/info
   Message, 'extinct, stars=stars, gas=gas, help=help', /info
   Message, 'Purpose: Calculate associated column density and hence extinction ', /info
   Message, '         level for selected steller particles', /info
   Message, 'Input:   stars = Data array of spatially cut stellar population', /info
   Message, '	      gas = Data array of gas distribution extended around $stars$', /info
   Message, 'Outputs: stars = Data array of stellar population as input, with', /info
   Message, '	      attached tags of both column density and extincton as', /info
   Message, '	      as required by SynCMD', /info
   return
endif
;
;
; - - - VARIABLE DEFINITIONS - - - ;
;
	numstar=n_elements(stars(0,*))
	numgas=n_elements(gas(0,*))
;
	rad2deg = (180.d)/!dpi
;
	nk_q=1
	n_k=6
;
; - - -	MAIN PROGRAM - - - ;
;
N_H=fltarr(1,numstar)
SAv=fltarr(1,numstar)
o_s=fltarr(1,numstar)
o_g=fltarr(1,numgas)
s_g=fltarr(1,numgas)
;
ficond=fltarr(1,numgas)
fi=fltarr(1,numgas)
AC_cond=fltarr(1,numgas)
;
L=fltarr(1,numgas)
cond=fltarr(1,numgas)
theta=fltarr(1,numgas)
R_SL=dblarr(1,numgas)
;
N_H_CD=dblarr(1,numgas)
w=dblarr(1,numgas)
const=dblarr(1,numgas)
;
N_H_GAS=dblarr(1,numgas)
;
;
for i=0L, numstar-1 do begin
N_H_TOT=0
count=0.
	for j=0L, numgas-1 do begin
;
; - - - Firstly define the smoothing length of the j'th gas particle, and it's column density peak
;
		R_SL(j) = 3.44e-3*((gas(3,j)/(gas(4,j)))^0.33)
		N_H_CD(j) = 1.26e14*(gas(5,j)*gas(3,j))/(!dpi*(R_SL(j))^2)
;
; - - - Define vectors between observer point and star, observer point and gas, and star particle
; - - - and gas particle
;
		o_s(i) = sqrt((stars(0,i)-x_0)^2+(stars(1,i)-y_0)^2+(stars(2,i)-z_0)^2)
		o_g(j) = sqrt((gas(0,j)-x_0)^2+(gas(1,j)-y_0)^2+(gas(2,j)-z_0)^2)
		s_g(j) = sqrt((gas(0,j)-stars(0,i))^2+(gas(1,j)-stars(1,i))^2+(gas(2,j)-stars(2,i))^2)
;
; - - - Define which geometric condition gas particle enters within the line-of-sight (LOS) system 
; - - - (behind observer/behind star/perpendicular to LOS)
;
		ficond(j) = (s_g(j)^2+o_s(i)^2-o_g(j)^2)/(2*o_s(i)*s_g(j))
		fi(j) = acos(ficond(j))
		AC_cond(j) = o_s(i) - (cos(fi(j))*s_g(j))
;
		if (ficond(j) gt -1) AND (ficond(j) lt 0) then begin
			L(j)=s_g(j)
			cond(j)=2
		endif
;
		if (ficond(j) gt 0) AND (ficond(j) lt 1) then begin
			if (AC_cond(j) gt 0) then begin
				dot_x = (stars(0,i)-x_0)*(gas(0,j)-x_0) + $
				(stars(1,i)-y_0)*(gas(1,j)-y_0) + $
				(stars(2,i)-z_0)*(gas(2,j)-z_0)
				theta(j)=acos(dot_x/(o_g(j)*o_s(i)))
				L(j)=o_g(j)*sin(theta(j))
				cond(j)=3
			endif
			if (AC_cond(j) lt 0) then begin
				L(j)=o_g(j)
				cond(j)=1
			endif		
		endif
;
; - - - Dependant on ratio of smoothing length to geometric distance to LOS, define kernel weighting
; - - - ratio - of Price(2010) - eq. 6.
;
		if (L(j) gt R_SL(j)) then begin
			cond(j)=4
		endif
;
		if (L(j) lt R_SL(j)) AND (L(j) gt 0) then begin
			count=count+1
;
			if (L(j) gt 0) AND (L(j) lt R_SL(j)/2.) then begin
				w(j) = (10./(7.*!dpi))*(((1./4.)*(2-((2*L(j))/R_SL(j)))^3.)-(1.-(2*L(j)/R_SL(j)))^3.)
			endif
;
			if (L(j) ge R_SL(j)/2.) AND (L(j) lt R_SL(j)) then begin
				w(j) = (10./(7.*!dpi))*(1./4.)*(2-((2*L(j))/R_SL(j)))^3.
			endif
;
			if (L(j) gt R_SL(j)) then begin
				w(j)=0
			endif
; 
; - - - With information of kernel weighting ratio, calculate normalisation constant of kernel
; - - - function, 1/(h^d). This requires use of local smoothing length average to the closest
; - - - n_k gas particles to the j'th gas contributor.
; - - - If nk_q set to zero, don't use any nearest neighbours for average smoothing length, use
; - - - only information of j'th particle R_SL
;
		if (nk_q eq 1) AND (nk_q ne 0) then begin
			sort_index=sort( sqrt( (gas(0,*)-gas(0,j))^2 + (gas(1,*)-gas(1,j))^2 + (gas(2,*)-gas(2,j))^2 ) )
			gas_sort=fltarr(6,numgas)
			for col=0, 5 do gas_sort[col,*]=gas[col, sort_index]
;
			gas_kern=fltarr(6,n_k)
			gas_kern(*,*)=gas_sort(*,[1:n_k])
			H = total(gas_kern(3,*)/gas_kern(4,*))^(-0.666)
		endif
;
		if (nk_q eq 0) AND (nk_q ne 1) then begin
			H=(gas(3,j)/gas(4,j))^(-0.666)
		endif
;
		const(j) = (8.44e3)^2 * ( H * (gas(3,j)/gas(4,j))^(-0.666) )
;
; - - - With information of the kernel weighting ratio, the normalisation constant and the value of
; - - - max. column density for the j'th gas particle, the contribtution of hydrogen to the LOS is:
;
		N_H_GAS(j) = N_H_CD(j) * const(j) * w(j)
;
		endif
;
; - - - Add j'th gas particle contribution, and continue over gas particles in sample.
;
	N_H_TOT=N_H_TOT+N_H_GAS(j)
	endfor
;
N_H(i)=N_H_TOT
SAv(i)=N_H(i)/1.8e21
;
if (i mod 1000 eq 0) then print, "Star particle iteration: ", i
;
endfor
;
; - - - Print the extinction parameters dependant on the value of n_k, and print the histogram/
; - - - spatially distributed extinction values into a .eps file.
;
print, "The value for n_k is: ", n_k
print, "The minimum of LOS extinction is: ", min(SAv)
print, "The maximum of LOS extinction is: ", max(SAv)
print, "The mean extinction/LOS distance value is: ", mean(SAv/o_s)
;
set_plot,'ps'
device, /encapsulated, file=arch_dir+'PLOTS/EXTINCT/'+sim1+sim2+'_'+tag+'_'+'sav_hist.eps', $
	xsize=16, ysize=8, /inches, /color
!p.multi=[0,2,1]
d_hist=histogram(o_s, binsize=0.25, locations=xbin_d)
d_hist=float(d_hist)/float(numstar)
sav_hist=histogram(SAv,binsize=0.25,locations=xbin)
sav_hist=float(sav_hist)/float(numstar)  
plot, xbin_d, d_hist, psym=10, title='Distance, d (kpc) distribution', $
	xtitle='Radial distance from obsever (kpc)', ytitle='Composite star number'
plot, xbin, sav_hist, psym=10, title='SaV (mag.) distribution', $
	xtitle='Extinction, SaV (mag.)', ytitle='Composite star number'
device,/close
set_plot,'X'
;
;
set_plot,'ps'
device, /encapsulated, file=arch_dir+'PLOTS/EXTINCT/'+sim1+sim2+'_'+tag+'_'+'sav_spatial.eps', $
	xsize=16, ysize=8, /inches, /color
!p.multi=[0,2,1]
loadct,0
xdum=[0,0]
ydum=[0,0]
zdum=[0,0]
symcol=fltarr(numstar)
;
plot, xdum, ydum, psym=3, title='Stellar X-Y distribution', xrange=[min(stars(0,*))-2, max(stars(0,*))+2], $
	yrange=[min(stars(1,*))-2, max(stars(1,*))+2], xtitle='X-position (kpc)', ytitle='Y-position (kpc)', $
	xmargin=[8,6], ymargin=[6,8], charsize=1.25
loadct, 39
for i=0L, numstar-1 do begin
	symcol(i)=floor((SAv(i)/max(SAv))*255)
	oplot, [stars(0,i),stars(0,i)], [stars(1,i),stars(1,i)], thick=5, color=symcol(i)
endfor	
;
loadct,0
plot, xdum, zdum, psym=3, title='Stellar X-Z distribution', xrange=[min(stars(0,*))-2, max(stars(0,*))+2], $
	yrange=[min(stars(2,*))-2, max(stars(2,*))+2], xtitle='X-position (kpc)', ytitle='Z-position (kpc)', $
	xmargin=[8,6], ymargin=[6,8], charsize=1.25
loadct,39
for i=0L, numstar-1 do begin
	oplot, [stars(0,i),stars(0,i)], [stars(2,i),stars(2,i)], thick=5, color=symcol(i)
endfor
cgcolorbar, divisions=floor(max(SAv)), minor=3, range=[min(SAv), max(SAv)], $
	/right,  position=[0.1,0.925,0.9,0.95], charsize=1, title='SaV (mag.)', tlocation=bottom
device,/close
set_plot,'X'
;
; - - - From extinction values calculated for varying n_k, fit model to determine optimised
; - - - value of n_k
;
x=[1,8,16,32,100,1000]
y=[3.66,0.859,0.519,0.305,0.119,0.017]
;A=[0.2,-1,3]
;exp_fit=comfit(alog10(x), y, a, /exponential)
;fit_plot=fltarr(2,100)
;for i=0, 99 do begin
;	fit_plot(0,i)=(max(alog10(x)/100))
;	fit_plot(1,i)=(exp_fit(0)*(fit_plot(0,i)^exp_fit(1)))+exp_fit(2)
;endfor
;
set_plot,'ps'
device, /encapsulated, file=arch_dir+'PLOTS/EXTINCT/sav_nk_hunt.eps', $
	xsize=8, ysize=8, /inches, /color
!p.multi=0
plot, alog10(x),y, psym=4, xtitle=textoidl('n_k'), ytitle=textoidl('Mean Sa(V)/OS'), xrange=[min(alog10(x))-0.1,max(alog10(x))+0.1], xstyle=1, yrange=[min(y)-0.1, max(y)+0.1], ystyle=1
device,/close
;oplot, fit_plot(0,*), fit_plot(1,*), linestyle=2
set_plot,'X'
;
; - - - With module completed, return to premain.pro
;
return
end
