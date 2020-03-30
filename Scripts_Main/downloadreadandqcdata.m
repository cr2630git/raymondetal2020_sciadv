%Download data and implement essential quality controls

download=0;
readin=0; %about 200 (!) hours on a laptop for all 7877 stations in HadISD (about 2 min per station)
computeaddlvars=0;
    addlvar='slp'; %'slp' or 'winddir'
normalqc=1;
    step0=0; %5 min
    step1=0; %3 min+saving
    step2=0; %10 min+saving
    step3=0; %15 sec
    step4=0; %3 min+saving
    step5=0; %2 min+saving
    step6=0; %5 sec+saving
    %%%At this point, run getstns35c33c31c loop in masterscript before continuing%%%
    step7=0; %8 min
    step8=0; %30 sec
    step9=0; %15 sec
    step10=0; %5 sec+saving
    step11=0; %15 sec
    step12=0; %10 sec
    step13=0; %2 sec
    step14=0; %8 min
    step15=0; %6 min
    step16=0; %5 sec
    step17=0; %2 sec+saving
veryconservativeqc=0; %results displayed in supplement


cd('/Volumes/ExternalDriveC/RaymondMatthewsHorton2020_Github/Scripts_final');


%Download data
if download==1
    for stn=1:7877
        startdate=cell2mat(stnstarts(stn));
        if str2double(startdate(1:4))<=1985
            stncode=stncodes(stn,:);
            outfilename=websave(strcat('/Volumes/ExternalDriveC/HadISD_station_data_final/',stncode,'.nc.gz'),...
                strcat('https://www.metoffice.gov.uk/hadobs/hadisd/v202_2017f',...
                '/data/hadisd.2.0.2.2017f_19310101-20171231_',stncode,'.nc.gz'));
        end
        if rem(stn,100)==0;disp(stn);disp(clock);end
    end
end
%Then, unzip all files using gunzip


%Read in data
%Note that days are UTC-based, not local time
if readin==1
    disp(clock);
    clear origtwarray;clear origtarray;clear origtdarray;
    for stn=1:7877
        thisfilename=strcat(rawdatadir,'hadisd.2.0.2.2017f_19310101-20171231_',stncodes(stn,:),'.nc');
        if exist(thisfilename,'file')==2
            %Using the full subdaily data, get temperature, dewpoint, and time vectors for this station, 
                %and also compute TW
            temperature=ncread(thisfilename,'temperatures');
            invalid=abs(temperature)>200;temperature(invalid)=NaN;
            dewpoint=ncread(thisfilename,'dewpoints');
            invalid=abs(dewpoint)>200;dewpoint(invalid)=NaN;
            relhum=calcrhfromTanddewpt(temperature,dewpoint);
            pres=pressurefromelev(finalstnelev(stn)).*slp./1000.*100.*ones(size(temperature,1),size(temperature,2),size(temperature,3));
            wetbulb=calcwbt_daviesjones(temperature,pres,relhum,1); %Davies-Jones method
            time=ncread(thisfilename,'time'); %contains hours since 1/1/1931
        end

        totalday=17533;
        for curyear=1979:2017
            if rem(curyear,4)==0;curyearlen=366;else;curyearlen=365;end
            dayssincedec311930=DaysApart(12,31,1930,1,1,curyear);

            daystarthours=dayssincedec311930*24-23:24:(dayssincedec311930+(curyearlen-1))*24-23; %for this year
            daytimes=time(:,1)>=daystarthours & time(:,1)<=daystarthours+23;
            for i=1:365
                dailytmax=nanmax(temperature(daytimes(:,i)));
                if size(dailytmax,1)==0;origtarray(stn,totalday+i-1,3)=NaN;else;origtarray(stn,totalday+i-1,3)=dailytmax;end
                dailytmin=nanmin(temperature(daytimes(:,i)));
                if size(dailytmin,1)==0;origtarray(stn,totalday+i-1,4)=NaN;else;origtarray(stn,totalday+i-1,4)=dailytmin;end

                dailytdmax=nanmax(dewpoint(daytimes(:,i)));
                if size(dailytdmax,1)==0;origtdarray(stn,totalday+i-1,3)=NaN;else;origtdarray(stn,totalday+i-1,3)=dailytdmax;end
                dailytdmin=nanmin(dewpoint(daytimes(:,i)));
                if size(dailytdmin,1)==0;origtdarray(stn,totalday+i-1,4)=NaN;else;origtdarray(stn,totalday+i-1,4)=dailytdmin;end

                dailytwmax=nanmax(wetbulb(daytimes(:,i)));
                if size(dailytwmax,1)==0;origtwarray(stn,totalday+i-1,3)=NaN;else;origtwarray(stn,totalday+i-1,3)=dailytwmax;end
                dailytwmin=nanmin(wetbulb(daytimes(:,i)));
                if size(dailytwmin,1)==0;origtwarray(stn,totalday+i-1,4)=NaN;else;origtwarray(stn,totalday+i-1,4)=dailytwmin;end
            end

            origtarray(stn,totalday:totalday+curyearlen-1,1)=curyear;
            origtarray(stn,totalday:totalday+curyearlen-1,2)=1:curyearlen;
            origtdarray(stn,totalday:totalday+curyearlen-1,1)=curyear;
            origtdarray(stn,totalday:totalday+curyearlen-1,2)=1:curyearlen;
            origtwarray(stn,totalday:totalday+curyearlen-1,1)=curyear;
            origtwarray(stn,totalday:totalday+curyearlen-1,2)=1:curyearlen;


            totalday=totalday+curyearlen;

            disp(curyear);
        end
        if rem(stn,250)==0;fprintf('stn is %d\n',stn);end
    end
    save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays_orig.mat','origtwarray','origtarray','origtdarray','-v7.3');
    disp(clock);
