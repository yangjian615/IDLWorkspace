
fn='~/car'

read_jpeg,fn+'.jpg',pic,ct,colors=256

;r,g,b,/verbose)
;stop
r=ct(*,0)
g=ct(*,1)
b=ct(*,2)
tvlct, r, g, b

d1=n_elements(pic(*,0))
d2=n_elements(pic(0,*))

fc=0.5
pic0=pic
pic=congrid(pic,d1*fc,d2*fc)
tv,pic

vx0=0. & vy0=0. & vx1 = 0. & vy1= 0.
read, 'value of x0 :',vx0
read, 'value of x1 :',vx1


 print, 'click on bl'
 cursor, x0, y0, /down,/dev
 print, 'click on tr'
 cursor, x1, y1, /down, /dev

 pic2=pic0(2*x0:2*x1,2*y0:2*y1)
 d1=2*x1-2*x0+1
 d2=2*y1-2*y0+1
 expfact=1.
 read,'expansion factor', expfact
 ;pic2 = rebin(pic2,d1*expfact,d2*expfact)
 pic2 = congrid(pic2,d1*expfact,d2*expfact);,/interp)

 d1=d1*3
 d2=d2


tv, pic2
tvlct, r, g, b
;stop
!mouse.button = 1

parr=fltarr(10000,2)
np=0
tek_color
while !mouse.button ne 4 do begin
    cursor, dx, dy,/device,/down
    parr(np,*) = [dx,dy]
    if np gt 0 then plots, parr([np-1,np],0), parr([np-1,np],1),color=2,/device,thick=2
    np=np+1
endwhile

print, 'click on bl (x0,y0) axis'
cursor, x0, y0,/down,/device
print, 'click on br (x1,y0) axis'
cursor, x1, dy,/down,/device
print, 'click on tl (x0,y1) axis'
cursor, dx, y1,/down,/device

read, 'value of y0 :',vy0
read, 'value of y1 :',vy1

x=float(parr(0:np-1,0)-x0) * float(vx1-vx0)/float(x1-x0) + vx0
y=float(parr(0:np-1,1)-y0) * float(vy1-vy0)/float(y1-y0) + vy0

idx=sort(x)
x=x(idx)
y=y(idx)

plot, x, y,psym=2
save,x,y,file=fn+'.sav',/verb
end





