@calches
function f, a, delay
common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
;[vcore,tcore,tcore2,aa0]
vcore=a(0)
tcore=a(1)
tedge=a(3)
vcore2=a(4)
tcore2=a(5)
;tcore3=a(3)
aa0=a(2)
ap0=1-aa0;a(3)
l0=cl0
l1=cl1
l2=cl2
ap1=cap1
ap2=cap2
;tedge=ctedge

forward_function fgaussof

fa0=aa0 * fgaussof(delay,l0,vcore,tcore) 
fp0=ap0 * fgaussof(delay,l0,0,tedge)
fp1=ap1 * fgaussof(delay,l1,0,tedge)
fp2=ap2 * fgaussof(delay,l2,0,tedge)

ftot1=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

fa0=aa0 * fgaussof(delay,l0,vcore2,tcore2) 

ftot2=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

;fa0=aa0 * fgaussof(delay,l0,vcore,tcore3) 

;ftot3=(fa0+fp0+fp1+fp2)/(aa0+ap0+ap1+ap2)

ftot=[ftot1,ftot2];,ftot3]

;print,'called f, a=',a,'delay=',delay,'result=',ftot
;if a(0) ne 1.8 then stop

return,ftot
end



function gaussof,lam,l0,vrot,ti



echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti/mi)/clight
scal=4e4/clight

vel=(lam-l0)/l0

val=exp(-(vel-vrot/clight)^2 / vth^2) / (vth/scal)
return,val
end

function fgaussof,N,l0,vrot,ti,lref=lref

kappa=1.

default,lref,529.0


echarge=1.6e-19
mi=6*1.67262158e-27;carbon
clight=3e8

vth=sqrt(2 * echarge * ti*1e3/mi)/clight
;vrot in units of 100km/s, ti in units of 1000eV
vrotc=(vrot * 100e3)/clight
dl=(l0-lref)/lref
ii=dcomplex(0,1)
gamma=exp(2*!pi*ii*N* (1+ kappa * (vrotc + dl)) - (!pi*kappa*N)^2 * vth^2)

return,gamma
end




tedge=0.6;01
tcore=3.5
tcore2=1.0
;tcore3=1.
vcore=2. * sqrt(tcore/3.5)
vcore2=vcore*sqrt(tcore2/tcore)
;vcore3=vcore*sqrt(tcore3/tcore)



dmax=1000
wthr=1e59 ; 1e3


l0=529.0

l1 = 529.4
l2=530.4

ap0=0.2
ap1=0.;05
ap2=0.;1
aa0=1.

asum=aa0+ap0+ap1+ap2

aa0/=asum
ap0/=asum
ap1/=asum
ap2/=asum

delay=linspace(0,2000,151) & nd=n_elements(delay)
par=[vcore,tcore,aa0,tedge,vcore2,tcore2]*1d0
common cbb,cl0,cl1,cl2,cap1,cap2,ctedge
cl0=l0
cl1=l1
cl2=l2
cap1=ap1
cap2=ap2
ctedge=tedge

ftot=f(par,delay)
fref=fgaussof(delay,l0,0,0.1) 

plot,delay,abs(ftot(0:nd-1))
oplot,delay,abs(ftot(nd:2*nd-1)),col=2

dinc=100.
dmax=1500.
nn=dmax/dinc
cmax=10000&cnt=0
ndel=3
npar=n_elements(par)
iarr=fltarr(ndel,cmax)
xx=0
for i1=1,nn do for i2=i1+xx,nn do for i3=i2+xx,nn do begin;lfor i4=i3,nn do begin
    iarr(0,cnt)=i1
    iarr(1,cnt)=i2
    iarr(2,cnt)=i3
;    iarr(3,cnt)=i4
cnt=cnt+1
endfor
ncnt=cnt
iarr=iarr(*,0:ncnt-1)
npar=n_elements(par)
met=fltarr(ncnt,npar)

for cnt=0,ncnt-1 do begin

;for i=n1/2,n1-1 do for j=n2-1,n2-1 do begin
delay1=dinc*iarr(0,cnt)
delay2=dinc*iarr(1,cnt)
delay3=dinc*iarr(2,cnt)

plot,delay,abs(ftot(0:nd-1))
oplot,delay,abs(ftot(nd:2*nd-1)),col=2

oplot,delay1*[1,1],!y.crange,linesty=2,col=2
oplot,delay2*[1,1],!y.crange,linesty=2,col=4
oplot,delay3*[1,1],!y.crange,linesty=2,col=4

vec=[delay1,delay2,delay3]
wt=[1,1,1,1,1,1]

scal=[1,1,1,1,1,1]*1d-5
calches,par,vec,hes,scal=scal,wt=wt
calches,par,vec,hes2,scal=scal/2,wt=wt
outby=max(abs(hes2/hes-1))
if outby gt 0.05 then begin
    print,'hessian error',outby
;    print,hes/hes2,outby
;    hes*=!values.d_nan


;    stop
;    continue
endif else print, 'hessian status:',outby
eval = float(HQR(ELMHES(hes), /DOUBLE))
;hes(1,2)=hes(2,1)
;hes(0,2)=hes(2,0)
;hes(0,1)=hes(1,0)
;eval=eigenql(hes)
print,'eigenvalues:',eval

if total(eval gt 0) ne npar then continue
;svdc,hes,w,u,v,/double
ihes0=invert(hes)
ihes=sqrt(ihes0)
dihes=diag_matrix(ihes)
met(cnt,*)=dihes
print,'errors',dihes

;stop
if n_elements(imax) ne 0 then begin
    aa=''
    if cnt eq imax then stop    ; read,'',aa
endif


endfor
plot,1/met(*,1),yr=[0,.6],xtitle='config #',ytitle='inverse error'
oplot,1/met(*,5),col=2
cmb=1/met(*,1)+1/met(*,5)
oplot,cmb,col=4
ift=where(finite(cmb))
dum=max(cmb(ift),imax) & imax=ift(imax)
plots,imax,cmb(imax),psym=4,col=4
print,dinc*iarr(*,imax)
legend,['tcore (3.5kV)','tcore2 (1kV)','sum'],textcol=[1,2,4],/right,box=0


end


