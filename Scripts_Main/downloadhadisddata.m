%Downloads and reads in data from the HadISD subdaily global station dataset
%Most common settings are computedailydata=1, doingindivstn=1, and everything else =0
%THIS SCRIPT PRODUCES FILES THAT HAVE ALREADY BEEN SAVED, AND THEREFORE
    %EXISTS SIMPLY FOR THE PURPOSES OF RECORD-KEEPING RATHER THAN RE-RUNNING

downloaddata=0; %about 2 sec per stn, 5 hours total for 7877 stns
computedailydata=1; %about 2 min per stn, 140 hours total for 7877 stns
    resetarrays=0; %1 min
    doingindivstn=1; %2 min; does computation for station 's'; for this, nothing usually needs to be saved
    enforceaddlqc=0;
getelevdataallstns=0; %10 sec
    

datadir='/Volumes/ExternalDriveC/HadISD_station_data/';
firstyear=1931;firstday=1;
finalyear=2016;

versionstring1='v201_2016f';
versionstring2='2.0.1.2016f';
totalnumdays=31412;


[stncodes,stnnames,stnlats,stnlons,stnelevs,stnstarts,stnends]=...
    textread(strcat('hadisd_station_metadata_v',num2str(finalyear),'.txt'),'%12c %30c %7f %8f %6f %10s %10s');

%Download data for stations with at least 30 years of data (e.g. a starting date <=1985)
if downloaddata==1
    for stn=1:size(stnnames,1)
        startdate=cell2mat(stnstarts(stn));
        if str2double(startdate(1:4))<=1985
            stncode=stncodes(stn,:);
            outfilename=websave(strcat('/Volumes/ExternalDriveC/NewStnDataJul31/',stncode,'.nc.gz'),...
                strcat('https://www.metoffice.gov.uk/hadobs/hadisd/',versionstring1,...
                '/data/hadisd.',versionstring2,'.',stncode,'.nc.gz'));
        end
        if rem(stn,100)==0;disp(stn);disp(clock);end
    end
end

%Then, unzip all files using gunzip


