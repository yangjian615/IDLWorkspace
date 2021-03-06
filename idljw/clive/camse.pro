;sh=7274&dtframe=0.0208
;sh=7266&dtframe=0.099
sh=7349 & dtframe=0.50

 goto,aa1
if n_elements(nbi) gt 0 then goto,aa1
spawn,'hostname',host
if host ne 'ikstar.nfri.re.kr' then mdsconnect,'172.17.250.100:8005'
mdsopen,'kstar',sh
;nbi=mdsvalue('\NB1_PB1')
;tnbi=mdsvalue('DIM_OF(\NB1_PB1)')
nbi=cgetdata('NB1_PB1')
ip=cgetdata('PCRC03')

aa1:


doplot=1


sets1={win:{type:'sg',sgmul:1.2,sgexp:10},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+1.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:5.4*105/50.,$        
        typthres:'win',$
        thres:0.1}             


r=0
prec='cal_532_sumd161_1600_1_1080' & sets=sets1
prer='c' & r=sh

nimg=400-2

prearr=[prec,replicate(prer,nimg-1)]
rarr=[0,replicate(r,nimg-1)]
idxarr=[0,indgen(nimg-1)+2]


for i=0,nimg-1 do begin

demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.16,r5fac=0.6,/dofifth,plotwin=0;,linalong=1;,/noopl
;limg=total(img,2)
;    stop
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        ph3s=ph1s
        ph5s=ph1s
        a1s=fltarr(sz(0),sz(1),nimg)
        a2s=a1s
        a3s=a1s
        a5s=a1s
        a4s=a1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    ph3=atan2(outs.c3/outsr.c3)
    ph5=atan2(outs.c5/outsr.c5)

    a1=abs(outs.c1)/abs(outs.c4)
    a2=abs(outs.c2)/abs(outs.c4)
    a3=abs(outs.c3)/abs(outs.c4)
    a5=abs(outs.c5)/abs(outs.c4)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
    ph5s(*,*,i)=ph5

    a4s(*,*,i)=abs(outs.c4)
    a1s(*,*,i)=a1
    a2s(*,*,i)=a2
    a3s(*,*,i)=a3
    a5s(*,*,i)=a5
    if i gt 0 then begin
        a1s(*,*,i)/=a1s(*,*,0)
        a2s(*,*,i)/=a2s(*,*,0)
        a3s(*,*,i)/=a3s(*,*,0)
        a5s(*,*,i)/=a5s(*,*,0)
    endif
goto,ee
pos=posarr(2,2,0)&zr=[0,1]
imgplot,a1s(*,*,i),pos=posarr(/curr),/cb,title='sumordiff',zr=zr
imgplot,a2s(*,*,i),pos=posarr(/next),/cb,title='difforsum',/noer,zr=zr
imgplot,a3s(*,*,i),pos=posarr(/next),/cb,title='5mm',/noer,zr=zr
imgplot,a5s(*,*,i),pos=posarr(/next),/cb,title='3mm',/noer,zr=zr
xyouts,0.5,0.95,string(prearr(i),rarr(i),idxarr(i)),ali=0.5,/norm
ee:
;stop
endfor

nx=n_elements(a4s(*,0,0))
ny=n_elements(a4s(0,*,0))
;plot,a4s(112/2,95/2,*),psym=4
a4s(*,*,0)=0.
tmy=dtframe * (idxarr) -0.18
plot,ip.t,-ip.v,xr=[2.2,3.2] 
plot,nbi.t,nbi.v,xr=!x.crange,col=2,/noer
plot,tmy,a4s(nx/2,ny/2,*),xr=!x.crange,col=4,/noer,psym=-4
plot,tmy,-phs_jump(ph3s(nx/2,ny/2,*)),xr=!x.crange,col=5,/noer,yr=[0,5]
oplot,tmy,phs_jump(ph5s(nx/2,ny/2,*)),col=6
oplot,tmy,phs_jump(ph1s(nx/2,ny/2,*)),col=7
oplot,tmy,-phs_jump(ph2s(nx/2,ny/2,*)),col=9
cursor,dx1,dy,/down
cursor,dx2,dy,/down
dum=min(abs(dx1-tmy),i1)
dum=min(abs(dx2-tmy),i2)
oplot,tmy(i1)*[1,1],!y.crange
oplot,tmy(i2)*[1,1],!y.crange
cursor,dx,dy,/down


