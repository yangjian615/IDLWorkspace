pro overplotResults

;Use radial avg function to overplot sets of data from experiments
;Experiment Title?
exTitle='1KW RF Hydrogen at 4.1mTorr'

path='~/Dropbox/ASC2Plots/'
cd,path

checkDir = file_test(exTitle)
if checkDir eq 0 then begin
  file_mkdir,exTitle
endif

cd,exTitle

startShots = [7760,7790,7820,7850]
k = n_elements(startShots)

numPoints = dataPoints(shot=startShots[0])

;dataset Ordering: temp, density, vplasma, isat
series = dblarr(4,numPoints,k)
;Series array = [dataSet,data,experiment]

for i = 0, k-1 do begin
  print,'Begun processing Experiment',string(i+1)
  result = radialAvg(startShots[i])
  xAxis = result.xaxis
  
  series[0,*,i] = result.temp
  series[1,*,i] = result.density
  series[2,*,i] = result.vplasma
  series[3,*,i] = result.isat
  
endfor

m=4 ; 4 data types temp, density, vplasma, isat
xAxTitle='Degrees'
yAxTitles=[' Temperature',' Density',' Vplasma',' I-Sat']
yAxUnits=[' (eV)',' (m^-3)',' (V)',' (mA)']

;Set ranges
;This bit searches data for maximums, minimums, and calculates standard deviations to 
;calculate appropriate plotting ranges
stddevs = fltarr(m) ;stddev for each measurement type
wiggleRooms = fltarr(m) ;stddev for each experiment
maxPoints = fltarr(m) ; max val for each type
minPoints = fltarr(m) ; min val for each type
maxBuffer=maxPoints
minBuffer=minPoints

for i = 0, m-1 do begin ;for each data type
  for k = 0, k-1 do begin ; for each experiment
    wiggleRooms[k] = stddev(series[i,*,k])
    maxBuffer[k] = max(series[i,*,k])
    minBuffer[k] = min(series[i,*,k])
  endfor
  stddevs[i] = max(wiggleRooms)
  maxPoints[i] = max(maxBuffer)
  minPoints[i] = min(minBuffer)
endfor

;Set ranges
minRange=minPoints-stddevs
maxRange=maxPoints+stddevs


;Plotting
for j = 0, m-1 do begin
window,j
mkfig,'~/'+exTitle+'/fig_'+yAxTitles[j],xsize=13,ysize=10,font_size=9
plot,xAxis,series[j,*,0],psym=1,xtitle=xAxTitle,ytitle=yAxTitles[j]+yAxUnits[j],title=exTitle+yAxTitles[j],$
yrange=[minRange,maxRange]
  for i = 1, k-1 do begin
oplot,xAxis,series[j,*,i],psym=i+1
endfig
  endfor

endfor


end