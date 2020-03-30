%Downloads and reads in data from the HadISD subdaily global station dataset
%Most common settings are computedailydata=1, doingindivstn=1, and everything else =0

computedailydata=1; %about 2 min per stn, 140 hours total for 7877 stns
computedailydataaddlvars=0; %20 sec per stn; get an addl variable (SLP, winddir, etc) for selected stations
    addlvar='winddir';
    

rawstndatadir='/Volumes/ExternalDriveC/HadISD_Incl_2017/';


%Get daily Tmax, Tdmax, and TWmax for each station
%In each file, time is given as hours since 1931-01-01 00:00 (hour 705284)
if computedailydata==1
    for stn=s:s
        thisfilename=strcat(rawstndatadir,'hadisd.2.0.2.2017f_19310101-20171231_',finalstncodes(stn,:),'.nc');
        if exist(thisfilename,'file')==2
            %Get temperature, dewpoint, and time vectors for this
                %station, and also compute WBT
            temperature=ncread(thisfilename,'temperatures');
            invalid=abs(temperature)>60;temperature(invalid)=NaN;
            dewpoint=ncread(thisfilename,'dewpoints');
            invalid=abs(dewpoint)>40;dewpoint(invalid)=NaN;
            relhum=calcrhfromTanddewpt(temperature,dewpoint);
            pres=pressurefromelev(finalstnelev(stn)).*slp./1000.*100.*ones(size(temperature,1),size(temperature,2),size(temperature,3));
            wetbulb=calcwbt_daviesjones(temperature,pres,relhum,1); %Davies-Jones method
            time=ncread(thisfilename,'time'); %contains hours since 1/1/1931
        end
    end
end

%Get extra variables for selected stations
if computedailydataaddlvars==1
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

            %Get variable for every available timestep in 1973-2016
                %(THIS DIFFERS FROM WHAT WAS DONE IN THE COMPUTEDAILYDATA ARRAY
                %ABOVE, SINCE THIS IS WRITTEN WITH MORE KNOWLEDGE OF THE
                %DATASET AND WHAT IS MOST IMPORTANT FOR THE FINAL ANALYSIS)
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