pos=posarr(2,2,0)
zr=[0,.2e4]
imgplot,a4s(*,*,i1),zr=zr,pos=pos,title='off'
imgplot,a4s(*,*,i2),zr=zr,pos=posarr(/next),/noer,title='on'
imgplot,a4s(*,*,i1)-a4s(*,*,i2),pos=posarr(/next),/noer,title='on-off'



end


 pars={nimg:1,$
      rarr:[fltarr(1)+1020],$
      iarr:[0],$
      sim:1}

nimg=150


pre='tse' & istart=48
;pre='tse';c';tst;run for tse -> room-> 4 -> 5->6
;pre='tsf'; room->6 then down to 5 then put paper to divert wind at about 15+70+25 run number.. that made a noticable difference
;pre='tsg' ; room->5 with better equal gap between ends and no pol inside-> both external ... but this one never stabilized???
;pre='tsh'&istart=20+30 ; ok chagned oven {same type, andover made} but same controller also changed to have 10+30sec delay not 10+60s delay
;pre='tsi'&istart=69 ; now put spacers in with o rings to make it more solid, then turned up to 7 (~50deg) from 5 (~40deg)  and did up some more screws to make it tighter
;pre='tsj' & istart=30 ; took windows off, set to 5, then turned up to 7 and put ffan on

pre='run' & istart=138 ; green

;pre='tsk' & istart=20;green laser sensicam

;pre='run' & istart=140
mdsplus=0

pre='run' & istart=802 & mdsplus=1

 pare={nimg:nimg,$
      rarr:[istart+indgen(nimg)],$
;      rarr:[0*(10+33+30)+indgen(nimg)],$
;      rarr:[0*(15+70)+indgen(nimg)],$
;      rarr:[1*(15)+indgen(nimg)],$
;      rarr:[1*(15)+indgen(nimg)],$
      iarr:fltarr(nimg),$
      sim:0}
;;pre='tsd';c';tst;run ; for tsd -> room->3->4->5


setsbb={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'hat'},$
;          aoffs:45,$             ;60+45.,$
;          c1offs:10,$
;          c2offs:-10,$
;          c3offs: 0.,$
      aoffs:45,$                      ;12.5,$;0,$;60+45.,$
      c1offs:-10,$
        c2offs:10,$
        c3offs: 0.,$
        fracbw:0.5,$
        pixfringe:10.,$         ;13.5,$
        typthres:'win',$
        thres:0.1}              ; this one for tsd




setscc={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'hat'},$
;          aoffs:45,$             ;60+45.,$
;          c1offs:10,$
;          c2offs:-10,$
;          c3offs: 0.,$
      aoffs:-75,$                      ;12.5,$;0,$;60+45.,$
      c1offs:-10,$
        c2offs:10,$
        c3offs: 0.,$
        fracbw:0.5,$
        pixfringe:10.,$         ;13.5,$
        typthres:'win',$
        thres:0.1}              ; this one for tsd

sets={win:{type:'sg',sgmul:1.5,sgexp:4},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
;      filt:{type:'hat'},$
;          aoffs:45,$             ;60+45.,$
;          c1offs:10,$
;          c2offs:-10,$
;          c3offs: 0.,$
      aoffs:-75,$                      ;12.5,$;0,$;60+45.,$
;      aoffs:-75-90+11,$                      ;12.5,$;0,$;60+45.,$
;      aoffs:-75+11+22.5,$                      ;12.5,$;0,$;60+45.,$
      c1offs:-10,$
        c2offs:10,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:9.*1.05,$         ;13.5,$;*660/530.
;        pixfringe:9.*1.05*1.2,$         ;13.5,$;*660/530.
        typthres:'win',$
        thres:0.1}              ; this one for tsd


