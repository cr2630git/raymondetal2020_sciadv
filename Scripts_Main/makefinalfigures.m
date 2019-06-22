%Make final figures (both main and supplemental)

figure1=0; %45 min
figure3=0; %5 min
figures1=0; %45 min
figures2=0; %3 min
figures3=0; %24 min
figures4=0; %4 min
figures6=0; %2 min
figures7=0; %40 min
figures8=0; %5 min
figures9=0; %30 sec
figures10=0; %1 min

disp(clock);
%Standard set-up options
figc=1;
startday=17533; %Jan 1, 1979
%addpath('/Volumes/ExternalDriveC/RaymondMatthewsHorton2019_Github/Scripts_Main');


%Figure 1
if figure1==1 
    clear histpct999wbt;temp=1:curnumstns;
    for stn=1:curnumstns
        histpct999wbt(stn)=quantile(finalwbtarraydj(stn,startday:31777,3),0.999);
    end
    histpct999wbtgoodstns=histpct999wbt(~isnan(histpct999wbt));ordsgoodstnswbt=temp(temp(~isnan(histpct999wbt)));
    
    colorcutoffs=[23;25;27;29;31;33];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('orange');colors('red')];
    quicklymapsomethingworld(histpct999wbtgoodstns,figc,finalstnlatlon(ordsgoodstnswbt,1),finalstnlatlon(ordsgoodstnswbt,2),...
        's',colorcutoffs,markercolors,4,1,...
        {'cblabeltext';sprintf('Daily Maximum WBT (%cC)',char(176));'cblabelfontsize';16},figloc,'pct999wbtmap');
    figure(figc);
    figname='figure1';curpart=2;highqualityfiguresetup;
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
    
    stnnums=[1:curnumstns]';
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
                thisdoy=finalwbtarraydj(stn,day,2);
                if ~isnan(finalwbtarraydj(stn,day,3)) && ~isnan(thisdoy)
                    sumbydoythisstn{stn}(thisdoy)=sumbydoythisstn{stn}(thisdoy)+finalwbtarraydj(stn,day,3);
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
                if ~isnan(thisdoy) && ~isnan(thispentad) && ~isnan(finaltarray(stn,wbt31cinstancesthisstn(c,2),3)) && ...
                        ~isnan(finaldewptarray(stn,wbt31cinstancesthisstn(c,2),3))
                    pentadc(thispentad)=pentadc(thispentad)+1;
                    assoctbypentadallstns(thispentad)=assoctbypentadallstns(thispentad)+finaltarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdbypentadallstns(thispentad)=assoctdbypentadallstns(thispentad)+finaldewptarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctsavevalspentad{thispentad}(pentadc(thispentad))=finaltarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdsavevalspentad{thispentad}(pentadc(thispentad))=finaldewptarray(stn,wbt31cinstancesthisstn(c,2),3);
                    
                    doyc(thisdoy)=doyc(thisdoy)+1;
                    assoctbydoyallstns(thisdoy)=assoctbydoyallstns(thisdoy)+finaltarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdbydoyallstns(thisdoy)=assoctdbydoyallstns(thisdoy)+finaldewptarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctsavevalsdoy{thisdoy}(doyc(thisdoy))=finaltarray(stn,wbt31cinstancesthisstn(c,2),3);
                    assoctdsavevalsdoy{thisdoy}(doyc(thisdoy))=finaldewptarray(stn,wbt31cinstancesthisstn(c,2),3);
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
    
    
    figure(988);hold on;curpart=1;highqualityfiguresetup;clf;
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
    ylim([0 2]);yticks([0;1;2]);
    x=[17 estavgmonsoonstartpentadearlyhalf estavgmonsoonstartpentadearlyhalf 17];y=[0 0 2 2];
    rect=patch(x,y,colors('brown'),'FaceAlpha',0.12);hold on;
    x=[estavgmonsoonstartpentadearlyhalf 61 61 estavgmonsoonstartpentadearlyhalf];y=[0 0 2 2];
    rect=patch(x,y,colors('blue'),'FaceAlpha',0.12);
    
    %Main plot
    c1=plot(pentad31callstnsearly,'color','k','linewidth',2);hold on;
    xlim([17 61]);
    ylabel({'Annual-Average','Occurrences','Per Station'},'fontweight','bold','fontname','arial','fontsize',10);
    yyaxis right;ylim([35 75]);set(gca,'YColor','k');
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
    ylim([0 3]);
    x=[17 estavgmonsoonstartpentadlatehalf estavgmonsoonstartpentadlatehalf 17];y=[0 0 3 3];
    rect=patch(x,y,colors('brown'),'FaceAlpha',0.12);hold on;
    x=[estavgmonsoonstartpentadlatehalf 61 61 estavgmonsoonstartpentadlatehalf];y=[0 0 3 3];
    rect=patch(x,y,colors('blue'),'FaceAlpha',0.12);
    
    %Main plot
    c3=plot(pentad31callstnslate,'color','k','linewidth',2);
    xlim([17 61]);
    ylabel({'Annual-Average','Occurrences','Per Station'},'fontweight','bold','fontname','arial','fontsize',10);
    yyaxis right;ylim([35 75]);set(gca,'YColor','k');
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
    clear histalltimemaxwbt;temp=1:curnumstns;
    for stn=1:curnumstns
        histalltimemaxwbt(stn)=max(finalwbtarraydj(stn,startday:31777,3));
    end
    histalltimemaxwbtgoodstns=histalltimemaxwbt(~isnan(histalltimemaxwbt));ordsgoodstnswbt=temp(temp(~isnan(histalltimemaxwbt)));
    
    colorcutoffs=[23;25;27;29;31;33];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('orange');colors('red')];
    quicklymapsomethingworld(histalltimemaxwbtgoodstns,figc,finalstnlatlon(ordsgoodstnswbt,1),finalstnlatlon(ordsgoodstnswbt,2),...
        's',colorcutoffs,markercolors,3,1,...
        {'cblabeltext';sprintf('Daily Maximum WBT (%cC)',char(176));'cblabelfontsize';16},figloc,'figures1');
    figure(figc);
    figname='figures1';curpart=2;highqualityfiguresetup;
