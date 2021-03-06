pro xyz_lbd, arch_dir=arch_dir, sim1=sim1, sim2=sim2, simdir=simdir, tag=tag, lbd_q=lbd_q, $
	x_up=x_up, x_down=x_down, y_up=y_up, y_down=y_down, z_up=z_up, z_down=z_down, l_up=l_up, $
	l_down=l_down, b_up=b_up, b_down=b_down, d_up=d_up, d_down=d_down, sim_xyz, stars, gas, $
	x_0, y_0, z_0, count_stars, count_gas, help=help
;
; - - Procedure written to convert selected simulation data to lbd co-ordinates if required, and
; - - supply a spatial cut as defined by premain.pro definitions
; - - variables
; 
; Author: Benjamin MacFarlane
; Date: 16/10/2014
; Contact: bmacfarlane@uclan.ac.uk
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
; = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 
if (keyword_set(help) eq 1) then begin
   Message, 'Usage:',/info
   Message, 'xyz_lbd, arch_dir=arch_dir, simdir=simdir, lbd=lbd', /info
   Message, '	      x_up=x_up, x_down=x_down, y_up=y_up, y_down=y_down', /info
   Message, '	      z_up=z_up, z_down=z_down, l_up=l_up, l_down=l_down', /info
   Message, '	      b_up=b_up, b_down=b_down, d_up=d_up, d_down=d_down, help=help', /info
   Message, 'Purpose: Convert xyz -> lbd co-ordinates, and apply user ', /info
   Message, '         defined spatial cuts', /info
   Message, 'Input:   arch_dir = Directoy_0 source for SynCMD', /info
   Message, '	      simdir = Directoy_0 in which simulation data is stored', /info
   Message, '	      tag = String tag to define SynCMD run', /info
   Message, '	      lbd_q = Quey_0 as to use the lbd transformation with', /info
   Message, '	      spatial cuts as defined', /info
   Message, '	      $i$_up (i=[x,y,z,l,b,d]) = Upper limit of', /info
   Message, '	      the ith component (kpc)', /info
   Message, '	      $i$_down (i=[x,y,z,l,b,d]) = Lower limit of', /info
   Message, '	      the ith component (kpc)', /info
   Message, 'Outputs: sim_xyz = xyz data of all simulation data', /info
   Message, '	      stars = 26D array of spatially cut data as required by SynCMD', /info
   Message, '	      $i$_0 (i=[x,y,z]) = Observer location w.r.t. galaxy centre', /info
   Message, '	      count_stars = number of stars within spatial construct', /info
   Message, '	      count_stars = number of gas particles within spatial construct', /info
   return
endif
;
;
; - - - VARIABLE DEFINITIONS - - - ;
;
	rad2deg = (180.d)/!dpi
	deg2rad = !dpi/180.d
;
	x_0=4.0
	y_0=6.92820
	z_0=0.
;
;
; - - -	MAIN PROGRAM - - - ;
;
;
		; - - - Read in simulation data
; SELENE
;
if (sim1 eq 'Selene') AND (sim1 ne 'MaGICC') AND (sim1 ne 'MUGS') then begin
	readcol, simdir, id, x, y, z, mass, age, metals, feh, mgfe, ofe, format=('UL, D, D, D, D, D, D, D, D, D')
;
	numstar=n_elements(id)
	d=fltarr(numstar)
	stars=fltarr(26,numstar)
;
	stars(0,*)=x
	stars(1,*)=y
	stars(2,*)=z
	stars(3,*)=mass
	stars(4,*)=sqrt((stars(0,*))^2+(stars(1,*))^2+(stars(2,*))^2)
	stars(5,*)=0
	stars(6,*)=0
	stars(7,*)=0
	stars(8,*)=age
	stars(9,*)=0
	stars(10,*)=metals
	stars(11,*)=ofe
	stars(12,*)=0
	stars(13,*)=0
	stars(14,*)=0
	stars(15,*)=0
	stars(16,*)=0
	stars(17,*)=mgfe
	stars(18,*)=0
	stars(19,*)=feh
	stars(20,*)=id
	stars(21,*)=0
	stars(22,*)=0
	stars(23,*)=sqrt((stars(0,*)-x_0)^2+(stars(1,*)-y_0)^2+(stars(2,*)-z_0)^2)
	stars(24,*)=0
	stars(25,*)=0
