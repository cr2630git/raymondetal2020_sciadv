function [eraeastrow,erawestrow,eranorthcol,erasouthcol,pt1w,pt2w,pt3w,pt4w] = erainfoforpt(lat,lon)
%Gets four ERA pts surrounding a given lat/lon point, and also computes the appropriate weights

fracdeglat=rem(lat,1);stemdeglat=lat-fracdeglat;
if lat<0;latsign=-1;else;latsign=1;end
if abs(fracdeglat)<=0.5;closesteralat=stemdeglat+latsign*0.25;else;closesteralat=stemdeglat+latsign*0.75;end
if lat>closesteralat
    eralatsouth=closesteralat;eralatnorth=closesteralat+0.5;
else
    eralatnorth=closesteralat;eralatsouth=closesteralat-0.5;
end
eralatnorth_weight=1-(abs(lat-eralatnorth)/0.5);
eralatsouth_weight=1-(abs(lat-eralatsouth)/0.5);

fracdeglon=rem(lon,1);stemdeglon=lon-fracdeglon;
if lon<0;lonsign=-1;else;lonsign=1;end
if abs(fracdeglon)<=0.5;closesteralon=stemdeglon+lonsign*0.25;else;closesteralon=stemdeglon+lonsign*0.75;end
if lon>closesteralon
    eralonwest=closesteralon;eraloneast=closesteralon+0.5;
else
    eraloneast=closesteralon;eralonwest=closesteralon-0.5;
end
eraloneast_weight=1-(abs(lon-eraloneast)/0.5);
eralonwest_weight=1-(abs(lon-eralonwest)/0.5);

%Convert lat/lon to ERA ordinates
%Arrays are oriented with north at left and 0 deg at top, with longitude increasing downward
eranorthcol=180.5-2*eralatnorth;erasouthcol=180.5-2*eralatsouth;
if lon>0
    eraeastrow=0.5+2*eraloneast;erawestrow=0.5+2*eralonwest;
else
    eraeastrow=720.5+2*eraloneast;erawestrow=720.5+2*eralonwest;
end

%Calculate final weights for all four points for each station
totaldist=sqrt(eraloneast_weight^2+eralatnorth_weight^2)+sqrt(eraloneast_weight^2+eralatsouth_weight^2)+...
    sqrt(eralonwest_weight^2+eralatsouth_weight^2)+sqrt(eralonwest_weight^2+eralatnorth_weight^2);
pt1w=sqrt(eraloneast_weight^2+eralatnorth_weight^2)/totaldist;
pt2w=sqrt(eraloneast_weight^2+eralatsouth_weight^2)/totaldist;
pt3w=sqrt(eralonwest_weight^2+eralatsouth_weight^2)/totaldist;
pt4w=sqrt(eralonwest_weight^2+eralatnorth_weight^2)/totaldist;

end

