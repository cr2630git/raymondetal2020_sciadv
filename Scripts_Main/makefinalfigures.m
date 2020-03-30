%Make final figures (both main and supplemental)

figure1=0; %45 min -- actual version is made with Python, this is a facsimile
    savedataonly=1; %5 sec -- for both fig 1 and s1
figure2=0; %2 sec -- actual version is made with Python, this is a facsimile
figure3=1; %5 min
figures1=0; %45 min
figures2=0; %3 min
figures3=0; %15 min
figures4=0; %5 min
figures5tos8=0;
    city='New Delhi';
    readinsoundings=1; %3-8 min, depending on station POR
    plotout=1; %all days, as percentiles, incl plots of wind
figures10=0; %10 min
figures11=0; %20 min
figures12=0; %5 min
figures13=0; %30 sec
figures14=0; %1 min
figures15=0; %10 sec
figures16=0; %30 sec
figures18=0; %10 sec
figures19=0; %15 sec
figures20=0; %30 sec
figures21=0; %15 sec
tables1=0; %tex file actually creates table, this just gets some data for it

disp(clock);
%Standard set-up options
figc=1;
startday=startday; %Jan 1, 1979
figloc='/Volumes/ExternalDriveC/RaymondMatthewsHorton2020_Github/';
savingdir=figloc;
cd(figloc);
addpath('/Volumes/ExternalDriveD/ERA5_Hourly_Data/');


%Figure 1
if figure1==1 
    if savedataonly==1
        %Save data in text file
        %Columns are latitude | longitude | all-time max WBT | p99.9 of WBT
        %Rows are stations
        clear histalltimemaxtw;clear histpct999tw;
        for stn=1:size(twarray,1);histalltimemaxtw(stn)=max(twarray(stn,startday:stopday,3));end
        for stn=1:size(twarray,1);histpct999tw(stn)=quantile(twarray(stn,startday:stopday,3),0.999);end
        bigarr=[finalstnlatlon(:,1) finalstnlatlon(:,2) histalltimemaxtw' histpct999tw'];
        dlmwrite(strcat(savingdir,'figure1s1data.txt'),bigarr);
    else
        clear histpct999wbt;temp=1:size(twarray,1);
        for stn=1:size(twarray,1)
            histpct999tw(stn)=quantile(twarray(stn,startday:stopday,3),0.999);
        end
        histpct999wbtgoodstns=histpct999tw(~isnan(histpct999tw));ordsgoodstnswbt=temp(temp(~isnan(histpct999tw)));

        colorcutoffs=[23;25;27;29;31;33];
        markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
            colors('green');colors('orange');colors('red')];
        quicklymapsomethingworld(histpct999wbtgoodstns,figc,finalstnlatlon(ordsgoodstnswbt,1),finalstnlatlon(ordsgoodstnswbt,2),...
            's',colorcutoffs,markercolors,4,1,...
            {'cblabeltext';sprintf('Daily Maximum WBT (%cC)',char(176));'cblabelfontsize';16},figloc,'pct999wbtmap');
        figure(figc);
        figname='figure1';curpart=2;highqualityfiguresetup;
    end
end

if figure2==1
    %Requires having already run annualtrends loop of masterscript
    %Columns are num35coccurrencesbyyear | num33coccurrencesbyyear |
        %num31coccurrencesbyyear | num29coccurrencesbyyear | num27coccurrencesbyyear
    %Rows are years, 1979-2017
    bigarr=[num35coccurrencesbyyear' num33coccurrencesbyyear' num31coccurrencesbyyear' num29coccurrencesbyyear' num27coccurrencesbyyear'];
    dlmwrite(strcat(savingdir,'figure2data.txt'),bigarr);
end

%Figure 3
%Timing of WBT extremes in South Asia -- average WBT by DOY, then smooth and get DOY of climo max
if figure3==1
    stnc=0;
    clear sumbydoythisstn;clear countbydoythisstn;clear sasiastnords;clear sasiastnlats;clear sasiastnlons;
    clear maxwbt;clear doyofmaxwbt;
    
    
    %31-C stns by whether they're in early-monsoon or late-monsoon areas of the subcontinent
    %Monsoon-date source: http://www.imd.gov.in/pages/monsoon_main.php?adta=JPG&adtb=1
    
    %2 regions -- early (<June 15) & late (>June 15)
    earlymonsoonpolygonlats=[22.81;24.80;25.28;29.63;30.00;8.00;3.80;22.81];
    earlymonsoonpolygonlons=[68.40;74.77;83.27;82.13;95.00;95.00;76.50;68.40];
    latemonsoonpolygonlats=[22.81;24.80;25.28;29.63;35.00;30.16;25.17;22.81];
    latemonsoonpolygonlons=[68.40;74.77;83.27;82.13;72.00;67.34;64.50;68.40];

    estavgmonsoonstartpentadearlyhalf=32;
    estavgmonsoonstartpentadlatehalf=38;
    
    stnnums=[1:size(twarray,1)]';
    temp=inpolygon(finalstnlatlon(:,1),finalstnlatlon(:,2),earlymonsoonpolygonlats,earlymonsoonpolygonlons);
    earlymonsoonstns=stnnums(temp==1);
    temp=inpolygon(finalstnlatlon(:,1),finalstnlatlon(:,2),latemonsoonpolygonlats,latemonsoonpolygonlons);
    latemonsoonstns=stnnums(temp==1);
    
    
    for loop=1:2
        assoctbypentadallstns=zeros(73,1);assoctdbypentadallstns=zeros(73,1);pentadc=zeros(73,1);
        assoctbydoyallstns=zeros(365,1);assoctdbydoyallstns=zeros(365,1);doyc=zeros(365,1);
        for pentad=1:73;assoctsavevalspentad{pentad}=0;assoctdsavevalspentad{pentad}=0;end
        for doy=1:365;assoctsavevalsdoy{doy}=0;assoctdsavevalsdoy{doy}=0;end
        if loop==1
            thisarr=earlymonsoonstns;
        else
            thisarr=latemonsoonstns;
        end
        total31cbystnanddoy=zeros(size(thisarr,1),365);
        
        for stnc=1:size(thisarr,1)
            stn=thisarr(stnc);
            sumbydoythisstn{stn}=zeros(366,1);
            countbydoythisstn{stn}=zeros(366,1);
            
            for day=startday:stopday
                thisdoy=twarray(stn,day,2);
                if ~isnan(twarray(stn,day,3)) && ~isnan(thisdoy)
                    sumbydoythisstn{stn}(thisdoy)=sumbydoythisstn{stn}(thisdoy)+twarray(stn,day,3);
                    countbydoythisstn{stn}(thisdoy)=countbydoythisstn{stn}(thisdoy)+1;
                end
            end
            smoothedclimowbt=smoothvector(sumbydoythisstn{stn}./countbydoythisstn{stn},15);
            [maxwbt(stnc),doyofmaxwbt(stnc)]=max(smoothedclimowbt);

            wbt31cinstancesthisstn=wbt31cinstances(wbt31cinstances(:,1)==stn,:);
            for doy=1:365
                total31cbystnanddoy(stnc,doy)=total31cbystnanddoy(stnc,doy)+size(wbt31cinstancesthisstn(wbt31cinstancesthisstn(:,6)==doy),1);
            end
            for c=1:size(wbt31cinstancesthisstn,1)
                thispentad=round2(wbt31cinstancesthisstn(c,6)/5,1,'ceil');
                thisdoy=wbt31cinstancesthisstn(c,6);
                if ~isnan(thisdoy) && ~isnan(thispentad) && ~isnan(tarray(stn,wbt31cinstancesthisstn(c,2),3)) && ...
                        ~isnan(tdarray(stn,wbt31cinstancesthisstn(c,2),3))
                    pentadc(thispentad)=pentadc(thispentad)+1;
                    assoctbypentadallstns(thispentad)=assoctbypentadallstns(thispentad)+tarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdbypentadallstns(thispentad)=assoctdbypentadallstns(thispentad)+tdarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctsavevalspentad{thispentad}(pentadc(thispentad))=tarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdsavevalspentad{thispentad}(pentadc(thispentad))=tdarray(stn,wbt31cinstancesthisstn(c,2),3);
                    
                    doyc(thisdoy)=doyc(thisdoy)+1;
                    assoctbydoyallstns(thisdoy)=assoctbydoyallstns(thisdoy)+tarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdbydoyallstns(thisdoy)=assoctdbydoyallstns(thisdoy)+tdarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctsavevalsdoy{thisdoy}(doyc(thisdoy))=tarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdsavevalsdoy{thisdoy}(doyc(thisdoy))=tdarray(stn,wbt31cinstancesthisstn(c,2),3);
                end
            end
        end
    
        assoctbypentadallstns=assoctbypentadallstns./pentadc;
        assoctdbypentadallstns=assoctdbypentadallstns./pentadc;
        assoctbydoyallstns=assoctbydoyallstns./doyc;
        assoctdbydoyallstns=assoctdbydoyallstns./doyc;
        for pentad=1:73
            stdevt(pentad)=std(assoctsavevalspentad{pentad});
            stdevtd(pentad)=std(assoctdsavevalspentad{pentad});
            %Require at least 7 values to make a meaningful average
            if pentadc(pentad)<7
                assoctbypentadallstns(pentad)=NaN;
                assoctdbypentadallstns(pentad)=NaN;
            end
        end
    
        doy31callstns=smoothvector(sum(total31cbystnanddoy,1)',15);
        pentad31callstns=zeros(73,1);
        for pentad=1:73
            pentad31callstns(pentad)=nansum(doy31callstns(pentad*5-4:pentad*5));
        end
        
        if loop==1
            pentad31callstnsearly=pentad31callstns./(size(thisarr,1).*numyears).*100;
            assoctbypentadallstnsearly=assoctbypentadallstns;
            assoctdbypentadallstnsearly=assoctdbypentadallstns;
            stdevtearly=stdevt;
            stdevtdearly=stdevtd;
        else
            pentad31callstnslate=pentad31callstns./(size(thisarr,1).*numyears).*100;
            disp(size(thisarr,1));
            assoctbypentadallstnslate=assoctbypentadallstns;
            assoctdbypentadallstnslate=assoctdbypentadallstns;
            stdevtlate=stdevt;
            stdevtdlate=stdevtd;
        end
    end
    
    %Compute associated RH for 31C WBT observations, from T and Td
    assocrhbypentadallstnsearly=calcrhfromTanddewpt(assoctbypentadallstnsearly,assoctdbypentadallstnsearly);
    assocrhbypentadallstnslate=calcrhfromTanddewpt(assoctbypentadallstnslate,assoctdbypentadallstnslate);
    
    colorcutoffs=[125;140;155;170;185;200;215];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('light green');colors('orange');colors('red')];
    
    
    figure(988);clf;hold on;curpart=1;highqualityfiguresetup;clf;
    %Subplot I
    ax=axes('Position',[0.28 0.55 0.44 0.44]);
    dontclear=1;plotBlankMap(988,'south-asia-larger',0,0,'ghost white',0);hold on;
    %Show early-monsoon region
    latstoplot=[22 24.5 25.25 26.75 29 25 11 5 22];lonstoplot=[69 76 83.25 83.5 83 95 99 76 69];
    geoshow(latstoplot,lonstoplot,'DisplayType','polygon','FaceColor',colors('orange'),'FaceAlpha',0.1);
    %Show late-monsoon region
    latstoplot=[22 25 30 35.5 36 29 26.75 25.25 24.5 22];lonstoplot=[69 61.5 66 71.5 75 83 83.5 83.25 76 69];
    gs=geoshow(latstoplot,lonstoplot,'DisplayType','polygon','FaceColor',colors('green'),'EdgeColor','k','FaceAlpha',0.1);
    
    %Subplot II
    hold on;
    ax=axes('Position',[0.13 0.32 0.74 0.24]);
    %First, shaded rectangles indicating pre- and post-monsoon dates
    ylim([0 1.5]);yticks([0;0.5;1;1.5]);
    x=[17 estavgmonsoonstartpentadearlyhalf estavgmonsoonstartpentadearlyhalf 17];y=[0 0 1.5 1.5];
    rect=patch(x,y,colors('brown'),'FaceAlpha',0.12);hold on;
    x=[estavgmonsoonstartpentadearlyhalf 61 61 estavgmonsoonstartpentadearlyhalf];y=[0 0 1.5 1.5];
    rect=patch(x,y,colors('blue'),'FaceAlpha',0.12);
    
    %Main plot
    c1=plot(pentad31callstnsearly,'color','k','linewidth',2);hold on;
    xlim([17 61]);
    ylabel({'Annual-Average','Occurrences','Per Station'},'fontweight','bold','fontname','arial','fontsize',10);
    yyaxis right;ylim([30 100]);set(gca,'YColor','k');
    c2=plot(assocrhbypentadallstnsearly,'color','k','linewidth',2,'linestyle','--');hold on;
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);
    xticklabels({'Apr 6-10';'May 1-5';'May 26-30';'Jun 20-24';'Jul 15-19';...
        'Aug 9-13';'Sep 3-7';'Sep 28-Oct 2';'Oct 23-27'});
    ylabel('Rel. Humidity (%)','fontweight','bold','fontname','arial','fontsize',10);
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);
    lgd=legend([c1 c2],{'Occurrences','Relative Humidity'},'Location','Northeast');
    
    %Subplot III
    ax=axes('Position',[0.13 0.04 0.74 0.24]);
    %First, shaded rectangles indicating pre- and post-monsoon dates
    ylim([0 6]);
    x=[17 estavgmonsoonstartpentadlatehalf estavgmonsoonstartpentadlatehalf 17];y=[0 0 6 6];
    rect=patch(x,y,colors('brown'),'FaceAlpha',0.12);hold on;
    x=[estavgmonsoonstartpentadlatehalf 61 61 estavgmonsoonstartpentadlatehalf];y=[0 0 6 6];
    rect=patch(x,y,colors('blue'),'FaceAlpha',0.12);
    
    %Main plot
    c3=plot(pentad31callstnslate,'color','k','linewidth',2);
    xlim([17 61]);
    ylabel({'Annual-Average','Occurrences','Per Station'},'fontweight','bold','fontname','arial','fontsize',10);
    yyaxis right;ylim([30 100]);set(gca,'YColor','k');
    c4=plot(assocrhbypentadallstnslate,'color','k','linewidth',2,'linestyle','--');hold on;
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);
    xticklabels({'Apr 6-10';'May 1-5';'May 26-30';'Jun 20-24';'Jul 15-19';...
        'Aug 9-13';'Sep 3-7';'Sep 28-Oct 2';'Oct 23-27'});
    ylabel('Rel. Humidity (%)','fontweight','bold','fontname','arial','fontsize',10);
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);
    lgd=legend([c3 c4],{'Occurrences','Relative Humidity'},'Location','Northeast');
   
    figname='figure3';curpart=2;highqualityfiguresetup;