;
	sim_xyz=fltarr(3,numstar)
	sim_xyz=stars([0:2],*)
;
	gas=0
	count_stars=numstar
	print, count_stars
	count_gas=0
;
	device, get_decomposed=old_decomposed
	device, decomposed=0
	!p.multi=[0,2,1]
	loadct,0
	tvlct,rr,gg,bb,/get
	window,30,xsize=1600,ysize=800,/pixmap
		plot, sim_xyz(0,*), sim_xyz(1,*), xrange=[-20,20], yrange=[-20,20], psym=3, $
		ytitle='Y position (kpc)', xtitle='X position (kpc)', $
		title='XY Profile   -   '+sim1+'-'+sim2+'   '+tag, charsize=1.5, background=255, color=0
		plot, sim_xyz(0,*), sim_xyz(2,*), xrange=[-20,20], yrange=[-20,20], psym=3, $
		ytitle='Z position (kpc)', xtitle='X position (kpc)', $
		title='XZ Profile   -   '+sim1+'-'+sim2+'   '+tag, charsize=1.5, background=255, color=0
	filename= arch_dir+'/PLOTS/SPATIAL/SPATIAL_'+sim1+sim2+'_'+tag+'.png'			
	write_png,filename,tvrd(/true)
	device, decomposed=old_decomposed
;
endif
;
; MUGS
;	
if (sim1 eq 'MUGS') AND (sim1 ne 'MaGICC') then begin
	rtipsy,simdir,h,g,d,s
	unitsMUGS,g,d,s,h.time
	com_stars,g,d,s
	align,g,d,s,5.
	metalinitgas,simdir,g
	metalinit,simdir,s
	numstar=h.nstar
	numgas=h.ngas
print, "MUGS"
	rawdata=fltarr(26,numstar)
	rho=fltarr(1,numstar)
;	
	rawdata(0,*)=s.x
	rawdata(1,*)=s.y
	rawdata(2,*)=s.z
	rawdata(3,*)=s.mass
	rawdata(4,*)=0
	rawdata(5,*)=s.vx
	rawdata(6,*)=s.vy
	rawdata(7,*)=s.vz
	rawdata(8,*)=s.tform
	rawdata(9,*)=s.eps
	rawdata(10,*)=s.metals
	rawdata(11,*)=s.ox
	rawdata(12,*)=s.fe
	rawdata(13,*)=s.hy
	rawdata(14,*)=0
	rawdata(15,*)=0
	rawdata(16,*)=0
	rawdata(17,*)=0
	rawdata(18,*)=0
	rawdata(19,*)=s.feh
endif
;
; MaGICC
;
if (sim1 eq 'MaGICC') AND (sim1 ne 'MUGS') then begin
	rtipsy,simdir,h,g,d,s
	unitscos68,g,d,s,h.time
	com_stars,g,d,s
	align,g,d,s,5.
	metalinitgas,simdir,g
	metalinit,simdir,s
	numstar=h.nstar
	numgas=h.ngas
print, "MaGICC"
	rawdata=fltarr(26,numstar)
	rho=fltarr(1,numstar)
;
	rawdata(0,*)=s.x
	rawdata(1,*)=s.y
	rawdata(2,*)=s.z
	rawdata(3,*)=s.mass
	rawdata(4,*)=0
	rawdata(5,*)=s.vx
	rawdata(6,*)=s.vy
	rawdata(7,*)=s.vz
	rawdata(8,*)=13.66-s.tform
	rawdata(9,*)=s.eps
	rawdata(10,*)=s.metals
	rawdata(11,*)=s.ox
	rawdata(12,*)=s.fe
	rawdata(13,*)=s.hy
	rawdata(14,*)=s.c
	rawdata(15,*)=s.n
	rawdata(16,*)=s.neon
	rawdata(17,*)=s.mg
	rawdata(18,*)=s.si
	rawdata(19,*)=s.feh