%Get daily data for each station
%WBT is computed using the Davies-Jones 2008 method 
    %Function was written by Bob Kopp (http://www.bobkopp.net/software/), relying on the formulae of Bolton (1980)
    %Pressure is taken to be a fixed function of elevation, with SLP always =1010 mb
    %Effect of using this vs Stull is about 0.5 deg C in the global average
%In each file, time is given as hours since 1931-01-01 00:00 (hour 705284)
if computedailydata==1
    if resetarrays==1
        if ~doingindivstn==1 %otherwise, these arrays are erased when the full versions 
                %may be needed in some other script (e.g. analyzeextremewbt)
            finalstncodes={};
            finalstnlatlon=NaN.*ones(size(stnnames,1),2);
            finaltarray=NaN.*ones(size(stnnames,1),totalnumdays,4);
            finaldewptarray=NaN.*ones(size(stnnames,1),totalnumdays,4);
            finalwbtarray=NaN.*ones(size(stnnames,1),totalnumdays,4);
        end
    end
    [stncodes,stnnames,stnlats,stnlons,stnelevs,~,~]=...
        textread('hadisd_station_metadata_v2016.txt','%12c %30c %7f %8f %6f %10s %10s');
    exist enforceaddlqc;if ans==0;enforceaddlqc=1;end
    slp=1010; %mb; not 1013 slightly lower b/c lower P over land than ocean
    
    for stn=s:s
        thisfilename=strcat(datadir,stncodes(stn,:),'.nc');
        if exist(thisfilename,'file')==2
            %Using the full subdaily data, get temperature, dewpoint, and time vectors for this station, 
                %and also compute TW
            temperature=ncread(thisfilename,'temperatures');
            invalid=abs(temperature)>200;temperature(invalid)=NaN;
            dewpoint=ncread(thisfilename,'dewpoints');
            invalid=abs(dewpoint)>200;dewpoint(invalid)=NaN;
            spechum=calcqfromTd(dewpoint)./1000;
            pres=pressurefromelev(finalstnelev(stn)).*slp./1000.*100.*ones(size(spechum,1),size(spechum,2),size(spechum,3));
            wbt=calcwbt_daviesjones(temperature,pres,spechum); %Davies-Jones method
            time=ncread(thisfilename,'time'); %contains hours since 1/1/1931

            finalstncodes{stn}=stncodes(stn,1:6);
            finalstnlatlon(stn,1)=ncread(thisfilename,'latitude');
            finalstnlatlon(stn,2)=ncread(thisfilename,'longitude');

            %Compute daily Tmax and WBTmax for every day, or a selected subset of them (e.g. those in a particular year)
            if ~doingindivstn==1
                year=firstyear;doy=1;
                daystarthours=0:24:totalnumdays*24-24;
                dayendhours=23:24:totalnumdays*24-1;
                for day=firstday:totalnumdays
                    if doy>=366 || day==totalnumdays
                        if rem(year,4)==0;daysinyear=366;else;daysinyear=365;end
                        if doy>daysinyear
                            finaltarray(stn,day-daysinyear:day-1,1)=year;
                            finaltarray(stn,day-daysinyear:day-1,2)=1:daysinyear;
                            finaldewptarray(stn,day-daysinyear:day-1,1)=year;
                            finaldewptarray(stn,day-daysinyear:day-1,2)=1:daysinyear;
                            finalwbtarray(stn,day-daysinyear:day-1,1)=year;
                            finalwbtarray(stn,day-daysinyear:day-1,2)=1:daysinyear;
                            doy=1;year=year+1;
                        elseif day==totalnumdays
                            finaltarray(stn,day-daysinyear+1:day,1)=year;
                            finaltarray(stn,day-daysinyear+1:day,2)=1:daysinyear;
                            finaldewptarray(stn,day-daysinyear+1:day,1)=year;
                            finaldewptarray(stn,day-daysinyear+1:day,2)=1:daysinyear;
                            finalwbtarray(stn,day-daysinyear+1:day,1)=year;
                            finalwbtarray(stn,day-daysinyear+1:day,2)=1:daysinyear;
                        end
                    end

                    curdaystarthour=daystarthours(day);
                    curdayendhour=dayendhours(day);

                    dailytmax=nanmax(temperature(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));
                    dailytmin=nanmin(temperature(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));
                    dailydewptmax=nanmax(dewpoint(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));
                    dailydewptmin=nanmin(dewpoint(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));
                    dailywbtmax=nanmax(wbt(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));
                    dailywbtmin=nanmin(wbt(time(:,1)>=curdaystarthour & time(:,1)<=curdayendhour));


                    if size(dailytmax,1)==0;finaltarray(stn,day,3)=NaN;else;finaltarray(stn,day,3)=dailytmax;end
                    if size(dailytmin,1)==0;finaltarray(stn,day,4)=NaN;else;finaltarray(stn,day,4)=dailytmin;end
                    if size(dailydewptmax,1)==0;finaldewptarray(stn,day,3)=NaN;else;finaldewptarray(stn,day,3)=dailydewptmax;end
                    if size(dailydewptmin,1)==0;finaldewptarray(stn,day,4)=NaN;else;finaldewptarray(stn,day,4)=dailydewptmin;end
                    if size(dailywbtmax,1)==0;finalwbtarray(stn,day,3)=NaN;else;finalwbtarray(stn,day,3)=dailywbtmax;end
                    if size(dailywbtmin,1)==0;finalwbtarray(stn,day,4)=NaN;else;finalwbtarray(stn,day,4)=dailywbtmin;end

                    doy=doy+1;
                end
            end
        end
        %Compare with previous 'master' version of finalwbtarray that's been saved, and set values =NaN if they're NaN in the master
            %version (since these reflect bad data found through the addl QC, so we don't want to inadvertently reinstate them)
        %However, this QC enforcement is unnecessary if only downloading data for a single station
        if enforceaddlqc==1
            temp=load(strcat(datadir,'finalwbtarrayfinal_latest_copy.mat'));
            prevfinalwbtarray=temp.finalwbtarray;
            for i=1:curnumstns
                for j=15342:totalnumdays
                    for k=3:4
                        if isnan(prevfinalwbtarray(i,j,k))
                            finalwbtarray(i,j,k)=NaN;
                        end
                    end
                end
            end
        end
        
        if rem(stn,5)==0;disp(stn);disp(clock);end
        if ~doingindivstn==1
            if rem(stn,25)==0
                disp('Saving arrays');
                save(strcat(datadir,'finaltarrayfinal_latest.mat'),'finalstncodes','finalstnlatlon','finaltarray','-v7.3');
                save(strcat(datadir,'finaldewptarrayfinal_latest.mat'),'finalstncodes','finalstnlatlon','finaldewptarray','-v7.3');
                save(strcat(datadir,'finalwbtarrayfinal_latest.mat'),'finalstncodes','finalstnlatlon','finalwbtarray','-v7.3');
                disp('Done saving arrays');
            end
        end
    end
    clear enforceaddlqc;
end

if getelevdataallstns==1
    finalstnelev=NaN.*ones(curnumstns,1);
    for stn=1:curnumstns
        if exist(strcat(datadir,stncodes(stn,:),'.nc'),'file')==2
            finalstnelev(stn)=ncread(strcat(datadir,stncodes(stn,:),'.nc'),'elevation');
        end
        
        if rem(stn,100)==0
            fprintf('Saving arrays for stn %d\n',stn);
            save(strcat(datadir,'finalelevarray.mat'),'finalstnelev','-v7.3');
        end
    end
end