end
%Number of 31C, 33C, 35C = 10482, 1023, 193


%Get extra variables for selected stations
if computeaddlvars==1
    %clear finalslparray;
    if strcmp(addlvar,'slp')
        finalslparray=cell(curnumstns,1);
    elseif strcmp(addlvar,'winddir')
        finalwinddirarray=cell(curnumstns,1);
    end
    finalarray=cell(curnumstns,1);
    
    %for stnc=1:size(stns33catleast3xords,1)
    for stnc=s:s
    %for stnc=1:curnumstns
        %stn=stns33catleast3xords(stnc);
        stn=stnc;
        
        if exist(strcat(rawstndatadir,finalstncodes(stn,:),'.nc'),'file')==2
            %Get variable and time vectors for this station
            if strcmp(addlvar,'slp')
                thisvar=ncread(strcat(rawstndatadir,finalstncodes(stn,:),'.nc'),'slp');
            elseif strcmp(addlvar,'winddir')
                thisvar=ncread(strcat(rawstndatadir,finalstncodes(stn,:),'.nc'),'winddirs');
            end
            temptime=ncread(strcat(rawstndatadir,finalstncodes(stn,:),'.nc'),'time'); %not to save, only for determining which hours are part of which days

            %Get variable for every available timestep
            daystarthours=0:24:totalnumdays*24-24;
            dayendhours=23:24:totalnumdays*24-1;
            for day=15342:totalnumdays

                curdaystarthour=daystarthours(day);
                curdayendhour=dayendhours(day);

                dailyvar=thisvar(temptime(:,1)>=curdaystarthour & temptime(:,1)<=curdayendhour);
                numdailyobsthisvar=size(dailyvar,1);

                if size(dailyvar,1)==0
                    finalarray{stn}(day-15342+1,1:numdailyobsthisvar)=NaN;
                else
                    finalarray{stn}(day-15342+1,1:numdailyobsthisvar)=dailyvar;
                end
            end
        end
        %disp(stnc);disp(clock);
        invalid=finalarray{stn}==0;finalarray{stn}(invalid)=NaN;
        invalid=abs(finalarray{stn})>1500;finalarray{stn}(invalid)=NaN;
        if rem(stnc,25)==0
            fprintf('Saving arrays at stnc %d\n',stnc);disp(clock);
            if strcmp(addlvar,'slp')
                finalslparray=finalarray;
                save(strcat(rawstndatadir,'finalslparray.mat'),'finalslparray','-v7.3');
            elseif strcmp(addlvar,'winddir')
                finalwinddirarray=finalarray;
                save(strcat(rawstndatadir,'finalwinddirarray.mat'),'finalwinddirarray','-v7.3');
            end
            disp('Done saving arrays');
        end
    end
    
    disp('Saving arrays for the last time');
    if strcmp(addlvar,'slp')
        finalslparray=finalarray;
        save(strcat(rawstndatadir,'finalslparray.mat'),'finalslparray','-v7.3');
    elseif strcmp(addlvar,'winddir')
        finalwinddirarray=finalarray;
        save(strcat(rawstndatadir,'finalwinddirarray.mat'),'finalwinddirarray','-v7.3');
    end
    disp('Truly done saving arrays');
end


