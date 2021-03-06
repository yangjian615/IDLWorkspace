;pro analrot, par


; par={nimg:24,$
;      mode:'phase',$
;      rarr:fltarr(24)+1001,$
;      iarr:[shift(intspace(0,23),0*4)],$
;      psi:intspace(0,23) / 24. * 1 * !pi,$
;      epsilon:fltarr(24)+!pi/4,$
;      sim:1}

; par={nimg:24,$
;      mode:'amp',$
;      rarr:fltarr(24)+1002,$
;      iarr:[shift(intspace(0,23),0)],$
;      psi:intspace(0,23) / 24. * 1 * !pi,$
;      epsilon:fltarr(24)+!pi/4,$
;      sim:1}


; par={nimg:24,$
;      mode:'amp',$
;      rarr:fltarr(24)+1003,$
;      iarr:[shift(intspace(0,23),6)],$
;      psi:intspace(0,23) / 24. * 1 * !pi,$
;      epsilon:fltarr(24)+!pi/4/1000,$
;      sim:1}

; par={nimg:24,$
;      mode:'amp',$
;      rarr:fltarr(24)+1004,$
;      iarr:[shift(intspace(0,23),6)],$
;      psi:intspace(0,23) / 24. * 1 * !pi,$
;      epsilon:fltarr(24)+!pi/8,$
;      sim:1}

; par={nimg:24,$
;      mode:'amp',$
;      rarr:[1003,fltarr(23)+1004],$
;      iarr:[18,shift(intspace(0,23),6)],$
;      psi:intspace(0,23) / 24. * 1 * !pi,$
;      epsilon:fltarr(24)+!pi/8,$
;      sim:1}

ns=1;-6&
 pars={nimg:24,$
      mode:'amp',$
      rarr:[fltarr(24)+1009],$
      iarr:[shift(intspace(0,23),ns)],$
      psi:shift(12+intspace(0,23),ns) / 24. * 1 * !pi,$
       epsilon:fltarr(24)+1e-4,$
      sim:2,$
      opt:'a'}

ns=-2;0;;-5
 pare={nimg:24,$
      mode:'amp',$
      rarr:[fltarr(24)+102],$
      iarr:[shift(intspace(0,23),ns)],$
      psi:shift(12+intspace(0,23),ns) / 24. * 1 * !pi,$
      epsilon:fltarr(24)+!pi/4,$
      sim:0,$
      f2:50,$
      w2:6.5e-3*1376,$
      opt:'b'}

 pare2={nimg:24,$
      mode:'amp',$
      rarr:[fltarr(24)+103],$
      iarr:[shift(intspace(0,23),ns)],$
      psi:shift(12+intspace(0,23),ns) / 24. * 1 * !pi,$
      epsilon:fltarr(24)+!pi/4,$
      sim:0,$
      f2:50,$
      w2:6.5e-3*1376,$
      opt:'a'}

ns=0;-2;0;;-5
 parew={nimg:1,$
      mode:'phase',$
      rarr:[fltarr(2)+57],$
      iarr:[shift(intspace(0,1),ns)],$
      psi:shift(12+intspace(0,1),ns) / 24. * 1 * !pi,$
      epsilon:fltarr(2)+!pi/4,$
      sim:0,$
      f2:50,$
      w2:6.5e-3*1376,$
      opt:'b'}


 pare3={nimg:24,$
      mode:'phase',$
      rarr:[fltarr(24)+89],$
      iarr:[shift(intspace(0,23),ns)],$
      psi:shift(12+intspace(0,23),ns) / 24. * 1 * !pi,$
      epsilon:fltarr(24)+!pi/4,$
      sim:0,$
      f2:50,$
      w2:6.5e-3*1376,$
      opt:'b'}



par=parew
    doplot=1
    dokb=1

nimg=par.nimg
iarr=par.iarr
; ;goto,ee
; nimg=16
; ;iarr=[3,intspace(0,14)];*3
; nimg=24;34
; iarr=[intspace(0,33)]
; iarr=[shift(intspace(0,23),0*4),intspace(24,33)]


if par.sim ne 0 then begin
    s0=8000. + par.psi*0
    s1=s0*cos(2*par.psi) * cos(par.epsilon)
    s2=s0*sin(2*par.psi) * cos(par.epsilon)
    s3=s0*sin(par.epsilon)
endif


for i=0,nimg-1 do begin
    r=par.rarr(i)
    mode=par.mode
    exists=0  ;par.sim eq 0 and 
    if doplot eq 0 then demodcs,save={txt:'run',shot:r,ix:iarr(i)},exists=exists,/testexists
    if exists eq 1 then goto,aaf

    if par.sim eq 0 then img=getimg(r,index=iarr(i))
    if par.sim eq 1 then begin
        img=simimg_p1(s0(i),s1(i),s2(i),s3(i),mode=par.mode)
    endif
    if par.sim eq 2 then begin
;        img=simimg_p2(s0(i),s1(i),s2(i),0.,mode=par.mode,deltawp=par.psi(i)+par.epsilon(i),/dosynth)

        img=simimg_p2(s0(i),s1(i),s2(i),s3(i),mode=par.mode,opt=par.opt)
    endif

    aaf:
