function emissionValue, shotNo

path='/media/adrian/Elements/camware'
cd,path


shot = string(shotNo, FORMAT='(I2.2)')


backShot = '55' ;f/11
backShotLength = 5. ;seconds (all calbration shots had same length; yay no more lookup tables!)

if shotNo ge 45 then begin
  backShot = '56' ;f/5.6
endif
if shotNo ge 48 then begin
  backShot = '54' ;f/22
endif

shotLength = exposureTime(shotNo)*0.001



timeScale = shotLength/backShotLength

background = read_tiff(backShot+'.tif') ;calibration
shotImage = read_tiff(shot+'.tif')

background = background * timeScale
;Calculation
emission = shotImage/background


radiance = 3.617E15*4.*!pi
;fwhm = 3E-9 of filter
ionPathL = 0.05 ;size of plasma, meters
sxb = 10.
emission = radiance*3.*emission*sxb/ionPathL

;Emission is the ionization rate
;Take the mean of 10x10 central values
;Array is 1400x1080

xCentral = indgen(10,start=695)
yCentral = indgen(10,start=515)
averagingArray = fltarr(10,10)
for i = 0, 9 do begin
  x = xCentral[i]
  for j = 0, 9 do begin
    y = yCentral[j]
    averagingArray[i,j] = emission[x,y]
  endfor
end

ionizationRate = mean(emission)



return,ionizationRate

end