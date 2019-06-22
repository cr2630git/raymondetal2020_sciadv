function pressure = pressurefromelev(elev)
%Calculates pressure (hPa) at a given elevation (m)
%   Uses the US standard atmosphere, verified with http://www.emd.dk/files/windpro/WindPRO_AirDensity.pdf

%Necessary constants
Tbase=288;      %temperature at base (i.e. at 1000 hPa) -- K
L=-6.5;         %lapse rate -- K/km
G=-9.81;        %gravity -- m/s^2
M=28.96;        %density of air -- kg/mol
R=8.314;        %universal gas constant -- J/(kg*mol)

pressure=1000*((Tbase+L*10^-3*elev)/Tbase).^((G*M)/(R*L));

end

