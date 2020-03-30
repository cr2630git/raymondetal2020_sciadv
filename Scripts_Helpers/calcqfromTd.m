function qarray = calcqfromTd(Tdarray)
%Calculates q (specific humidity) from Td, using the formula of Bolton 1980
    %(listed at https://www.eol.ucar.edu/projects/ceop/dm/documents/refdata_report/eqns.html)
%Td is in C, q is in g/kg

%Table for validation: http://www.engineeringtoolbox.com/moist-air-properties-d_1256.html


%First, compute vapor pressure
vp=6.112.*exp((17.67.*Tdarray)./(Tdarray+243.5));

%Then, specific humidity is trivial to compute, assuming that sfc pressure is 1010 mb
sfcP=1010;
qarray=1000.*(0.622.*vp)./(sfcP-(0.378.*vp));


end

