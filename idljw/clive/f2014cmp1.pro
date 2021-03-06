pro f2014s, case1,bm,res,ex=ex
default,ex,''
lut=0
db='k'

if case1 eq 'old' and bm eq 1 then begin
;   sh=9323 & twant=0.925 & multiplier=1
sh=9328 & twant=0.54 & multiplier=1 ; beam 1 into gas last campaign
;90kV
endif

;sh=9955 & twant=2.38 & multiplier=4 ; beam3 new campgin

;sh=10536 & twant=0.9 & multiplier=1

;sh=10536 & twant=10.64 +0.04*0& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)

if case1 eq 'new' and bm eq 1 then begin
sh=10536 & twant=0.92& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)
endif

if case1 eq 'new' and bm eq 1 and ex eq '90' then begin
sh=10558 & twant=0.92& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)
endif

if case1 eq 'new' and bm eq 1 and ex eq '95' then begin
sh=10560 & twant=0.92& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)
endif

if case1 eq 'new' and bm eq 1 and ex eq '80' then begin
sh=10559 & twant=0.92& multiplier=1&db='kl' ; one recomended by ntm eccdguy (young)
endif


;sh=10502 & twant=14.0 & multiplier=1&db='kl' ; biam ingo gas
;sh=10502 & twant=8.6 & multiplier=1&db='kl' ; biam ingo gas

;sh=33 & twant = 2. & multiplier=1 & db='kcal2014'

;sh=9332 & twant=0.82 & multiplier=1 ; beam 2 into gas last campaign vf -6ka
;sh=9328 & twant=0.54 & multiplier=1 ; beam 1 into gas last campaign

;sh=9958 & twant=1.04 & multiplier=3 ; beam2

if case1 eq 'new' and bm eq 2 then begin
   sh=9998 & twant=3.10 & multiplier=3 ; beam 2 new campaign
endif

;sh=9892 & twant=0.95 & multiplier=1 ; pol in

;sh=9880 & twant=3.36 & multiplier=1 ; first shot

;sh=9943 & twant=0.8 & multiplier=1  ; ok b3 early one

if case1 eq 'old' and bm eq 2 then begin
;sh=9414 & twant=6.425 & multiplier=1 ; b2 old campaign

sh=9328 & twant=0.82 & multiplier=1 ; beam 2 into gas last campaign
;80kV
endif



 newdemodflclt,sh,twant=twant,multiplier=multiplier,/only2,demodtype='sm32013mse',lut=lut,/noid2,angt=ang,dostop=0,db=db,doplot=0,inten=inten,lin=lin,dopc=dopc


if case1 eq 'new' then begin
sh=33 & twant = 2. & multiplier=1 & db='kcal2014' & sg=1.
endif

if case1 eq 'old' then begin
sh=172 & twant = 33. & multiplier=1 & db='kcal' & sg=-1
endif

lut=0
 newdemodflclt,sh,twant=twant,multiplier=multiplier,/only2,demodtype='sm32013mse',lut=lut,/noid2,angt=ang2,dostop=0,db=db,doplot=0,inten=inten2,lin=lin2,dopc=dopc2

deltadopc=dopc-dopc2
deltadopc*=!dtor&jumpimg,deltadopc&deltadopc*=!radeg*sg
;imgplot,deltadopc,/cb
;plotm,deltadopc
;plotm,inten,/noer
sz=size(deltadopc,/dim)
res=deltadopc(*,sz(1)/2)
end

;fac=1.
fac=1

;goto,ee
f2014s,'old',1,d80
f2014s,'new',1,d90,ex='90'

;analbeam6,0,ans70x,ans70,1.,1,cmno=34
;analbeam6,1,ans60x,ans60,1.,1,cmno=34


;analbeam6,0,ans80x,ans80,-1.,0,cmno=33

ee:
n=n_elements(d80)
plot,d80-d80(n/2),title='beam 1'
oplot,n/2*[1,1],!y.crange
oplot,(d90-d90(n/2))*fac,col=2
legend,['old #9328','new #9998 [both 90kV'],textcol=[1,2]


end


