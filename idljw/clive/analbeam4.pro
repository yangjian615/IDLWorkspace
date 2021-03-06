@filt_common
pro createvig,sz,vig,imgbin=imgbin
; for roi 1600x1644 pco edge images
x=findgen(sz(0))
mid=[  0.415375,     0.459976]

theta = (x - sz(0)*mid(0)) * 6.5e-3 * imgbin / 55. * !radeg
y=findgen(sz(1))
thetay = (y - sz(1)*mid(1)) * 6.5e-3 * imgbin / 55. * !radeg
thx2=theta # replicate(1,n_elements(thetay))
thy2=replicate(1,n_elements(theta)) # thetay
th2=sqrt(thx2^2+thy2^2)
vig=vigfunc2(th2)
end



pro getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,file=file,doback=doback

;view={tor:134.35,$
;      rad:2.208,$
;      hei:0.2,$
;      yaw:0.,$
;      pit:-14.,$
;      rol:0.}

;view={tor:134.935,$
;      rad:2.22626,$
;      hei:0.199349,$
;      yaw:-0.939619,$;
;      pit:-13.0344,$
;      rol:-0.562990}
;flen=4.81661e-3
;dist=0.239977


;restore,file='~/idl/clive/nleonw/kmse2/irset.sav',/verb

restore,file=file

;restore,file='~/idl/clive/nleonw/kmse_7891/irset.sav',/verb
;restore,file='~/idl/clive/nleonw/kmse_7891n2/irset.sav',/verb

view=str
flen=str.flen*1e-3
dist=str.dist
distcx=str.distcx
distcy=str.distcy
;stop



;focal length: 4.81661
; dist1/rad2 = 0.239977
;centx=0.5
;centy=0.7

ang=view.tor*!dtor
r=view.rad*1e2
z=view.hei*1e2
yaw=view.yaw*!dtor

if keyword_set(doback) then begin
    ang=ang-90*!dtor
    yaw=-yaw
endif

ang2=ang+yaw-!pi
pit=view.pit*!dtor
rol=view.rol*!dtor


;z=-z*0
;pit=pit*1.2
;rol=-rol*0.4*0
;flen=flen*0.7
;stop
;pit*=1.3
;stop
;z/=2
;z=0
;pit=0.
;rol=0.

;
p0=[r*cos(ang),r*sin(ang),z]

zhat=[cos(ang2)*cos(pit),sin(ang2)*cos(pit),sin(pit)] & zhat=zhat/norm(zhat)
xhat=-crossp([0,0,1],zhat) & xhat=xhat/norm(xhat)
yhat=-crossp(zhat,xhat) & yhat=yhat/norm(yhat)

; ah ! xhat and y hat did not include any "roll" of camera about its
; axis.  This is defined by xhat2,yhat2

xhat2=xhat * cos(rol) + yhat * sin(rol)
yhat2=-xhat*sin(rol) +  yhat * cos(rol)

;stop
xhat=xhat2 ; and overwrite the orinal array
yhat=yhat2

end


pro getpts,sz,bin,imgbin,pts,file=file,doback=doback,detx=detx,dety=dety

;bin=8;0


;sz=[688,520] / bin

;sz=[688,512] / bin
psiz=6.5e-6*imgbin * bin

nx=sz(0)
ny=sz(1)
ix1=indgen(nx)
iy1=indgen(ny)


