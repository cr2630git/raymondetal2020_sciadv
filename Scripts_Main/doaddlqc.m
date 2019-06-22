%Impose additional requirements on the HadISD data to remove values that
    %seem suspicious but passed the initial (Hadley Centre) QC procedures
%Note that only WBT values are set to NaN, leaving the underlying T and
    %dewpt values unchanged (this makes it easier to reinstate values if 
    %the specifics of this QC are changed in any way)

    
dopart1=0; %automated
dopart2=0; %manual -- copy and paste segments of code only rather than running directly from here


%1. Automated part

%This part requires that 
%    -the dewpoint depression at the time of the WBTmax be >0.5 C
%    -less than half of the data on the surrounding days be missing
%    -if ERA-Interim has accurate terrain near the station in question, its
%       dewpoint matches the station's dewpoint reasoanably well

%Ensure that proper options are selected in the downloadprephadisddata and
    %subdailyanalysis scripts -- that is:
    %downloadprep: computedailydata=1, resetarrays=0, doingindivstn=1
    %subdailyanalysis: makefigure=0, standaloneplot=0, trytodeterminesettingsautomatically=1

if dopart1==1
    erainterimelevdata=ncread('/Volumes/ExternalDriveC/Basics_ERA-Interim/erainterimelev.nc','z');
    for stnc=229:242
        stn=stns31catleast3xords(stnc);
        thisstnlat=finalstnlatlon(stn,1);thisstnlon=finalstnlatlon(stn,2);
        latdiff=abs(eralats-thisstnlat);[~,eracorresprow]=min(latdiff(1,:));
        londiff=abs(eralons-thisstnlon);[~,eracorrespcol]=min(londiff(:,1));
        if eracorrespcol==1;eracorrespcol=2;end
        if eracorresprow==1;eracorresprow=2;end

        erainterimelev=squeeze(erainterimelevdata(eracorrespcol-1:eracorrespcol+1,eracorresprow-1:eracorresprow+1));
        fprintf('Starting QC checks for stn %d\n',stn);
        if abs(erainterimelev(2,2)-finalstnelev(stn))<300 %ERA & stn are close enough in elev that they can reasonably be compared
            s=stn;downloadprephadisddata;
            thisstn31cinstances=wbt31cinstances(wbt31cinstances(:,1)==stn,:);
            for daytoinvestigate=1:size(thisstn31cinstances,1)
                thisdayday=thisstn31cinstances(daytoinvestigate,2);
                thisdaydoy=thisstn31cinstances(daytoinvestigate,6);
                thisdayyear=thisstn31cinstances(daytoinvestigate,5);

                if ~isnan(finalwbtarray(stn,thisdayday,3)) %if there's any need to check at all

                    subdailyanalysis;
                    [a,b]=max(subdailywbtadj); %WBT max value & time at which it supposedly occurred
                    assoct=subdailytadj(b);assoctd=subdailytdadj(b);

                    if thisdayyear>=1979
                        erainterimtddata=ncread(strcat(erainterimdir,'td2m',num2str(thisdayyear),'.nc'),'d2m')-273.15;

                        %Allow for some spatial uncertainty in the ERA-Interim gridpt match
                        if thisstnlon<-90 %max occurs near 00 UTC
                            erainterimtd=squeeze(erainterimtddata(eracorrespcol-1:eracorrespcol+1,eracorresprow-1:eracorresprow+1,thisdaydoy*4-3));
                        elseif thisstnlon<0 %max occurs near 18 UTC
                            erainterimtd=squeeze(erainterimtddata(eracorrespcol-1:eracorrespcol+1,eracorresprow-1:eracorresprow+1,thisdaydoy*4));
                        elseif thisstnlon<90 %max occurs near 12 UTC
                            erainterimtd=squeeze(erainterimtddata(eracorrespcol-1:eracorrespcol+1,eracorresprow-1:eracorresprow+1,thisdaydoy*4-1));
                        else %max occurs near 06 UTC
                            erainterimtd=squeeze(erainterimtddata(eracorrespcol-1:eracorrespcol+1,eracorresprow-1:eracorresprow+1,thisdaydoy*4-2));
                        end
                    end

                    if assoct-assoctd<0.5 %small dewpt depression at this time --> highly questionable WBT, so set to NaN
                        finalwbtarray(stn,thisdayday,3:4)=[NaN;NaN];
                        fprintf('Bad data (small dewpt depression) found for stn %d, day %d\n',stn,thisdayday);
                    else %dewpt depression is OK
                        if sum(~isnan(subdailytadj))<0.5*size(subdailytadj,2) || sum(~isnan(subdailytdadj))<0.5*size(subdailytdadj,2)
                            %more than half of T or Td data on surrounding days is missing
                            finalwbtarray(stn,thisdayday,3:4)=[NaN;NaN];
                            fprintf('Bad data (lots missing) found for stn %d, day %d\n',stn,thisdayday);
                        else %enough data is present
                            if thisdayyear>=1979
                                if abs(max(max(erainterimtd))-assoctd)>10
                                    %large discrepancy between ERA-Interim and station data means the latter is probably too high
                                    finalwbtarray(stn,thisdayday,3:4)=[NaN;NaN];
                                    fprintf('Bad data (large ERA/station discrepancy) found for stn %d, day %d\n',stn,thisdayday);
                                else %ERA-Interim and station agree fairly well
                                    fprintf('Data is OK for stn %d, day %d\n',stn,thisdayday);
                                end
                            else %can't check against ERA-Interim b/c it doesn't exist prior to 1979
                                fprintf('Cannot check (pre-1979) for stn %d, day %d\n',stn,thisdayday);
                            end
                        end
                    end
                end
            end
        else %can't check against ERA-Interim b/c it doesn't match the stn elev
            fprintf('Cannot check (different elevs) for stn %d\n',stn);
        end
        fprintf('Just finished QC checks for stn %d\n',stn);

        if rem(stnc,10)==0
            fprintf('\n');disp('Saving finalwbtarray');fprintf('\n');
            save(strcat(datadir,'finalwbtarraystull.mat'),'finalwbtarray','-append');
        end
    end
    fprintf('\n');disp('Saving finalwbtarray for the last time');
    save(strcat(datadir,'finalwbtarraystull.mat'),'finalwbtarray','-append');