par=pare

doplot=1
dokb=1


nimg=par.nimg
iarr=par.iarr


for i=0,nimg-1 do begin
    r=par.rarr(i)
    exists=0                    ;par.sim eq 0 and 
    if doplot eq 0 then demodcs,save={txt:pre,shot:r,ix:iarr(i)},exists=exists,/testexists
    if exists eq 1 then goto,aaf
    
;    if par.sim eq 0 then img=getimg(r,index=iarr(i),sm=1,pre=pre,ndig=3)
    if par.sim eq 0 then img=getimg(r,index=iarr(i),sm=2,pre=pre,ndig=3,mdsplus=mdsplus)
    if par.sim eq 1 then begin
        img=simimg_cxrs4()
    endif
    
    aaf:
;imgplot,img
    
    
;    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:pre,shot:r,ix:iarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.2,r5fac=0.8,/dofifth ;,linalong=45*!dtor;,/noopl
;    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:pre,shot:r,ix:iarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.2,r5fac=0.66,/dofifth ;,linalong=45*!dtor;,/noopl
    demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=1. ,save={txt:pre,shot:r,ix:iarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.2,r5fac=0.66,/dofifth ;,linalong=45*!dtor;,/noopl

;limg=total(img,2)
    
    if i eq 0 then begin
        outsr=outs
        sz=size(outs.c1,/dim)
        ph1s=fltarr(sz(0),sz(1),nimg)
        ph2s=ph1s
        ph3s=ph1s
        ph5s=ph1s
        a1s=fltarr(sz(0),sz(1),nimg)
        a2s=a1s
        a3s=a1s
        a5s=a1s
        
        outss=replicate(outs,nimg)
;        continue
    endif
    outss(i)=outs

    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    ph3=atan2(outs.c3/outsr.c3)
    ph5=atan2(outs.c5/outsr.c5)

    a1=abs(outs.c1)/abs(outs.c4)
    a2=abs(outs.c2)/abs(outs.c4)
    a3=abs(outs.c3)/abs(outs.c4)
    a5=abs(outs.c5)/abs(outs.c4)

    ph1s(*,*,i)=ph1
    ph2s(*,*,i)=ph2
    ph3s(*,*,i)=ph3
    ph5s(*,*,i)=ph5

    a1s(*,*,i)=a1
    a2s(*,*,i)=a2
    a3s(*,*,i)=a3
    a5s(*,*,i)=a5

;    imgplot,ph1,/cb,pos=posarr(3,1,0)
;    imgplot,ph2,/cb,pos=posarr(/next),/noer
;    imgplot,ph3,/cb,pos=posarr(/next),/noer

del=[932.10026,    460.36878,       1403.8318]
del=[1,1,1,1]
    if i gt 1 then begin
!p.psym=-4
        plot,phs_jump(-ph1s(64,54,0:i)),yr=[-1,1]*1*0.3,pos=posarr(2,1,0)
        oplot,phs_jump(ph2s(64,54,0:i))/del(0)*del(1),col=2
        oplot,phs_jump(ph3s(64,54,0:i))/del(2)*del(1),col=4
        oplot,phs_jump(-ph5s(64,54,0:i))/del(2)*del(1),col=5

        oplot,phs_jump(ph3s(64,54,0:i)) + phs_jump(-ph5s(64,54,0:i)),linesty=1,col=2

        oplot,phs_jump(ph3s(64,54,0:i)) - phs_jump(-ph5s(64,54,0:i)),linesty=1,col=1


        plot,a1s(64,54,0:i)*2,yr=[0,.5],pos=posarr(/next),/noer,ysty=1
        oplot,a2s(64,54,0:i)*2,col=2
        oplot,a3s(64,54,0:i),col=4
        oplot,a5s(64,54,0:i),col=5
!p.psym=0
        
    endif

print,a1s(64,54,0)
print,a2s(64,54,0)
print,a3s(64,54,0)
print,a5s(64,54,0)

if dokb eq 1 then stop;begin&a=''&read,'',a&end


;    stop
endfor
stop
end