endif
;
		; - - - Convert MaGICC/MUGS raw simulation data from xyz -> lbd
;
if ((sim1 eq 'MaGICC') OR (sim1 eq 'MUGS')) AND (sim1 ne 'Selene') then begin
;
	if (x_0 eq 0) AND (y_0 eq 0) then theta=0
	if (x_0 gt 0) AND (y_0 gt 0) then theta=((atan(y_0/x_0))*rad2deg)
	if (x_0 eq 0) AND (y_0 gt 0) then theta=90
	if (x_0 lt 0) AND (y_0 gt 0) then theta=((atan(y_0/x_0))*rad2deg) + 180
	if (x_0 lt 0) AND (y_0 eq 0) then theta = 180
	if (x_0 lt 0) AND (y_0 lt 0) then theta=((atan(y_0/x_0))*rad2deg) + 180
	if (x_0 eq 0) AND (y_0 lt 0) then theta=270
	if (x_0 gt 0) AND (y_0 lt 0) then theta=((atan(y_0/x_0))*rad2deg) + 360
;
rho = sqrt( (s.x-x_0)^2 + (s.y-y_0)^2)
lrad=atan(s.y-y_0,s.x-x_0)
brad=0.5*!dpi-atan(s.y-y_0,(s.z-z_0)*sin(lrad))
for i=0L, numstar-1 do begin
	if (brad(i) gt  0.5*!dpi) then brad(i)=brad(i)-!dpi
	if (brad(i) lt -0.5*!dpi) then brad(i)=brad(i)+!dpi
endfor
r=sqrt((s.x)^2 + (s.y)^2 + (s.z)^2)
d=sqrt((s.x-x_0)^2 + (s.y-y_0)^2 + (s.z-z_0)^2)
b=brad*rad2deg
l=(lrad*rad2deg)-theta
for i=0L, numstar-1 do begin
	if (l(i) lt 0.) then l(i)=l(i)+360.
endfor
d=sqrt((s.x-x_0)^2 + (s.y-y_0)^2 + (s.z-z_0)^2)
namecount=where(s.mass gt 0)
rawdata(4,*)=r
rawdata(20,*)=[namecount]+1
rawdata(21,*)=l
rawdata(22,*)=b
rawdata(23,*)=d
rawdata(24,*)=0
rawdata(25,*)=0
;
		; - - - Print MaGICC/MUGS xyz data for raw data into array
;
	sim_xyz=fltarr(3,numstar)
	sim_xyz=rawdata([0:2],*)