end


if figures1==1
    disp('Starting figure s1');disp(clock);
    clear histalltimemaxtw;temp=1:size(twarray,1);
    for stn=1:size(twarray,1)
        histalltimemaxtw(stn)=max(twarray(stn,startday:stopday,3));
    end
    
    colorcutoffs=[23;25;27;29;31;33];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('orange');colors('red')];
    figure(figc);clf;
    quicklymapsomethingworld(histalltimemaxtw,figc,finalstnlatlon(:,1),finalstnlatlon(:,2),'s',colorcutoffs,markercolors,3,1,...
        {'cblabeltext';sprintf('Daily Maximum TW (%cC)',char(176));'cblabelfontsize';16},figloc,'figures1');
    figname='figures1_50percent';curpart=2;highqualityfiguresetup;
    disp('Finished figure s1');disp(clock);
end

%Maximum number of consecutive hours above 33 C, for stations with high-temporal-resolution data
if figures2==1
    %Get data on event lengths for high-temporal-resolution stations
    stnlist1hourly=[];
    prevstn=0;
    for row=1:size(wbt33cinstances,1)
        thisstn=wbt33cinstances(row,1);
        if thisstn~=prevstn
            thisfilename=strcat(rawstndatadir,'hadisd.2.0.2.2017f_19310101-20171231_',finalstncodes(thisstn,:),'.nc');
            time=ncread(thisfilename,'time');
            day=wbt33cinstances(row,2);
            firsthourtoplot=day*24-23;lasthourtoplot=day*24;
            subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
            if size(subdailytimes,1)>=1
                adsh=max(firsthourtoplot,subdailytimes(1));
                subdailytimesoffset=subdailytimes(2:end);diffs=subdailytimesoffset-subdailytimes(1:end-1);
                hourinterval=mode(diffs);
                if hourinterval==1;stnlist1hourly=[stnlist1hourly;thisstn];end
            end
            prevstn=wbt33cinstances(row,1);
        end
    end
    
    eventcountsbylength=zeros(100,1);
    for stnindex=1:size(stnlist1hourly,1)
        s=stnlist1hourly(stnindex);
        downloadprephadisddata;
        invalid=isnan(wetbulb);wetbulb(invalid)=0;
        hoursabove33c=find(wetbulb>=33);

        ord=1;keepgoingthisstn=1;
        while ord<=size(hoursabove33c,1) && keepgoingthisstn==1
            thishour=hoursabove33c(ord);prevhour=thishour;
            thiseventlength=1;eventcontinues=1;
            ordtocheck=ord;
            while eventcontinues==1 && ordtocheck<=size(hoursabove33c,1)
                ordtocheck=ordtocheck+1;
                if ordtocheck<=size(hoursabove33c,1)
                    thishour=hoursabove33c(ordtocheck);
                    if thishour-prevhour==1 %next hour sequentially follows
                        thiseventlength=thiseventlength+1;prevhour=prevhour+1;
                        eventcontinues=1;
                    else
                        %Event ends (or never started)
                        if thiseventlength>=1
                            eventcountsbylength(thiseventlength)=eventcountsbylength(thiseventlength)+1;
                            %fprintf('this length is %d\n',thiseventlength);
                            ord=ord+thiseventlength;
                        end
                        eventcontinues=0;
                    end
                end
            end
            if ordtocheck>=size(hoursabove33c,1);keepgoingthisstn=0;end
        end
        fprintf('Stn is %d of %d for step 2\n',stnindex,size(stnlist1hourly,1));
    end
    eventcountsbylength=eventcountsbylength(1:8);
    
    figure(figc);clf;curpart=1;highqualityfiguresetup;
    plot(eventcountsbylength,'linewidth',2,'color','k');
    title(strcat('Wet-Bulb Temperatures >= 33',char(176),'C'),'fontsize',18,'fontweight','bold','fontname','arial');
    xlabel('Event Length (Hours)','fontsize',14,'fontweight','bold','fontname','arial');
    ylabel('Count','fontsize',14,'fontweight','bold','fontname','arial');
    set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
    figname='figures2';curpart=2;highqualityfiguresetup;
end


%Uses gridded 6-hourly ERA-Interim data and hourly ERA5 data to plot composites for all 35C days
    %at the two stations that have recorded >=3 such days
if figures3==1
    %Set up regional lat/lon arrays
    clear middleeastsouthasialats;clear middleeastsouthasialons;
    templats=0:0.5:89.5;templons=0:0.5:89.5;
    for i=1:size(templats,2)
        for j=1:size(templons,2)
            middleeastsouthasialats(i,j)=templats(i);
            middleeastsouthasialons(i,j)=templons(i);
        end
    end
    middleeastsouthasialats=flipud(middleeastsouthasialats);middleeastsouthasialons=middleeastsouthasialons';
    
    exist uclimo1000;
    if ans==0
        temp=load('/Volumes/ExternalDriveC/Basics_ERA-Interim/computeerainterimclimo.mat');
        uclimo1000=temp.uclimo1000;vclimo1000=temp.vclimo1000;
    end
    
    for loop=2:2
        if loop==1 %Middle East
            s=1756;
            closestrowtostn_erai=129;closestcoltostn_erai=360+113; %found using middleeastsouthasialats, middleeastsouthasialons
            closestrowtostn_era5=39;closestcoltostn_era5=65; %found using reglats, reglons
            doys=[214;224;223;189];years=[1995;1995;2009;2010];correspdays=[23590;23600;28713;29044];
            southlatindex=180;northlatindex=1;westlonindex=360;eastlonindex=539; %0 N, 90 N, 0 E, 90 E
            ts=3; %6-hourly timestep (UTC) corresponding to afternoon in the Middle East
            regiontoplot='persian-gulf';conttoplot='Asia';regionallats=middleeastsouthasialats;regionallons=middleeastsouthasialons;
        elseif loop==2 %South Asia
            s=1780;
            closestrowtostn_erai=123;closestcoltostn_erai=360+138; %found using middleeastsouthasialats, middleeastsouthasialons
            closestrowtostn_era5=28;closestcoltostn_era5=115; %found using reglats, reglons
            doys=[206;156;158;178;181;195];years=[1987;2005;2005;2010;2010;2012];correspdays=[20660;27185;27187;29033;29036;29780];
            southlatindex=180;northlatindex=1;westlonindex=360;eastlonindex=539; %0 N, 90 N, 0 E, 90 E
            ts=3; %6-hourly timestep (UTC) corresponding to afternoon in South Asia
            regiontoplot='south-asia-west';conttoplot='Asia';regionallats=southasialats;regionallons=southasialons;
        end

        %ERA-Interim first
        %1000-mb winds and TW
        clear regionaluwindactual_erai;clear regionalvwindactual_erai;clear regionaltw_erai;
        validdayc=0;
        for day=1:size(doys,1)
            if years(day)>=1979
                validdayc=validdayc+1;
                
                uwindcuryear=ncread(strcat(erainterimdir,num2str(years(day)),'vars1000mb.nc'),'u');
                uwinddayofinterest=uwindcuryear(:,:,doys(day)*4-(4-ts));
                uwinddayofinterest=permute(uwinddayofinterest,[2 1 3]);
                uwinddayofinterest=[uwinddayofinterest(:,361:720,:) uwinddayofinterest(:,1:360,:)];
                c=1;clear uwindclimodoi;for i=1:1;uwindclimodoi(:,:,i)=uclimo1000{doys(day),c};c=c+1;if c>=5;c=1;end;end
                uwindactualdoi=uwinddayofinterest;
                regionaluwindactual_erai(validdayc,:,:)=uwindactualdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);

                vwindcuryear=ncread(strcat(erainterimdir,num2str(years(day)),'vars1000mb.nc'),'v');
                vwinddayofinterest=vwindcuryear(:,:,doys(day)*4-(4-ts));
                vwinddayofinterest=permute(vwinddayofinterest,[2 1 3]);
                vwinddayofinterest=[vwinddayofinterest(:,361:720,:) vwinddayofinterest(:,1:360,:)];
                c=1;clear vwindclimodoi;for i=1:1;vwindclimodoi(:,:,i)=vclimo1000{doys(day),c};c=c+1;if c>=5;c=1;end;end
                vwindactualdoi=vwinddayofinterest;
                regionalvwindactual_erai(validdayc,:,:)=vwindactualdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);

                twdatafromfile=load(strcat(erainterimdir,'savederatwarrays',num2str(years(day)),'.mat'));

                twdata=twdatafromfile.thisyeartw;clear twdatafromfile;
                twtimeofinterest=twdata(:,:,doys(day)*4-(4-ts))';
                twtimeofinterest=[twtimeofinterest(:,361:720) twtimeofinterest(:,1:360)];

                regionaltw_erai(validdayc,:,:)=squeeze(twtimeofinterest(northlatindex:southlatindex,westlonindex:eastlonindex));
                
                maxbyhour_erai(validdayc)=...
                    max(max(regionaltw_erai(validdayc,closestrowtostn_erai-1:closestrowtostn_erai+1,closestcoltostn_erai-1:closestcoltostn_erai+1)));
            end
            fprintf('Just completed day %d of %d for loop %d\n',day,size(doys,1),loop);
        end

        %Average multiple days together to make a composite
        regionaluwindactual_erai=squeeze(nanmean(regionaluwindactual_erai));
        regionalvwindactual_erai=squeeze(nanmean(regionalvwindactual_erai));
        regionaltw_erai=squeeze(nanmean(regionaltw_erai));

        underlaydata_erai={regionallats;regionallons;regionaltw_erai};
        data_erai={regionallats;regionallons;regionaluwindactual_erai;regionalvwindactual_erai};
        
        
        %ERA5
        %ERA5 data retrieved for 15N-35N, 40E-80E -- see 1era5downloadscript.sh.py
        exist era5elev;if ans==0;era5elev=ncread('/Volumes/ExternalDriveD/ERA5_Hourly_Data/era5elev.nc','z')/9.81;end
        %latvec=90:-0.25:-90;lonvec=0:0.25:359.75; %use these for determining subsets of elev data
        era5elevthisreg=era5elev(161:321,221:301)';
        clear presarray;presarray=pressurefromelev(era5elevthisreg).*slp./1000*100;
        reglats=35:-0.25:15;reglons=40:0.25:80;
        for row=1:size(reglats,2)
            for col=1:size(reglons,2)
                reglatarray(row,col)=reglats(row);
                reglonarray(row,col)=reglons(col);
            end
        end
        
        clear subdailytw;
        downloadprephadisddata;
        for day=1:size(doys,1)
            firsthourtoplot(day)=correspdays(day)*24-23;lasthourtoplot(day)=correspdays(day)*24;
            subdailytw{day}=wetbulb(time(:,1)>=firsthourtoplot(day) & time(:,1)<=lasthourtoplot(day));
        end
        bigarraytw=NaN.*ones(size(doys,1),24,81,161);
        bigarrayu=NaN.*ones(size(doys,1),24,81,161);
        bigarrayv=NaN.*ones(size(doys,1),24,81,161);
        clear twforcomposite;clear uforcomposite;clear vforcomposite;clear maxbyhour;
        for day=1:size(doys,1)
            doytodo=doys(day);doyreltodataset=doytodo-DatetoDOY(5,1,years(day))+1;
            firsthourtocalc=doyreltodataset.*24-23;lasthourtocalc=doyreltodataset.*24;

            file=ncgeodataset(strcat('/Volumes/ExternalDriveD/ERA5_Hourly_Data/data',num2str(years(day)),'.grib')); %starts on May 1
            t=file{'2_metre_temperature_surface'};
            td=file{'2_metre_dewpoint_temperature_surface'};
            u=file{'10_metre_U_wind_component_surface'};
            v=file{'10_metre_V_wind_component_surface'};

            arrayt=NaN.*ones(lasthourtocalc-firsthourtocalc+1,81,161);arraytd=NaN.*ones(lasthourtocalc-firsthourtocalc+1,81,161);
            arrayrh=NaN.*ones(lasthourtocalc-firsthourtocalc+1,81,161);arraytw=NaN.*ones(lasthourtocalc-firsthourtocalc+1,81,161);
            for i=firsthourtocalc:lasthourtocalc
                arrayt(i-firsthourtocalc+1,:,:)=double(squeeze(t.data(i,:,:)))-273.15;
                arraytd(i-firsthourtocalc+1,:,:)=double(squeeze(td.data(i,:,:)))-273.15;

                arrayrh=calcrhfromTanddewpt(arrayt(i-firsthourtocalc+1,:,:),arraytd(i-firsthourtocalc+1,:,:));
                bigarraytw(day,i-firsthourtocalc+1,:,:)=calcwbt_daviesjones(squeeze(arrayt(i-firsthourtocalc+1,:,:)),presarray,squeeze(arrayrh),1); 

                bigarrayu(day,i-firsthourtocalc+1,:,:)=double(squeeze(u.data(i,:,:)));
                bigarrayv(day,i-firsthourtocalc+1,:,:)=double(squeeze(v.data(i,:,:)));
            end

            %Calc hour of max near station (within 0.5 deg)
            for hour=1:24
                maxbyhour_era5(day,hour)=squeeze(max(squeeze(max(squeeze(bigarraytw(day,hour,closestrowtostn_era5-2:closestrowtostn_era5+2,closestcoltostn_era5-2:closestcoltostn_era5+2))))));
            end
            [~,b]=max(maxbyhour_era5(day,:));
            twforcomposite(day,:,:)=squeeze(bigarraytw(day,b,:,:));
            uforcomposite(day,:,:)=squeeze(bigarrayu(day,b,:,:));
            vforcomposite(day,:,:)=squeeze(bigarrayv(day,b,:,:));
        end
        
        %Average multiple days together to make a composite
        regionaluwindactual_era5=squeeze(nanmean(uforcomposite));
        regionalvwindactual_era5=squeeze(nanmean(vforcomposite));
        regionaltw_era5=squeeze(nanmean(twforcomposite));

        underlaydata_era5={reglatarray;reglonarray;regionaltw_era5};
        data_era5={reglatarray;reglonarray;regionaluwindactual_era5;regionalvwindactual_era5};
        
        return;
        
        %Final map, combining the two datasets
        figure(1);clf;hold on;curpart=1;highqualityfiguresetup;
        region='persian-gulf-pakistan';datatype='custom';
        cmin=24;cmax=34;
        
        %ERA-I
        vararginnew={'variable';'wind';'mystepunderlay';0.5;'underlaycaxismax';cmax;'underlaycaxismin';cmin;'contour';1;...
            'vectorData';data_erai;'datatounderlay';underlaydata_erai;'underlayvariable';'temperature';'overlaynow';0;'anomavg';'anom';...
            'conttoplot';'Asia';'nonewfig';1;'mapareadivvalue';10};
        plotModelData(data_erai,region,vararginnew,datatype);set(gca,'Position',[0.1 0.53 0.8 0.45]);
        geoshow(finalstnlatlon(s,1),finalstnlatlon(s,2),'DisplayType','point','Marker','s',...
            'MarkerSize',9,'MarkerFaceColor',colors('blue'),'MarkerEdgeColor',colors('blue'));
        colormap(colormaps('wbt','more','not'));
        cblabeltext=sprintf('TW (%cC)',char(176));fignametext='tw';
        h=text(1.2,0.4,cblabeltext,'fontname','arial','fontsize',16,'fontweight','bold','units','normalized');set(h,'Rotation',90);
        %annotation('textarrow',[0.93 0.96],[0.15 0.15],'String','','units','normalized');
        %text(1.12,0.02,'2 m/s','fontsize',14,'fontname','arial','fontweight','bold','units','normalized');
        
        %ERA5
        subplot(2,1,2);
        vararginnew={'variable';'wind';'mystepunderlay';0.5;'underlaycaxismax';cmax;'underlaycaxismin';cmin;'contour';1;...
            'vectorData';data_era5;'datatounderlay';underlaydata_era5;'underlayvariable';'temperature';'overlaynow';0;'anomavg';'anom';...
            'conttoplot';'Asia';'nonewfig';1;'mapareadivvalue';2};
        plotModelData(data_era5,region,vararginnew,datatype);set(gca,'Position',[0.1 0.02 0.8 0.45]);
        geoshow(finalstnlatlon(s,1),finalstnlatlon(s,2),'DisplayType','point','Marker','s',...
            'MarkerSize',9,'MarkerFaceColor',colors('blue'),'MarkerEdgeColor',colors('blue'));
        colormap(colormaps('wbt','more','not'));
        cblabeltext=sprintf('TW (%cC)',char(176));fignametext='tw';
        h=text(1.2,0.4,cblabeltext,'fontname','arial','fontsize',16,'fontweight','bold','units','normalized');set(h,'Rotation',90);
        annotation('textarrow',[0.8 0.83],[0.15 0.15],'String','','units','normalized');
        text(1.25,0.18,'10 m/s','fontsize',14,'fontname','arial','fontweight','bold','units','normalized');
        
        %Save
        figname=strcat('figures3NEWloop',num2str(loop));
        curpart=2;highqualityfiguresetup;
    end