end

%Maximum number of consecutive hours above 33 C, for stations with high-temporal-resolution data
if figures2==1
    %First, get stations that have exceeded 33 C at least 3 times
    exist stns33catleast3xords;
    if ans==0
        temp=load(strcat(extremewbtdir,'stns33c35cdata'));
        stns35catleast3xregions=temp.stns35catleast3xregions;
        stns33catleast3xregions=temp.stns33catleast3xregions;
        stns35catleast3xords=temp.stns35catleast3xords;
        stns33catleast3xords=temp.stns33catleast3xords;
        wbt33cinstances=temp.wbt33cinstances;
        wbt35cinstances=temp.wbt35cinstances;
    end
    exist stns31catleast3xords;
    if ans==0
        temp=load(strcat(extremewbtdir,'stns29c31cdata'));
        stns31catleast3xords=temp.stns31catleast3xords;
        wbt31cinstances=temp.wbt31cinstances;
    end
    
    
    %Get data on event lengths for high-resolution stations
    stnlist1hourly=[3420;3422;3428;3432;3499;3510;3511;3512;3513;3514;3517;3523];
    eventcountsbylength=zeros(100,1);
    for stnindex=1:size(stnlist1hourly,1)
        s=stnlist1hourly(stnindex);
        downloadhadisddata;
        hoursabove33c=find(wbt>=33);

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


%Uses gridded 6-hourly ERA-Interim data to plot composites for all 35C days
    %at the two stations that have recorded >=3 such days