ix=reform(ix1 # replicate(1,ny),nx*ny)
iy=reform(replicate(1,nx) # iy1,nx*ny)
np=nx*ny


getax,xhat,yhat,zhat,p0,flen=flen,distt=dist,distcx=distcx,distcy=distcy,file=file,doback=doback

cdir=fltarr(3,np)
p0p=cdir

detx=((ix1-sz(0)/2) * psiz)
dety=((iy1-sz(1)/2) * psiz)

for i=0,np-1 do begin

    thx=((ix(i)-sz(0)/2) * psiz/flen)
    thy=((iy(i)-sz(1)/2) * psiz/flen)

;    print,"thx,thy",thx,thy
    thxc=((sz(0)*distcx-sz(0)/2) * psiz/flen)
    thyc=((sz(1)*distcy-sz(1)/2) * psiz/flen)

    thx=atan(thx-thxc)
    thy=atan(thy-thyc)

;    print,thx*!radeg,thy*!radeg
    thr = sqrt((thx)^2+(thy)^2)
    fac=(1 - dist * thr^2 + 3 * dist^2 * thr^4)
;    print,'fac=',1-fac,i,np
;    stop
    thx = (thx )* fac
    thy = (thy )* fac
    
    thx=thx+atan(thxc)
    thy=thy+atan(thyc)


    cdir1=zhat + xhat * tan(thx) + yhat * tan(thy)
    cdir1=cdir1/norm(cdir1)
    cdir(*,i)=cdir1
    p0p(*,i)=p0

;    pv=[ -1196.07   ,   918.184   ,  -364.050]/10.

;    tmp=(pv-p0)/cdir1
;    print,tmp/tmp(0)
;    stop

endfor
nl=100*3
lene=[50,400]
len=linspace(lene(0),lene(1),nl)
dl=(len(1)-len(0) ) * 0.01 ; cm to m
pts=fltarr(np,nl,3)
for i=0,np-1 do begin
    for j=0,2 do pts(i,*,j)=p0p(j,i) + cdir(j,i) * len
endfor


pts=reform(pts,nx,ny,nl,3)
end


;img=getimg(7350,index=20,/mdsplus,info=info,/getinfo,/flipy)

;uc=getimg(7350,index=6,/mdsplus,info=info,/getinfo,/flipy)& imgbin=4


;uc=getimg(7430,index=71,/mdsplus,info=info,/getinfo,/flipy,sm=2)<200 & imgbin=4

;uc=getimg(7891,index=25,sm=1,path='/home/cam112/prlpro/res_jh/mse_data')>350<600& imgbin=1;for finding references
;stop
;uc=getimg(7894,index=35,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 & imgbin=4; smaller radius on

;uc=getimg(7983,index=34,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 & imgbin=4 & uc=float(uc)&uc-=400.& uc=uc>0


;uc=getimg(7485,index=52,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy) & imgbin=2 & uc=float(uc)

;uc=getimg(7869,index=50,info=info,/getinfo,path=getenv('HOME')+'/prlpro/res_jh/mse_data',sm=4)&imbin=4;;;used for vignetting



;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7485,index=52,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy) & imgbin=2 & uc=float(uc)&cmno=13&ii=400
;7897/13
;7983/34
;.201303201517

fileali='~/idl/clive/nleonw/kmse_7891n2/irset.sav'&uc=fltarr(2560,2160)
;getimg(7983,index=34,sm=4,path='/home/cam112/prlpro/res_jh/mse_data')<2000 
 imgbin=4 & uc=float(uc)&uc-=300&uc=uc>0&cmno=24&ii=200


;fileali='~/idl/clive/nleonw/kmse_mate/irset.sav'&uc=read_tiff('~/idl/clive/nleonw/kmse_mate/beam2.tif')&uc=reform(uc(0,*,*))&uc=rotate(uc,5) & imgbin=2 & &cmno=16&ii=400

;fileali='~/idl/clive/nleonw/kmse_7345n2/irset.sav'&uc=getimg(7451,index=44,sm=1,path='/home/cam112/prlpro/res_jh/mse_data',/mdsplus,/flipy)<1000 & imgbin=2 & uc=float(uc)&uc-=00&uc=uc>0&cmno=12&ii=400
;prev line one for NBI2 only
doback=0

dores=1
docmb=1


if dores eq 1 then restore,file='/home/cam112/rsphy/fres/KSTAR/26887/cd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat',/verb  
if dores eq 1 and docmb eq 1 then combinebeams,cd,wt=[1,0]

createvig,size(uc,/dim),vig,imgbin=imgbin
;vig=uc*0+1


sz=size(uc,/dim)

bin=8;0

szb=sz / bin

xx=cd.coords.xx
yy=cd.coords.yy
zz=cd.coords.zz
nx=cd.coords.nx
ny=cd.coords.ny
nz=cd.coords.nz

x2=reform(cd.coords.x,nx,ny,nz)
y2=reform(cd.coords.y,nx,ny,nz)
z2=reform(cd.coords.z,nx,ny,nz)

;rho=reform(cd.coords.rho,nx,ny,nz)
r2=reform(cd.coords.r,nx,ny,nz)
inout=reform(cd.coords.inout,nx,ny,nz)

gr=cd.inputs.g.r
gz=cd.inputs.g.z
ssimag=cd.inputs.g.ssimag
ssibry=cd.inputs.g.ssibry
ix=interpol(findgen(n_elements(gr)),gr*100,r2)
iy=interpol(findgen(n_elements(gz)),gz*100,z2)
psia=interpolate(cd.inputs.g.psirz,ix,iy)
rhoa=(psia-ssimag)/(ssibry-ssimag)
rho=reform(rhoa,nx,ny,nz)
rho=r2;fudge
uo=cd.coords.uo
vo=cd.coords.vo




u=(reform(cd.coords.u,nx,ny,nz))[*,0,0]
v=(reform(cd.coords.v,nx,ny,nz))[0,*,0]
z=reform(z2(0,0,*))
x=reform(x2(*,0,0))
y=reform(y2(0,*,0))
rotangle=cd.inputs.nbgeom.alpha

em=reform(total(cd.neutrals.frspectra,2),nx,ny,nz)     

nlam=n_elements(cd.spectra.lambda)
stoklam=fltarr(nx*ny*nz,nlam,4)
stoklam(*,*,0)=cd.neutrals.frspectra0+cd.neutrals.hrspectra0+cd.neutrals.trspectra0
stoklam(*,*,1)=cd.neutrals.frspectra1+cd.neutrals.hrspectra1+cd.neutrals.trspectra1
stoklam(*,*,2)=cd.neutrals.frspectra2+cd.neutrals.hrspectra2+cd.neutrals.trspectra2
stoklam(*,*,3)=cd.neutrals.frspectra+cd.neutrals.hrspectra+cd.neutrals.trspectra
spv=reform(stoklam,nx,ny,nz,nlam,4)

;; simple model
;spv1=spv(*,ny/2,*,*,*)&spv*=0&spv(*,ny/2,*,*,*)=spv1


getpts,szb,bin,imgbin,pts,file=fileali,doback=doback,detx=detx,dety=dety


ptsr=pts

ptst=pts
ptst(*,*,*,0)-=uo
ptst(*,*,*,1)-=vo
rotangle=-rotangle
ptsr(*,*,*,0) = ptst(*,*,*,0) * cos(rotangle) - ptst(*,*,*,1) * sin(rotangle)
ptsr(*,*,*,1) = ptst(*,*,*,1) * cos(rotangle) + ptst(*,*,*,0) * sin(rotangle)

if dores eq 0 then goto,ee
ix=interpol(findgen(n_elements(xx)),xx,ptsr(*,*,*,0))
iy=interpol(findgen(n_elements(yy)),yy,ptsr(*,*,*,1))
iz=interpol(findgen(n_elements(zz)),zz,ptsr(*,*,*,2))
;stop
spvr=fltarr(szb(0),szb(1),nlam,4)
for il=0,nlam-1 do for k=0,3 do begin
tmp=interpolate(spv(*,*,*,il,k),ix,iy,iz,missing=0)
spvr(*,*,il,k)=total(tmp,3)
print,il,nlam
endfor

ee:
lam=cd.spectra.lambda*1e9

scalld,la,fa,l0=661.1,fwhm=2.,opt='a3'

nxim=n_elements(pts(*,0,0,0))
nyim=n_elements(pts(0,*,0,0))


filtstr={nref:2.05,cwl:661.1}
thetatilt=1.12*!dtor
nlam=n_elements(lam)
f2=fltarr(nlam,nxim,nyim)
tshiftarr=fltarr(nxim,nyim)
dshift2=tshiftarr

mom=fltarr(nxim,nyim,3,4)
;topl=transpose(reform(spvr(*,15,*,0)))

par3={crystal:'bbo',thickness:5e-3,lambda:lam*1e-9,facetilt:30*!dtor}
nwav=opd(1e-6,0.,par=par3,delta=!pi/4)/2/!pi
eikonal = exp(complex(0,1)*2*!pi*nwav)
spvrw=complexarr(nxim,nyim,4)
for i=0,nxim-1 do for j=0,nyim-1 do begin
    thetax = detx(i)/55e-3 - thetatilt
    thetay = dety(j)/55e-3 
    thetao=sqrt(thetax^2+thetay^2)
    dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
    tshifted=filtstr.cwl*dlol ;lam0c=lam0*(1-dlol)
    tshiftarr(i,j)=tshifted
    f2(*,i,j)=interpolo(fa,la,lam+tshifted)  

    for k=0,3 do for h=0,2 do begin
        exp=1.
        if h eq 0 then premu=1.
        if h eq 0 then denom=1 else denom=mom(i,j,0,k)
        if h eq 1 then premu=lam
        if h eq 2 then premu=(lam-mom(i,j,1,k))^2
        if h eq 2 then exp=0.5
        mom(i,j,h,k)=( total(spvr(i,j,*,k)*f2(*,i,j) * premu) / denom )^exp
;        mom(i,j,h,k)=( total(spvr(i,j,*,k) * premu) / denom )^exp

    endfor

    for k=0,3 do begin
        spvrw(i,j,k) = total(spvr(i,j,*,k)*f2(*,i,j)*eikonal)
    endfor

endfor

c1=complex(float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
           -float(spvrw(*,*,2)) - imaginary(spvrw(*,*,1)) )

c2=complex(-float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
           -float(spvrw(*,*,2)) + imaginary(spvrw(*,*,1)) )

p1=atan2(c1)
p2=atan2(c2)

jumpimg,p1
jumpimg,p2

psi=(p1-p2)/4

;top=imaginary(spvrw(*,*,2))
;bottom=float(spvrw(*,*,1))
;p1=atan(-top,bottom)
;p2=atan(-top,-bottom)
;imgplot,topl,lam,indgen(50),pos=posarr(3,1,0)
;imgplot,f2,lam,indgen(50),pos=posarr(/next),/noer
;imgplot,topl*f2,lam,indgen(50),pos=posarr(/next),/noer



;for i=0,nxim-1 do begin



end
