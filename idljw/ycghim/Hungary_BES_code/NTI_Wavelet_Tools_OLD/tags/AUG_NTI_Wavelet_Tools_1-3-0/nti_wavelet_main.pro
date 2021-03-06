;+
;
;NAME: nti_wavelet_main
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2011.07.25.
;
; PURPOSE: Calculate scalograms (or spectrograms), cross/transforms, coherences and mode numbers
;       on the time-frequency plane.
;
; CALLING SEQUENCE (optional variables marked by []): 
;    nti_wavelet_main, data [,dtimeax] [,chpos] [,expname] [,shotnumber] [,timerange] $
;      [,channels] [,channelpairs_used] [,transf_selection] $
;      [,cwt_selection] [,cwt_family] [,cwt_order] [,cwt_dscale] $
;      [,stft_selection] [,stft_window] [,stft_length] [,stft_fres] [,stft_step] $
;      [,freq_min] [,freq_max] $
;      [,crosstr_selection] [,coh_selection] [,coh_avr] [,transfer_selection]$
;      [,mode_selection] [,mode_type] [,mode_filter] $
;      [,mode_steps] [,mode_min [,mode_max] [,startpath] $
;      [,timeaxg [,freqax] [,scaleax] [,transforms] [,smoothed_apsds] $
;      [,crosstransforms] [,smoothed_crosstransforms] $
;      [,coherences] [,transfers] [,modenumbers] [,qs]
;
; INPUTS:
;    data: data vectors, Float[number of data points, number of channels]
;    dtimeax: time axis of data vectors in s, Double[number of data points]
;    chpos: channel positions in radian, Double[number of channels]
;    expname: name of the experiment, String (for example: SXR, MHA); default: 'General'
;    shotnumber: shot number, Long; default: 0
;    timerange: timerange to view in s, Double[2]; default: the start and the end of the time axis
;    channels: channel names, String[number of channels]; default: integer indexes
;    channelpairs_used: the used channel pairs, String[2,number of selected channel pairs]; default: all possible pairs
;    transf_selection: selecting to calculate transforms, Int; default: 1
;    cwt_selection: selecting CWT as transformation, Int; default: 1
;    cwt_family: wavelet family, String; default: 'Morlet'
;    cwt_order: order of wavelet, Long; range: 3 - 24; default: 6 
;    cwt_dscale: fraction of diadic scaling, Double, default: 0.1
;    stft_selection: selecting STFT as transformation. Presently unused, not(cwt_selection) is used.
;    stft_window: window type, String; default: 'Gauss'
;    stft_length: the length of the window in number os data points, Double; default: 50
;    stft_fres: number of frequency samlpes of STFT in number of frequency points, Long; default: 1000
;    stft_step: length of time steps of STFT in number of data points, Long; default: 1
;    freq_min: minimum frequency in kHz, Double; default for STFT: 0, for CWT: the possibly smallest frequency
;    freq_max: maximum frequency in kHz, Double; default: the half of the sampling rate (Nyquist-frequency)
;    crosstr_selection: selecting to calculate cross-transforms, Int; default: 1
;    coh_selection: selecting to calculate coherences, Int; default: 1 
;    coh_avr: number of averages, Long; default: 5
;    transfer_selection: selecting to calculate transfer functions, Int; default: 1 
;    mode_selection: selecting to calculate mode numbers, Int; default: 1 
;    mode_type: type of the mode number, Srting; default: 'Toroidal'
;    mode_filter: type of the mode filter, String; default: 'Rel. pos.'
;    mode_steps: steps between the calculated mode numbers, Double/Int; default: 1
;    mode_min: minimum mode number, Double/Int; default: -6
;    mode_max: maximum mode number, Double/Int; default: 6
;    startpath: start path, String; default: current directory
;
; OUTPUTS:
;    timeax: time axis of transforms in s, Float[number of points in the time axis of the transform]
;    freqax: frequency axis in kHz, Float[number of points in the frequency axis of the transform]
;    scaleax: scale axis (for CWT), Float[number of points in the frequency axis of the transform]
;    transforms: the transformated values, 
;      Complex[number of channels, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    smooth_apsds: the smoothed APSD (auto power density),
;      Float[number of channels, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    crosstransforms: the cross-transform values,
;      Complex[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    smoothed_cosstransforms: the smoothed cross-transform values,
;      Complex[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    coherences: the calculated coherences
;      Float[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    transfers: the calculated transfer functions
;      Complex[2,number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    modenumbers: the calculated mode numbers
;      Float[number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    qs: the calculated q fitting parameter values
;      Float[number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;
;-

pro nti_wavelet_main,$
  ; Input
    data=data, dtimeax=dtimeax, chpos=chpos, expname=expname, shotnumber=shotnumber, timerange=timerange,$
    channels=channels, channelpairs_used=channelpairs_used, transf_selection=transf_selection,$
    cwt_selection=cwt_selection, cwt_family=cwt_family, cwt_order=cwt_order, cwt_dscale=cwt_dscale,$
    stft_selection=stft_selection, stft_window=stft_window, stft_length=stft_length, stft_fres=stft_fres,$
    stft_step=stft_step, freq_min=freq_min, freq_max=freq_max,$
    crosstr_selection=crosstr_selection, coh_selection=coh_selection, coh_avr=coh_avr,$
    transfer_selection=transfer_selection, mode_selection=mode_selection, mode_type=mode_type, mode_filter=mode_filter,$
    mode_steps=mode_steps, mode_min=mode_min, mode_max=mode_max,startpath=startpath,$
  ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs

compile_opt defint32 ; 32 bit integers

; Set defaults and constants
datasize=size(data) ; First index is time, second is channel
nti_wavelet_default,expname,'General'
nti_wavelet_default,shotnumber,0
nti_wavelet_default,timerange,[min(dtimeax),max(dtimeax)]
nti_wavelet_default,channels,string(indgen(datasize(2)))
if not(nti_wavelet_defined(channelpairs_used)) then begin
  channelpairs_used=strarr(2, (datasize(2)*(datasize(2)-1)/2))
  k=0
  for i=0L,datasize(2)-1 do begin
    for j=i+1,datasize(2)-1 do begin
      channelpairs_used(0,k)=channels(i)
      channelpairs_used(1,k)=channels(j)
      k=k+1
    endfor
  endfor
endif
nti_wavelet_default,transf_selection,1
nti_wavelet_default,cwt_selection,1
nti_wavelet_default,cwt_family,'Morlet'
nti_wavelet_default,cwt_order,6
nti_wavelet_default,cwt_dscale,0.1
stft_selection = not(cwt_selection)
nti_wavelet_default,stft_window,'Gauss'
nti_wavelet_default,stft_length,50
nti_wavelet_default,stft_fres,1000
nti_wavelet_default,stft_step,1
if not(nti_wavelet_defined(freq_min)) then freq_min=0 else freq_min=double(freq_min)
if not(nti_wavelet_defined(freq_max)) then freq_max=1.0e32 else freq_max=double(freq_max)
nti_wavelet_default,crosstr_selection,1
nti_wavelet_default,coh_selection,1
nti_wavelet_default,coh_avr,5
nti_wavelet_default,transfer_selection,1
nti_wavelet_default,mode_selection,1
nti_wavelet_default,mode_type,'Toroidal'
nti_wavelet_default,mode_filter,'Rel. pos.'
nti_wavelet_default,mode_steps,1
nti_wavelet_default,mode_min,-6
nti_wavelet_default,mode_max,6
if not(nti_wavelet_defined(startpath)) then cd, current=startpath

;Set size of channelpairs_used:
size_channelpairs_used = size(channelpairs_used)
if (size_channelpairs_used(0) eq 1) then begin
  channelpairs_used = reform(channelpairs_used, 2, 1)
endif

channelsize=n_elements(channels)
crosssize=(size(channelpairs_used))(2)
timeax=dtimeax
timesize=n_elements(timeax)

; Downsampling to freq_max
if timeax(timesize-1)-timeax(0) LT (timesize-1)/(freq_max*1000*2) then begin
  print,'Downsampling data'
  timesize=floor((timeax(timesize-1)-timeax(0))*freq_max*1000*2)
  data_resampled=fltarr(timesize,channelsize)
  for i=0,channelsize-1 do begin
    data_resampled(*,i)=pg_resample(reform(data(*,i)),timesize)
  endfor
  data=data_resampled
  datasize=size(data)
  timeax=timeax(0)+dindgen(timesize)/(freq_max*1000*2) ; New time axis
  timesize=n_elements(timeax)
endif


; Calculate energy-density distributions
if transf_selection then begin
  if cwt_selection then begin
    ; Calculate minimum frequency for CWT
    dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)
    freq_min=max([freq_min*1000,max([1,coh_avr])*cwt_order*2/(timeax(n_elements(timeax)-1)-timeax(0))]) ; in Hz
    start_scale=cwt_order/!PI
    max_scale=cwt_order/freq_min/2/!PI/dt
    nscale=ceil(pg_log2(max_scale/start_scale)/cwt_dscale)+1 ; Calculate nscale from minimum frequency
    freq_min=freq_min/1000. ; Conver to kHz and return
    
  	print,'CWT for '+nti_wavelet_i2str(shotnumber)+channels(0)
  	time=timeax ; Load original time axis for new data
  	transform=pg_scalogram_sim2(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  		start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax, /double)
	  time = float(time)
	  freqax = float(freqax)
	  scaleax = float(scaleax)
  	transformsize=size(transform)
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform
  	for i=1,channelsize-1 do begin
  		print,'CWT for '+nti_wavelet_i2str(shotnumber)+channels(i)
  		time=timeax ; Load original time axis for new data
  		transforms(i,*,*)=pg_scalogram_sim2(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  			start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax, /double)
  	endfor
	  time = float(time)
	  freqax = float(freqax)
	  scaleax = float(scaleax)
  endif else begin
  	print,'STFT for '+nti_wavelet_i2str(shotnumber)+channels(0)
  	freqres=stft_fres*2-1
  	masksize=stft_fres*2-1
  	time=timeax ; Load original time axis for new data
  	transform=pg_spectrogram_sim(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,windowname=stft_window, $
  		windowsize=stft_length,masksize=masksize,step=stft_step, freqres=freqres, plot=-1, freqax=freqax, /double)
	  time = float(time)
	  freqax = float(freqax)
  	transformsize=size(transform)
  	transformsize(2)=transformsize(2)/2+1 ;Store for positive frequencies only
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
  	for i=1,channelsize-1 do begin
  		print,'STFT for '+nti_wavelet_i2str(shotnumber)+channels(i)
  		time=timeax ; Load original time axis for new data
  		transform=pg_spectrogram_sim(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,windowname=stft_window, $
  			windowsize=stft_length,masksize=masksize,step=stft_step, freqres=freqres, plot=-1, freqax=freqax, /double)
  		transforms(i,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
  	endfor
	  time = float(time)
	  freqax = float(freqax)
	  stft_fres = ceil(freqres/2.)
  endelse
  timeax=time ;Set new time axis
  timesize=n_elements(timeax)
endif

;Calculate transformsize again:
  transformsize=size(reform(transforms(0,*,*)))

if crosstr_selection then begin
  ; Create arrays for crosstransforms
  crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))
  
  for i=0,crosssize-1 do begin
  	print,'Crosstransforms for '+nti_wavelet_i2str(shotnumber)+channelpairs_used(*,i)
  	wait,0.1
  	transform1=reform(transforms(where(channels EQ channelpairs_used(0,i)),*,*))
  	transform2=reform(transforms(where(channels EQ channelpairs_used(1,i)),*,*))
  	crosstransforms(i,*,*)=conj(transform1)*transform2 ; Calculate cross-transform
  endfor
endif

if coh_selection then begin
  ; Create array for coherences
  coherences=fltarr(crosssize,transformsize(1),transformsize(2))

  ; Create array for transfer functions
  if transfer_selection then begin
  transfers=complexarr(2,crosssize,transformsize(1),transformsize(2))
  endif
  
  ; Calculate smoothed energy density distributions
   if (coh_avr GT 0) then begin
    print,'Smoothing energy density distributions'
    wait,0.1
    smoothed_apsds=fltarr(channelsize,transformsize(1),transformsize(2))
    for i=0,channelsize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do begin
          inttime=ceil(scaleax(k)*coh_avr*2.)
          if inttime GT transformsize(1) then begin
            print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
            inttime=transformsize(1)
          endif
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
        endfor
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        if inttime GT transformsize(1) then begin
          print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
          inttime=transformsize(1)
        endif
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
      endelse
    endfor
    
    ; Calculate smoothed cross-transforms
    print,'Smoothing cross-transforms'
    wait,0.1
    smoothed_crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))
    for i=0,crosssize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do begin
          inttime=ceil(scaleax(k)*coh_avr*2.)
          if inttime GT transformsize(1) then begin
            print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
            inttime=transformsize(1)
          endif
          smoothed_crosstransforms(i,*,k)=smooth(reform(crosstransforms(i,*,k)),inttime, /EDGE_TRUNCATE)
        endfor
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        if inttime GT transformsize(1) then begin
          print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
          inttime=transformsize(1)
        endif
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_crosstransforms(i,*,k)=smooth(reform(crosstransforms(i,*,k)),inttime, /EDGE_TRUNCATE)
      endelse
    endfor
  endif else begin
    smoothed_apsds=abs(transforms)^2
    smoothed_crosstransforms=crosstransforms
  endelse
  
  ;Calculate coherence
  print,'Calculate coherences'
  for i=0,crosssize-1 do begin
    smoothed_apsd1=reform(smoothed_apsds(where(channels EQ channelpairs_used(0,i)),*,*))
    smoothed_apsd2=reform(smoothed_apsds(where(channels EQ channelpairs_used(1,i)),*,*))
    coherences(i,*,*)=float(abs(reform(smoothed_crosstransforms(i,*,*)))/sqrt(smoothed_apsd1*smoothed_apsd2))
  endfor

  ;Calculate transfer function
  if transfer_selection then begin
    print,'Calculate transfer functions'
    for i=0,crosssize-1 do begin
      transfers(0,i,*,*)=complex(reform(smoothed_crosstransforms(i,*,*))/smoothed_apsd1)
      transfers(1,i,*,*)=complex(reform(smoothed_crosstransforms(i,*,*))/smoothed_apsd2)
    endfor
  endif
endif

if mode_selection then begin
  ; Calculate mode numbers on the time-frequency plane
  print,'Mode numbers for '+nti_wavelet_i2str(shotnumber)
  wait,0.1
  ; Create array for mode numbers
  modenumbers=fltarr(transformsize(1),transformsize(2))+1000 ; Initialize mode number arraz with 1000 standing for undefined
  qs=fltarr(transformsize(1),transformsize(2))
  if (size(smoothed_crosstransforms))(0) LT 2 then $ ; Calculate cross-phase
    cphases=atan(imaginary(crosstransforms),float(crosstransforms))$
    else $
    cphases=atan(imaginary(smoothed_crosstransforms),float(smoothed_crosstransforms))
    
  
  T=systime(1) ; Initialize progress indicator
  ; Fill 2D chpos array
  chpos2D=fltarr(2,crosssize)
  for i=0,1 do begin
    for j=0,crosssize-1 do begin
      chpos2D(i,j)=chpos(where(channels EQ channelpairs_used(i,j)))
    endfor
  endfor
;  channels=transpose(channels)
;  chpos2D=transpose(chpos2D)
  for i=0,transformsize(1)-1 do begin
  	for j=0,transformsize(2)-1 do begin
  	  case mode_filter of 
  	    'Rel. pos.': begin
          ; Filter Rel. Pos.: positive-negative mode numbers from relative positions
          ; (linear fit with weighting 1)
          m0=pg_modefilter_fitrel(reform(cphases(*,i,j)),chpos2D,$
            modestep=mode_steps, moderange=[mode_min,mode_max],qs=qs_all,ms=ms_all)
          if NOT(m0 EQ 1000) then begin
            modenumbers(i,j)=m0
            qs(i,j)=min(qs_all)
          endif
        end
      endcase

  		; Progress indicator
  		if floor(systime(1)-T) GE 10 then begin
  			print, pg_num2str(double(i)/double(transformsize(1))*100.)+' % done'
  			T=systime(1)
  			wait,0.1
  		endif
  	endfor
  endfor
endif

end