end

%Plot diurnal temperature & dewpoint associated with all Tw=33C and Tw=35C occurrences
if figures4==1
    clear savearraytw_33;clear savearrayt_33;clear savearraytd_33;clear hourofmaxval_33;
    prevs=0;
    for row=1:size(wbt33cinstances,1)
        s=wbt33cinstances(row,1);
        d=wbt33cinstances(row,2);
        if s~=prevs;downloadprephadisddata;prevs=s;end
        
        firsthourtoplot_centralday=d*24-23;lasthourtoplot_centralday=d*24;
        subdailytw_centralday=wetbulb(time(:,1)>=firsthourtoplot_centralday & time(:,1)<=lasthourtoplot_centralday);
        subdailytimes_centralday=time(time(:,1)>=firsthourtoplot_centralday & time(:,1)<=lasthourtoplot_centralday);
        
        [~,b]=max(subdailytw_centralday);
        if size(b,1)>=1
            timeofpeak=subdailytimes_centralday(b);
            tw_twelvebeforetwelveafterpeak=wetbulb(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            td_twelvebeforetwelveafterpeak=dewpoint(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            t_twelvebeforetwelveafterpeak=temperature(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            times_twelvebeforetwelveafterpeak=time(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);

            hourofmaxval_33(row)=b;

            %Interpolate Tw data for 12 hours before peak to 12 hours
            %after peak to hourly resolution, but only if
            %temporal gaps within this period are <=3 hours
            if max(diff(subdailytimes_centralday))<=3
                savearraytw_33(row,:)=interp1(times_twelvebeforetwelveafterpeak,tw_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                savearraytd_33(row,:)=interp1(times_twelvebeforetwelveafterpeak,td_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                savearrayt_33(row,:)=interp1(times_twelvebeforetwelveafterpeak,t_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                fprintf('Valid 33C data found for row %d\n',row);
            else
                savearraytw_33(row,:)=NaN.*ones(1,25);
                savearraytd_33(row,:)=NaN.*ones(1,25);
                savearrayt_33(row,:)=NaN.*ones(1,25);
            end
        end
        if rem(row,20)==0;fprintf('Line 492; on row %d of row %d for 33C\n',row,size(wbt33cinstances,1));end
    end

    
    clear savearraytw_35;clear savearrayt_35;clear savearraytd_35;clear hourofmaxval_35;
    prevs=0;
    for row=1:size(wbt35cinstances,1)
        s=wbt35cinstances(row,1);
        d=wbt35cinstances(row,2);
        if s~=prevs;downloadprephadisddata;prevs=s;end
        
        firsthourtoplot_centralday=d*24-23;lasthourtoplot_centralday=d*24;
        subdailytw_centralday=wetbulb(time(:,1)>=firsthourtoplot_centralday & time(:,1)<=lasthourtoplot_centralday);
        subdailytimes_centralday=time(time(:,1)>=firsthourtoplot_centralday & time(:,1)<=lasthourtoplot_centralday);
        
        [~,b]=max(subdailytw_centralday);
        if size(b,1)>=1
            timeofpeak=subdailytimes_centralday(b);
            tw_twelvebeforetwelveafterpeak=wetbulb(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            td_twelvebeforetwelveafterpeak=dewpoint(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            t_twelvebeforetwelveafterpeak=temperature(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);
            times_twelvebeforetwelveafterpeak=time(time(:,1)>=timeofpeak-12 & time(:,1)<=timeofpeak+12);

            hourofmaxval_35(row)=b;

            %Interpolate Tw data for 12 hours before peak to 12 hours
            %after peak to hourly resolution, but only if
            %temporal gaps within this period are <=3 hours
            if max(diff(subdailytimes_centralday))<=3
                savearraytw_35(row,:)=interp1(times_twelvebeforetwelveafterpeak,tw_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                savearraytd_35(row,:)=interp1(times_twelvebeforetwelveafterpeak,td_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                savearrayt_35(row,:)=interp1(times_twelvebeforetwelveafterpeak,t_twelvebeforetwelveafterpeak,timeofpeak-12:timeofpeak+12);
                fprintf('Valid 35C data found for row %d\n',row);
            else
                savearraytw_35(row,:)=NaN.*ones(1,25);
                savearraytd_35(row,:)=NaN.*ones(1,25);
                savearrayt_35(row,:)=NaN.*ones(1,25);
            end
        end
        if rem(row,20)==0;fprintf('Line 492; on row %d of row %d for 35C\n',row,size(wbt35cinstances,1));end
    end
    
    
    %Figure
    figure(101);clf;hold on;curpart=1;highqualityfiguresetup;
    
    %Main plot
    invalid=savearrayt_33==0;savearrayt_33(invalid)=NaN;
    invalid=savearraytd_33==0;savearraytd_33(invalid)=NaN;
    meantrace_t=nanmean(savearrayt_33,1);
    meantrace_td=nanmean(savearraytd_33,1);
    plot(meantrace_t,'color',colors('sirkes_dark red'),'linewidth',2.5);hold on;plot(meantrace_td,'b','linewidth',2.5);
    
    invalid=savearrayt_35==0;savearrayt_35(invalid)=NaN;
    invalid=savearraytd_35==0;savearraytd_35(invalid)=NaN;
    meantrace_t=nanmean(savearrayt_35,1);
    meantrace_td=nanmean(savearraytd_35,1);
    plot(meantrace_t,'color',colors('light red'),'linewidth',2.5);hold on;plot(meantrace_td,'color',colors('light blue'),'linewidth',2.5);
    
    set(gca,'fontsize',16,'fontweight','bold','fontname','arial');
    xticks([1;7;13;19;25]);xlim([1 25]);xticklabels({'-12';'-6';'0';'6';'12'});
    xlabel('Hours Relative to Peak TW','fontsize',16,'fontweight','bold','fontname','arial');
    ylabel(sprintf('Value (%cC)',char(176)),'fontsize',16,'fontweight','bold','fontname','arial');
    lgd=legend('T (33C)','Td (33C)','T (35C)','Td (35C)','Location','northeast','autoupdate','off');
    set(lgd,'fontsize',15,'fontweight','bold','fontname','arial');
    
    %Inset plot: 'dot plot' of hours of occurrence (based on
    %rem(hourofmaxval,24)) -- for Middle East, a value of 10 there -> 1 PM local time
    %THIS MUST ALL BE MANUALLY CHANGED IF DATA CHANGE
    insetplot=0;
    if insetplot==1
    %Times
    line([2 10],[40 40],'color','k','linewidth',2);
    text(1.4,39.3,'12am','fontsize',14,'fontweight','bold','fontname','arial');
    text(3.4,39.3,'6am','fontsize',14,'fontweight','bold','fontname','arial');
    text(5.4,39.3,'12pm','fontsize',14,'fontweight','bold','fontname','arial');
    text(7.4,39.3,'6pm','fontsize',14,'fontweight','bold','fontname','arial');
    %Occurrences
    %marker size 12 for 1 occurrence, marker size 18 for 2 occurrences
    plot(5.67,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %11am
    plot(6,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %12pm
    plot(6.33,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %1pm
    plot(6.67,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %2pm
    end
    
    figname='figures4';curpart=2;highqualityfiguresetup;
end

%Read and analyze soundings from
%a. Abu Dhabi, UAE
%b. Sterling VA (adjacent to Dulles Airport)
%c. Bandar Abbas, Iran
%d. Muscat, Oman
%e. Jacobabad, Pakistan

%Soundings downloaded from https://www1.ncdc.noaa.gov/pub/data/igra/data/data-por/ using
    %station list at https://www1.ncdc.noaa.gov/pub/data/igra/igra2-station-list.txt
if figures5tos8==1
    if readinsoundings==1
        if strcmp(city,'Abu Dhabi')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/AEM00041217-data.txt','r');
            soundingtopchars='#AEM';por='1983-2019';cityforfilenames='abudhabi';areatoplot='abu-dhabi-area';
            goallevels=[995;975;950;925;850];
            %identified as of interest: sounding starting at idx 602082 -- 12z, doy 208, 2014 (Jul 27)
            %(using plot(twvec) and zooming in)
        elseif strcmp(city,'Sterling')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/USM00072403-data.txt','r');
            soundingtopchars='#USM';por='1960-2019';cityforfilenames='sterling';areatoplot='sterling-area';
            goallevels=[990;975;950;925;850];
        elseif strcmp(city,'Bandar Abbas')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/IRM00040875-data.txt','r');
            soundingtopchars='#IRM';por='1989-2018';cityforfilenames='bandarabbas';areatoplot='bandar-abbas-area';
            goallevels=[995;975;950;925;850];
        elseif strcmp(city,'Muscat')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/MUM00041256-data.txt','r');
            soundingtopchars='#MUM';por='1978-2019';cityforfilenames='muscat';areatoplot='muscat-area';
            goallevels=[995;975;950;925;850];
        elseif strcmp(city,'Dhahran')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/SAM00040416-data.txt','r');
            soundingtopchars='#SAM';por='1976-1997';cityforfilenames='dhahran';areatoplot='dhahran-area'; 
            goallevels=[995;975;950;925;850];
        elseif strcmp(city,'New Delhi')
            fid=fopen('/Volumes/ExternalDriveC/WBTT_Overlap_Saved_Arrays/INM00042182-data.txt','r');
            soundingtopchars='#INM';por='1983-2019';cityforfilenames='newdelhi';areatoplot='newdelhi-area';
            goallevels=[970;960;950;925;850];
        else
            disp('Help!! I am stuck');return;
        end

        clear twvec;clear tvec;clear rhvec;clear dpdvec;clear presvec;clear winddirvec;clear windspdvec;
        clear basetwvec;clear basetwvec_idxsaver;
        clear yearvec;clear doyvec;clear todvec;
        idx=1;nearsfctwindex=1;
        while ~feof(fid) %check every line
            templine=fgetl(fid);
            if strcmp(templine(1:4),soundingtopchars) %top of a new sounding
                yearvec(idx)=str2num(templine(14:17));
                month=str2num(templine(19:20));day=str2num(templine(22:23));
                doyvec(idx)=DatetoDOY(month,day,yearvec(idx));
                todvec(idx)=str2num(templine(25:26));
                idx=idx+1;
            else %data within a sounding
                continueon=1;
                if strcmp(city,'Dhahran') && max(yearvec)<=1979;continueon=0;end %Dhahran data for the 1970s is unreliable
                if continueon==1
                    temperature=templine(23:27);temperature=strrep(temperature,'B',' ');
                    rh=templine(29:33);rh=strrep(rh,'B',' ');
                    dpd=templine(34:39);dpd=strrep(dpd,'B',' ');
                    p=templine(11:16);p=strrep(p,'B',' ');p=strrep(p,'A',' ');
                    winddir=templine(40:46);windspd=templine(48:51);

                    temperature=double(str2num(temperature))./10;
                    rh=double(str2num(rh))./10;
                    dpd=double(str2num(dpd))./10;
                    p=double(str2num(p))./100;
                    winddir=double(str2num(winddir));windspd=double(str2num(windspd))./10;
                    
                    if temperature~=-999.9 && rh~=-999.9 && ~strcmp(rh,' ') %use T & RH
                        presvec(idx)=p;
                        tvec(idx)=temperature;rhvec(idx)=rh;
                        twvec(idx)=calcwbt_daviesjones(tvec(idx),presvec(idx)*100,rhvec(idx),1);
                        if abs(twvec(idx))>=40;twvec(idx)=NaN;end
                        if ~isempty(winddir);if abs(winddir)~=9999 && abs(winddir)~=8888;winddirvec(idx)=winddir;else;winddirvec(idx)=NaN;end;end
                        if ~isempty(windspd);if abs(windspd)~=999.9 && abs(windspd)~=888.8;windspdvec(idx)=windspd;else;windspdvec(idx)=NaN;end;end
                        idx=idx+1;

                        indexoflastnonzero=find(todvec,1,'last');
                        if p>=goallevels(1) && todvec(indexoflastnonzero)==12
                            basetwvec(nearsfctwindex)=twvec(idx-1);
                            basetwvec_idxsaver(nearsfctwindex)=idx-1;          
                            nearsfctwindex=nearsfctwindex+1;
                        end
                    elseif temperature~=-999.9 && dpd~=-999.9 && ~strcmp(dpd,' ') %use T & DPD
                        presvec(idx)=p;
                        tvec(idx)=temperature;dpdvec(idx)=dpd;
                        dewpt(idx)=tvec(idx)-dpdvec(idx);
                        relhum=calcrhfromTanddewpt(tvec(idx),dewpt(idx));
                        twvec(idx)=calcwbt_daviesjones(tvec(idx),presvec(idx)*100,relhum,1);
                        %if ~isnan(twvec(idx));if tvec(idx)>=0;fprintf('Tw is %0.2f, T is %0.2f, dewpt is %0.2f, all at index %d\n',...
                        %            twvec(idx),tvec(idx),dewpt(idx),idx);end;end
                        if abs(twvec(idx))>=40;twvec(idx)=NaN;end
                        if ~isempty(winddir);if abs(winddir)~=9999 && abs(winddir)~=8888;winddirvec(idx)=winddir;else;winddirvec(idx)=NaN;end;end
                        if ~isempty(windspd);if abs(windspd)~=999.9 && abs(windspd)~=888.8;windspdvec(idx)=windspd;else;windspdvec(idx)=NaN;end;end
                        idx=idx+1;

                        indexoflastnonzero=find(todvec,1,'last');
                        if p>=goallevels(1) && todvec(indexoflastnonzero)==12
                            basetwvec(nearsfctwindex)=twvec(idx-1);
                            basetwvec_idxsaver(nearsfctwindex)=idx-1;
                            nearsfctwindex=nearsfctwindex+1;
                            %disp('Found one (line 717!)');
                            %fprintf('Tw is %0.2f, T is %0.2f, dewpt is %0.2f, all at index %d\n',...
                            %        twvec(idx-1),tvec(idx-1),dewpt(idx-1),idx-1);
                        end
                    end
                end
            end
            if rem(idx,10^4)==0;fprintf('At line 721, idx is %d\n',idx);disp(clock);end
        end

        basetwp99pt75=quantile(basetwvec,0.9975);
        basetwp97pt5=quantile(basetwvec,0.975);
        basetwp90=quantile(basetwvec,0.9);
        basetwp50=quantile(basetwvec,0.5);
        c=zeros(4,1);clear arr1;clear arr11;clear arr2;clear arr22;clear arr3;clear arr33;clear arr4;clear arr44;
        for i=1:size(basetwvec,2)
            if basetwvec(i)>=basetwp99pt75
                c(1)=c(1)+1;
                arr1(c(1))=basetwvec(i);
                arr11(c(1))=basetwvec_idxsaver(i);
            elseif basetwvec(i)>=basetwp97pt5
                c(2)=c(2)+1;
                arr2(c(2))=basetwvec(i);
                arr22(c(2))=basetwvec_idxsaver(i);
            elseif basetwvec(i)>=basetwp90
                c(3)=c(3)+1;
                arr3(c(3))=basetwvec(i);
                arr33(c(3))=basetwvec_idxsaver(i);
            elseif basetwvec(i)>=basetwp50
                c(4)=c(4)+1;
                arr4(c(4))=basetwvec(i);
                arr44(c(4))=basetwvec_idxsaver(i);
            end
        end
    end

    if plotout==1
        %Interpolate soundings
        %Interpolation scheme necessarily assumes a linear change between each observed pressure level
        for pctrange=1:4
            clear cleanpresarr;clear cleantwarr;clear cleantarr;clear cleanwinddirarr;clear cleanwindspdarr;
            if pctrange==1;arr=arr11;elseif pctrange==2;arr=arr22;elseif pctrange==3;arr=arr33;else;arr=arr44;end
            for sounding=1:size(arr,2)
                thesetws=twvec(arr(sounding):arr(sounding)+12);
                thesets=tvec(arr(sounding):arr(sounding)+12);
                thesewinddirs=winddirvec(arr(sounding):arr(sounding)+12);
                thesewindspds=windspdvec(arr(sounding):arr(sounding)+12);
                thesepres=presvec(arr(sounding):arr(sounding)+12);

                cleantws=zeros(5,1);cleants=zeros(5,1);cleanwinddirs=zeros(5,1);cleanwindspds=zeros(5,1);cleanpres=zeros(5,1);
                for goallev=1:5
                    thisgoallev=goallevels(goallev);

                    %Move through pressure vector until two values that span current goallev are found
                    %Unless, of course, this level is already a goallev
                    lev=1;
                    while lev<=size(thesepres,2)-1
                        thislev=thesepres(lev);nextlev=thesepres(lev+1);
                        if thislev==thisgoallev
                            cleanpres(goallev)=thesepres(lev);
                            cleantws(goallev)=thesetws(lev);
                            cleants(goallev)=thesets(lev);
                            cleanwinddirs(goallev)=thesewinddirs(lev);
                            cleanwindspds(goallev)=thesewindspds(lev);
                            lev=1000;
                        elseif thislev>thisgoallev && nextlev<thisgoallev
                            difffromthis=abs(thislev-thisgoallev);
                            difffromnext=abs(nextlev-thisgoallev);
                            thislevweight=difffromnext./(difffromthis+difffromnext);
                            nextlevweight=1-thislevweight;

                            cleanpres(goallev)=thesepres(lev).*thislevweight+thesepres(lev+1).*nextlevweight;
                            cleantws(goallev)=thesetws(lev).*thislevweight+thesetws(lev+1).*nextlevweight;
                            cleants(goallev)=thesets(lev).*thislevweight+thesets(lev+1).*nextlevweight;
                            cleanwinddirs(goallev)=thesewinddirs(lev).*thislevweight+thesewinddirs(lev+1).*nextlevweight;
                            cleanwindspds(goallev)=thesewindspds(lev).*thislevweight+thesewindspds(lev+1).*nextlevweight;
                            lev=1000;
                        end
                        lev=lev+1;
                    end
                end

                cleanpresarr(sounding,:)=cleanpres;
                cleantwarr(sounding,:)=cleantws;
                cleantarr(sounding,:)=cleants;
                cleanwinddirarr(sounding,:)=cleanwinddirs;
                cleanwindspdarr(sounding,:)=cleanwindspds;
            end
            twcomposite(pctrange,:)=nanmean(cleantwarr,1);tcomposite(pctrange,:)=nanmean(cleantarr,1);
            winddircomposite(pctrange,:)=nanmean(cleanwinddirarr,1);windspdcomposite(pctrange,:)=nanmean(cleanwindspdarr,1);
        end



        figure(12);clf;curpart=1;highqualityfiguresetup;

        %Map
        dontclear=1;
        shadingcolor='light brown';
        set(gca,'Position',[-0.08 0.57 0.34 0.34]);
        if strcmp(city,'Abu Dhabi')
            quicklymapsomethingregion(areatoplot,1,12,24.445,54.646,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            text(0.25,0.8,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.5,0.3,'UAE','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        elseif strcmp(city,'Sterling')
            quicklymapsomethingregion(areatoplot,1,12,38.972,-77.452,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            %text(0.3,0.15,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.4,0.8,'USA','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        elseif strcmp(city,'Bandar Abbas')
            quicklymapsomethingregion(areatoplot,1,12,27.158,56.169,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            text(0.3,0.15,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.4,0.8,'Iran','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        elseif strcmp(city,'Muscat')
            quicklymapsomethingregion(areatoplot,1,12,23.601,58.291,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            text(0.35,0.8,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.4,0.2,'Oman','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        elseif strcmp(city,'Dhahran')
            quicklymapsomethingregion(areatoplot,1,12,26.265,50.152,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            text(0.45,0.8,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.25,0.25,'Saudi Arabia','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.5,0.4,'Bahrain','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            text(0.63,0.1,'Qatar','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        elseif strcmp(city,'New Delhi')
            quicklymapsomethingregion(areatoplot,1,12,28.284,68.45,'x',...
                0,'r',15,0,0,shadingcolor,figloc,strcat('verif',cityforfilenames,'soundings_bypct'));
            %text(0.35,0.8,'Persian Gulf','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
            %text(0.4,0.2,'Oman','fontsize',12,'fontweight','bold','fontname','arial','fontangle','italic','units','normalized');
        end

        %Scatterplot
        axes('Position',[0.25 0.11 0.6 0.815]);
        titlestr={'>p99.75';'p97.5-p99.75';'p90-p97.5';'p50-p90'};
        mcolors={'r';colors('orange');colors('medium green');'b'};
        %Plot T and Tw
        %Plot laboriously instead of in a loop to facilitate legend creation
        l4=scatter(tcomposite(4,:),cleanpresarr(4,:),70,'filled','d','MarkerEdgeColor',mcolors{4},'MarkerFaceColor',mcolors{4});hold on;
        l3=scatter(tcomposite(3,:),cleanpresarr(3,:),70,'filled','d','MarkerEdgeColor',mcolors{3},'MarkerFaceColor',mcolors{3});
        l2=scatter(tcomposite(2,:),cleanpresarr(2,:),70,'filled','d','MarkerEdgeColor',mcolors{2},'MarkerFaceColor',mcolors{2});
        l1=scatter(tcomposite(1,:),cleanpresarr(1,:),70,'filled','d','MarkerEdgeColor',mcolors{1},'MarkerFaceColor',mcolors{1});
        scatter(twcomposite(4,:),cleanpresarr(4,:),70,'filled','o','MarkerEdgeColor',mcolors{4},'MarkerFaceColor',mcolors{4});
        scatter(twcomposite(3,:),cleanpresarr(3,:),70,'filled','o','MarkerEdgeColor',mcolors{3},'MarkerFaceColor',mcolors{3});
        scatter(twcomposite(2,:),cleanpresarr(2,:),70,'filled','o','MarkerEdgeColor',mcolors{2},'MarkerFaceColor',mcolors{2});
        scatter(twcomposite(1,:),cleanpresarr(1,:),70,'filled','o','MarkerEdgeColor',mcolors{1},'MarkerFaceColor',mcolors{1});
        set(gca,'YDir','reverse');
        %Plot winds
        for pctrange=1:4
            goallevelsflipped=[855;875;900;925;1000];glfrelpos=[0.138 0.24 0.375 0.512 0.92];
            for preslev=1:5
                thislev=goallevelsflipped(preslev); %since these vectors don't get flipped upside down along with the scattered points
                [ucomposite,vcomposite]=uandvfromwinddirandspeed(winddircomposite(pctrange,preslev),windspdcomposite(pctrange,preslev));
                if ~isnan(ucomposite) && ~isnan(vcomposite)
                    %Scale vectors so that a u or v component of 10 is the full width between the axis and the figure edge
                    if strcmp(city,'Dhahran');divfactor=120;else;divfactor=100;end
                    x=[0.9155 (0.9155+ucomposite/divfactor)];y=[glfrelpos(preslev) glfrelpos(preslev)+vcomposite/divfactor]; %previously 0.92 for x
                    h=annotation('arrow',x,y);
                    set(h,'color',mcolors{pctrange});
                end
            end
        end

        set(gca,'fontweight','bold','fontname','arial','fontsize',16);box on;
        xlabel(sprintf('Tw (%cC)',char(176)),'fontweight','bold','fontname','arial','fontsize',18);
        ylabel('Pressure (hPa)','fontweight','bold','fontname','arial','fontsize',18);
        title(strcat([city,', ',por]),'fontweight','bold','fontname','arial','fontsize',20);
        ylim([850 1000]);
        legend([l1,l2,l3,l4],titlestr{1},titlestr{2},titlestr{3},titlestr{4});

        figname=strcat('verif',cityforfilenames,'soundings_bypct');curpart=2;highqualityfiguresetup;
    end
end

%Compare pdfs of hottest stations to those of hottest regional ERA-Interim gridpts
if figures10==1
    exist histpct999tw;
    if ans==0
        clear histpct999tw;
        for stn=1:size(twarray,1)
            histpct999tw(stn)=quantile(twarray(stn,startday:stopday,3),0.999);
        end
    end
    %Find hottest stations in each region
    maxvalbyregion=zeros(8,1);stnordofmax=zeros(8,1);
    for stn=1:size(twarray,1)
        if finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)<=-90 %tropics #1
            if histpct999tw(stn)>maxvalbyregion(1)
                maxvalbyregion(1)=histpct999tw(stn);stnordofmax(1)=stn;
            end
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>-90 && finalstnlatlon(stn,2)<=0 %tropics #2
            if histpct999tw(stn)>maxvalbyregion(2)
                maxvalbyregion(2)=histpct999tw(stn);stnordofmax(2)=stn;
            end
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>0 && finalstnlatlon(stn,2)<=90 %tropics #3
            if histpct999tw(stn)>maxvalbyregion(3)
                maxvalbyregion(3)=histpct999tw(stn);stnordofmax(3)=stn;
            end
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>90 %tropics #4
            if histpct999tw(stn)>maxvalbyregion(4)
                maxvalbyregion(4)=histpct999tw(stn);stnordofmax(4)=stn;
            end
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)<=-90 %subtropics #1
            if histpct999tw(stn)>maxvalbyregion(5)
                maxvalbyregion(5)=histpct999tw(stn);stnordofmax(5)=stn;
            end
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>-90 && finalstnlatlon(stn,2)<=0 %subtropics #2
            if histpct999tw(stn)>maxvalbyregion(6)
                maxvalbyregion(6)=histpct999tw(stn);stnordofmax(6)=stn;
            end
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>0 && finalstnlatlon(stn,2)<=90 %subtropics #3
            if histpct999tw(stn)>maxvalbyregion(7)
                maxvalbyregion(7)=histpct999tw(stn);stnordofmax(7)=stn;
            end
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>90 %subtropics #4
            if histpct999tw(stn)>maxvalbyregion(8)
                maxvalbyregion(8)=histpct999tw(stn);stnordofmax(8)=stn;
            end
        end
    end
    
    %Find ERA-I gridpts closest to each of the above-identified stations (0.5-deg resolution)
    %Finding the hottest gridpts in each region (as originally conceived)
        %would be prohibitively time-consuming when done over the whole globe for 40 years of 6-hourly data
    for stn=1:size(stnordofmax,1)
        thisstnlat=finalstnlatlon(stnordofmax(stn),1);
        thisstnlon=finalstnlatlon(stnordofmax(stn),2);

        [eraeastrow(stn),erawestrow(stn),eranorthcol(stn),erasouthcol(stn),pt1w(stn),...
            pt2w(stn),pt3w(stn),pt4w(stn)]=erainfoforpt(thisstnlat,thisstnlon);
    end

    %Read in data from ERA array, calculating Tw and saving values from all years for these 8 points
    %PT 1 = lat north, lon east; PT 2 = lat south, lon east; PT 3 =
        %lat south, lon west; PT 4 = lat north, lon west
    overallindex=1;clear twarrfinal;clear tarrfinal;clear tdarrfinal;clear rharrfinal;
    erainterimelevdata=ncread('/Volumes/ExternalDriveC/Basics_ERA-Interim/erainterimelev.nc','z')/9.81;
    for year=1979:2017
        t2m=ncread(strcat(erainterimdir,'t2m',num2str(year),'.nc'),'t2m')-273.15;
        td2m=ncread(strcat(erainterimdir,'td2m',num2str(year),'.nc'),'d2m')-273.15;
        yearlen=size(t2m,3);

        for stn=1:8
            clear tarr;clear tdarr;clear qarrhelper;clear tarrhelper;clear tdarrhelper;
            tarr(:,1)=squeeze(t2m(eraeastrow(stn),eranorthcol(stn),:));tarr(:,2)=squeeze(t2m(eraeastrow(stn),erasouthcol(stn),:));
            tarr(:,3)=squeeze(t2m(erawestrow(stn),erasouthcol(stn),:));tarr(:,4)=squeeze(t2m(erawestrow(stn),eranorthcol(stn),:));
            tarrhelper=tarr(:,1).*pt1w(stn)+tarr(:,2).*pt2w(stn)+tarr(:,3).*pt3w(stn)+tarr(:,4).*pt4w(stn);
            tdarr(:,1)=squeeze(td2m(eraeastrow(stn),eranorthcol(stn),:));tdarr(:,2)=squeeze(td2m(eraeastrow(stn),erasouthcol(stn),:));
            tdarr(:,3)=squeeze(td2m(erawestrow(stn),erasouthcol(stn),:));tdarr(:,4)=squeeze(td2m(erawestrow(stn),eranorthcol(stn),:));
            tdarrhelper=tdarr(:,1).*pt1w(stn)+tdarr(:,2).*pt2w(stn)+tdarr(:,3).*pt3w(stn)+tdarr(:,4).*pt4w(stn);
            rharrhelper=calcrhfromTanddewpt(tarrhelper,tdarrhelper);
            zarr(1)=erainterimelevdata(eraeastrow(stn),eranorthcol(stn),1);zarr(2)=erainterimelevdata(eraeastrow(stn),erasouthcol(stn),1);
            zarr(3)=erainterimelevdata(erawestrow(stn),erasouthcol(stn),1);zarr(4)=erainterimelevdata(erawestrow(stn),eranorthcol(stn),1);
            zarrhelper=zarr(:,1).*pt1w(stn)+zarr(:,2).*pt2w(stn)+zarr(:,3).*pt3w(stn)+zarr(:,4).*pt4w(stn);
            preshelper=ones(size(tarrhelper,1),1).*pressurefromelev(zarrhelper).*slp./1000.*100;
            
            twarrfinal(stn,overallindex:overallindex+yearlen-1)=calcwbt_daviesjones(tarrhelper,preshelper,rharrhelper,1);
            tarrfinal(stn,overallindex:overallindex+yearlen-1)=tarrhelper;
            tdarrfinal(stn,overallindex:overallindex+yearlen-1)=tdarrhelper;
            rharrfinal(stn,overallindex:overallindex+yearlen-1)=rharrhelper;
        end
        overallindex=overallindex+yearlen;
        fprintf('For figure s10, year is %d\n',year);
    end
    tarrfinal_era=tarrfinal;tdarrfinal_era=tdarrfinal;rharrfinal_era=rharrfinal;twarrfinal_era=twarrfinal;

    %Plot pdfs for each region
    %Check histograms for each (using histfit) to ensure that the ksdensity
        %bandwidth is appropriate (and adjust it if not)
    figure(178);clf;curpart=1;highqualityfiguresetup;
    xmins=[10;10;10;8;10;5;0;10];xmaxs=[34;34;34;34;38;38;38;38];
    ymaxs=[0.35;0.4;0.5;0.5;0.25;0.25;0.12;0.12];
    regorder=[5;6;7;8;1;2;3;4];
    for c=1:8
        subplot(2,4,c);reg=regorder(c);hold on;
        vectoplot=twarray(stnordofmax(reg),startday:stopday,3);vectoplot=vectoplot(~isnan(vectoplot));
        h=histogram(vectoplot,'Normalization','probability','BinEdges',xmins(reg):xmaxs(reg),'FaceColor',colors('green'));alpha(h,0.5);
        hh=histogram(twarrfinal_era(reg,:),'Normalization','probability','BinEdges',xmins(reg):xmaxs(reg),'FaceColor',colors('orange'));alpha(hh,0.5);
        xlim([xmins(reg) xmaxs(reg)]);ylim([0 ymaxs(reg)]);
        %Compute and display ERA biases of the 50th, 95th, and 99.9th percentiles
        diff50=quantile(twarrfinal_era(reg,:),0.5)-quantile(twarray(stnordofmax(reg),startday:stopday,3),0.5);
        xpos1=xmins(reg)+0.1*(xmaxs(reg)-xmins(reg));ypos=0.92*ymaxs(reg);
        text(xpos1,ypos+0.06*ymaxs(reg),'p50','fontweight','bold');text(xpos1,ypos,sprintf('%0.1f',diff50),'fontweight','bold');
        diff95=quantile(twarrfinal_era(reg,:),0.95)-quantile(twarray(stnordofmax(reg),startday:stopday,3),0.95);
        xpos2=xmins(reg)+0.4*(xmaxs(reg)-xmins(reg));
        text(xpos2,ypos+0.06*ymaxs(reg),'p95','fontweight','bold');text(xpos2,ypos,sprintf('%0.1f',diff95),'fontweight','bold');
        diff999=quantile(twarrfinal_era(reg,:),0.999)-quantile(twarray(stnordofmax(reg),startday:stopday,3),0.999);
        xpos3=xmins(reg)+0.7*(xmaxs(reg)-xmins(reg));
        text(xpos3,ypos+0.06*ymaxs(reg),'p99.9','fontweight','bold');text(xpos3,ypos,sprintf('%0.1f',diff999),'fontweight','bold');
        if reg==1 || reg==5
            title('180 W - 90 W','fontsize',24,'fontweight','bold','fontname','arial');
            if reg==5
                text(-0.4,0.5*ymaxs(reg),'Subtropics','fontsize',18,'fontweight','bold','fontname','arial','units','normalized','rotation',90);
            elseif reg==1
                text(-0.4,0.5*ymaxs(reg),'Tropics','fontsize',18,'fontweight','bold','fontname','arial','units','normalized','rotation',90);
            end
        elseif reg==2 || reg==6
            title('90 W - 0 W','fontsize',24,'fontweight','bold','fontname','arial');
        elseif reg==3 || reg==7
            title('0 E - 90 E','fontsize',24,'fontweight','bold','fontname','arial');
        elseif reg==4 || reg==8
            title('90 E - 180 E','fontsize',24,'fontweight','bold','fontname','arial');
        end
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
    end
    figname='figures10';curpart=2;width=14;highqualityfiguresetup;
end
   
%Biases of ERA-Interim relative to TW>33C stations in SW Asia
if figures11==1
    %Get SW Asia stations within each ERA grid box (if any), and their position relative to the center of it
    %Recall that ERA data is 0.5x0.5
    numstns=0;clear centerweight;clear nsweight;clear ewweight;
    threshtouse=31;
    for boxrow=60:140 %longitudes
        for boxcol=110:150 %latitudes
            boxcenterlat=90.5-0.5*boxcol;
            boxcenterlon=-0.25+boxrow/2;
            
            for stn=1:size(finalstnlatlon,1)
                stnlat=finalstnlatlon(stn,1);stnlon=finalstnlatlon(stn,2);
                if abs(stnlat-boxcenterlat)<0.25 && abs(stnlon-boxcenterlon)<0.25
                    if max(squeeze(twarray(stn,:,3)))>=threshtouse
                        numstns=numstns+1;
                        thesestnsords(numstns)=stn;
                        latdist=stnlat-boxcenterlat;londist=stnlon-boxcenterlon;
                        disttocenterbox=sqrt(latdist.^2+londist.^2);
                        centerboxrow(numstns)=boxrow;centerboxcol(numstns)=boxcol;
                        if latdist>=0 && londist>=0 %stn to NE of box center
                            disttonsbox=sqrt((stnlat-(boxcenterlat+0.5)).^2+londist.^2);
                            disttoewbox=sqrt(latdist.^2+(stnlon-(boxcenterlon+0.5)).^2);
                            nsboxrow(numstns)=boxrow;nsboxcol(numstns)=boxcol-1;
                            ewboxrow(numstns)=boxrow-1;ewboxcol(numstns)=boxcol;
                        elseif latdist>=0 && londist<0 %stn to NW of box center
                            disttonsbox=sqrt((stnlat-(boxcenterlat+0.5)).^2+londist.^2);
                            disttoewbox=sqrt(latdist.^2+(stnlon-(boxcenterlon-0.5)).^2);
                            nsboxrow(numstns)=boxrow;nsboxcol(numstns)=boxcol-1;
                            ewboxrow(numstns)=boxrow+1;ewboxcol(numstns)=boxcol;
                        elseif latdist<0 && londist<0 %stn to SW of box center
                            disttonsbox=sqrt((stnlat-(boxcenterlat-0.5)).^2+londist.^2);
                            disttoewbox=sqrt(latdist.^2+(stnlon-(boxcenterlon-0.5)).^2);
                            nsboxrow(numstns)=boxrow;nsboxcol(numstns)=boxcol+1;
                            ewboxrow(numstns)=boxrow+1;ewboxcol(numstns)=boxcol;
                        elseif latdist<0 && londist>=0 %stn to SE of box center
                            disttonsbox=sqrt((stnlat-(boxcenterlat-0.5)).^2+londist.^2);
                            disttoewbox=sqrt(latdist.^2+(stnlon-(boxcenterlon+0.5)).^2);
                            nsboxrow(numstns)=boxrow;nsboxcol(numstns)=boxcol+1;
                            ewboxrow(numstns)=boxrow-1;ewboxcol(numstns)=boxcol;
                        end
                        
                        %Weights, in order to calculate ERA value corresponding to this station
                        alldists=disttocenterbox+disttonsbox+disttoewbox;
                        centerweight(numstns)=1-disttocenterbox/alldists;
                        nsweight(numstns)=1-disttonsbox/alldists;
                        ewweight(numstns)=1-disttoewbox/alldists;
                        adjfactor=centerweight(numstns)+nsweight(numstns)+ewweight(numstns);
                        centerweight(numstns)=centerweight(numstns)./adjfactor;
                        nsweight(numstns)=nsweight(numstns)./adjfactor;
                        ewweight(numstns)=ewweight(numstns)./adjfactor;
                    end
                end
            end
        end
    end
    
    %Get data for each station
    yearstartday=17533;
    clear actualtwvals;clear interptwvals;clear actualtvals;clear interptvals;clear actualtdvals;clear interptdvals;
    clear generoustwvals;clear generoustvals;clear generoustdvals;
    for year=1979:2017
        if rem(year,4)==0;yearlen=366;else;yearlen=365;end
        
        %Load ERA data
        data=load(strcat('/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/savederatwarrays_swasia',num2str(year)));
        thisyeartw=data.thisyeartw;
        thisyeart=ncread(strcat('/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/t2m',num2str(year),'.nc'),'t2m')-273.15;
        thisyeartd=ncread(strcat('/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/td2m',num2str(year),'.nc'),'d2m')-273.15;
        
        %Interpolate gridpoint values to station locations
        for i=1:numstns
            twarrtemp=squeeze(thisyeartw(centerboxrow(i),centerboxcol(i),:).*centerweight(i)+...
                thisyeartw(nsboxrow(i),nsboxcol(i),:).*nsweight(i)+thisyeartw(ewboxrow(i),ewboxcol(i),:).*ewweight(i));
            tarrtemp=squeeze(thisyeart(centerboxrow(i),centerboxcol(i),:).*centerweight(i)+...
                thisyeart(nsboxrow(i),nsboxcol(i),:).*nsweight(i)+thisyeart(ewboxrow(i),ewboxcol(i),:).*ewweight(i));
            tdarrtemp=squeeze(thisyeartd(centerboxrow(i),centerboxcol(i),:).*centerweight(i)+...
                thisyeartd(nsboxrow(i),nsboxcol(i),:).*nsweight(i)+thisyeartd(ewboxrow(i),ewboxcol(i),:).*ewweight(i));
            for hourord=1:size(thisyeartw,3)
                [rowofmax(hourord),colofmax(hourord),twarrgenerous(hourord)]=...
                    rowcolofmax2darray(thisyeartw(centerboxrow(i)-1:centerboxrow(i)+1,centerboxcol(i)-1:centerboxcol(i)+1,hourord));
            end
            %Convert from 4x daily to daily max
            neword=1;clear tw_dm;clear t_dm;clear td_dm;clear twgen_dm;
            for oldord=1:4:size(twarrtemp,1)-3
                tw_dm(neword)=max(twarrtemp(oldord:oldord+3));
                t_dm(neword)=max(tarrtemp(oldord:oldord+3));
                td_dm(neword)=max(tdarrtemp(oldord:oldord+3));
                [twgen_dm(neword),hourofmax]=max(twarrgenerous(oldord:oldord+3));
                tgen_dm(neword)=thisyeart(centerboxrow(i)+rowofmax(oldord+hourofmax-1)-2,centerboxcol(i)+colofmax(oldord+hourofmax-1)-2,oldord+hourofmax-1);
                tdgen_dm(neword)=thisyeartd(centerboxrow(i)+rowofmax(oldord+hourofmax-1)-2,centerboxcol(i)+colofmax(oldord+hourofmax-1)-2,oldord+hourofmax-1);
                neword=neword+1;
            end
            interptwvals(year-1978,i,1:365)=tw_dm(1:365);
            interptvals(year-1978,i,1:365)=t_dm(1:365);
            interptdvals(year-1978,i,1:365)=td_dm(1:365);
            interptwgenvals(year-1978,i,1:365)=twgen_dm(1:365);
            interptgenvals(year-1978,i,1:365)=tgen_dm(1:365);
            interptdgenvals(year-1978,i,1:365)=tdgen_dm(1:365);
        end
        
        %Load station data
        for i=1:numstns
            actualtwvals(year-1978,i,1:365)=twarray(thesestnsords(i),yearstartday:yearstartday+364,3);
            actualtvals(year-1978,i,1:365)=tarray(thesestnsords(i),yearstartday:yearstartday+364,3);
            actualtdvals(year-1978,i,1:365)=tdarray(thesestnsords(i),yearstartday:yearstartday+364,3);
        end
        yearstartday=yearstartday+yearlen;
        fprintf('Year is %d within erabiases for figure s11\n',year);
    end
    
    %Compute biases for all days with TWmax>=threshtouse
    %Negative bias means that ERA is too low relative to stn
    numdatapoints=0;numpgdatapoints=0;
    temp=actualtwvals>=threshtouse;
    twbiases=NaN.*ones(size(actualtwvals,1),size(actualtwvals,2),size(actualtwvals,3));
    twgenbiases=NaN.*ones(size(actualtwvals,1),size(actualtwvals,2),size(actualtwvals,3));
    clear twbiases_1d;clear tbiases_1d;clear tdbiases_1d;clear twgenbiases_1d;clear tgenbiases_1d;clear tdgenbiases_1d;
    clear twgenbiases_1d_pg;
    for i=1:size(actualtwvals,1)
        for j=1:size(actualtwvals,2)
            for k=1:size(actualtwvals,3)
                if actualtwvals(i,j,k)>=threshtouse
                    numdatapoints=numdatapoints+1;
                    twbiases(i,j,k)=interptwvals(i,j,k)-actualtwvals(i,j,k);
                    twgenbiases(i,j,k)=interptwgenvals(i,j,k)-actualtwvals(i,j,k);
                    twbiases_1d(numdatapoints)=interptwvals(i,j,k)-actualtwvals(i,j,k);
                    tbiases_1d(numdatapoints)=interptvals(i,j,k)-actualtvals(i,j,k);
                    tdbiases_1d(numdatapoints)=interptdvals(i,j,k)-actualtdvals(i,j,k);
                    twgenbiases_1d(numdatapoints)=interptwgenvals(i,j,k)-actualtwvals(i,j,k);
                    tgenbiases_1d(numdatapoints)=interptgenvals(i,j,k)-actualtvals(i,j,k);
                    tdgenbiases_1d(numdatapoints)=interptdgenvals(i,j,k)-actualtdvals(i,j,k);
                    if j>=11 && j<=23 %western & southern Persian Gulf shoreline
                        numpgdatapoints=numpgdatapoints+1;
                        twgenbiases_1d_pg(numpgdatapoints)=interptwgenvals(i,j,k)-actualtwvals(i,j,k);
                    end
                end
            end
        end
    end
    %Mean bias by gridbox, with map
    meanbias=squeeze(nanmean(squeeze(nanmean(twgenbiases,3)),1));
    meanbiasarray=NaN.*ones(720,361);
    for stn=1:numstns
        meanbiasarray(centerboxrow(stn),centerboxcol(stn))=meanbias(stn);
    end
    
    figure(100);clf;curpart=1;highqualityfiguresetup;
    data={eralats;eralons;meanbiasarray};datatype='CPC';region='middle-east-small';
    vararginnew={'underlayvariable';'wet-bulb temp';'contour';0;...
    'underlaycaxismin';-10;'underlaycaxismax';0;'mystepunderlay';1;...
    'overlaynow';0;'datatounderlay';data;'nonewfig';1;'conttoplot';'all'};
    figc=100;plotModelData(data,region,vararginnew,datatype);
    set(gca,'fontweight','bold','fontname','arial','fontsize',16);
    h=colorbar;ylabel(h,'ERA-Interim Bias, Station Means','fontweight','bold','fontname','arial','fontsize',16);
    figname='figures11';curpart=2;highqualityfiguresetup;
end

%Analyze linearly detrended TW occurrences by year vs ENSO
if figures12==1
    numoccurrencesbylatbandandyear=zeros(10,39,6);
    num21coccurrencesbylatbandandyear=zeros(39,6);
    num27coccurrencesbylatbandandyear=zeros(39,6);
    num29coccurrencesbylatbandandyear=zeros(39,6);
    num31coccurrencesbylatbandandyear=zeros(39,6);
    ti=0;
    for thresh=15:2:33
        fprintf('Starting threshold %d\n',thresh);
        ti=ti+1;thisyear=prevyear;
        for day=startday:size(twarray,2)
            if twarray(1,day,2)==1 %Jan 1 of a year
                thisyear=thisyear+1;
                if rem(thisyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                for stn=1:size(twarray,1)
                    thisthreshcount=nansum(twarray(stn,day:day+thisyearlen-1,3)>=thresh);
                    thiscount21c=nansum(twarray(stn,day:day+thisyearlen-1,3)>=21);
                    thiscount27c=nansum(twarray(stn,day:day+thisyearlen-1,3)>=27);
                    thiscount29c=nansum(twarray(stn,day:day+thisyearlen-1,3)>=29);
                    thiscount31c=nansum(twarray(stn,day:day+thisyearlen-1,3)>=31);
                    %fprintf('Count is %d for stn %d and year %d\n',thiscount,stn,thisyear);
                    if abs(finalstnlatlon(stn,1))>=15 && finalstnlatlon(stn,2)<-30 %subtropics: Americas
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,1)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,1)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,1)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,1)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,1)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,1)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,1)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,1)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,1)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,1)+thiscount31c;
                    elseif abs(finalstnlatlon(stn,1))>=15 && finalstnlatlon(stn,2)<50 %subtropics: Europe & Africa
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,2)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,2)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,2)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,2)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,2)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,2)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,2)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,2)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,2)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,2)+thiscount31c;
                    elseif abs(finalstnlatlon(stn,1))>=15 %subtropics: Asia & Oceania
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,3)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,3)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,3)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,3)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,3)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,3)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,3)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,3)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,3)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,3)+thiscount31c;
                    elseif finalstnlatlon(stn,2)<-30 %deep tropics: Americas
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,4)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,4)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,4)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,4)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,4)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,4)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,4)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,4)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,4)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,4)+thiscount31c;
                    elseif finalstnlatlon(stn,2)<50 %deep tropics: Africa
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,5)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,5)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,5)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,5)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,5)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,5)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,5)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,5)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,5)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,5)+thiscount31c;
                    else %deep tropics: Asia & Oceania
                        numoccurrencesbylatbandandyear(ti,thisyear-prevyear,6)=...
                            numoccurrencesbylatbandandyear(ti,thisyear-prevyear,6)+thisthreshcount;
                        num21coccurrencesbylatbandandyear(thisyear-prevyear,6)=...
                            num21coccurrencesbylatbandandyear(thisyear-prevyear,6)+thiscount21c;
                        num27coccurrencesbylatbandandyear(thisyear-prevyear,6)=...
                            num27coccurrencesbylatbandandyear(thisyear-prevyear,6)+thiscount27c;
                        num29coccurrencesbylatbandandyear(thisyear-prevyear,6)=...
                            num29coccurrencesbylatbandandyear(thisyear-prevyear,6)+thiscount29c;
                        num31coccurrencesbylatbandandyear(thisyear-prevyear,6)=...
                            num31coccurrencesbylatbandandyear(thisyear-prevyear,6)+thiscount31c;
                    end
                end
            end
        end
    end
    
    clear numoccurdetr;
    x=1:39;
    for ti=1:10
        for i=1:6
            p=polyfit(x,numoccurrencesbylatbandandyear(ti,:,i),2);f=polyval(p,x);
            numoccurdetr(ti,:,i)=numoccurrencesbylatbandandyear(ti,:,i)-f;
        end
    end
    numoccurdetrglobal=nansum(numoccurdetr,3);
    
    %Interannual correlations for all thresholds 15-33 C
    %Also bootstrap correlation coefficient standard errors
    ensoindex=textread('indicesmonthlybest.txt');janfebensoindex=nanmean(ensoindex(32:end,2:3),2);
    clear ensocorrs;
    for ti=1:10
        temp=corrcoef(janfebensoindex,numoccurdetrglobal(ti,:));
        ensocorrs(ti)=temp(2,1);
        
        [bootstat,bootsam]=bootstrp(1000,@corr,janfebensoindex,numoccurdetrglobal(ti,:)');
        p5bound(ti)=quantile(bootstat,0.05);
        p95bound(ti)=quantile(bootstat,0.95);
    end
    
    figure(92);clf;curpart=1;highqualityfiguresetup;
    threshs=15:2:33;
    plot(threshs,ensocorrs,'linewidth',3);hold on;
    xticks([15 17 19 21 23 25 27 29 31 33]);xlim([15 33]);
    dottedlinevals=zeros(10,1);
    plot(threshs,dottedlinevals,'linewidth',3,'linestyle',':','color','k');
    X=[threshs,fliplr(threshs)];
    Y=[p5bound,fliplr(p95bound)];
    Z=fill(X,Y,'b');alpha(Z,0.15);
    set(gca,'fontweight','bold','fontname','arial','fontsize',12);
    xlabel('Threshold (C)','fontweight','bold','fontname','arial','fontsize',14);
    ylabel('Correlation','fontweight','bold','fontname','arial','fontsize',14);
    title('Interannual Correlation Between BEST ENSO Index and Global TW Threshold Exceedances',...
        'fontweight','bold','fontname','arial','fontsize',16);
    figname='figures12';curpart=2;highqualityfiguresetup;
end

if figures13==1
    num27ctropics1=zeros(39,1);num27ctropics2=zeros(39,1);num27ctropics3=zeros(39,1);num27ctropics4=zeros(39,1);
    num27csubtropics1=zeros(39,1);num27csubtropics2=zeros(39,1);num27csubtropics3=zeros(39,1);num27csubtropics4=zeros(39,1);
    num31ctropics1=zeros(39,1);num31ctropics2=zeros(39,1);num31ctropics3=zeros(39,1);num31ctropics4=zeros(39,1);
    num31csubtropics1=zeros(39,1);num31csubtropics2=zeros(39,1);num31csubtropics3=zeros(39,1);num31csubtropics4=zeros(39,1);
    tropics1stncount=0;tropics2stncount=0;tropics3stncount=0;tropics4stncount=0;
    subtropics1stncount=0;subtropics2stncount=0;subtropics3stncount=0;subtropics4stncount=0;
    clear annavgwbtmatrixtropics1;clear annavgwbtmatrixtropics2;clear annavgwbtmatrixtropics3;clear annavgwbtmatrixtropics4;
    clear annavgwbtmatrixsubtropics1;clear annavgwbtmatrixsubtropics2;clear annavgwbtmatrixsubtropics3;clear annavgwbtmatrixsubtropics4;
    for stn=1:size(twarray,1)
        year=1979;yearlen=365;clear num27c;clear num31c;clear annavgwbt;
        for jan1day=startday:yearlen:stopday-364 %1979-2017
            dec31day=jan1day+yearlen-1;
            num27c(year-1978,1)=sum(twarray(stn,jan1day:dec31day,3)>=27);
            num31c(year-1978,1)=sum(twarray(stn,jan1day:dec31day,3)>=31);
            annavgwbt(year-1978,1)=nanmean(twarray(stn,jan1day:dec31day,3));
            year=year+1;
            if rem(year,4)==0;yearlen=366;else;yearlen=365;end
        end
        
        if finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)<=-90 %tropics #1
            num27ctropics1=num27ctropics1+num27c;num31ctropics1=num31ctropics1+num31c;
            tropics1stncount=tropics1stncount+1;annavgwbtmatrixtropics1(tropics1stncount,:)=annavgwbt;
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>-90 && finalstnlatlon(stn,2)<=0 %tropics #2
            num27ctropics2=num27ctropics2+num27c;num31ctropics2=num31ctropics2+num31c;
            tropics2stncount=tropics2stncount+1;annavgwbtmatrixtropics2(tropics2stncount,:)=annavgwbt;
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>0 && finalstnlatlon(stn,2)<=90 %tropics #3
            num27ctropics3=num27ctropics3+num27c;num31ctropics3=num31ctropics3+num31c;
            tropics3stncount=tropics3stncount+1;annavgwbtmatrixtropics3(tropics3stncount,:)=annavgwbt;
        elseif finalstnlatlon(stn,1)>=-15 && finalstnlatlon(stn,1)<=15 && finalstnlatlon(stn,2)>90 %tropics #4
            num27ctropics4=num27ctropics4+num27c;num31ctropics4=num31ctropics4+num31c;
            tropics4stncount=tropics4stncount+1;annavgwbtmatrixtropics4(tropics4stncount,:)=annavgwbt;
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)<=-90 %subtropics #1
            num27csubtropics1=num27csubtropics1+num27c;num31csubtropics1=num31csubtropics1+num31c;
            subtropics1stncount=subtropics1stncount+1;annavgwbtmatrixsubtropics1(subtropics1stncount,:)=annavgwbt;
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>-90 && finalstnlatlon(stn,2)<=0 %subtropics #2
            num27csubtropics2=num27csubtropics2+num27c;num31csubtropics2=num31csubtropics2+num31c;
            subtropics2stncount=subtropics2stncount+1;annavgwbtmatrixsubtropics2(subtropics2stncount,:)=annavgwbt;
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>0 && finalstnlatlon(stn,2)<=90 %subtropics #3
            num27csubtropics3=num27csubtropics3+num27c;num31csubtropics3=num31csubtropics3+num31c;
            subtropics3stncount=subtropics3stncount+1;annavgwbtmatrixsubtropics3(subtropics3stncount,:)=annavgwbt;
        elseif ((finalstnlatlon(stn,1)>15 && finalstnlatlon(stn,1)<=35) || (finalstnlatlon(stn,1)>-35 && finalstnlatlon(stn,1)<=-15)) &&...
                finalstnlatlon(stn,2)>90 %subtropics #4
            num27csubtropics4=num27csubtropics4+num27c;num31csubtropics4=num31csubtropics4+num31c;
            subtropics4stncount=subtropics4stncount+1;annavgwbtmatrixsubtropics4(subtropics4stncount,:)=annavgwbt;
        end
    end
    
    clear nino34djfindex;
    temp=load('indicesmonthlynino34.txt');
    startrow=109;
    for year=1979:2017
        nino34djfindex(year-1978,1)=mean(temp(startrow,13)+temp(startrow+1,2)+temp(startrow+1,3));
        startrow=startrow+1;
    end
    
    %Detrended correlations among 27+C WBT in each region and Nino 3.4
    ensocorrelarray(1,1)=corr(detrend(num27csubtropics1),detrend(nino34djfindex));
    ensocorrelarray(1,2)=corr(detrend(num27csubtropics2),detrend(nino34djfindex));
    ensocorrelarray(1,3)=corr(detrend(num27csubtropics3),detrend(nino34djfindex));
    ensocorrelarray(1,4)=corr(detrend(num27csubtropics4),detrend(nino34djfindex));
    ensocorrelarray(2,1)=corr(detrend(num27ctropics1),detrend(nino34djfindex));
    ensocorrelarray(2,2)=corr(detrend(num27ctropics2),detrend(nino34djfindex));
    ensocorrelarray(2,3)=corr(detrend(num27ctropics3),detrend(nino34djfindex));
    ensocorrelarray(2,4)=corr(detrend(num27ctropics4),detrend(nino34djfindex));
    
    
    %JJA SST anomalies from HadISST
    sstdata=ncread('/Volumes/ExternalDriveC/HadISST/HadISST_sst_monthly.nc','sst');
    sstdata=sstdata(:,:,1309:1776); %1979-2017
    invalid=abs(sstdata)>100;sstdata(invalid)=NaN;
    clear jjaanomssttropics1;clear jjaanomssttropics2;clear jjaanomssttropics3;clear jjaanomssttropics4;
    clear jjaanomsstsubtropics1;clear jjaanomsstsubtropics2;clear jjaanomsstsubtropics3;clear jjaanomsstsubtropics4;
    for year=1979:2017
        m1=(year-1978)*12-6;m2=m1+2;
        jjaanomssttropics1(year-1978,1)=nanmean(nanmean(nanmean(sstdata(1:90,75:105,m1:m2))));
        jjaanomssttropics2(year-1978,1)=nanmean(nanmean(nanmean(sstdata(91:180,75:105,m1:m2))));
        jjaanomssttropics3(year-1978,1)=nanmean(nanmean(nanmean(sstdata(181:270,75:105,m1:m2))));
        jjaanomssttropics4(year-1978,1)=nanmean(nanmean(nanmean(sstdata(271:360,75:105,m1:m2))));
        jjaanomsstsubtropics1(year-1978,1)=...
            (nanmean(nanmean(nanmean(sstdata(1:90,55:75,m1:m2))))+nanmean(nanmean(nanmean(sstdata(1:90,105:125,m1:m2)))))./2;
        jjaanomsstsubtropics2(year-1978,1)=...
            (nanmean(nanmean(nanmean(sstdata(91:180,55:75,m1:m2))))+nanmean(nanmean(nanmean(sstdata(91:180,105:125,m1:m2)))))./2;
        jjaanomsstsubtropics3(year-1978,1)=...
            (nanmean(nanmean(nanmean(sstdata(181:270,55:75,m1:m2))))+nanmean(nanmean(nanmean(sstdata(181:270,105:125,m1:m2)))))./2;
        jjaanomsstsubtropics4(year-1978,1)=...
            (nanmean(nanmean(nanmean(sstdata(271:360,55:75,m1:m2))))+nanmean(nanmean(nanmean(sstdata(271:360,105:125,m1:m2)))))./2;
    end
    
    %Correlations among 27+ WBT in each region and local SSTs
    sstcorrelarray(1,1)=corr(detrend(num27csubtropics1),detrend(jjaanomsstsubtropics1));
    sstcorrelarray(1,2)=corr(detrend(num27csubtropics2),detrend(jjaanomsstsubtropics2));
    sstcorrelarray(1,3)=corr(detrend(num27csubtropics3),detrend(jjaanomsstsubtropics3));
    sstcorrelarray(1,4)=corr(detrend(num27csubtropics4),detrend(jjaanomsstsubtropics4));
    sstcorrelarray(2,1)=corr(detrend(num27ctropics1),detrend(jjaanomssttropics1));
    sstcorrelarray(2,2)=corr(detrend(num27ctropics2),detrend(jjaanomssttropics2));
    sstcorrelarray(2,3)=corr(detrend(num27ctropics3),detrend(jjaanomssttropics3));
    sstcorrelarray(2,4)=corr(detrend(num27ctropics4),detrend(jjaanomssttropics4));
    
    
    %Correlations among 27+ WBT in each region and local annual-average WBT
    annavgwbtmatrixtropics1=nanmean(annavgwbtmatrixtropics1,1);annavgwbtmatrixtropics2=nanmean(annavgwbtmatrixtropics2,1);
    annavgwbtmatrixtropics3=nanmean(annavgwbtmatrixtropics3,1);annavgwbtmatrixtropics4=nanmean(annavgwbtmatrixtropics4,1);
    annavgwbtmatrixsubtropics1=nanmean(annavgwbtmatrixsubtropics1,1);annavgwbtmatrixsubtropics2=nanmean(annavgwbtmatrixsubtropics2,1);
    annavgwbtmatrixsubtropics3=nanmean(annavgwbtmatrixsubtropics3,1);annavgwbtmatrixsubtropics4=nanmean(annavgwbtmatrixsubtropics4,1);
    
    meanwbtcorrelarray(1,1)=corr(detrend(num27csubtropics1),detrend(annavgwbtmatrixsubtropics1'));
    meanwbtcorrelarray(1,2)=corr(detrend(num27csubtropics2),detrend(annavgwbtmatrixsubtropics2'));
    meanwbtcorrelarray(1,3)=corr(detrend(num27csubtropics3),detrend(annavgwbtmatrixsubtropics3'));
    meanwbtcorrelarray(1,4)=corr(detrend(num27csubtropics4),detrend(annavgwbtmatrixsubtropics4'));
    meanwbtcorrelarray(2,1)=corr(detrend(num27ctropics1),detrend(annavgwbtmatrixtropics1'));
    meanwbtcorrelarray(2,2)=corr(detrend(num27ctropics2),detrend(annavgwbtmatrixtropics2'));
    meanwbtcorrelarray(2,3)=corr(detrend(num27ctropics3),detrend(annavgwbtmatrixtropics3'));
    meanwbtcorrelarray(2,4)=corr(detrend(num27ctropics4),detrend(annavgwbtmatrixtropics4'));
    
    %Make figure
    figure(figc);clf;curpart=1;highqualityfiguresetup;
    subplot(3,1,1);imagescnan(ensocorrelarray);colorbar;
    xticks([0.5 1.5 2.5 3.5 4.5]);xticklabels({'180 W','90 W','0','90 E','180 E'});
    yticks([1 2]);yticklabels({'Subtropics','Tropics'});
    set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
    title('Correlation with Nino 3.4 Index','fontsize',16,'fontweight','bold','fontname','arial');
    colormap(colormaps('wbt','more','not'));caxis([0 1]);
    subplot(3,1,2);imagescnan(sstcorrelarray);colorbar;
    xticks([0.5 1.5 2.5 3.5 4.5]);xticklabels({'180 W','90 W','0','90 E','180 E'});
    yticks([1 2]);yticklabels({'Subtropics','Tropics'});
    set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
    title('Correlation with Local SSTs','fontsize',16,'fontweight','bold','fontname','arial');
    colormap(colormaps('wbt','more','not'));caxis([0 1]);
    subplot(3,1,3);imagescnan(meanwbtcorrelarray);colorbar;
    xticks([0.5 1.5 2.5 3.5 4.5]);xticklabels({'180 W','90 W','0','90 E','180 E'});
    yticks([1 2]);yticklabels({'Subtropics','Tropics'});
    set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
    title('Correlation with Local Annual-Mean Tw','fontsize',16,'fontweight','bold','fontname','arial');
    colormap(colormaps('wbt','more','not'));caxis([0 1]);
    figname='figures13';curpart=2;highqualityfiguresetup;
end

if figures14==1
    %Find RH of all a. 27+ WBT occurrences, b. 31+ WBT occurrences, and c. 35+ WBT occurrences, and create validation plot
    %Also, exclude bad data (RH>100%)
    figure(900);clf;curpart=1;highqualityfiguresetup;hold on;
    subplotbottoms=[0.7;0.39;0.08];
    for loop=1:3
        if loop==1;todo=27;elseif loop==2;todo=31;else;todo=35;end
        clear tdistn27;clear dewptdistn27;clear rhdistn27;
        clear tdistn31;clear dewptdistn31;clear rhdistn31;
        clear tdistn35;clear dewptdistn35;clear rhdistn35;
        c27=0;c31=0;c35=0;baddatac=0;
        for stn=1:size(twarray,1)
            for day=startday:stopday
                if twarray(stn,day,3)>=27
                    c27=c27+1;
                    if tdarray(stn,day,3)>tarray(stn,day,3)+0.5
                        tdarray(stn,day,3)=NaN;tdarray(stn,day,4)=NaN;
                        tarray(stn,day,3)=NaN;tarray(stn,day,4)=NaN;
                        twarray(stn,day,3)=NaN;twarray(stn,day,4)=NaN;
                        baddatac=baddatac+1;
                    else
                        tdistn27(c27)=tarray(stn,day,3);
                        dewptdistn27(c27)=tdarray(stn,day,3);
                        rhdistn27(c27)=calcrhfromTanddewpt(tdistn27(c27),dewptdistn27(c27));
                    end
                end
                if twarray(stn,day,3)>=31
                    c31=c31+1;
                    tdistn31(c31)=tarray(stn,day,3);
                    dewptdistn31(c31)=tdarray(stn,day,3);
                    rhdistn31(c31)=calcrhfromTanddewpt(tdistn31(c31),dewptdistn31(c31));
                end
                if twarray(stn,day,3)>=35
                    c35=c35+1;
                    tdistn35(c35)=tarray(stn,day,3);
                    dewptdistn35(c35)=tdarray(stn,day,3);
                    rhdistn35(c35)=calcrhfromTanddewpt(tdistn35(c35),dewptdistn35(c35));
                end
            end
        end

        if todo==27
            tdistn=tdistn27;rhdistn=rhdistn27;
            xt=[4 9 14 19 24 29];xtl={'30','35','40','45','50','55'};
        elseif todo==31
            tdistn=tdistn31;rhdistn=rhdistn31;
            xt=[4 9 14 19 24 29];xtl={'30','35','40','45','50','55'};
        elseif todo==35
            tdistn=tdistn35;rhdistn=rhdistn35;
            xt=[4 9 14 19 24 29];xtl={'30','35','40','45','50','55'};
        end

        vectorofts=27:1:55;
        vectorofrhs=10:5:100;
        counts=zeros(size(vectorofts,2),size(vectorofrhs,2));
        for i=1:size(tdistn,2)
            for j=1:size(vectorofts,2)
                for k=1:size(vectorofrhs,2)
                    if abs(tdistn(i)-vectorofts(j))<=0.5 && abs(rhdistn(i)-vectorofrhs(k))<=2.5
                        counts(j,k)=counts(j,k)+1;
                    end
                end
            end
        end
        counts=counts';counts=flipud(counts);
        invalid=counts==0;counts(invalid)=NaN;
        
        subplot(3,1,loop);
        imagescnan(counts);h=colorbar;ylabel(h,'Count (Station-Days)','fontsize',12,'fontweight','bold','fontname','arial');
        colormap(colormaps('blueyellowred','more','not'));
        xticks(xt);xticklabels(xtl);xlim([1 29]);
        yticks([1 5 9 13 17]);yticklabels({'100','80','60','40','20'});set(gca,'YDir','reverse');
        ylabel('RH (%)','fontsize',14,'fontweight','bold','fontname','arial');
        set(gca,'Position',[0.2 subplotbottoms(loop) 0.6 0.26]);
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        %if loop==1;title(strcat('Wet-Bulb Temperatures >= ',num2str(todo),char(176),'C'),'fontsize',18,'fontweight','bold','fontname','arial');end
    end
    xlabel(strcat('Dry-Bulb Temperature (',char(176),'C)'),'fontsize',14,'fontweight','bold','fontname','arial');
    figname='figures14';curpart=2;highqualityfiguresetup;
end

if figures15==1
    figure(800);clf;curpart=1;highqualityfiguresetup;
    subplot(2,2,1);plot(tdarray(3913,:,3),'linewidth',1.3);hold on %Loreto switched effective Jan 1, 2008
    x=[28125 28125];y=[-20 40];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Days since Jan 1, 1931','fontweight','bold','fontname','arial','fontsize',14);
    ylabel(strcat('Dewpoint Temperature (',char(176),'C)'),'fontweight','bold','fontname','arial','fontsize',14);
    ylim([-5 35]);xlim([startday stopday]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title('Loreto, Baja California','fontweight','bold','fontname','arial','fontsize',18);
    
    subplot(2,2,2);plot(tdarray(3956,:,3),'linewidth',1.3);hold on %Villahermosa switched effective Jan 1, 2009
    x=[28491 28491];y=[-20 40];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Days since Jan 1, 1931','fontweight','bold','fontname','arial','fontsize',14);
    ylabel(strcat('Dewpoint Temperature (',char(176),'C)'),'fontweight','bold','fontname','arial','fontsize',14);
    ylim([-5 35]);xlim([startday stopday]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title('Villahermosa, Tabasco','fontweight','bold','fontname','arial','fontsize',18);
    
    subplot(2,2,3);plot(tdarray(3911,:,3),'linewidth',1.3);hold on %Empalme switched effective Jan 1, 2013
    x=[29952 29952];y=[-20 40];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Days since Jan 1, 1931','fontweight','bold','fontname','arial','fontsize',14);
    ylabel(strcat('Dewpoint Temperature (',char(176),'C)'),'fontweight','bold','fontname','arial','fontsize',14);
    ylim([-5 35]);xlim([startday stopday]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title('Empalme, Sonora','fontweight','bold','fontname','arial','fontsize',18);
    
    subplot(2,2,4);plot(tdarray(3909,:,3),'linewidth',1.3);hold on %Ciudad Obregon switched effective Jan 1, 2006
    x=[27395 27395];y=[-20 40];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Days since Jan 1, 1931','fontweight','bold','fontname','arial','fontsize',14);
    ylabel(strcat('Dewpoint Temperature (',char(176),'C)'),'fontweight','bold','fontname','arial','fontsize',14);
    ylim([-5 35]);xlim([startday stopday]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title('Ciudad Obregon, Sonora','fontweight','bold','fontname','arial','fontsize',18);
    
    figname='figures15';curpart=2;highqualityfiguresetup;
end

if figures16==1
    %Consult with
    %https://mesonet.agron.iastate.edu/request/download.phtml?network=FL_ASOS
    %to see which stations in wbt31cinstances are U.S. ASOS stations
    jan1date=startday;
    stnlist=[3305;3331;3347;3359;3889;3895;3898];
    num31callyears=zeros(39,1);num27callyears=zeros(39,1);
    for year=1979:2017
        if rem(year,4)==0;yearlen=366;else;yearlen=365;end
        num31cthisyear=0;num27cthisyear=0;
        for i=1:size(stnlist,1)
            num31cthisyear=num31cthisyear+sum(twarray(stnlist(i),jan1date:jan1date+yearlen-1,3)>=31);
            num27cthisyear=num27cthisyear+sum(twarray(stnlist(i),jan1date:jan1date+yearlen-1,3)>=27);
        end
        num31callyears(year-1978)=num31cthisyear;
        num27callyears(year-1978)=num27cthisyear;
        jan1date=jan1date+yearlen;
    end
    
    figure(801);clf;curpart=1;highqualityfiguresetup;
    subplot(2,1,1);
    years=1979:2017;
    plot(years,num31callyears,'color','b','linewidth',1.5);
    x=[2014 2014];y=[0 10];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Year','fontweight','bold','fontname','arial','fontsize',14);
    ylabel('Exceedances (Count)','fontweight','bold','fontname','arial','fontsize',14);
    ylim([0 10]);xlim([1979 2017]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title(strcat('Tw=31',char(176),'C at U.S. ASOS Stations'),'fontweight','bold','fontname','arial','fontsize',16);
    subplot(2,1,2);
    plot(years,num27callyears,'color','b','linewidth',1.5);
    x=[2014 2014];y=[0 250];line(x,y,'color','k','linestyle','--','linewidth',3);
    xlabel('Year','fontweight','bold','fontname','arial','fontsize',14);
    ylabel('Exceedances (Count)','fontweight','bold','fontname','arial','fontsize',14);
    ylim([0 250]);xlim([1979 2017]);set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    title(strcat('Tw=27',char(176),'C at U.S. ASOS Stations'),'fontweight','bold','fontname','arial','fontsize',16);
    figname='figures16';curpart=2;highqualityfiguresetup;
end

%Timeseries for stations having recorded TW=33C at least 5x
if figures18==1
    figure(50);clf;hold on;curpart=1;highqualityfiguresetup;set(gca,'visible','off');
    for i=1:size(stns33catleast5xords,1);minbystn(i)=min(tdarray(stns33catleast5xords(i),startday:stopday,3));end
    for i=1:size(stns33catleast5xords,1);maxbystn(i)=max(tdarray(stns33catleast5xords(i),startday:stopday,3));end
    ymins=[-5;-14;-5;-18;-3;0;0;-3;0;-14;-14;-3];
    ymaxs=37.*ones(size(stns33catleast5xords,1),1);
    for stn=1:size(stns33catleast5xords,1)
        if rem(stn,2)==1;lefts(stn)=0.14;else;lefts(stn)=0.63;end
    end
    bottoms=[.09+.12*5+.16*5/5;.09+.12*5+.16*5/5;.09+.12*4+.16*4/5;.09+.12*4+.16*4/5;.09+.12*3+.16*3/5;.09+.12*3+.16*3/5;...
        .09+.12*2+.16*2/5;.09+.12*2+.16*2/5;.09+.12+.16/5;.09+.12+.16/5;.09;.09];
    widths=0.35.*ones(size(stns33catleast5xords,1),1);heights=0.12.*ones(size(stns33catleast5xords,1),1);
    for i=1:size(stns33catleast5xords,1)
        ax=axes('Position',[lefts(i) bottoms(i) widths(i) heights(i)]);
        plot(tdarray(stns33catleast5xords(i),startday:stopday,3));
        ylim([ymins(i) ymaxs(i)]);xlim([0 15000]);
        yticks([-10;10;30]);if i<=size(stns33catleast5xords,1)-2;xticklabels('');end
        thisstnname=finalstnnames{stns33catleast5xords(i)};thisstnnamesplit=split(thisstnname,',');
        text(-0.35,0.65,thisstnnamesplit{1},'fontweight','bold','fontname','arial','fontsize',11,'units','normalized');
        text(-0.36,0.35,thisstnnamesplit{2},'fontweight','bold','fontname','arial','fontsize',11,'units','normalized');
        %title(finalstnnames{stns33catleast5xords(i)},'fontweight','bold','fontname','arial','fontsize',13);
        set(gca,'fontweight','bold','fontname','arial','fontsize',10);
    end
    figname='figures18';curpart=2;highqualityfiguresetup;
end

if figures19==1
    for stn=1:size(twarray,1)
        diffbystn(stn)=max(twarray(stn,startday:end,3))-quantile(twarray(stn,startday:end,3),0.95);
        alltimemaxbystn(stn)=max(twarray(stn,startday:end,3));
    end
    clear pts;clear N;
    pts=linspace(-10,40,101);
    N=histcounts2(alltimemaxbystn,diffbystn,pts,pts)';
    invalid=N==0;N(invalid)=NaN;
    
    figure(19);clf;curpart=1;highqualityfiguresetup;
    imagesc(pts,pts,N);
    pcolor(pts,pts,[N nan(100,1);nan(1,101)]);shading flat;
    ylim([0 15]);xlim([0 40]);
    colorbar;
    colormap(colormaps('wbt','more','not'));
    title('Difference between All-Time Maximum and 95th Percentile of Tw','fontweight','bold','fontname','arial','fontsize',20);
    xlabel('All-Time Maximum Tw (C)','fontweight','bold','fontname','arial','fontsize',16);
    ylabel('Difference (C)','fontweight','bold','fontname','arial','fontsize',16);
    set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    figname='figures19';curpart=2;highqualityfiguresetup;
end


%Single-day dewpoint-temperature changes before/after TW=31C days, aggregated into regions
if figures20==1
    countbyreg=ones(4,1);numstnsbyreg=zeros(4,1);
    clear dailychangesregs;totalnum31cstns=0;
    for stn=1:size(twarray,1)
        if max(twarray(stn,startday:stopday,3))>=31
            totalnum31cstns=totalnum31cstns+1;
            
            thislat=finalstnlatlon(stn,1);
            thislon=finalstnlatlon(stn,2);
            %SW North America is #1, Mediterranean is #2, SW Asia is #3, S Asia is #4
            if thislat>=15 && thislon<=-85
                thisreg=1;numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
            elseif thislat>=0 && thislat<=45 && thislon>=-20 && thislon<=30
                thisreg=2;numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
            elseif thislat>=10 && thislat<=50 && thislon>=30 && thislon<=62
                thisreg=3;numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
            elseif thislat>=0 && thislat<=40 && thislon>=62 && thislon<=100
                thisreg=4;numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
            %elseif thislat>=-40 && thislat<=-5 && thislon>=110 && thislon<=155
            %    thisreg=5;numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
            else
                thisreg=NaN;
            end
            

            if ~isnan(thisreg)
                for day=startday+1:stopday-1
                    thistw=twarray(stn,day,3);thistd=tdarray(stn,day,3);

                    td_before=tdarray(stn,day-1,3);td_after=tdarray(stn,day+1,3);
                    tw_before=twarray(stn,day-1,3);tw_after=twarray(stn,day+1,3);

                    if thistw>=31 || tw_before==31
                        dailychange1=thistd-td_before;if dailychange1==0;dailychange1=NaN;end
                        if ~isnan(dailychange1)
                            dailychangesregs{thisreg}(countbyreg(thisreg))=dailychange1;
                            countbyreg(thisreg)=countbyreg(thisreg)+1;
                        end
                    end
                    if thistw>=31 || tw_after==31
                        dailychange2=td_after-thistd;if dailychange2==0;dailychange2=NaN;end
                        if ~isnan(dailychange2)
                            dailychangesregs{thisreg}(countbyreg(thisreg))=dailychange2;
                            countbyreg(thisreg)=countbyreg(thisreg)+1;
                        end
                    end
                end
            end
        end
    end
    
    
    %Boxplot of distribution of single-day increases at >31C stations involving a Tw>=31
    %Intended to show similarities across the world, or at least within
        %similar-climate regions, and thus to identify any remaining suspicious outliers as well
    %Alternative: map of stations, showing % of valid values involving an
        %daily change >=10 C
    %Extremes are not overly dependent on 'spikes'
    %clear qsbyr;
    %for reg=1:5
    %    absdailychangesregs{reg}=abs(dailychangesregs{reg});
    %    qsbyr(reg,1)=quantile(absdailychangesregs{reg},0.8);
    %    qsbyr(reg,2)=quantile(absdailychangesregs{reg},0.99);
    %    qsbyr(reg,3)=quantile(absdailychangesregs{reg},0.999);
    %end
    
    clear x1;clear x2;clear x3;clear x4;
    x1=dailychangesregs{1}';x2=dailychangesregs{2}';x3=dailychangesregs{3}';x4=dailychangesregs{4}';
    x=[x1;x2;x3;x4];
    g=[ones(size(x1));2*ones(size(x2));3*ones(size(x3));4*ones(size(x4))];
    figure(50);clf;curpart=1;highqualityfiguresetup;
    h=boxplot(x,g);set(h,'linewidth',2);
    title(strcat('Daily Dewpoint-Temperature Change for Tw>=31',char(176),'C'),'fontweight','bold','fontname','arial','fontsize',18);
    ylabel(strcat('Change (',char(176),'C)'),'fontweight','bold','fontname','arial','fontsize',14);
    set(gca,'XTickLabel',{'SW North America','Mediterranean','SW Asia','South Asia'});
    set(gca,'fontweight','bold','fontname','arial','fontsize',14);
    figname='figures20';curpart=2;highqualityfiguresetup;
end


if figures21==1
    %Cities are Ras Al-Khaimah, UAE and Jacobabad, Pakistan
    for loop=1:2
        mc=zeros(12,1);
        if loop==1
            citydata=squeeze(twarray(1756,startday:stopday,:));
        elseif loop==2
            citydata=squeeze(twarray(1780,startday:stopday,:));
        end
        for i=1:size(citydata,1)
            monthtosearch=1;
            while monthtosearch<=12
                if citydata(i,2)<=mends(monthtosearch)
                    mc(monthtosearch)=mc(monthtosearch)+1;databymonth{loop,monthtosearch}(mc(monthtosearch))=citydata(i,3);
                    monthtosearch=13;
                else
                    monthtosearch=monthtosearch+1;
                end
            end
        end
    end
    
    figure(70);clf;curpart=1;highqualityfiguresetup;
    for loop=1:2
        subplot(2,1,loop);
        x1=databymonth{loop,1};x2=databymonth{loop,2};x3=databymonth{loop,3};x4=databymonth{loop,4};
        x5=databymonth{loop,5};x6=databymonth{loop,6};x7=databymonth{loop,7};x8=databymonth{loop,8};
        x9=databymonth{loop,9};x10=databymonth{loop,10};x11=databymonth{loop,11};x12=databymonth{loop,12};
        x=[x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12];
        g=[ones(size(x1)) 2*ones(size(x2)) 3*ones(size(x3)) 4*ones(size(x4)) 5*ones(size(x5)) 6*ones(size(x6)) ...
            7*ones(size(x7)) 8*ones(size(x8)) 9*ones(size(x9)) 10*ones(size(x10)) 11*ones(size(x11)) 12*ones(size(x12))];
        h=boxplot(x,g);set(h,'linewidth',1.5);
        
        yposloops=[41;41;41];
        for m=1:12
            n(m)=sum(~isnan(databymonth{loop,m}));text(m-0.35,yposloops(loop),strcat('n=',num2str(n(m))),'fontname','arial','fontweight','bold');
        end
        set(gca,'fontsize',12,'fontweight','bold','fontname','arial');
        ylabel(strcat('Tw (',char(176),'C)'),'fontsize',14,'fontweight','bold','fontname','arial');
        yticks([5 10 15 20 25 30 35]);ylim([0 38]);
    end
    xlabel('Month of Year','fontsize',14,'fontweight','bold','fontname','arial');
    figname='figures21';curpart=2;highqualityfiguresetup;
end

if tables1==1
    stntouse=3929;
    fprintf('Displaying results for stn %s, #%d\n',finalstnnames{stntouse},stntouse);
    disp(sum(wbt33cinstances(:,1)==stntouse));
    fprintf('Num valid years is %0.2f\n',sum(~isnan(twarray(stntouse,startday:stopday,3)))./365);
    disp(quantile(twarray(stntouse,startday:stopday,3),0.99));
    disp(quantile(twarray(stntouse,startday:stopday,3),0.9));
    disp(quantile(twarray(stntouse,startday:stopday,3),0.5));
end