endif
;
		; - - - Begin restriction of spatial dimensions (apply observational kinematic
		; - - - cut (units of kpc for xyz/d, deg. for lb)
; 
		; - - - FOR MUGS RUNS
;
if (sim1 eq 'MUGS') AND (sim1 ne 'MaGICC') then begin
	if (lbd_q eq 1) AND (lbd_q ne 0) then begin
		lbdcut=where((l gt l_down) AND (l lt l_up) AND (sqrt(b^2) gt b_down) AND $
		(sqrt(b^2) lt b_up) AND	(d gt d_down) AND (d lt d_up) AND (sqrt(s.z^2) lt z_up) $
		AND (sqrt(s.z^2) gt z_down), count) 
		count=count
		stars=fltarr(26, count)
;
		stars(0,*)=s[lbdcut].x
		stars(1,*)=s[lbdcut].y
		stars(2,*)=s[lbdcut].z
		stars(3,*)=s[lbdcut].mass
		stars(4,*)=r[lbdcut]
		stars(5,*)=s[lbdcut].vx
		stars(6,*)=s[lbdcut].vy
		stars(7,*)=s[lbdcut].vz
		stars(8,*)=(13.66-s[lbdcut].tform)
		stars(9,*)=s[lbdcut].eps
		stars(10,*)=s[lbdcut].metals
		stars(11,*)=s[lbdcut].ox
		stars(12,*)=s[lbdcut].fe
		stars(13,*)=s[lbdcut].hy
		stars(14,*)=0
		stars(15,*)=0
		stars(16,*)=0
		stars(17,*)=0
		stars(18,*)=0
		stars(19,*)=s[lbdcut].feh
		cutnamecount=where(s[lbdcut].mass gt 0)
		stars(20,*)=[cutnamecount]+1
		stars(21,*)=l[lbdcut]
		stars(22,*)=b[lbdcut]
		stars(23,*)=d[lbdcut]
		stars(24,*)=0
		stars(25,*)=0
	endif
;
	if (lbd_q eq 0) AND (lbd_q ne 1) then begin
		xyzcut=where((s.x gt x_down) AND (s.x lt x_up) AND (s.y gt y_down) OR (s.y lt y_up) AND $
		(sqrt(s.z^2) gt z_down) AND (sqrt(s.z^2) lt z_up), count) 
		count=count
		stars=fltarr(26, count)
;
		stars(0,*)=s[lbdcut].x
		stars(1,*)=s[lbdcut].y
		stars(2,*)=s[lbdcut].z
		stars(3,*)=s[lbdcut].mass
		stars(4,*)=r[lbdcut]
		stars(5,*)=s[lbdcut].vx
		stars(6,*)=s[lbdcut].vy
		stars(7,*)=s[lbdcut].vz
		stars(8,*)=(13.66-s[lbdcut].tform)
		stars(9,*)=s[lbdcut].eps
		stars(10,*)=s[lbdcut].metals
		stars(11,*)=s[lbdcut].ox
		stars(12,*)=s[lbdcut].fe
		stars(13,*)=s[lbdcut].hy
		stars(14,*)=0
		stars(15,*)=0
		stars(16,*)=0
		stars(17,*)=0
		stars(18,*)=0
		stars(19,*)=s[lbdcut].feh
		cutnamecount=where(s[lbdcut].mass gt 0)
		stars(20,*)=[cutnamecount]+1
		stars(21,*)=l[lbdcut]
		stars(22,*)=b[lbdcut]
		stars(23,*)=d[lbdcut]
		stars(24,*)=0
		stars(25,*)=0
	endif
endif
; 
		; - - - FOR MaGICC RUNS
;
if (sim1 eq 'MaGICC') AND (sim1 ne 'MUGS') AND (sim1 ne 'Selene') then begin
	if (lbd_q eq 1) AND (lbd_q ne 0) then begin
		lbdcut=where((l gt l_down) AND (l lt l_up) AND (sqrt(b^2) gt b_down) AND $
		(sqrt(b^2) lt b_up) AND	(d gt d_down) AND (d lt d_up) AND (sqrt(s.z^2) lt z_up) AND $
		(sqrt(s.z^2) gt z_down), count) 
		count=count
		stars=fltarr(26, count)
;
		stars(0,*)=s[lbdcut].x
		stars(1,*)=s[lbdcut].y
		stars(2,*)=s[lbdcut].z
		stars(3,*)=s[lbdcut].mass
		stars(4,*)=r[lbdcut]
		stars(5,*)=s[lbdcut].vx
		stars(6,*)=s[lbdcut].vy
		stars(7,*)=s[lbdcut].vz
		stars(8,*)=(13.66-s[lbdcut].tform)
		stars(9,*)=s[lbdcut].eps
		stars(10,*)=s[lbdcut].metals
		stars(11,*)=s[lbdcut].ox
		stars(12,*)=s[lbdcut].fe
		stars(13,*)=s[lbdcut].hy
		stars(14,*)=s[lbdcut].c
		stars(15,*)=s[lbdcut].n
		stars(16,*)=s[lbdcut].neon
		stars(17,*)=s[lbdcut].mg
		stars(18,*)=s[lbdcut].si
		stars(19,*)=s[lbdcut].feh
		cutnamecount=where(s[lbdcut].mass gt 0)
		stars(20,*)=[cutnamecount]+1
		stars(21,*)=l[lbdcut]
		stars(22,*)=b[lbdcut]
		stars(23,*)=d[lbdcut]
		stars(24,*)=0
		stars(25,*)=0
	endif
;
	if (lbd_q eq 0) AND (lbd_q ne 1) then begin
		xyzcut=where((s.x gt x_down) AND (s.x lt x_up) AND (s.y gt y_down) OR (s.y lt y_up) AND $
		(s.z gt z_down) AND (s.z lt z_up), count) 
		count=count
		stars=fltarr(26, count)
;
		stars(0,*)=s[lbdcut].x
		stars(1,*)=s[lbdcut].y
		stars(2,*)=s[lbdcut].z
		stars(3,*)=s[lbdcut].mass
		stars(4,*)=r[lbdcut]
		stars(5,*)=s[lbdcut].vx
		stars(6,*)=s[lbdcut].vy
		stars(7,*)=s[lbdcut].vz
		stars(8,*)=(13.66-s[lbdcut].tform)
		stars(9,*)=s[lbdcut].eps
		stars(10,*)=s[lbdcut].metals
		stars(11,*)=s[lbdcut].ox
		stars(12,*)=s[lbdcut].fe
		stars(13,*)=s[lbdcut].hy
		stars(14,*)=s[lbdcut].c
		stars(15,*)=s[lbdcut].n
		stars(16,*)=s[lbdcut].neon
		stars(17,*)=s[lbdcut].mg
		stars(18,*)=s[lbdcut].si
		stars(19,*)=s[lbdcut].feh
		cutnamecount=where(s[lbdcut].mass gt 0)
		stars(20,*)=[cutnamecount]+1
		stars(21,*)=l[lbdcut]
		stars(22,*)=b[lbdcut]
		stars(23,*)=d[lbdcut]
		stars(24,*)=0
		stars(25,*)=0
	endif
count_stars=n_elements(lbdcut)
print, count_stars
;
endif
;
		; - - - Determine gas particles within the stellar sphere of influence and
		; - - - create $gas$ array for use within extinction determination
;
if ((sim1 eq 'MaGICC') OR (sim1 eq 'MUGS')) AND (sim1 ne 'Selene') then begin
	d_g=sqrt((g.x-x_0)^2 + (g.y-y_0)^2 + (g.z-z_0)^2)
	d_smax=max(stars(23,*))
gascut=where((d_g lt 2*d_smax), count) 
;	gascut=where((g.mass ne 0), count)
	count=count
	gas=fltarr(6,count)
;
	gas(0,*)=g[gascut].x
	gas(1,*)=g[gascut].y
	gas(2,*)=g[gascut].z
	gas(3,*)=g[gascut].mass
	gas(4,*)=g[gascut].dens
	gas(5,*)=g[gascut].hy
;
	count_gas=n_elements(gascut)
	print, count_gas
;
	device, get_decomposed=old_decomposed
	device, decomposed=0
	!p.multi=[0,2,1]
	loadct,0
	tvlct,rr,gg,bb,/get
	window,30,xsize=1600,ysize=800,/pixmap
		plot, sim_xyz(0,*), sim_xyz(1,*), xrange=[-20,20], yrange=[-20,20], psym=3, $
		ytitle='Y position (kpc)', xtitle='X position (kpc)', $
		title='XY Profile   -   '+sim1+'-'+sim2+'   '+tag, charsize=1.5, background=255, color=0
		loadct,1
		oplot, stars(0,*), stars(1,*),color=200, psym=3	
		loadct,0
		plot, sim_xyz(0,*), sim_xyz(2,*), xrange=[-20,20], yrange=[-20,20], psym=3, $
		ytitle='Z position (kpc)', xtitle='X position (kpc)', $
		title='XZ Profile   -   '+sim1+'-'+sim2+'   '+tag, charsize=1.5, background=255, color=0
		loadct,1
		oplot, stars(0,*), stars(2,*),color=200, psym=3	
	filename= arch_dir+'/PLOTS/SPATIAL/SPATIAL_'+sim1+sim2+'_'+tag+'.png'			
	write_png,filename,tvrd(/true)
	device, decomposed=old_decomposed
endif
;
		; - - - Plot the distribution of rawdata and spatially restricted stars
;
;
;
return
end