end



%2. Manual part

%This part is necessary because stations in complex terrain cannot be
    %checked against ERA-Interim and spot-checking their WBT values
    %suggested that further QC was necessary
%Here, 'bad' values are identified by a station's dewpoint being >7.5 C higher than
    %any of its comparable-elevation neighbors on the same day
%%% Priority stations to do this for are those in stns33catleast3xords %%%
%Requires repeated manual copy-and-pasting of the below code, once for each
    %day, which is OK because each one must be carefully checked anyway before
    %being eliminated or saved
if dopart2==1
    %Do some QC
    st=5736;
    [a,b]=max(finalwbtarraydj(st,:,3));
    figure(90);plot(finaldewptarray(st-100:st+100,b,3)); %how do neighbors compare?
    figure(91);plot(finaldewptarray(st,b-30:b+30,3)); %how do days compare? if badly, many bad days are we looking at here?
    finalwbtarray(st,b,:); %DOY

    %If day is bad, remove it
    finalwbtarray(st,b:b,3:4)=NaN; 
    
    
    %Remove data that's been identified as bad by iterating through the above lines of code
    %Heniches'k, Ukraine
    finalwbtarray(3081,18473,3:4)=NaN;
    %Sharjah, UAE
    finalwbtarray(3429,17378,3:4)=NaN;
    %Quetta, Pakistan
    finalwbtarray(3544,15922,3:4)=NaN;
    %Jacobabad, Pakistan
    finalwbtarray(3547,29029:29036,3:4)=NaN;finalwbtarray(3547,29039:29040,3:4)=NaN;
    finalwbtarray(3547,27184,3:4)=NaN;finalwbtarray(3547,27186,3:4)=NaN;
    finalwbtarray(3547,27540,3:4)=NaN;finalwbtarray(3547,29780,3:4)=NaN;finalwbtarray(3547,29790,3:4)=NaN;
    %Khuzdar, Pakistan
    finalwbtarray(3548,29052,3:4)=NaN;
    %Hisar, India
    finalwbtarray(3560,27924,3:4)=NaN;
    %Gwalior, India
    finalwbtarray(3570,16615,3:4)=NaN;
    %Gaya, India
    finalwbtarray(3579,22392,3:4)=NaN;
    %Badger, NL, Canada
    finalwbtarray(5229,16469:16470,3:4)=NaN;
    finalwbtarray(5251,17869:17890,3:4)=NaN;
    finalwbtarray(5337,24669,3:4)=NaN;
    %Newport News, VA, USA
    finalwbtarray(5736,29774,3:4)=NaN;
    %Loreto, Mexico
    finalwbtarray(6530,29432:29433,3:4)=NaN;finalwbtarray(6530,29810:29811,3:4)=NaN;
    %Monclova, Mexico
    finalwbtarray(6533,27197:27198,3:4)=NaN;
    %La Paz, Mexico
    finalwbtarray(6544,29071,3:4)=NaN;
    %Villamontes, Bolivia
    finalwbtarray(6873,29134,3:4)=NaN;finalwbtarray(6873,29843,3:4)=NaN;
    %Onslow, Australia
    finalwbtarray(7212,26357:26358,3:4)=NaN;
    
    
    %Save
    save(strcat(datadir,'finalwbtarraystull.mat'),'finalwbtarray','-append');
    
    
    %If any Davies-Jones WBT values are erroneously NaN for this station, recompute them
    stnstart=st;stnend=st;
    spechum=calcqfromTd(finaldewptarray(stnstart:stnend,:,3:4))./1000;
    pres=pressurefromelev(finalstnelev(stnstart:stnend)).*slp./1000.*100.*ones(size(spechum,1),size(spechum,2),size(spechum,3));
    finalwbtarraydj(stnstart:stnend,:,1:2)=finaltarray(stnstart:stnend,:,1:2);
    finalwbtarraydj(stnstart:stnend,:,3:4)=calcwbt_daviesjones(finaltarray(stnstart:stnend,:,3:4),pres,spechum);
    
    %After doing all days for this QC round, make values that are NaN in the Stull WBT array NaN in the Davies-Jones array as well
    for stn=1:curnumstns
        for day=1:31412
            for col=3:4
                if isnan(finalwbtarraystull(stn,day,col))
                    finalwbtarraydj(stn,day,col)=NaN;
                end
            end
        end
        if rem(stn,1000)==0;disp(stn);end
    end
 
    
    %Save
    save(strcat(datadir,'finalwbtarraydj'),'finalwbtarraydj','-v7.3');
end
