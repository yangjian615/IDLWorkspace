function getflcnew,sh
common cbshot, shotc,dbc, isconnected
mdsopen,'mse',sh
flc={flc0:cgetdata('.DAQ.DATA:FLC_0',/norest),flc1:cgetdata('.DAQ.DATA:FLC_1',/norest),flc0ms:[mdsvalue('.MSE.FLC.FLC__00:MARK'),mdsvalue('.MSE.FLC.FLC__00:SPACE')],flc1ms:[mdsvalue('.MSE.FLC.FLC__01:MARK'),mdsvalue('.MSE.FLC.FLC__01:SPACE')],flc0i:mdsvalue('.MSE.FLC.FLC__00:INVERT'),flc1i:mdsvalue('.MSE.FLC.FLC__00:INVERT') ,edge:mdsvalue('.MSE.FLC_EDGE')}
mdsclose
return,flc
end
