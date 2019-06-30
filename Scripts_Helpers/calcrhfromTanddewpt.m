function rh = calcrhfromTanddewpt(T,dewpt)
%Calculate RH from T and dewpt (both in deg C)
%Uses formula listed at http://andrew.rsmas.miami.edu/bmcnoldy/Humidity.html

rh=100.*(exp((17.625.*dewpt)./(243.04+dewpt))./exp((17.625.*T)./(243.04+T)));

end

