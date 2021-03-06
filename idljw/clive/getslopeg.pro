

pro getslopeg, l0, dl, dpdx, dpdy,ph=ph,which=which,ang=ang
default,ang,0
common cbb, thx,thy
sh=63
if which eq 'displacer' then dbtrue='kcal2015tt'
if which eq 'savart' then dbtrue='kcal2015t0'
la=659.89e-9

;   lamv=lam*(fltarr(1600,1644)+1) ;529e-9

;simimgnew,img,sh=sh,db=dbtrue,lam=la,svec=[2.2,1,1,.2];,/angdeptilt
img=fltarr(1280,1080)
db='kcal2015'
doplot=0
demodtype='basicnofull2'
if n_elements(thx) eq 0 then $
newdemod,img,cars,sh=sh,ifr=ifr,db=db,lam=lam,doplot=doplot,demodtype=demodtype,ix=ix,iy=iy,p=strr,kx=kx,ky=ky,kz=kz,thx=thx,thy=thy;,/doload;,/cachewrite,/cacheread

;stop

nx=n_elements(thx)
ny=n_elements(thy)
thv=fltarr(nx,ny,2)
thv(*,*,0) = thx # replicate(1,ny)
thv(*,*,1) = replicate(1,nx) # thy

;l0=659.89
;dl=1
ix1=thv(*,*,0)/max(abs(thv(*,*,0)))
iy1=thv(*,*,1)/max(abs(thv(*,*,0)))


lamv =1e-9*( l0 + cos(ang) * dl * ix1 + sin(ang) * dl * iy1)

;lamh=linspace(l0-dl,l0+dl,nx)*1e-9
;lamv2=lamh # replicate(1,ny)
;stop

gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kxa,ky=kya,kz=kza,tkz=tkz,vth=thv,vkzv=kzva,/quiet,indexlist=indexlist
gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=lamv,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv,/quiet,indexlist=indexlist,/useindex

;gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=lamv,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzv,/quiet
;gencarriers2,th=[0,0], sh=sh,db=dbtrue,lam=la,kx=kx,ky=ky,kz=kz,tkz=tkz,vth=thv,vkzv=kzva,/quiet


dkzv=(kzv-kzva) * 2 * !pi ; fringes to radians

if which eq 'displacer' then ph=dkzv(*,*,3)
if which eq 'savart' then ph=dkzv(*,*,3) / 2 ; pol angle is half savart fringe

;imgplot,ph,/cb,pos=posarr(2,1,0)
;plot,ph(*,ny/2),pos=posarr(/next),/noer
;oplot,ph(nx/2,*),col=2
dpdx=(deriv(ph(*,ny/2)))(nx/2)
dpdy=(deriv(ph(nx/2,*)))(ny/2)
;stop
end