%Algorithmically impose additional requirements on the HadISD data to remove values that
    %seem suspicious but passed the initial Hadley Centre QC procedures
%Criteria for elimination are listed as numbered steps 
if normalqc==1
    %0. Eliminate stations with <50% data availability
    finalstnlist=[];clear validvals;
    if step0==1
        for stn=1:size(origtwarray,1)
            validvals(stn)=sum(~isnan(origtwarray(stn,startday:stopday,3)));
            if validvals(stn)>=0.5*(stopday-startday+1)
                finalstnlist=[finalstnlist;stn];
            end
        end
        fprintf('Stnlist size is %d\n',size(finalstnlist,1));
        
        %Shorten station list to consist of only these good stations
        finalstnelev=stnelev(finalstnlist);
        finalstnlatlon=stnlatlon(finalstnlist,:);
        finalstnnames=cellstr(stnnames(finalstnlist,:));
        finalstncodes=stncodes(finalstnlist,:);
        
        save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/stndatanov14_50percent.mat',...
            'finalstnelev','finalstnlatlon','finalstnnames','finalstncodes','finalstnlist');
        
        %Also shorten data arrays
        twarray=origtwarray(finalstnlist,:,:);
        tdarray=origtdarray(finalstnlist,:,:);
        tarray=origtarray(finalstnlist,:,:);
        save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays0nov14_50percent.mat','twarray','tarray','tdarray','-v7.3');
    end
    
    %1. dewpoint depression at time of TWmax <=0.5 C
    if step1==1
        disp(clock);
        step1thresh=29;
        for stn=1:size(twarray,1)
            if max(twarray(stn,day,3))>=step1thresh
                thisstnlat=finalstnlatlon(stn,1);thisstnlon=finalstnlatlon(stn,2);
                thisfilename=strcat(rawdatadir,'hadisd.2.0.2.2017f_19310101-20171231_',stncodes(stn,:),'.nc');
                if exist(thisfilename,'file')==2
                    %Using the full subdaily data, get temperature, dewpoint, and time vectors for this station, 
                        %and also compute TW
                    temperature=ncread(thisfilename,'temperatures');
                    invalid=abs(temperature)>200;temperature(invalid)=NaN;
                    dewpoint=ncread(thisfilename,'dewpoints');
                    invalid=abs(dewpoint)>200;dewpoint(invalid)=NaN;
                    relhum=calcrhfromTanddewpt(temperature,dewpoint);
                    pres=pressurefromelev(finalstnelev(stn)).*slp./1000.*100.*ones(size(temperature,1),size(temperature,2),size(temperature,3));
                    wetbulb=calcwbt_daviesjones(temperature,pres,relhum,1); %Davies-Jones method
                    time=ncread(thisfilename,'time'); %contains hours since 1/1/1931
                end

                for day=startday:stopday
                    if twarray(stn,day,3)>=step1thresh
                        thisdayyear=twarray(stn,day,1);thisdaydoy=twarray(stn,day,2);
                        if ~isnan(twarray(stn,day,3))
                            subdailyanalysis;
                            [a,b]=max(subdailytw); %TW max value & time at which it supposedly occurred
                            assoct=subdailyt(b);assoctd=subdailytd(b);
                            if assoct-assoctd<=0.5
                                twarray(stn,day,3)=NaN;
                                tdarray(stn,day,3)=NaN;
                            end
                        end
                    end
                end
                if rem(stn,100)==0;fprintf('Stn is %d for step 1\n',stn);end
            end
        end
        %save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays1.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 1, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
        disp(clock);
    end
    %Number of 31C, 33C, 35C = 10427, 1021, 193
    
    %2. discrepancy between station TWmax and ERA-Interim TWmax is >=10 C
        %(only if ERA-Interim elevation is close to that of station)
    if step2==1
        step2thresh=29;
        c=0;clear stns29c;
        for stn=1:size(twarray,1)
            if max(twarray(stn,:,3))>=step2thresh
                c=c+1;stns29c(c)=stn;
            end
        end

        erainterimelevdata=ncread('/Volumes/ExternalDriveC/Basics_ERA-Interim/erainterimelev.nc','z')/9.81;
        prevthisdayyear=1978;thisdayyear=1979;
        for day=startday:stopday
            if thisdayyear~=prevthisdayyear
                erainterimtddata=ncread(strcat(erainterimdir,'td2m',num2str(thisdayyear),'.nc'),'d2m')-273.15;
                fprintf('We have just loaded in erainterimtddata for year %d\n',thisdayyear);
                prevthisdayyear=thisdayyear;
            end
            thisdayyear=twarray(1,day,1);thisdaydoy=twarray(1,day,2); 

            for count=1:size(stns29c,2)
                stn=stns29c(count);
                if ~isnan(twarray(stn,day,3))
                    if twarray(stn,day,3)>=step2thresh
                        thisstnlat=finalstnlatlon(stn,1);thisstnlon=finalstnlatlon(stn,2);
                        if thisstnlon<=0;eracorresprow=720+2*round(thisstnlon);else;eracorresprow=2*round(thisstnlon);end
                        eracorrespcol=181-round(2*thisstnlat);

                        if eracorrespcol<=2;eracorrespcol=3;elseif eracorrespcol>=360;eracorrespcol=359;end
                        if eracorresprow<=2;eracorresprow=3;elseif eracorresprow>=719;eracorresprow=718;end

                        erainterimelev=squeeze(erainterimelevdata(eracorresprow-2:eracorresprow+2,eracorrespcol-2:eracorrespcol+2));
                        if abs(erainterimelev(2,2)-finalstnelev(stn))<=100 %ERA & stn are close enough in elev that they can reasonably be compared
                            clear erainterimtd;
                            %Allow for some spatial uncertainty in the ERA-Interim gridpt match
                            if thisstnlon<-90 %max occurs near 00 UTC
                                erainterimtd=squeeze(erainterimtddata(eracorresprow-2:eracorresprow+2,eracorrespcol-2:eracorrespcol+2,thisdaydoy*4-3));
                            elseif thisstnlon<0 %max occurs near 18 UTC
                                erainterimtd=squeeze(erainterimtddata(eracorresprow-2:eracorresprow+2,eracorrespcol-2:eracorrespcol+2,thisdaydoy*4));
                            elseif thisstnlon<90 %max occurs near 12 UTC
                                erainterimtd=squeeze(erainterimtddata(eracorresprow-2:eracorresprow+2,eracorrespcol-2:eracorrespcol+2,thisdaydoy*4-1));
                            else %max occurs near 06 UTC
                                erainterimtd=squeeze(erainterimtddata(eracorresprow-2:eracorresprow+2,eracorrespcol-2:eracorrespcol+2,thisdaydoy*4-2));
                            end

                            %Station data
                            stnmaxtd=tdarray(stn,day,3);

                            %Compare
                            if abs(max(max(erainterimtd))-stnmaxtd)>10
                                %large discrepancy between ERA-Interim and station data means the latter is almost certainly too high
                                twarray(stn,day,3:4)=[NaN;NaN];
                                tdarray(stn,day,3:4)=[NaN;NaN];
                                fprintf('Bad data (large ERA/station discrepancy) found for stn %d, day %d\n',stn,day);
                                disp(max(max(erainterimtd)));disp(stnmaxtd);
                            end

                        end

                    end
                end
            end
        end
        %save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays2.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 2, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
        disp(clock);
    end
    %Number of 31C, 33C, 35C = 10138, 873, 133
    
    %3. The highest TW value in the first 15 years (1979-1993) is larger than that in the last 15 years (2003-2017)
    if step3==1
        disp(clock);
        for stn=1:size(twarray,1)
            if max(twarray(stn,17533:23011,3))>max(twarray(stn,26299:31777,3))
                temp=twarray(stn,:,3);
                invalid=temp>max(twarray(stn,26299:31777,3))+2;temp(invalid)=NaN;
                twarray(stn,:,3)=temp;
            end
        end
        disp(clock);
        fprintf('After QC step 3, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 10071, 808, 106
    
    %4. If a station has any gaps of at least 1000 consecutive days in its
        %Td record, eliminate all data prior to this gap as potentially
        %unreliable (possible changepoints, etc.)
    if step4==1
        for stn=1:size(twarray,1)
            day=17533;
            while day<=stopday-999
                if sum(isnan(tdarray(stn,day:day+999,3)))==1000
                    tdarray(stn,startday:day+999,3)=NaN;
                    twarray(stn,startday:day+999,3)=NaN;
                    day=day+1000;
                else
                    day=day+1;
                end
            end
            if rem(stn,500)==0;fprintf('Stn %d for step 4\n',stn);disp(clock);end
        end
        %save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays3.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 4, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 9706, 783, 106
    
    %5. Daily-max Td and daily-min Td are the same, OR daily-max TW and daily-min TW are the same
    %This indicates either only one valid data point, or erroneous data
    if step5==1
        for stn=1:size(twarray,1)
            for day=startday:stopday
                if twarray(stn,day,3)==twarray(stn,day,4) || tdarray(stn,day,3)==tdarray(stn,day,4)
                    tdarray(stn,day,3:4)=NaN;
                    twarray(stn,day,3:4)=NaN;
                end
            end
        end
        fprintf('After QC step 5, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 9653, 773, 104
    
    %6. No nearby stns (in a 7.5x7.5 box) within 7.5C of this station's TW maximum
    if step6==1
        for stn=1:size(twarray,1)
            if max(twarray(stn,:,3))>=27
                clear nearbystns;
                nearbystns(1)=stn;
                nearbystnc=1;
                for i=1:size(twarray,1)
                    if finalstnlatlon(i,1)>=finalstnlatlon(stn,1)-3.75 && finalstnlatlon(i,1)<=finalstnlatlon(stn,1)+3.75 && ...
                            finalstnlatlon(i,2)>=finalstnlatlon(stn,2)-3.75 && finalstnlatlon(i,2)<=finalstnlatlon(stn,2)+3.75 &&...
                            finalstnlatlon(i,1)~=finalstnlatlon(stn,1) && finalstnlatlon(i,2)~=finalstnlatlon(stn,2)
                        nearbystnc=nearbystnc+1;
                        nearbystns(nearbystnc,1)=i;
                    end
                end

                clear nearbyarray;
                for day=startday:stopday
                    if twarray(stn,day,3)>=27
                        nearbyarray=twarray(nearbystns,day,3);
                        mindiff=nearbyarray(1)-max(nearbyarray(2:end));
                        
                        if size(mindiff,2)>=1
                            if mindiff>=7.5 && nearbystnc>=3 %difference is too large
                                twarray(stn,day,3:4)=NaN;
                            end
                        end
                    end
                end
            end
        end
        save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays4_50percent.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 6, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 9248, 692, 60
    
    %%%Run getstns35c33c31c loop in masterscript before continuing%%%
    %7. Purported Tw=33C instances with excessively large hourly changes of Td (>8C in an hour or >12C in 3 hours)
    if step7==1        
        prevs=0;
        for linec=1:size(wbt33cinstances,1)
            s=wbt33cinstances(linec,1);d=wbt33cinstances(linec,2);
            if s~=prevs;downloadprephadisddata;fprintf('In QC step 7, doing station %d (currently at line %d)\n',s,linec);prevs=s;end
            day=wbt33cinstances(linec,2);
            
            firsthourtoplot=day*24-23;lasthourtoplot=day*24;

            subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytd=dewpoint(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailyt=temperature(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytw=wetbulb(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);

            if size(subdailytimes,1)>=1
                adsh=max(firsthourtoplot,subdailytimes(1));
                subdailytimesoffset=subdailytimes(2:end);diffs=subdailytimesoffset-subdailytimes(1:end-1);
                hourinterval=mode(diffs);
                
                if hourinterval==1
                    [a,b]=max(subdailytd);
                    if b>=2
                        if a-subdailytd(b-1)>8
                            fprintf('Found an excessive hourly change (%0.2f -- station %d, day %d, line %d), eliminating %0.2f\n',...
                                a-subdailytd(b-1),s,day,linec,twarray(s,day,3));
                            tdarray(s,day,3:4)=NaN;
                            twarray(s,day,3:4)=NaN;
                        end
                    end
                    if b>=4
                        if a-subdailytd(b-3)>12
                            fprintf('Found an excessive 3-hourly change (%0.2f -- station %d, day %d, line %d), eliminating %0.2f\n',...
                                a-subdailytd(b-3),s,day,linec,twarray(s,day,3));
                            tdarray(s,day,3:4)=NaN;
                            twarray(s,day,3:4)=NaN;
                        end
                    end
                elseif hourinterval==3
                    [a,b]=max(subdailytd);
                    if b>=2
                        if a-subdailytd(b-1)>12
                            fprintf('Found an excessive 3-hourly change (%0.2f -- station %d, day %d, line %d), eliminating %0.2f\n',...
                                a-subdailytd(b-1),s,day,linec,twarray(s,day,3));
                            tdarray(s,day,3:4)=NaN;
                            twarray(s,day,3:4)=NaN;
                        end
                    end
                else
                    %Also eliminate if there's very little data for this day (3 or fewer valid observations)
                    if size(subdailytw,1)<=3
                        fprintf('3 or fewer observations on this day (station %d, day %d, line %d), eliminating %0.2f\n',...
                            s,day,linec,twarray(s,day,3));
                        twarray(s,day,3:4)=NaN;
                    end
                end
            end
        end
        %save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays5.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 7, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 9171, 615, 56
    
    %8. Td>35C
    if step8==1
        for stn=1:size(twarray,1)
            for day=startday:stopday
                if tdarray(stn,day,3)>35
                    tdarray(stn,day,3)=NaN;
                    twarray(stn,day,3)=NaN;
                end
            end
        end
        fprintf('After QC step 8, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 9153, 597, 38
    
    %9. Two or more consecutive Tw and Td daily maxes that are exactly the same
    if step9==1
        for stn=1:size(twarray,1)
            for day=startday:stopday-3
                if twarray(stn,day,3)==twarray(stn,day+1,3) && tdarray(stn,day,3)==tdarray(stn,day+1,3) %2 in a row
                    if twarray(stn,day,3)==twarray(stn,day+2,3) && tdarray(stn,day,3)==tdarray(stn,day+2,3) %3 in a row
                        if twarray(stn,day,3)==twarray(stn,day+3,3) && tdarray(stn,day,3)==tdarray(stn,day+3,3) %4 in a row
                            if twarray(stn,day,3)>=33
                                fprintf('For stn %d, days %d-%d are identical (Tw=%0.2f)\n',stn,day,day+3,twarray(stn,day,3));
                            end
                            tdarray(stn,day:day+3,3)=NaN;twarray(stn,day:day+3,3)=NaN;
                        else %3 in a row
                            if twarray(stn,day,3)>=33
                                fprintf('For stn %d, days %d-%d are identical (Tw=%0.2f)\n',stn,day,day+2,twarray(stn,day,3));
                            end
                            tdarray(stn,day:day+2,3)=NaN;twarray(stn,day:day+2,3)=NaN;
                        end
                    else %2 in a row
                        if twarray(stn,day,3)>=33
                            fprintf('For stn %d, days %d-%d are identical (Tw=%0.2f)\n',stn,day,day+1,twarray(stn,day,3));
                        end
                        tdarray(stn,day:day+1,3)=NaN;twarray(stn,day:day+1,3)=NaN;
                    end
                end
            end
        end
        %save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays6.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 9, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8864, 587, 38
    
    %10. Any value at a station that is above what it has recorded since 2001
    if step10==1
        for stn=1:size(twarray,1)
            stn21cmax=max(twarray(stn,25569:stopday,3));
            temp=twarray(stn,startday:25568,3);
            
            invalid=temp>stn21cmax;temp(invalid)=NaN;
            if sum(invalid)>0 && max(twarray(stn,:,3)>31);fprintf('Removing %d values for high-value stn %d\n',sum(invalid),stn);end
            twarray(stn,startday:25568,3)=temp;
        end
        save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays7_FINAL_NOV18.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 10, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8594, 442, 24
    
     %11. Eliminate days with top-5 values all within a 365-day period
    if step11==1
        stnstop10=NaN.*ones(size(twarray,1),10);diffbetween=NaN.*ones(size(twarray,1),1);
        for stn=1:size(twarray,1)
            temp=sort(twarray(stn,startday:stopday,3),'descend');
            pos=find(~isnan(temp),1);
            if size(pos,2)==1
                for i=1:10;stnstop10(stn,i)=temp(pos+i-1);end
                diffbetween(stn)=stnstop10(stn,1)-stnstop10(stn,2);
                if diffbetween(stn)>=3
                    fprintf('Difference is %0.2f for station %d (#1 is %0.2f)\n',diffbetween(stn),stn,temp(pos));
                end
            end
        end
    
        for stntouse=1:size(twarray,1)
            i=1;clear daysoftop10;
            while i<=10
                thisval=stnstop10(stntouse,i);
                [a,b]=find(twarray(stntouse,startday:stopday,3)==thisval);
                if size(b,2)==1
                    daysoftop10(i)=startday+b-1;i=i+1;
                elseif size(b,2)==2
                    daysoftop10(i:i+1)=startday+b-1;i=i+2;
                elseif size(b,2)==3
                    daysoftop10(i:i+2)=startday+b-1;i=i+3;
                elseif size(b,2)==4
                    daysoftop10(i:i+3)=startday+b-1;i=i+4;
                elseif size(b,2)==5
                    daysoftop10(i:i+4)=startday+b-1;i=i+5;
                elseif size(b,2)==6
                    daysoftop10(i:i+5)=startday+b-1;i=i+6;
                elseif size(b,2)==7
                    daysoftop10(i:i+6)=startday+b-1;i=i+7;
                elseif size(b,2)==8
                    daysoftop10(i:i+7)=startday+b-1;i=i+8;
                elseif size(b,2)==9
                    daysoftop10(i:i+8)=startday+b-1;i=i+9;
                elseif size(b,2)==10
                    daysoftop10(i:i+9)=startday+b-1;i=i+10;
                else
                    daysoftop10=NaN.*ones(10,1);i=11;
                end
            end
            
            top5firstday=min(daysoftop10(1:5));top5lastday=max(daysoftop10(1:5));
            if ~isnan(top5firstday)
                if top5lastday-top5firstday<=365 %top 5 too concentrated
                    fprintf('Top 5 too concentrated for stn %d, with #1 value %0.2f\n',stntouse,stnstop10(stntouse,1));
                    twarray(stntouse,daysoftop10(1:5),3)=NaN;
                end
            end
        end
        fprintf('After QC step 11, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8534, 431, 24
    
    %12. The 99.5th percentile of the first 5000 days is more than 1C
    %higher than the 99.9th percentile of the last 5000 days -- remove TW
    %above the former level
    %(Essentially, this is searching for unlikely decreases in extreme TW
    %from beginning to end of timeseries)
    if step12==1
        clear thisval;
        for stn=1:size(twarray,1)
            if sum(~isnan(tdarray(stn,stopday-4999:stopday,3)))>=3000 && sum(~isnan(tdarray(stn,startday:startday+4999,3)))>=3000
                thisval(stn)=quantile(tdarray(stn,stopday-4999:stopday,3),0.999)-quantile(tdarray(stn,startday:startday+4999,3),0.995);
                if thisval(stn)<=-1
                    fprintf('Removing values above %0.2f for stn %d\n',quantile(tdarray(stn,startday:startday+4999,3),0.995),stn);
                    invalid=tdarray(stn,startday:stopday,3)>quantile(tdarray(stn,startday:startday+4999,3),0.995);
                    temp=twarray(stn,startday:stopday,3);temp(invalid)=NaN;
                    twarray(stn,startday:stopday,3)=temp;
                end
            end
        end
        fprintf('After QC step 12, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8479, 422, 24
    
    %13. The 99.9th percentile of the first 5000 days is more than 6C
    %lower than the 99.5th percentile of the last 5000 days -- remove TW
    %above the latter level
    %(Essentially, this is searching for unlikely decreases in extreme TW
    %from beginning to end of timeseries)
    if step13==1
        clear thisval;
        for stn=1:size(twarray,1)
            if sum(~isnan(tdarray(stn,stopday-4999:stopday,3)))>=3000 && sum(~isnan(tdarray(stn,startday:startday+4999,3)))>=3000
                thisval(stn)=quantile(tdarray(stn,stopday-4999:stopday,3),0.995)-quantile(tdarray(stn,startday:startday+4999,3),0.999);
                if thisval(stn)>=2
                    fprintf('Removing values above %0.2f for stn %d\n',quantile(tdarray(stn,stopday-4999:stopday,3),0.995),stn);
                    invalid=tdarray(stn,startday:stopday,3)>quantile(tdarray(stn,stopday-4999:stopday,3),0.995);
                    temp=twarray(stn,startday:stopday,3);temp(invalid)=NaN;
                    twarray(stn,startday:stopday,3)=temp;
                end
            end
        end
        fprintf('After QC step 13, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8117, 374, 19
    
    %14. A TW extreme is associated with an RH of >=95%
    if step14==1
        for linec=1:size(wbt33cinstances,1)
            s=wbt33cinstances(linec,1);d=wbt33cinstances(linec,2);
            if s~=prevs;downloadprephadisddata;fprintf('For step 14, doing station %d (currently at line %d)\n',s,linec);prevs=s;end
            day=wbt33cinstances(linec,2);

            firsthourtoplot=day*24-23;lasthourtoplot=day*24;

            subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytd=dewpoint(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytw=wetbulb(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailyt=temperature(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);

            if size(subdailytimes,1)>=1
                [a,b]=max(subdailytw);
                tofmaxtw=subdailyt(b);tdofmaxtw=subdailytd(b);
                rhofmaxtw(linec)=calcrhfromTanddewpt(tofmaxtw,tdofmaxtw);
                if rhofmaxtw(linec)>=95
                    twarray(s,day,3)=NaN;
                    fprintf('In step 14, just removed TW=%0.2f for stn %d, day %d\n',max(subdailytw),s,day);
                end
            end
        end
        fprintf('After QC step 14, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8088, 345, 19
    
    %15. Eliminate TW>=33C if daily maximum value occurs before 11am or after 8pm
    if step15==1
        for linec=1:size(wbt33cinstances,1)
            s=wbt33cinstances(linec,1);d=wbt33cinstances(linec,2);
            if s~=prevs;downloadprephadisddata;fprintf('In QC step 15, doing station %d (currently at line %d)\n',s,linec);prevs=s;end
            day=wbt33cinstances(linec,2);
            thistz=stntzs(s);

            firsthourtoplot=day*24-23;lasthourtoplot=day*24;

            subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytd=dewpoint(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailytw=wetbulb(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            subdailyt=temperature(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);

            if size(subdailytimes,1)>=1
                [a,b]=max(subdailytw);
                timeofmax_utc=subdailytimes(b)-firsthourtoplot+1; %0 is midnight, 23 is 11pm
                timeofmax_local=timeofmax_utc+thistz;
                if timeofmax_local<0;timeofmax_local=timeofmax_local+24;elseif timeofmax_local>=24;timeofmax_local=timeofmax_local-24;end
                if timeofmax_local<=10 || timeofmax_local>=21 %before 11am or after 8pm
                    twarray(s,day,3)=NaN;
                    fprintf('In step 15, just removed TW=%0.2f for stn %d, day %d\n',max(subdailytw),s,day);
                end
            end
        end
        fprintf('After QC step 15, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8062, 319, 19
    
    %16. Remove all-time maxima that are more than 2C warmer than the next-largest value
    if step16==1
        clear temp;
        for stn=1:size(twarray,1)
            [a,b]=max(twarray(stn,startday:stopday,3));
            temp=twarray(stn,startday:stopday,3);temp(b)=NaN;[c,d]=max(temp);
            if a-c>=2
                twarray(stn,b+startday-1,3)=NaN;
                fprintf('In step 16, just removed TW=%0.2f for stn %d, day %d\n',a,stn,b+startday-1);
            end
        end
        fprintf('After QC step 16, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 8056, 316, 18
    
    %17. Eliminate a handful of extreme values after manual examination of
        %timeseries, including apparent changepoints
    %Remove 35C occurrence at Al Hofuf Saudi Arabia, which is not fully supported by ERA-Interim and NCEP/NCAR
    %Remove all values up to Jul 31 2002 at Sur Oman; up to Mar 31 1989 at
    %Nawabshah Pakistan; up to Jul 15 1995 at Appleton WI; and after Jan 1 2016 at Choix Mexico
    %Remove all Td values above 30C at Port Hedland Australia and Yannarie
    %Australia, and above 31.5C at Villahermosa Mexico
    if step17==1
        twarray(1700,25776,3)=NaN;
        twarray(1765,1:26190,3)=NaN;
        twarray(1782,1:21275,3)=NaN;
        twarray(3755,1:23572,3)=NaN;
        twarray(3914,31046:end,3)=NaN;
        invalid=tdarray(3956,startday:stopday,3)>31.5;temp=twarray(3956,startday:stopday,3);temp(invalid)=NaN;twarray(3956,startday:stopday,3)=temp;
        invalid=tdarray(4355,startday:stopday,3)>30;temp=twarray(4355,startday:stopday,3);temp(invalid)=NaN;twarray(4355,startday:stopday,3)=temp;
        invalid=tdarray(4357,startday:stopday,3)>30;temp=twarray(4357,startday:stopday,3);temp(invalid)=NaN;twarray(4357,startday:stopday,3)=temp;
        save('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/masterarrays8_50percent_FINALNOV18.mat','twarray','tarray','tdarray','-v7.3');
        fprintf('After QC step 17, number of 31C, 33C, 35C is %d, %d, %d\n',sum(sum(twarray(:,startday:stopday,3)>=31)),...
            sum(sum(twarray(:,startday:stopday,3)>=33)),sum(sum(twarray(:,startday:stopday,3)>=35)));
    end
    %Number of 31C, 33C, 35C = 7548, 281, 14
    
    %FIN
end


%For the supplement and R2R, produce a further-pruned dataset where any
    %high-TW value with even the slightest whiff of doubt is thrown out
%This eliminates many probably-valid values, but is useful for the sake of argument
%BEFORE DOING, NEED TO RUN FIGURES4 TO REMAKE SAVEARRAYTW
if veryconservativeqc==1
    figure(101);clf;imagescnan(savearraytw_33(1:25,:));colorbar;
end


