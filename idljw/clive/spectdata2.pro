pro spectdata2,d,ps,t,f,t0=t0,fdig=fdig,dt=dt,df=df,dostop=dostop,nohan=nohan

default,t0,0.
default,fdig,1e6
default,df,10.e3
default,dt,0.1
nt0=n_elements(d)
nf=fdig/df/2.

tarr=findgen(nt0)/fdig+t0
npb=round(dt*fdig)
print,npb
nt = nt0/npb
f=findgen(nf)/float(nf)*fdig/2
f2=findgen(nf*2)/float(nf*2)*fdig
t=fltarr(nt)
ps=fltarr(nt,nf)
win=hanning(npb)
if keyword_set(nohan) then win(*)=1.
iwant=fltarr(nf+1)
f1=findgen(npb)/float(npb)*fdig
print,'npb=',npb
;for i=0L,nf do begin
;    dummy=min(abs(f1-f2(i)),imin)
;    iwant(i)=imin
;endfor
iwant=value_locate(f1,f2)
for i=0L,nt-1 do begin
    idx=lindgen(npb) + long(npb)*i
    t(i)=tarr(idx(0))
;    stop
    s=abs(fft(d(idx)*win))^2

;    for j=0,nf-1 do begin
;        idx2=where((f1 ge f2(j)) and (f1 lt f2(j+1)))
        pcum=total(double(s),/cum)
        pcumi2=pcum(iwant(1:nf))
        pcumi1=pcum(iwant(0:nf-1))
        pstemp=pcumi2-pcumi1
        ps(i,*)=pstemp
;        stop
;    endfor
endfor

if keyword_set(dostop) then stop
end

