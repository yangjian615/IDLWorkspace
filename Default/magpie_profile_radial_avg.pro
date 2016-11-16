pro magpie_profile_radial_avg

;This procedure plots radial (180 or 360 degree) triple probe data
;Make sure phys_quantity is behaving right; eg. set to Argon on Hydrogen as appropriate
;Currently hardcoded for 360 scan, with 20 degree incremements 3 times each
;Need to do: averaging, options, automatically save plots
;Make sure data is mounted before running, either hard drive or network. Change magpie_data as necessary.

;Write experiment title here for plot
  exTitle = 'Hydrogen 1kw source'
  
  
  
  setNum =  [1,2,3]
  start_shot = 7850
  
  points_num = 18 ;18*3 (3 measurements per angle), total 54 measurements

  
  if start_shot ge 7214 then begin
    points_num = 9 ;9*3 = 27 measurements total for second set
  endif
  
  if start_shot ge 7760 then begin
    points_num = 10 ;9*3 = 30 measurements total for third set
  endif
  
  temp=dblarr(points_num,3)
  dens=dblarr(points_num,3)
  vplasma=dblarr(points_num,3)
  isat=vplasma
  
for k = 0, 2 do begin
  
  probe_ax = ptrarr(points_num)
  

;Probe areas, precalculated by Jaewook. Redo if using new probe.
  area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
  area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

 if start_shot ge 6964 then begin
  species = 'hydrogen'
 endif


  for i = 0, points_num-1 do begin
    shot_number = i*setNum[k]+start_shot 
    probe_ax[i] = ptr_new(phys_quantity(shot_number,gas_type=species))
  endfor

;Create arrays
  temp_ax_mean = dblarr(points_num)
  dens_ax_mean = dblarr(points_num)
  vplasma_ax_mean = dblarr(points_num)
  isat_ax_mean = vplasma_ax_mean

  
  probe_degrees=[180,160,140,120,100,80,60,40,20,0]
  shiftVal = 0
  
  
  if start_shot le 7213 then begin ;Second set, only 180 degree rotations
    probe_degrees=[10,30,50,70,90,110,130,150,170,190,210,230,250,270,290,310,330,350]
    shiftVal = -5
  endif
  if start_shot le 6960 then begin ;Second set, only 180 degree rotations
    probe_degrees=[270,290,310,330,350,10,30,50,70,90,110,130,150,170,190,210,230,250]
    shiftVal = -5
  endif
  
  probe_radians = probe_degrees * !DtoR
  ;#Coordinates#

;#Arrange data#

  radius = 3 ;length of probe end shaft, defining radius traced
  yoff = 2.75
  for i = 0, points_num-1 do begin
    temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,(*probe_ax[i]).ptime)
    dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,(*probe_ax[i]).ptime)
    vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,(*probe_ax[i]).btime)
    isat_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,(*probe_ax[i]).btime)

    temp_ax_mean[i] = mean(temp_ax_cut.yvector)
    dens_ax_mean[i] = mean(dens_ax_cut.yvector)
    vplasma_ax_mean[i] = mean(vplasma_ax_cut.yvector)
    isat_ax_mean[i] = mean(isat_cut.yvector)
    
;probe_ax_location[i] = sqrt( (radius*cos(probe_radians[i]))^2+(yoff-radius*sin(probe_radians[i]))^2   )
    
    endfor

;Shifting data for plotting

temp_ax_mean = shift(temp_ax_mean, shiftVal)
dens_ax_mean = shift(dens_ax_mean, shiftVal)
vplasma_ax_mean = shift(vplasma_ax_mean, shiftVal)

temp[*,k]=temp_ax_mean
dens[*,k]=dens_ax_mean
vplasma[*,k]=vplasma_ax_mean
isat[*,k]=isat_ax_mean


measPrint = ['One','Two','Three']
print, ('done measurement' + measPrint[k])


endfor ;end of big loop
temp_avg = fltarr(points_num)
dens_avg = fltarr(points_num)
vplasma_avg = fltarr(points_num)
isat_avg=vplasma_avg


temp_avg = (temp[*,0]+temp[*,1]+temp[*,2])/3.
dens_avg = (dens[*,0]+dens[*,1]+dens[*,2])/3.
vplasma_avg = (vplasma[*,0]+vplasma[*,1]+vplasma[*,2])/3.
isat_avg = (isat[*,0]+isat[*,1]+isat[*,2])/3.


stop
xlab='Degrees'

window,0
  plot, probe_degrees, temp_avg, title=exTitle+' Temperature',xtitle=xlab,ytitle='Temperature (eV)',psym=4
window,1
  plot, probe_degrees, dens_avg, title=exTitle+' Density',xtitle=xlab,ytitle='Density (m^(-3))',psym=4
window,2
  plot, probe_degrees, vplasma_avg, title =exTitle+' Plasma Potential',xtitle=xlab,ytitle='Voltage (V)',psym=4
window,3
  plot, probe_degrees, isat_avg, title =exTitle+'ISat',xtitle=xlab,ytitle=oin'Current (mA)',psym=4

  stop

end