;imgplot,img

    sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
          filt:{type:'hat'},$
          aoffs:60.,$
          c1offs:180+180,$
          c2offs:0+180,$
          c3offs: par.opt eq 'b' ? 0 : 90,$
          fracbw:1.0,$
          pixfringe:10,$
          typthres:'win',$
          thres:0.1}

    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:'run',shot:r,ix:iarr(i)},downsamp=sets.pixfringe,override=doplot eq 1;,linalong=45*!dtor;,/noopl
;limg=total(img,2)
    
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        phxs=ph1s
        circ1s=fltarr(sz(0),sz(1),nimg)
        circ2s=circ1s
        circxs=circ1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    c1c=outs.c1/outsr.c1
    c2c=outs.c2/outsr.c2
    c3c=outs.c3/outsr.c3
    
    sc1c = float(c1c)/abs(float(c1c)) ;*0+1
    sc2c = float(c2c)/abs(float(c2c)) ;*0+1
    sc3c = float(c3c)/abs(float(c3c)) ;*0+1
    
    if mode eq 'phase' then begin
        ph1=atan2(c1c)
        ph2=atan2(c2c)
        phx=(ph1-ph2)/2.
        if i eq 0 then phx(0,0)=1.

        circ1=atan(abs(outs.c3) * sc3c,2*abs(outs.c1)*sc1c)
        circ2=atan(abs(outs.c3) * sc3c,2*abs(outs.c2)*sc2c)
        circx=atan(abs(outs.c3) * sc3c,(abs(outs.c1)*sc1c + abs(outs.c2)*sc2c) )
    endif
    if mode eq 'amp' then begin
        
        ph1=atan(abs(outs.c3) * sc3c,2*abs(outs.c1)*sc1c)
        ph2=atan(abs(outs.c3) * sc3c,2*abs(outs.c2)*sc2c)
        phx=atan(abs(outs.c3) * sc3c,(abs(outs.c1)*sc1c + abs(outs.c2)*sc2c) )

        circ1=atan2(c1c*sc1c)
        circ2=atan2(c2c*sc2c)
        circx=(circ1+circ2)/2.

        calccorr,par=par,corr=corr,sz=size(ph1,/dim)
;        corr= 
        phx=phx - corr * (par.opt eq 'a' ? -1 : 1)
;        print,c1c(icx,icy)

    endif

    pos=posarr(2,2,0)
    zrr=[-.1,.1]
    icx=sz(0)*0.5
    icy=sz(1)*0.5
;    if n_elements(zrr) ne 0 then dum=temporary(zrr)

    imgplot,ph1-ph1(icx,icy),pos=pos,/cb,title=i*7.5,zr=zrr,pal=-2
    imgplot,ph2-ph2(icx,icy),/noer,pos=posarr(/next),/cb,zr=zrr,pal=-2
    imgplot,phx-median(phx),/noer,pos=posarr(/next),/cb,zr=zrr,pal=-2;(icx,icy)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    phxs(*,*,i)=phx

    circ1s(*,*,i)=circ1
    circ2s(*,*,i)=circ2
    circxs(*,*,i)=circx
    imgplot,circ2-0*median(circx),/cb,pal=-2,pos=posarr(/next),/noer,zr=zrr
if dokb eq 1 then begin&a=''&read,'',a&end
;    stop
endfor
ee:

ix=sz(0)*0.5
iy=sz(1)*0.5


;zfit=intspace(0,nimg-1) / 24. * 2 * !pi ;linspace(0,2*!pi,25)
;plot,zfit*!radeg,

ph1t=(ph1s(ix,iy,*))*!radeg
ph2t=(ph2s(ix,iy,*))*!radeg
circ1t=circ1s(ix,iy,*)*!radeg
circ2t=circ2s(ix,iy,*)*!radeg


save,ph1s,ph2s,phxs,file='/scratch/cam112/demod/pcmb'+string(par.rarr(0),format='(I0)')+'.sav'

;plot,zfit*!radeg,deriv(zfit*!radeg,ph1t),psym=-4
psi=par.psi*2
epsilon=par.epsilon


cv2non,psi,epsilon,chi,delta

plot,ph1t,psym=4



; ;zz=rebin(ph1s,86,65,50)
; ax=5
; ay=5
; zz=congrid(ph1s,ax,ay,nimg)
; zz2=congrid(ph2s,ax,ay,nimg)
; zzr=transpose(reform(zz,ax*ay,nimg))
; zzr2=transpose(reform(zz2,ax*ay,nimg))
; for i=0,ax*ay-1 do zzr(*,i)=phs_jump(zzr(*,i))
; for i=0,ax*ay-1 do zzr2(*,i)=phs_jump(zzr2(*,i))
; ;plotm,zz
; z=phs_jump(ph1s(ix,iy,*))
; z2=phs_jump(ph2s(ix,iy,*))
; plot,z
; ix=indgen(n_elements(z))
; ii=intspace(0,24)
; dum=linfit(ix(ii),z(ii),yfit=zfit)
; zfit=dum(0)+ix*dum(1)
; zfit=intspace(0,nimg-1) / 24. * 2 * !pi ;linspace(0,2*!pi,25)
; zfit(32:*)=0.
; oplot,zfit,col=2
; plot,z-zfit,yr=[-.1,.1]
; zfit2=zfit#replicate(1,ax*ay)
; plotm,(zzr-zzr2)/2.-zfit2,yr=[-.3,.3]/3
; ;oplot,-z2,col=2
; ;plot,(z+z2)/2-zfit


end
