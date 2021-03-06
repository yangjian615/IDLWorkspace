dorot=0
;sh=8044 
;lam=656e-9
;sh='cxrstestb4';74;8;l74;94;88;74
;sh='cxrstesta100mmp5ap2';74;8;l74;94;88;74
;sh='cxrstestc42';85  
;sh='cxrstestc42';2';74;8;l74;94;88;74
;sh='cxrstestd42';74;8;l74;94;88;74
;sh='cxrstestbb4new3' &dorot=1
;sh='edge_cal'
;sh='cxrstesta100mmp5ap2'
;sh='cxrstestp5ap'
;sh='tst3'

;sh='mport_test_mse_50mm'
;sh='cxrstest4_cube4_sphere_test2'
;shb='cxrstest4_cube4_sphere_test2_black'
;nofilter2 and filterother2 prove filter on lens towards plasma is ok
;sh='tst_4mm_mon1_nofilter3_refl';filterfront3'
;sh='pimax_cxrs_tues1'
;sh='pimax_bin2_mse_tues2'
;sh='cxrstest4_tuni_white_660_03nmfilter'
sh='cxrstest4_tuni_white_cxrsfilter'

;sh='cxrstest4_tuni_laser'

dorot=0
shb=sh+'_black'
imw=0

;imw=100

;shb=sh+'_black'
;shb='cxrstestc4_black'
;dum=file_search('~/rsphy/kstartestimages'+shb+'.tif',count=cnt)
;if cnt eq 0 then shb='cxrstestp5ap_black'
;lam=660e-9
lam=529e-9
;lam=sh eq 'cxrstest4_tuni_white_651filter' ? 651e-9 : 529e-9
;lam=667e-9
doplot=0


;svec=[1,1/sqrt(2),1/sqrt(2),0]
;tt=-11.5*!dtor*0+
;if sh eq 'edge_cal' then tt=11.5*2 - 22.5 else tt=22.5
;if strmid(sh,0,9) eq 'cxrstestp' then tt=90.+22.5
;if strmid(sh,0,15) eq 'cxrstesta100mmp' then tt=90.+22.5
tt=-45.
;tt=0
tt*=!dtor

svec=[1,cos(2*tt),sin(2*tt),0]
;svec=[1,1,0,0]
;svec=[1,0,-1,0]

;simimgnew,simg,sh=sh,lam=lam,svec=svec
;myroi=[651,2080,341,1820]
;myroi=[2560/2 + [ -127,128],2160/2 + [-127,128]]
;delvar,myroi
simga=getimgnew(sh,imw,info=info,/getinfo,str=p,roi=myroi)*1.0
readpatch,sh,p,/getflc,/getinfo

simgb=getimgnew(shb,0,roi=myroi)*1.0
simg=simga-simgb
if dorot eq 1 then simg=rotate(simg,7)
demodtype='basicd44'
;demodtype='basicd32'

readdemodp,demodtype,sd
readcell,p.cellno,str

newdemod,simg,cars,sh=sh,lam=lam,demodtype=demodtype,ix=ix,iy=iy,p=p,doplot=doplot,thx=thx,thy=thy,/noload,sd=sd,str=str
;lam=529e-9
stop
gencarriers2,th=[0,0],sh=sh,mat=mat,dmat=dmat,kz=kz,lam=lam,kx=kx,ky=ky,dkx=dkx,dky=dky,p=p

iz=(where(kz eq 0))(0)
nn=n_elements(kz)
carsb = cars/replarr(abs(cars(*,*,iz)),nn)

contrast=abs(carsb)

amp = reform(abs(dmat ## svec) )
amp=amp/amp(iz)

print,abs(amp)

for i=0,nn-1 do contrast(*,*,i)/=amp(i)

pos=posarr(2,3,0)
erase
for i=0,nn-1 do begin
if kz(i) ne 0 then imgplot,contrast(*,*,i),thx*!radeg,thy*!radeg,title=kz(i),pos=pos,/noer,/cb,zr=[0.,1];*0.75
oplot,[-4,4,4,-4,-4],[-4,-4,4,4,-4],col=2


if kz(i) ne 0 then pos=posarr(/next)
endfor
sz=size(contrast,/dim)
plot,kz,contrast(sz(0)/2,sz(1)/2,*),pos=pos,/noer,yr=[0,1]
pos=posarr(/next)
imgplot,cars(*,*,iz),title='intensity',pos=pos,/noer



         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/p.flencam* $; per mm on detector
            6.5e-3*p.bin ; per binned pixel

print,kz
print,kx*kmult
print,ky*kmult

;calcmet,[kz(1:*)],met
stop

print,'dky/dkx=',dky/dkx,'dkx=',dkx*kmult,'dky=',dky*kmult



;-1 =  savart
;1=bbo
;2=ln
cdb=[$
[1,6.,45],$
[1,5.,30],$
[1,7.5,35],$
[1,5,45],$
[1,4,45],$
[1,3,45],$
[-1,2,45],$
[-1,2.5,45],$
[2,1.,45],$
[-2,2,45],$
[1,2.2,0],$
[1,1.0,0],$
[1,2.0,0],$
[2,0.6,0],$
[2,2.0,0]]


end