if figures3==1
    %Choose 6-hourly timestep (UTC) corresponding to afternoon in the Middle East
    ts=4;
    
    %Set regional bounds
    southlatindex=180;%0 N
    northlatindex=1; %90 N
    westlonindex=360; %0 E
    eastlonindex=539; %90 E
    
    %Set up lat/lon arrays
    clear middleeastlats;clear middleeastlons;
    templats=0:0.5:89.5;templons=0:0.5:89.5;
    for i=1:size(templats,2)
        for j=1:size(templons,2)
            middleeastlats(i,j)=templats(i);
            middleeastlons(i,j)=templons(i);
        end
    end
    middleeastlats=flipud(middleeastlats);middleeastlons=middleeastlons';
    
    for loop=1:2
        if loop==1
            stntoplot=3422;
            eradaydoy=[189;210;199;205;207;210;211;214];eradayyear=[2003;2007;2012;2012;2012;2012;2012;2012];
        elseif loop==2
            stntoplot=3512;
            eradaydoy=[214;224;185;203;223;189];eradayyear=[1995;1995;2009;2009;2009;2010];
        end

        %1000-mb wind anomalies and actual values
        clear middleeastuwindanom;clear middleeastvwindanom;clear middleeastuwindactual;clear middleeastvwindactual;
        clear middleeastwbt;clear middleeastsstactual;clear middleeastsstanom;
        validdayc=0;
        for day=1:size(eradaydoy,1)
            if eradayyear(day)>=1979
                validdayc=validdayc+1;
                %Get data for timestep 1 of the day of interest
                %REQUIRES 1000-MB, 6-HOURLY ERA-INTERIM DATA FROM 1979-2017
                uwindcuryear=ncread(strcat(erainterimdir,num2str(eradayyear(day)),'vars1000mb.nc'),'u');
                uwinddayofinterest=uwindcuryear(:,:,eradaydoy(day)*4-(4-ts));
                uwinddayofinterest=permute(uwinddayofinterest,[2 1 3]);
                uwinddayofinterest=[uwinddayofinterest(:,361:720,:) uwinddayofinterest(:,1:360,:)];
                c=1;clear uwindclimodoi;for i=1:1;uwindclimodoi(:,:,i)=uclimo1000{eradaydoy(day),c};c=c+1;if c>=5;c=1;end;end
                uwindactualdoi=uwinddayofinterest;
                uwindanomdoi=uwinddayofinterest-uwindclimodoi;
                middleeastuwindactual(validdayc,:,:)=uwindactualdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);
                middleeastuwindanom(validdayc,:,:)=uwindanomdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);

                vwindcuryear=ncread(strcat(erainterimdir,num2str(eradayyear(day)),'vars1000mb.nc'),'v');
                vwinddayofinterest=vwindcuryear(:,:,eradaydoy(day)*4-(4-ts));
                vwinddayofinterest=permute(vwinddayofinterest,[2 1 3]);
                vwinddayofinterest=[vwinddayofinterest(:,361:720,:) vwinddayofinterest(:,1:360,:)];
                c=1;clear vwindclimodoi;for i=1:1;vwindclimodoi(:,:,i)=vclimo1000{eradaydoy(day),c};c=c+1;if c>=5;c=1;end;end
                vwindactualdoi=vwinddayofinterest;
                vwindanomdoi=vwinddayofinterest-vwindclimodoi;
                middleeastvwindactual(validdayc,:,:)=vwindactualdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);
                middleeastvwindanom(validdayc,:,:)=vwindanomdoi(northlatindex:southlatindex,westlonindex:eastlonindex,:);

                wbtdatafromfile=load(strcat(erainterimdir,'savederatwarrays',num2str(eradayyear(day)),'.mat'));

                wbtdata=wbtdatafromfile.thisyeartw;clear wbtdatafromfile;
                wbtdaysofinterest=wbtdata(:,:,eradaydoy(day)*4-(4-ts));
                wbtdaysofinterest=permute(wbtdaysofinterest,[2 1 3]);
                wbtdaysofinterest=[wbtdaysofinterest(:,361:720,:) wbtdaysofinterest(:,1:360,:)];

                middleeastwbt(validdayc,:,:)=squeeze(wbtdaysofinterest(northlatindex:southlatindex,westlonindex:eastlonindex,:));
            end
        end

        %Average multiple days together to make a composite
        middleeastuwindanom=squeeze(nanmean(middleeastuwindanom));
        middleeastvwindanom=squeeze(nanmean(middleeastvwindanom));
        middleeastuwindactual=squeeze(nanmean(middleeastuwindactual));
        middleeastvwindactual=squeeze(nanmean(middleeastvwindactual));
        middleeastwbt=squeeze(nanmean(middleeastwbt));


        underlaydata={middleeastlats;middleeastlons;middleeastwbt};
        data={middleeastlats;middleeastlons;middleeastuwindactual;middleeastvwindactual};


        figure(loop);clf;curpart=1;highqualityfiguresetup;
        region='persian-gulf';datatype='custom';
        cmin=24;cmax=34;
        vararginnew={'variable';'wind';'mystepunderlay';0.5;'underlaycaxismax';cmax;'underlaycaxismin';cmin;'contour';1;...
            'vectorData';data;'datatounderlay';underlaydata;'underlayvariable';'temperature';'overlaynow';0;'anomavg';'anom'};
        plotModelData(data,region,vararginnew,datatype);
        geoshow(finalstnlatlon(stntoplot,1),finalstnlatlon(stntoplot,2),'DisplayType','point','Marker','s',...
            'MarkerSize',10,'MarkerFaceColor',colors('blue'),'MarkerEdgeColor',colors('blue'));
        colormap(colormaps('wbt','more','pale'));
        cblabeltext=sprintf('WBT (%cC)',char(176));fignametext='wbt';
        h=text(1.15,0.4,cblabeltext,'fontname','arial','fontsize',16,'fontweight','bold','units','normalized');set(h,'Rotation',90);
        annotation('textarrow',[0.9 0.93],[0.15 0.15],'String','','units','normalized');
        text(1.17,0.02,'2 m/s','fontsize',14,'fontname','arial','fontweight','bold','units','normalized');

        figname=strcat('figures3part',num2str(loop));
        curpart=2;highqualityfiguresetup;
    end
