%Calculate 2-m TW in 6-hourly ERA-Interim data from T and Td
%Care needs to be taken to avoid overloading Matlab

%V1: Values corresponding to T>=27 C are computed but only for SW Asia (i=60:140, j=110:150)
    %this is 15.5-35.5 N, 29.75-69.75 E
%V2: Values corresponding to only T>=31 C are computed but for the whole globe
v=1;

datadir='/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/';
if v==1;arrayname='swasia';elseif v==2;arrayname='globe';end

%30 sec per year for reading in T and Td, 10 sec for converting to q, 18 (30) min per year for calculating Tw via V1 (V2)
for year=1980:2017 %default is 1979-2017
    disp(clock);
    thisyeart=ncread(strcat(datadir,'t2m',num2str(year),'.nc'),'t2m')-273.15;
    thisyeartd=ncread(strcat(datadir,'td2m',num2str(year),'.nc'),'d2m')-273.15;
    
    thisyearq=calcqfromTd(thisyeartd)./1000;

    thisyeartw=NaN.*ones(size(thisyeart,1),size(thisyeart,2),size(thisyeart,3));
    
    if v==1
        istart=60;iend=140;jstart=110;jend=150;
    elseif v==2
        istart=1;iend=size(thisyeart,1);jstart=1;jend=size(thisyeart,2);
    end
   
    posted=0;
    for i=istart:iend
        for j=jstart:jend
            for k=1:size(thisyeart,3)
                if thisyeart(i,j,k)>=27
                    thisyeartw(i,j,k)=calcwbt_daviesjones(thisyeart(i,j,k),10^5,thisyearq(i,j,k));
                end
            end
        end
        if i>istart+(iend-istart)/2 && posted==0
            fprintf('Halfway thru for year %d\n',year);disp(clock);posted=1;
        end
    end
    %Alternative full calculation
    %presmatrix=10^5.*ones(size(thisyeart,1),size(thisyeart,2),size(thisyeart,3));
    %thisyeartw=calcwbt_daviesjones(thisyeart,presmatrix,thisyearq);
    
    save(strcat(datadir,'savederatwarrays_',arrayname,num2str(year)),'thisyeartw','-v7.3');
    fprintf('Just finished year %d\n',year);disp(clock);
end