end

%Plot diurnal temperature & dewpoint associated with all 21 Tw=35C occurrences
if figures4==1
    colorstouse=varycolor(size(wbt35cinstances,1));
    clear savearraywbt;clear savearrayt;clear savearraytd;
    
    for row=1:size(wbt35cinstances,1)
    %for row=1:3
        s=wbt35cinstances(row,1);
        d=wbt35cinstances(row,2);
        downloadhadisddata;
        thisdayyear=wbt35cinstances(row,5);thisdaydoy=wbt35cinstances(row,6);
        subdailyanalysis;
        if hourinterval==1
            [a,b]=max(subdailywbt);
            if b>=13 && b<=size(subdailywbt,1)-12
                hourofmaxval(row)=b;
                savearraywbt(row,:)=subdailywbt(b-12:b+12);
                if max(savearraywbt(row,:))>=33.5 %allow some leeway for Davies-Jones vs Stull; 
                        %otherwise, timing is off somewhere and day shouldn't be used
                    savearrayt(row,:)=subdailyt(b-12:b+12);
                    savearraytd(row,:)=subdailytd(b-12:b+12);
                    fprintf('Valid data found for row %d\n',row);
                end
            end
        end
    end
    
    %Figure
    figure(101);clf;hold on;curpart=1;highqualityfiguresetup;
    invalid=savearrayt==0;savearrayt(invalid)=NaN;
    invalid=savearraytd==0;savearraytd(invalid)=NaN;
    meantrace_t=nanmean(savearrayt,1);
    meantrace_td=nanmean(savearraytd,1);
    plot(meantrace_t,'r','linewidth',2.5);hold on;plot(meantrace_td,'b','linewidth',2.5);
    set(gca,'fontsize',16,'fontweight','bold','fontname','arial');
    xticks([1;7;13;19;25]);xlim([1 25]);xticklabels({'-12';'-6';'0';'6';'12'});
    xlabel('Hours Relative to Peak TW','fontsize',16,'fontweight','bold','fontname','arial');
    ylabel(sprintf('Value (%cC)',char(176)),'fontsize',16,'fontweight','bold','fontname','arial');
    lgd=legend('Dry-Bulb Temperature','Dewpoint Temperature','Location','northeast','autoupdate','off');
    set(lgd,'fontsize',15,'fontweight','bold','fontname','arial');
    
    %Inset plot: 'dot plot' of hours of occurrence
    line([2 10],[40 40],'color','k','linewidth',2);
    text(1.4,39.3,'12am','fontsize',14,'fontweight','bold','fontname','arial');
    text(3.4,39.3,'6am','fontsize',14,'fontweight','bold','fontname','arial');
    text(5.4,39.3,'12pm','fontsize',14,'fontweight','bold','fontname','arial');
    text(7.4,39.3,'6pm','fontsize',14,'fontweight','bold','fontname','arial');
    %marker size 12 for 1 occurrence, marker size 18 for 2 occurrences
    plot(2,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %12am
    plot(5,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %9am
    plot(5.67,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green')); %11am
    plot(6,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(6.33,40,'o','markersize',18,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(6.67,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(7,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(7.33,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(7.67,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    plot(8,40,'o','markersize',12,'markerfacecolor',colors('medium green'),'markeredgecolor',colors('medium green'));
    
    
    figname='figures4';curpart=2;highqualityfiguresetup;
end

%Compare pdfs of hottest stations to those of hottest regional ERA-Interim gridpts
if figures6==1
    exist histpct999wbt;
    if ans==0
        clear histpct999wbt;
        for stn=1:curnumstns
            histpct999wbt(stn)=quantile(finalwbtarraydj(stn,startday:31777,3),0.999);
        end
    end
    %Find hottest stations in each region
    maxvalbyregion=zeros(8,1);stnordofmax=zeros(8,1);
    for stn=1:curnumstns
        if stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)<=-90 %tropics #1
            if histpct999wbt(stn)>maxvalbyregion(1)
                maxvalbyregion(1)=histpct999wbt(stn);stnordofmax(1)=stn;
            end
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>-90 && stnlons(stn)<=0 %tropics #2
            if histpct999wbt(stn)>maxvalbyregion(2)
                maxvalbyregion(2)=histpct999wbt(stn);stnordofmax(2)=stn;
            end
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>0 && stnlons(stn)<=90 %tropics #3
            if histpct999wbt(stn)>maxvalbyregion(3)
                maxvalbyregion(3)=histpct999wbt(stn);stnordofmax(3)=stn;
            end
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>90 %tropics #4
            if histpct999wbt(stn)>maxvalbyregion(4)
                maxvalbyregion(4)=histpct999wbt(stn);stnordofmax(4)=stn;
            end
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)<=-90 %subtropics #1
            if histpct999wbt(stn)>maxvalbyregion(5)
                maxvalbyregion(5)=histpct999wbt(stn);stnordofmax(5)=stn;
            end
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>-90 && stnlons(stn)<=0 %subtropics #2
            if histpct999wbt(stn)>maxvalbyregion(6)
                maxvalbyregion(6)=histpct999wbt(stn);stnordofmax(6)=stn;
            end
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>0 && stnlons(stn)<=90 %subtropics #3
            if histpct999wbt(stn)>maxvalbyregion(7)
                maxvalbyregion(7)=histpct999wbt(stn);stnordofmax(7)=stn;
            end
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>90 %subtropics #4
            if histpct999wbt(stn)>maxvalbyregion(8)
                maxvalbyregion(8)=histpct999wbt(stn);stnordofmax(8)=stn;
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
    overallindex=1;clear twarrfinal;clear tarrfinal;clear tdarrfinal;clear qarrfinal;
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
            qarrhelper=calcqfromTd(tdarrhelper)./1000;
            twarrfinal(stn,overallindex:overallindex+yearlen-1)=calcwbt_daviesjones(tarrhelper,10^5.*ones(yearlen,1),qarrhelper);
            tarrfinal(stn,overallindex:overallindex+yearlen-1)=tarrhelper;
            tdarrfinal(stn,overallindex:overallindex+yearlen-1)=tdarrhelper;
            qarrfinal(stn,overallindex:overallindex+yearlen-1)=qarrhelper;
        end
        overallindex=overallindex+yearlen;
        fprintf('Year is %d\n',year);
    end
    tarrfinal_era=tarrfinal;tdarrfinal_era=tdarrfinal;qarrfinal_era=qarrfinal;twarrfinal_era=twarrfinal;

    %Plot pdfs for each region
    %Check histograms for each (using histfit) to ensure that the ksdensity
        %bandwidth is appropriate (and adjust it if not)
    figure(178);clf;curpart=1;highqualityfiguresetup;
    xmins=[10;10;10;8;10;5;0;10];xmaxs=[34;34;34;34;38;38;38;38];
    ymaxs=[0.35;0.3;0.3;0.4;0.25;0.18;0.12;0.28];
    regorder=[5;6;7;8;1;2;3;4];
    for c=1:8
        subplot(2,4,c);reg=regorder(c);hold on;
        vectoplot=finalwbtarraydj(stnordofmax(reg),startday:31777,3);vectoplot=vectoplot(~isnan(vectoplot));
        h=histogram(vectoplot,'Normalization','probability','BinEdges',xmins(reg):xmaxs(reg),'FaceColor',colors('green'));alpha(h,0.5);
        hh=histogram(twarrfinal_era(reg,:),'Normalization','probability','BinEdges',xmins(reg):xmaxs(reg),'FaceColor',colors('orange'));alpha(hh,0.5);
        xlim([xmins(reg) xmaxs(reg)]);ylim([0 ymaxs(reg)]);
        %Compute and display ERA biases of the 50th, 95th, and 99.9th percentiles
        diff50=quantile(twarrfinal_era(reg,:),0.5)-quantile(finalwbtarraydj(stnordofmax(reg),startday:31777,3),0.5);
        xpos1=xmins(reg)+0.1*(xmaxs(reg)-xmins(reg));ypos=0.92*ymaxs(reg);
        text(xpos1,ypos+0.06*ymaxs(reg),'p50','fontweight','bold');text(xpos1,ypos,sprintf('%0.1f',diff50),'fontweight','bold');
        diff95=quantile(twarrfinal_era(reg,:),0.95)-quantile(finalwbtarraydj(stnordofmax(reg),startday:31777,3),0.95);
        xpos2=xmins(reg)+0.4*(xmaxs(reg)-xmins(reg));
        text(xpos2,ypos+0.06*ymaxs(reg),'p95','fontweight','bold');text(xpos2,ypos,sprintf('%0.1f',diff95),'fontweight','bold');
        diff999=quantile(twarrfinal_era(reg,:),0.999)-quantile(finalwbtarraydj(stnordofmax(reg),startday:31777,3),0.999);
        xpos3=xmins(reg)+0.7*(xmaxs(reg)-xmins(reg));
        text(xpos3,ypos+0.06*ymaxs(reg),'p99.9','fontweight','bold');text(xpos3,ypos,sprintf('%0.1f',diff999),'fontweight','bold');
        if reg==1 || reg==5
            title('180 W - 90 W','fontsize',24,'fontweight','bold','fontname','arial');
            if reg==5
                text(-0.5,0.5*ymaxs(reg),'Subtropics','fontsize',18,'fontweight','bold','fontname','arial','units','normalized');
            elseif reg==1
                text(-0.5,0.5*ymaxs(reg),'Tropics','fontsize',18,'fontweight','bold','fontname','arial','units','normalized');
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
    figname='figures6';curpart=2;width=14;highqualityfiguresetup;
end
   
%Biases of ERA-Interim relative to stations in SW Asia
if figures7==1
    %Get SW Asia stations within each ERA grid box (if any), and their position relative to the center of it
    %Recall that ERA data is 0.5x0.5
    numstns=0;clear centerweight;clear nsweight;clear ewweight;
    threshtouse=33;
    for boxrow=60:140 %longitudes
        for boxcol=110:150 %latitudes
            boxcenterlat=90.5-0.5*boxcol;
            boxcenterlon=-0.25+boxrow/2;
            
            for stn=1:size(finalstnlatlon,1)
                stnlat=finalstnlatlon(stn,1);stnlon=finalstnlatlon(stn,2);
                if abs(stnlat-boxcenterlat)<0.25 && abs(stnlon-boxcenterlon)<0.25
                    if max(squeeze(finalwbtarraydj(stn,:,3)))>=threshtouse
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
        
        %Actual station data
        for i=1:numstns
            actualtwvals(year-1978,i,1:365)=finalwbtarraydj(thesestnsords(i),yearstartday:yearstartday+364,3);
            actualtvals(year-1978,i,1:365)=finaltarray(thesestnsords(i),yearstartday:yearstartday+364,3);
            actualtdvals(year-1978,i,1:365)=finaldewptarray(thesestnsords(i),yearstartday:yearstartday+364,3);
        end
        yearstartday=yearstartday+yearlen;
        fprintf('Year is %d within erabiases\n',year);
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
    'overlaynow';0;'datatounderlay';data;'nonewfig';1};
    figc=100;plotModelData(data,region,vararginnew,datatype);
    set(gca,'fontweight','bold','fontname','arial','fontsize',16);
    h=colorbar;ylabel(h,'ERA-Interim Bias, Station Means','fontweight','bold','fontname','arial','fontsize',16);
    figname='figures7';curpart=2;highqualityfiguresetup;
end

%Analyze linearly detrended TW occurrences by year vs ENSO
if figures8==1
    numoccurrencesbylatbandandyear=zeros(10,39,6);
    num21coccurrencesbylatbandandyear=zeros(39,6);
    num27coccurrencesbylatbandandyear=zeros(39,6);
    num29coccurrencesbylatbandandyear=zeros(39,6);
    num31coccurrencesbylatbandandyear=zeros(39,6);
    ti=0;
    for thresh=15:2:33
        fprintf('Starting threshold %d\n',thresh);
        ti=ti+1;thisyear=prevyear;
        for day=startday:size(finalwbtarraydj,2)
            if finalwbtarraydj(1,day,2)==1 %Jan 1 of a year
                thisyear=thisyear+1;
                if rem(thisyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                for stn=1:curnumstns
                    thisthreshcount=nansum(finalwbtarraydj(stn,day:day+thisyearlen-1,3)>=thresh);
                    thiscount21c=nansum(finalwbtarraydj(stn,day:day+thisyearlen-1,3)>=21);
                    thiscount27c=nansum(finalwbtarraydj(stn,day:day+thisyearlen-1,3)>=27);
                    thiscount29c=nansum(finalwbtarraydj(stn,day:day+thisyearlen-1,3)>=29);
                    thiscount31c=nansum(finalwbtarraydj(stn,day:day+thisyearlen-1,3)>=31);
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
    figname='figures8';curpart=2;highqualityfiguresetup;
end

if figures9==1
    num27ctropics1=zeros(39,1);num27ctropics2=zeros(39,1);num27ctropics3=zeros(39,1);num27ctropics4=zeros(39,1);
    num27csubtropics1=zeros(39,1);num27csubtropics2=zeros(39,1);num27csubtropics3=zeros(39,1);num27csubtropics4=zeros(39,1);
    num31ctropics1=zeros(39,1);num31ctropics2=zeros(39,1);num31ctropics3=zeros(39,1);num31ctropics4=zeros(39,1);
    num31csubtropics1=zeros(39,1);num31csubtropics2=zeros(39,1);num31csubtropics3=zeros(39,1);num31csubtropics4=zeros(39,1);
    tropics1stncount=0;tropics2stncount=0;tropics3stncount=0;tropics4stncount=0;
    subtropics1stncount=0;subtropics2stncount=0;subtropics3stncount=0;subtropics4stncount=0;
    clear annavgwbtmatrixtropics1;clear annavgwbtmatrixtropics2;clear annavgwbtmatrixtropics3;clear annavgwbtmatrixtropics4;
    clear annavgwbtmatrixsubtropics1;clear annavgwbtmatrixsubtropics2;clear annavgwbtmatrixsubtropics3;clear annavgwbtmatrixsubtropics4;
    for stn=1:curnumstns
        year=1979;yearlen=365;clear num27c;clear num31c;clear annavgwbt;
        for jan1day=17533:yearlen:31777-364 %1979-2017
            dec31day=jan1day+yearlen-1;
            num27c(year-1978,1)=sum(finalwbtarraydj(stn,jan1day:dec31day,3)>=27);
            num31c(year-1978,1)=sum(finalwbtarraydj(stn,jan1day:dec31day,3)>=31);
            annavgwbt(year-1978,1)=nanmean(finalwbtarraydj(stn,jan1day:dec31day,3));
            year=year+1;
            if rem(year,4)==0;yearlen=366;else;yearlen=365;end
        end
        
        if stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)<=-90 %tropics #1
            num27ctropics1=num27ctropics1+num27c;num31ctropics1=num31ctropics1+num31c;
            tropics1stncount=tropics1stncount+1;annavgwbtmatrixtropics1(tropics1stncount,:)=annavgwbt;
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>-90 && stnlons(stn)<=0 %tropics #2
            num27ctropics2=num27ctropics2+num27c;num31ctropics2=num31ctropics2+num31c;
            tropics2stncount=tropics2stncount+1;annavgwbtmatrixtropics2(tropics2stncount,:)=annavgwbt;
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>0 && stnlons(stn)<=90 %tropics #3
            num27ctropics3=num27ctropics3+num27c;num31ctropics3=num31ctropics3+num31c;
            tropics3stncount=tropics3stncount+1;annavgwbtmatrixtropics3(tropics3stncount,:)=annavgwbt;
        elseif stnlats(stn)>=-15 && stnlats(stn)<=15 && stnlons(stn)>90 %tropics #4
            num27ctropics4=num27ctropics4+num27c;num31ctropics4=num31ctropics4+num31c;
            tropics4stncount=tropics4stncount+1;annavgwbtmatrixtropics4(tropics4stncount,:)=annavgwbt;
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)<=-90 %subtropics #1
            num27csubtropics1=num27csubtropics1+num27c;num31csubtropics1=num31csubtropics1+num31c;
            subtropics1stncount=subtropics1stncount+1;annavgwbtmatrixsubtropics1(subtropics1stncount,:)=annavgwbt;
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>-90 && stnlons(stn)<=0 %subtropics #2
            num27csubtropics2=num27csubtropics2+num27c;num31csubtropics2=num31csubtropics2+num31c;
            subtropics2stncount=subtropics2stncount+1;annavgwbtmatrixsubtropics2(subtropics2stncount,:)=annavgwbt;
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>0 && stnlons(stn)<=90 %subtropics #3
            num27csubtropics3=num27csubtropics3+num27c;num31csubtropics3=num31csubtropics3+num31c;
            subtropics3stncount=subtropics3stncount+1;annavgwbtmatrixsubtropics3(subtropics3stncount,:)=annavgwbt;
        elseif ((stnlats(stn)>15 && stnlats(stn)<=35) || (stnlats(stn)>-35 && stnlats(stn)<=-15)) &&...
                stnlons(stn)>90 %subtropics #4
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
    figname='figures9';curpart=2;highqualityfiguresetup;
end

if figures10==1
    %Find RH of all a. 27+ WBT occurrences, b. 31+ WBT occurrences, and c. 35+ WBT occurrences, and create validation plot
    %Also, exclude bad data (RH>100%)
    for loop=1:3
        if loop==1;todo=27;elseif loop==2;todo=31;else;todo=35;end
        clear tdistn27;clear dewptdistn27;clear rhdistn27;
        clear tdistn31;clear dewptdistn31;clear rhdistn31;
        clear tdistn35;clear dewptdistn35;clear rhdistn35;
        c27=0;c31=0;c35=0;baddatac=0;
        for stn=1:curnumstns
            for day=17533:31777
                if finalwbtarraydj(stn,day,3)>=27
                    c27=c27+1;
                    if finaldewptarray(stn,day,3)>finaltarray(stn,day,3)+0.5
                        finaldewptarray(stn,day,3)=NaN;finaldewptarray(stn,day,4)=NaN;
                        finaltarray(stn,day,3)=NaN;finaltarray(stn,day,4)=NaN;
                        finalwbtarraydj(stn,day,3)=NaN;finalwbtarraydj(stn,day,4)=NaN;
                        baddatac=baddatac+1;
                    else
                        tdistn27(c27)=finaltarray(stn,day,3);
                        dewptdistn27(c27)=finaldewptarray(stn,day,3);
                        rhdistn27(c27)=calcrhfromTanddewpt(tdistn27(c27),dewptdistn27(c27));
                    end
                end
                if finalwbtarraydj(stn,day,3)>=31
                    c31=c31+1;
                    tdistn31(c31)=finaltarray(stn,day,3);
                    dewptdistn31(c31)=finaldewptarray(stn,day,3);
                    rhdistn31(c31)=calcrhfromTanddewpt(tdistn31(c31),dewptdistn31(c31));
                end
                if finalwbtarraydj(stn,day,3)>=35
                    c35=c35+1;
                    tdistn35(c35)=finaltarray(stn,day,3);
                    dewptdistn35(c35)=finaldewptarray(stn,day,3);
                    rhdistn35(c35)=calcrhfromTanddewpt(tdistn35(c35),dewptdistn35(c35));
                end
            end
        end

        if todo==27
            tdistn=tdistn27;rhdistn=rhdistn27;
            xt=[4 9 14 19 24 29];xtl={'30','35','40','45','50','55'};
        elseif todo==31
            tdistn=tdistn31;rhdistn=rhdistn31;
            xt=[5 10 15 20 25];xtl={'35','40','45','50','55'};
        elseif todo==35
            tdistn=tdistn35;rhdistn=rhdistn35;
            xt=[5 10 15 20 25];xtl={'35','40','45','50','55'};
        end

        vectorofts=todo:1:55;
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
        figure(loop);clf;curpart=1;highqualityfiguresetup;
        imagescnan(counts);h=colorbar;ylabel(h,'Total Count (Station-Days)');
        colormap(colormaps('blueyellowred','more','not'));
        xticks(xt);xticklabels(xtl);
        xlabel(strcat('Dry-Bulb Temperature (',char(176),'C)'),'fontsize',14,'fontweight','bold','fontname','arial');
        yticks([1 5 9 13 17]);yticklabels({'100','80','60','40','20'});
        ylabel('Relative Humidity (%)','fontsize',14,'fontweight','bold','fontname','arial');
        set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
        title(strcat('Wet-Bulb Temperatures >= ',num2str(todo),char(176),'C'),'fontsize',18,'fontweight','bold','fontname','arial');
        figname=strcat('figures10part',num2str(loop));curpart=2;highqualityfiguresetup;
    end
end

disp(clock);