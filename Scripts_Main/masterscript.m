%Master script and extra analysis that did not directly contribute to one
    %of the final figures

%Loops to run
reloaddata=0; %15 min total
    barebones=0; %if =1, reload only the absolutely necessary arrays (5 min)
addlqc=0; %5 min per stn -- after each round of this, finalwbtarray needs to be reloaded from finalwbtarrayfinal.mat
getstnstats=0; %45 sec -- necessary only on start-up
missingdataanalysis=0; %10 sec
getstnlistextremesbyregion=0; %30 sec
    regforextremes='midwestus'; %'easterneurope', 'westerneurope','southasia', 'midwestus'
mapstns35c=0; %3 min
mapallstnshighestwbt=0; %25 min
mappersiangulfstnshighestwbt=0; %3 min
mapstnsbynumberofexceedances=0; %10 min
annualtrends=0; %5 sec
seasonalregionalpattern=0; %10 sec
    choose33or35=33;
subdailyneighboringcombo=0; %10 sec per subplot for the first 4, 1 min per subplot for the next 4 (5 min total)
calcpct999=0; %1 min
calcalltimemaxoisst=0; %10 min
maperainterimhighestobs=0; %2 min
counteragridptsabovethreshs=0; %2 min
   

yeartostartat=1979; %Jan 1, 1979 corresponds to day 17533
prevyear=1978;startday=17533;
yeartostopat=2017; %Dec 31, 2017 is day 31777
stopday=31777;

numyears=yeartostopat-yeartostartat+1;


%Station & date selections for certain specific plots
%These can either be a single day or a vector of days, but always a single station


datadir='/Volumes/ExternalDriveC/RaymondMatthewsHorton2019_Github/Data/';
erainterimdir='/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/';
figloc='/Volumes/ExternalDriveC/RaymondMatthewsHorton2019_Github/';
addpath(genpath('/Volumes/ExternalDriveC/RaymondMatthewsHorton2019_Github'));

[stncodes,stnnames,stnlats,stnlons,stnelevs,stnstarts,stnends]=...
        textread('hadisd_station_metadata_v2016.txt','%12c %30c %7f %8f %6f %10s %10s');
curnumstns=size(stncodes,1);
exist figc;if ans==0;figc=1;end
%Set names and time zones for selected stations
finalstntzs=NaN.*ones(curnumstns,1);
finalstntzs(3422)=3;finalstntzs(3492)=4.5;finalstntzs(3510)=3;finalstntzs(3511)=3;
finalstntzs(3512)=3;finalstntzs(3521)=4;finalstntzs(3526)=4;finalstntzs(3547)=5;
finalstntzs(3549)=5;finalstntzs(3552)=5;finalstntzs(4784)=2;
finalstntzs(6127)=-5;finalstntzs(6271)=-5;finalstntzs(6275)=-5;
finalstntzs(6524)=-8;finalstntzs(6526)=-8;finalstntzs(6530)=-8;
finalstntzs(6531)=-6;finalstntzs(6555)=-5;finalstntzs(6566)=-5;finalstntzs(6574)=-5;
finalstntzs(6598)=-5;
finalstntzs(7191)=9.5;
finalstntzs(7212)=8;
finalstntzs(7216)=8;finalstntzs(7219)=8;
finalstntzs(7246)=8;

    
%Reload arrays
if reloaddata==1
    temp=load(strcat(datadir,'finaltarrayfinal19312017.mat'));
    finaltarray=temp.finaltarrayverylatest;
    finalstncodes=temp.finalstncodes;
    finalstnlatlon=temp.finalstnlatlon;
    temp=load(strcat(datadir,'finaldewptarrayfinal19312017.mat'));
    finaldewptarray=temp.finaldewptarrayverylatest;
    temp=load(strcat(datadir,'finalwbtarrayfinaldj19312017.mat'));
    finalwbtarraydj=temp.finalwbtarraydj;
    temp=load(strcat(datadir,'finalelevarray.mat'));
    finalstnelev=temp.finalstnelev;
    temp=load(strcat(datadir,'wbtextremesarrays'));markersize=temp.markersize;
    
    
    if barebones~=1
        temp=load('/Volumes/ExternalDriveC/Basics_ERA-Interim/computeerainterimclimo.mat');
        uclimo1000=temp.uclimo1000;vclimo1000=temp.vclimo1000;

        temp=load(strcat(datadir,'stns33c35cdata'));
        stns35catleast3xregions=temp.stns35catleast3xregions;
        stns33catleast3xregions=temp.stns33catleast3xregions;
        stns35catleast3xords=temp.stns35catleast3xords;
        stns33catleast3xords=temp.stns33catleast3xords;
        wbt33cinstances=temp.wbt33cinstances;
        wbt35cinstances=temp.wbt35cinstances;

        temp=load(strcat(datadir,'stns29c31cdata'));
        stns31catleast3xords=temp.stns31catleast3xords;
        stns29catleast3xords=temp.stns29catleast3xords;
        wbt29cinstances=temp.wbt29cinstances;
        wbt31cinstances=temp.wbt31cinstances;

        temp1=-179.75:0.5:179.75;temp2=-90:0.5:90;
        clear eralats;clear eralons;
        for i=1:720
            for j=1:361    
                eralats(i,j)=temp2(j);
                eralons(i,j)=temp1(i);
            end
        end
        eralats=fliplr(eralats);
        eralons=[eralons(361:720,:);eralons(1:360,:)];
    end
end

%Additional QC
if addlqc==1
    doaddlqc;
end

%Some basic stn stats
if getstnstats==1
    thisyear=prevyear;
    for day=startday:size(finalwbtarraydj,2)
        if finalwbtarraydj(1,day,2)==1 %Jan 1 of a year
            thisyear=thisyear+1;
            if rem(thisyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
            for stn=1:7877
                wbtmaxnumnansbyyearandstn(thisyear-prevyear,stn)=sum(isnan(finalwbtarraydj(stn,day:day+thisyearlen-1,3)));
                tmaxnumnansbyyearandstn(thisyear-prevyear,stn)=sum(isnan(finaltarray(stn,day:day+thisyearlen-1,3)));
                wbtminnumnansbyyearandstn(thisyear-prevyear,stn)=sum(isnan(finalwbtarraydj(stn,day:day+thisyearlen-1,4)));
                tminnumnansbyyearandstn(thisyear-prevyear,stn)=sum(isnan(finaltarray(stn,day:day+thisyearlen-1,4)));
            end
        end
    end
    
    stnarraygoodwbtmax=zeros(curnumstns,numyears);stnlistgoodwbtmax=zeros(curnumstns,1);
    stnarraygoodtmax=zeros(curnumstns,numyears);stnlistgoodtmax=zeros(curnumstns,1);
    stnarraygoodwbtmin=zeros(curnumstns,numyears);stnlistgoodwbtmin=zeros(curnumstns,1);
    stnarraygoodtmin=zeros(curnumstns,numyears);stnlistgoodtmin=zeros(curnumstns,1);
    for stn=1:curnumstns
        for year=1:numyears
            if wbtmaxnumnansbyyearandstn(year,stn)<=0.1*365;stnarraygoodwbtmax(stn,year)=1;end
            if tmaxnumnansbyyearandstn(year,stn)<=0.1*365;stnarraygoodtmax(stn,year)=1;end
            if wbtminnumnansbyyearandstn(year,stn)<=0.1*365;stnarraygoodwbtmin(stn,year)=1;end
            if tminnumnansbyyearandstn(year,stn)<=0.1*365;stnarraygoodtmin(stn,year)=1;end
        end
        
        if sum(stnarraygoodwbtmax(stn,:))>=0.9*numyears;stnlistgoodwbtmax(stn)=1;end
        if sum(stnarraygoodtmax(stn,:))>=0.9*numyears;stnlistgoodtmax(stn)=1;end
        if sum(stnarraygoodwbtmin(stn,:))>=0.9*numyears;stnlistgoodwbtmin(stn)=1;end
        if sum(stnarraygoodtmin(stn,:))>=0.9*numyears;stnlistgoodtmin(stn)=1;end
    end
    
    
    %Long-term averages by stn
    for stn=1:curnumstns
        wbtltabystn(stn)=nanmean(finalwbtarraydj(stn,:,3));
        tltabystn(stn)=nanmean(finaltarray(stn,:,3));
    end
end


%Invalid/missing data by stn and year, to see if there are systematic 
    %problems that might be biasing the results AMONG STNS THAT HAVE ALREADY PASSED THE 90% THRESHOLD
if missingdataanalysis==1
    nummissingarray=zeros(6,5);numpresentarray=zeros(6,5);
    %We are interested in the % of data missing by decade, for each of these bins
    for stn=1:curnumstns
        if stnlistgoodwbtmax(stn)==1
            if histalltimemaxwbt(stn)>=33
                stnbins(stn)=1;
            elseif histalltimemaxwbt(stn)>=31
                stnbins(stn)=2;
            elseif histalltimemaxwbt(stn)>=29
                stnbins(stn)=3;
            elseif histalltimemaxwbt(stn)>=27
                stnbins(stn)=4;
            elseif histalltimemaxwbt(stn)>=25
                stnbins(stn)=5;
            else
                stnbins(stn)=6;
            end

            yearstart=15342;curyear=1973;
            while yearstart<=31413
                if rem(curyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
                if curyear<=1979;td=1;elseif curyear<=1989;td=2;elseif curyear<=1999;td=3;elseif curyear<=2009;td=4;else;td=5;end
                nummissingarray(stnbins(stn),td)=nummissingarray(stnbins(stn),td)+...
                    sum(isnan(finalwbtarraydj(stn,yearstart:yearstart+thisyearlen-1,3)));
                numpresentarray(stnbins(stn),td)=numpresentarray(stnbins(stn),td)+...
                    sum(~isnan(finalwbtarraydj(stn,yearstart:yearstart+thisyearlen-1,3)));

                yearstart=yearstart+thisyearlen;curyear=curyear+1;
            end
        end
    end
    
    pctmissingarray=100.*nummissingarray./(nummissingarray+numpresentarray);
    
    
    figure(79);clf;curpart=1;highqualityfiguresetup;
    plot(pctmissingarray(1,:),'color',colors('red'),'linewidth',1.5);hold on;
    plot(pctmissingarray(2,:),'color',colors('orange'),'linewidth',1.5);
    plot(pctmissingarray(3,:),'color',colors('green'),'linewidth',1.5);
    plot(pctmissingarray(4,:),'color',colors('light blue'),'linewidth',1.5);
    plot(pctmissingarray(5,:),'color',colors('blue'),'linewidth',1.5);
    plot(pctmissingarray(6,:),'color',colors('light purple'),'linewidth',1.5);
    
    legend('Stns with All-Time Max >=33 C','Stns with All-Time Max 31-33 C','Stns with All-Time Max 29-31 C',...
        'Stns with All-Time Max 27-29 C','Stns with All-Time Max 25-27 C','Stns with All-Time Max <25 C',...
        'Location','Northeast');
    xlim([1 5]);xticks([1 2 3 4 5]);
    xticklabels({'1970s','1980s','1990s','2000s','2010s'});
    ylabel('Percent Invalid/Missing');
    set(gca,'fontsize',14,'fontweight','bold','fontname','arial');
    figname='missingdatacheck';curpart=2;highqualityfiguresetup;
end


%Get list of stations that have purportedly hit various WBT thresholds in a
%given region and year (e.g. Western Europe 2003, Russia 2010)
if getstnlistextremesbyregion==1
    numstnsfound=0;
    if strcmp(regforextremes,'westerneurope')
        southlat=40;northlat=65;westlon=-15;eastlon=20;firstday=26299;lastday=26663;
        regtoplot='western-europe';figname='westerneuropewbtmax2003';
        titletext='2003 Maximum WBT, Western Europe';
    elseif strcmp(regforextremes,'easterneurope')
        southlat=45;northlat=70;westlon=20;eastlon=60;firstday=28856;lastday=29220;
        regtoplot='eastern-europe';figname='easterneuropewbtmax2010';
        titletext='2010 Maximum WBT, Eastern Europe';
    elseif strcmp(regforextremes,'southasia')
        southlat=15;northlat=35;westlon=62;eastlon=90;firstday=30810;lastday=30880;
        regtoplot='south-asia';figname='southasiawbtmax2015';
        titletext='2015 Maximum WBT, South Asia';
    elseif strcmp(regforextremes,'midwestus')
        southlat=35;northlat=50;westlon=-100;eastlon=-80;firstday=23560;lastday=23600;
        regtoplot='midwestern-usa';figname='midwestuswbtmax1995';
        titletext='1995 Maximum WBT, Midwest US';
    elseif strcmp(regforextremes,'allusa')
        southlat=25;northlat=50;westlon=-125;eastlon=-66;firstday=17533;lastday=31777;
        regtoplot='usa';figname='contiguswbtmax19792017';
        titletext='1979-2017 Maximum WBT, Contiguous US';
    elseif strcmp(regforextremes,'custom')
        southlat=41.5;northlat=43;westlon=-78;eastlon=-75;firstday=24000;lastday=30500;
    end
    clear thislist;
    for stn=1:curnumstns
        if finalstnlatlon(stn,1)>=southlat && finalstnlatlon(stn,1)<=northlat &&...
                finalstnlatlon(stn,2)>=westlon && finalstnlatlon(stn,2)<=eastlon
            numstnsfound=numstnsfound+1;
            thislist(numstnsfound)=stn;
        end
    end
    
    num30cstnsfound=0;total30cinstancesfound=0;
    clear wbt30cstns;clear wbt30cinstances;
    for stnc=1:size(thislist,2)
        thisstn=thislist(stnc);thisstnhashit30c=0;
        for day=startday:size(finalwbtarraydj,2)
            if finalwbtarraydj(thisstn,day,3)>=30
                if thisstnhashit30c==0;num30cstnsfound=num30cstnsfound+1;thisstnhashit30c=1;end
                total30cinstancesfound=total30cinstancesfound+1;
                wbt30cstns(num30cstnsfound)=thisstn;
                wbt30cinstances(total30cinstancesfound,1)=thisstn;
                wbt30cinstances(total30cinstancesfound,2)=day;
                wbt30cinstances(total30cinstancesfound,3)=finalstnlatlon(thisstn,1);
                wbt30cinstances(total30cinstancesfound,4)=finalstnlatlon(thisstn,2);
                wbt30cinstances(total30cinstancesfound,5)=finalwbtarraydj(thisstn,day,1);
                wbt30cinstances(total30cinstancesfound,6)=finalwbtarraydj(thisstn,day,2);
                wbt30cinstances(total30cinstancesfound,7)=finalwbtarraydj(thisstn,day,3);
            end
        end
    end
    
    make28c=0;
    if make28c==1
    num28cstnsfound=0;total28cinstancesfound=0;
    clear wbt28cstns;clear wbt28cinstances;
    for stnc=1:size(thislist,2)
        thisstn=thislist(stnc);thisstnhashit28c=0;
        for day=startday:size(finalwbtarraydj,2)
            if finalwbtarraydj(thisstn,day,3)>=28
                if thisstnhashit28c==0;num28cstnsfound=num28cstnsfound+1;thisstnhashit28c=1;end
                total28cinstancesfound=total28cinstancesfound+1;
                wbt28cstns(num28cstnsfound)=thisstn;
                wbt28cinstances(total28cinstancesfound,1)=thisstn;
                wbt28cinstances(total28cinstancesfound,2)=day;
                wbt28cinstances(total28cinstancesfound,3)=finalstnlatlon(thisstn,1);
                wbt28cinstances(total28cinstancesfound,4)=finalstnlatlon(thisstn,2);
                wbt28cinstances(total28cinstancesfound,5)=finalwbtarraydj(thisstn,day,1);
                wbt28cinstances(total28cinstancesfound,6)=finalwbtarraydj(thisstn,day,2);
                wbt28cinstances(total28cinstancesfound,7)=finalwbtarraydj(thisstn,day,3);
            end
        end
    end
    end
    
    %Sort by date to identify particular events that may have had extreme
    %WBT at multiple stations (and thus can inspire more confidence in their accuracy)
    wbt30cinstancessorted=sortrows(wbt30cinstances,[5 6]);
    if make28c==1;wbt28cinstancessorted=sortrows(wbt28cinstances,[5 6]);end
    
    %Make map of this region's stations by their highest observed WBT in the year of interest
    validstnc=0;clear maxwbtthisyearbystn;clear dayofhw;clear latstoplot;clear lonstoplot;
    for stnc=1:size(thislist,2)
        thisstn=thislist(stnc);
        if ~isnan(nanmax(squeeze(finalwbtarraydj(thisstn,firstday:lastday,3))))
            validstnc=validstnc+1;
            [maxwbtthisyearbystn(validstnc),dayofhw(validstnc)]=nanmax(squeeze(finalwbtarraydj(thisstn,firstday:lastday,3)));
            latstoplot(validstnc)=finalstnlatlon(thisstn,1);
            lonstoplot(validstnc)=finalstnlatlon(thisstn,2);
        end
    end
    colorcutoffs=[20;22;24;26;28;30;32];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('light green');colors('orange');colors('red')];
    quicklymapsomethingregion(regtoplot,maxwbtthisyearbystn,50,latstoplot,...
        lonstoplot,'s',colorcutoffs,markercolors,7,1,0,figloc,figname);
    h=text(1.2,0.42,'WBT (C)','FontSize',16,'FontWeight','bold','FontName','Arial','units','normalized');
    set(h,'rotation',90);
    title(titletext,'fontsize',20,'fontweight','bold','fontname','arial');
    curpart=2;highqualityfiguresetup;
end

%Make map of stations that have ever purportedly hit 27 C or higher, 29 C or higher, 31 C or higher, 33 C or higher, and 35 C or higher
%Also save the corresponding dates
if mapstns35c==1
    num27cstnsfound=0;total27cinstancesfound=0;
    num29cstnsfound=0;total29cinstancesfound=0;
    num31cstnsfound=0;total31cinstancesfound=0;
    num33cstnsfound=0;total33cinstancesfound=0;
    num35cstnsfound=0;total35cinstancesfound=0;
    clear wbt27cstns;clear wbt27cinstances;
    clear wbt29cstns;clear wbt29cinstances;
    clear wbt31cstns;clear wbt31cinstances;
    clear wbt33cstns;clear wbt33cinstances;
    clear wbt35cstns;clear wbt35cinstances;
    for stn=1:curnumstns
        thisstnhashit27c=0;thisstnhashit29c=0;thisstnhashit31c=0;thisstnhashit33c=0;thisstnhashit35c=0;
        for day=startday:size(finalwbtarraydj,2)
            if finalwbtarraydj(stn,day,3)>=27
                if thisstnhashit27c==0;num27cstnsfound=num27cstnsfound+1;thisstnhashit27c=1;end
                total27cinstancesfound=total27cinstancesfound+1;
                wbt27cstns(num27cstnsfound)=stn;
                wbt27cinstances(total27cinstancesfound,1)=stn;
                wbt27cinstances(total27cinstancesfound,2)=day;
                wbt27cinstances(total27cinstancesfound,3)=finalstnlatlon(stn,1);
                wbt27cinstances(total27cinstancesfound,4)=finalstnlatlon(stn,2);
                wbt27cinstances(total27cinstancesfound,5)=finalwbtarraydj(stn,day,1);
                wbt27cinstances(total27cinstancesfound,6)=finalwbtarraydj(stn,day,2);
                wbt27cinstances(total27cinstancesfound,7)=finalwbtarraydj(stn,day,3);
            end
            
            if finalwbtarraydj(stn,day,3)>=29
                if thisstnhashit29c==0;num29cstnsfound=num29cstnsfound+1;thisstnhashit29c=1;end
                total29cinstancesfound=total29cinstancesfound+1;
                wbt29cstns(num29cstnsfound)=stn;
                wbt29cinstances(total29cinstancesfound,1)=stn;
                wbt29cinstances(total29cinstancesfound,2)=day;
                wbt29cinstances(total29cinstancesfound,3)=finalstnlatlon(stn,1);
                wbt29cinstances(total29cinstancesfound,4)=finalstnlatlon(stn,2);
                wbt29cinstances(total29cinstancesfound,5)=finalwbtarraydj(stn,day,1);
                wbt29cinstances(total29cinstancesfound,6)=finalwbtarraydj(stn,day,2);
                wbt29cinstances(total29cinstancesfound,7)=finalwbtarraydj(stn,day,3);
            end
            
            if finalwbtarraydj(stn,day,3)>=31
                if thisstnhashit31c==0;num31cstnsfound=num31cstnsfound+1;thisstnhashit31c=1;end
                total31cinstancesfound=total31cinstancesfound+1;
                wbt31cstns(num31cstnsfound)=stn;
                wbt31cinstances(total31cinstancesfound,1)=stn;
                wbt31cinstances(total31cinstancesfound,2)=day;
                wbt31cinstances(total31cinstancesfound,3)=finalstnlatlon(stn,1);
                wbt31cinstances(total31cinstancesfound,4)=finalstnlatlon(stn,2);
                wbt31cinstances(total31cinstancesfound,5)=finalwbtarraydj(stn,day,1);
                wbt31cinstances(total31cinstancesfound,6)=finalwbtarraydj(stn,day,2);
                wbt31cinstances(total31cinstancesfound,7)=finalwbtarraydj(stn,day,3);
            end
            
            if finalwbtarraydj(stn,day,3)>=33
                if thisstnhashit33c==0;num33cstnsfound=num33cstnsfound+1;thisstnhashit33c=1;end
                total33cinstancesfound=total33cinstancesfound+1;
                wbt33cstns(num33cstnsfound)=stn;
                wbt33cinstances(total33cinstancesfound,1)=stn;
                wbt33cinstances(total33cinstancesfound,2)=day;
                wbt33cinstances(total33cinstancesfound,3)=finalstnlatlon(stn,1);
                wbt33cinstances(total33cinstancesfound,4)=finalstnlatlon(stn,2);
                wbt33cinstances(total33cinstancesfound,5)=finalwbtarraydj(stn,day,1);
                wbt33cinstances(total33cinstancesfound,6)=finalwbtarraydj(stn,day,2);
                wbt33cinstances(total33cinstancesfound,7)=finalwbtarraydj(stn,day,3);
            end
            
            if finalwbtarraydj(stn,day,3)>=35
                if thisstnhashit35c==0;num35cstnsfound=num35cstnsfound+1;thisstnhashit35c=1;end
                total35cinstancesfound=total35cinstancesfound+1;
                wbt35cstns(num35cstnsfound)=stn;
                wbt35cinstances(total35cinstancesfound,1)=stn;
                wbt35cinstances(total35cinstancesfound,2)=day;
                wbt35cinstances(total35cinstancesfound,3)=finalstnlatlon(stn,1);
                wbt35cinstances(total35cinstancesfound,4)=finalstnlatlon(stn,2);
                wbt35cinstances(total35cinstancesfound,5)=finalwbtarraydj(stn,day,1);
                wbt35cinstances(total35cinstancesfound,6)=finalwbtarraydj(stn,day,2);
                wbt35cinstances(total35cinstancesfound,7)=finalwbtarraydj(stn,day,3);
            end
        end
    end

    %List (and map) of the 30 stns that have purportedly hit 35 C or higher at least 3 times
    %Also calculate stns that have hit 33 C or higher at least 3 times, for various later uses
    clear stns35catleast3xords;numstnsfound=0;thisstnfound=0;
    for i=3:size(wbt35cinstances,1)
        if wbt35cinstances(i,1)==wbt35cinstances(i-2,1) && thisstnfound==0 %at least 3 instances at this stn
            numstnsfound=numstnsfound+1;thisstnfound=1;
            stns35catleast3xords(numstnsfound,1)=wbt35cinstances(i,1);
        elseif wbt35cinstances(i,1)~=wbt35cinstances(i-1,1)
            thisstnfound=0;
        end
    end
    clear stns33catleast3xords;numstnsfound=0;thisstnfound=0;
    for i=3:size(wbt33cinstances,1)
        if wbt33cinstances(i,1)==wbt33cinstances(i-2,1) && thisstnfound==0 %at least 3 instances at this stn
            numstnsfound=numstnsfound+1;thisstnfound=1;
            stns33catleast3xords(numstnsfound,1)=wbt33cinstances(i,1);
        elseif wbt33cinstances(i,1)~=wbt33cinstances(i-1,1)
            thisstnfound=0;
        end
    end
    clear stns31catleast3xords;numstnsfound=0;thisstnfound=0;
    for i=3:size(wbt31cinstances,1)
        if wbt31cinstances(i,1)==wbt31cinstances(i-2,1) && thisstnfound==0 %at least 3 instances at this stn
            numstnsfound=numstnsfound+1;thisstnfound=1;
            stns31catleast3xords(numstnsfound,1)=wbt31cinstances(i,1);
        elseif wbt31cinstances(i,1)~=wbt31cinstances(i-1,1)
            thisstnfound=0;
        end
    end
    clear stns29catleast3xords;numstnsfound=0;thisstnfound=0;
    for i=3:size(wbt29cinstances,1)
        if wbt29cinstances(i,1)==wbt29cinstances(i-2,1) && thisstnfound==0 %at least 3 instances at this stn
            numstnsfound=numstnsfound+1;thisstnfound=1;
            stns29catleast3xords(numstnsfound,1)=wbt29cinstances(i,1);
        elseif wbt29cinstances(i,1)~=wbt29cinstances(i-1,1)
            thisstnfound=0;
        end
    end
    
    
    %Sort stations into regions
    %Note: SW North America is #1, N Africa is #2, SW Asia is #3, S Asia is #4, Australia is #5
    clear stns33catleast3xregions;
    for i=1:size(stns33catleast3xords,1)
        thislat=finalstnlatlon(stns33catleast3xords(i),1);
        thislon=finalstnlatlon(stns33catleast3xords(i),2);
        if thislat>=15 && thislon<=-85
            stns33catleast3xregions(i,1)=1;
        elseif thislat>=0 && thislat<=35 && thislon>=-20 && thislon<=30
            stns33catleast3xregions(i,1)=2;
        elseif thislat>=10 && thislat<=50 && thislon>=30 && thislon<=62
            stns33catleast3xregions(i,1)=3;
        elseif thislat>=0 && thislat<=40 && thislon>=62 && thislon<=100
            stns33catleast3xregions(i,1)=4;
        elseif thislat>=-40 && thislat<=-5 && thislon>=110 && thislon<=155
            stns33catleast3xregions(i,1)=5;
        end
    end
    clear stns35catleast3xregions;
    for i=1:size(stns35catleast3xords,1)
        thislat=finalstnlatlon(stns35catleast3xords(i),1);
        thislon=finalstnlatlon(stns35catleast3xords(i),2);
        if thislat>=15 && thislon<=-85
            stns35catleast3xregions(i,1)=1;
        elseif thislat>=0 && thislat<=35 && thislon>=-20 && thislon<=30
            stns35catleast3xregions(i,1)=2;
        elseif thislat>=10 && thislat<=50 && thislon>=30 && thislon<=62
            stns35catleast3xregions(i,1)=3;
        elseif thislat>=0 && thislat<=40 && thislon>=62 && thislon<=100
            stns35catleast3xregions(i,1)=4;
        elseif thislat>=-40 && thislat<=-5 && thislon>=110 && thislon<=155
            stns35catleast3xregions(i,1)=5;
        end
    end
    
    save(strcat(figloc,'stns33c35cdata'),'stns35catleast3xregions','stns33catleast3xregions',...
        'stns35catleast3xords','stns33catleast3xords','wbt33cinstances','wbt35cinstances');
    save(strcat(figloc,'stns29c31cdata'),'stns31catleast3xords','stns29catleast3xords',...
        'wbt29cinstances','wbt31cinstances');
    save(strcat(figloc,'stns27cdata'),'wbt27cinstances');
    
    
    %Determine whether a station exceeds the 35-C threshold as well as the 33-C one
    clear tempvals;clear ords;
    for i=1:size(stns33catleast3xords,1)
        thisstn=stns33catleast3xords(i);
        ords(i,1)=thisstn;
        if checkifthingsareelementsofvector(stns35catleast3xords,thisstn)
            ords(i,2)=100;
        else
            ords(i,2)=0;
        end
    end
    ords=sortrows(ords,2);
    %Map of relatively reliable 33 and 35 C stns
    quicklymapsomethingworld(ords(:,2),990,finalstnlatlon(ords(:,1),1),...
        finalstnlatlon(ords(:,1),2),'s',50,[colors('orange');colors('red')],7,0,0,figloc,...
        strcat('stns33and35catleast3x',wbtdefn));
    
        
    %Array containing WBT, T, and dewpt daily maxes for 5 days before to 5 days
        %after each instance of 35 C or higher at the 3x-or-more stns
    c=0;clear wbt35cinstancesfreqstns;
    for i=1:size(wbt35cinstances,1)
        if checkifthingsareelementsofvector(stns35catleast3xords,wbt35cinstances(i,1))
            c=c+1;
            wbt35cinstancesfreqstns(c,:)=wbt35cinstances(i,:);
        end
    end
    clear wbtsurr35cinstances;clear tsurr35cinstances;clear dewptsurr35cinstances;
    for i=1:size(wbt35cinstancesfreqstns,1)
        thisstn=wbt35cinstancesfreqstns(i,1);
        thisday=wbt35cinstancesfreqstns(i,2);
        wbtsurr35cinstances(i,:)=finalwbtarraydj(thisstn,thisday-5:thisday+5,3);
        tsurr35cinstances(i,:)=finaltarray(thisstn,thisday-5:thisday+5,3);
        dewptsurr35cinstances(i,:)=finaldewptarray(thisstn,thisday-5:thisday+5,3);
    end
end


%Map of all stations showing their highest WBT ever observed
if mapallstnshighestwbt==1
    temp=finalwbtarraydj(:,:,3);
    highestwbtever=squeeze(nanmax(temp,[],2));
    
    colorcutoffs=[23;25;27;29;31;33;35];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('light green');colors('orange');colors('red')];
    quicklymapsomethingworld(highestwbtever,figc,finalstnlatlon(1:curnumstns,1),finalstnlatlon(1:curnumstns,2),...
        's',colorcutoffs,markercolors,markersize',1,...
        {'cblabeltext';'Daily Max WBT (C)';'cblabelfontsize';16},figloc,'highestwbtevermap');
    figure(figc);
    title('Highest WBT Ever Observed','fontsize',20,'fontweight','bold','fontname','arial');
    figname='highestwbtevermap';curpart=2;highqualityfiguresetup;
end


%Map of Persian Gulf stations showing their highest WBT ever observed
if mappersiangulfstnshighestwbt==1
    temp=finalwbtarraydj(:,:,3);
    highestwbtever=squeeze(nanmax(temp,[],2));
    
    colorcutoffs=[23;25;27;29;31;33];
    markercolors=[colors('black');colors('purple');colors('blue');colors('sky blue');...
        colors('medium-dark green');colors('light orange');colors('red')];
    quicklymapsomethingregion('persian-gulf',highestwbtever,figc,finalstnlatlon(1:curnumstns,1),finalstnlatlon(1:curnumstns,2),...
        's',colorcutoffs,markercolors,10,1,...
        {'cblabeltext';strcat('Daily Max Tw (',char(176),'C)');'cblabelfontsize';16},figloc,'highestwbtevermap_pg');
    figure(figc);
    title('Highest WBT Observed, 1979-2017','fontsize',20,'fontweight','bold','fontname','arial');
    figname='highestwbtevermap_pg';curpart=2;highqualityfiguresetup;
end


%Map of all stations showing their number of exceedances of a given WBT threshold
if mapstnsbynumberofexceedances==1
    thresh=30;
    temp=finalwbtarraydj(:,:,3);
    exceedances=temp>=thresh;
    exceedancesbystn=sum(exceedances,2);
    
    stnc=0;clear exceedancesbystnreduced;clear stnlatsreduced;clear stnlonsreduced;
    clear markersizereduced;
    for stn=1:curnumstns
        if exceedancesbystn(stn)>=25
            stnc=stnc+1;
            exceedancesbystnreduced(stnc)=exceedancesbystn(stn);
            stnlatsreduced(stnc)=finalstnlatlon(stn,1);
            stnlonsreduced(stnc)=finalstnlatlon(stn,2);
            markersizereduced(stnc)=markersize(stn);
        end
    end
    
    colorcutoffs=[50;100;250;500;1000];
    markercolors=[colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('orange');colors('red')];
    quicklymapsomethingworld(exceedancesbystnreduced,figc,stnlatsreduced,stnlonsreduced,...
        's',colorcutoffs,markercolors,5,1,...
        {'cblabeltext';'Count';'cblabelfontsize';16},figloc,strcat('mapstnexceedances',num2str(thresh)));
    figure(figc);
    title(sprintf('Number of Days with WBT>=%d%cC, 1973-2017 (Minimum: 25)',thresh,char(176)),...
        'fontsize',20,'fontweight','bold','fontname','arial');
    figname=strcat('mapstnexceedances',num2str(thresh));curpart=2;highqualityfiguresetup;
end


%Total number of occurrences above a threshold by year, 1979-2017, for
%stations for which at least 90% of years are valid (validity being defined as >=90% data availability in that year)
%Requires having already run getstnstats loop
if annualtrends==1
    clear num35coccurrencesbyyear;clear num33coccurrencesbyyear;clear num31coccurrencesbyyear;
    clear num29coccurrencesbyyear;clear num27coccurrencesbyyear;
    clear avgwbtbyyear;clear avgtbyyear;clear tmaxgoodstnsclimobyyear;
    
    %Do this only on the first run of a session (10 min)
    dothis=0;
    if dothis==1
    goodstnc=0;
    for stn=1:curnumstns
        if stnlistgoodwbtmax(stn)==1
            goodstnc=goodstnc+1;
            finalwbtarraydjgoodstns(goodstnc,:,:)=finalwbtarraydj(stn,:,:);
            stnlatsgoodstns(goodstnc)=stnlats(stn);
            stnlonsgoodstns(goodstnc)=stnlons(stn);
        end
    end
    end
    exist finalwbtarraydjgoodstns;if ans==0;disp('Need to create finalwbtarraydjgoodstns');return;end
    
    thisyear=prevyear;
    stnords=1:curnumstns;

    for day=startday:size(finalwbtarraydjgoodstns,2)
        if finalwbtarraydjgoodstns(1,day,2)==1 %Jan 1 of a year
            thisyear=thisyear+1;
            if rem(thisyear,4)==0;thisyearlen=366;else;thisyearlen=365;end
            num35coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=35));
            num33coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=33));
            num31coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=31));
            num29coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=29));
            num27coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=27));
            num10coccurrencesbyyear(thisyear-prevyear)=nansum(nansum(finalwbtarraydjgoodstns(:,day:day+thisyearlen-1,3)>=10));
            
            goodwbtmaxstnsthisyear=stnarraygoodwbtmax(:,thisyear-prevyear);
            wbtmaxdataallstns=finalwbtarraydj(:,day:day+thisyearlen-1,3);
            wbtmaxdatagoodstns=wbtmaxdataallstns(goodwbtmaxstnsthisyear==1,:);
            wbtmaxgoodstnsclimobyyear(thisyear-prevyear)=nanmean(wbtltabystn(goodwbtmaxstnsthisyear==1));
            
            goodtmaxstnsthisyear=stnarraygoodtmax(:,thisyear-prevyear);
            tmaxdataallstns=finaltarray(:,day:day+thisyearlen-1,3);
            tmaxdatagoodstns=tmaxdataallstns(goodtmaxstnsthisyear==1,:);
            tmaxgoodstnsclimobyyear(thisyear-prevyear)=nanmean(tltabystn(goodtmaxstnsthisyear==1));
            
            avgwbtmaxbyyear(thisyear-prevyear)=nanmean(nanmean(wbtmaxdatagoodstns));
            avgtmaxbyyear(thisyear-prevyear)=nanmean(nanmean(tmaxdatagoodstns));
        end
    end
    %Adjust means by the composition of the stations that comprise them
    overallwbtmaxmean=nanmean(wbtmaxgoodstnsclimobyyear);
    necoffsetwbtmax=overallwbtmaxmean-wbtmaxgoodstnsclimobyyear;
    avgwbtmaxbyyear=avgwbtmaxbyyear+necoffsetwbtmax;
    
    overalltmaxmean=nanmean(tmaxgoodstnsclimobyyear);
    necoffsettmax=overalltmaxmean-tmaxgoodstnsclimobyyear;
    avgtmaxbyyear=avgtmaxbyyear+necoffsettmax;
        
    
    figure(189);clf;curpart=1;highqualityfiguresetup;
    oldversionofplot=0;
    if oldversionofplot==1
        subplot('Position',[0.09 0.3 0.76 0.65]);
        semilogy(years,num27coccurrencesbyyear,'linewidth',2,'color','b');hold on;
        semilogy(years,num29coccurrencesbyyear,'linewidth',2,'color',colors('light blue'));
        semilogy(years,num31coccurrencesbyyear,'linewidth',2,'color','g');
        semilogy(years,num33coccurrencesbyyear,'linewidth',2,'color',colors('orange'));
        semilogy(years,num35coccurrencesbyyear,'linewidth',2,'color','r');
        ylim([0 10^5]);
        %symlog(gca,'y',0); %add 0 -- DO THIS MANUALLY AFTER THE PLOT HAS BEEN MADE

        ylabel('Count','fontname','arial','fontsize',16,'fontweight','bold');
        lgd1=legend({sprintf('27%cC',char(176)),sprintf('29%cC',char(176)),sprintf('31%cC',char(176)),sprintf('33%cC',char(176)),sprintf('35%cC',char(176))},...
            'Location','EastOutside');set(lgd1,'Position',[0.92 0.5 0.06 0.25]);
        xlim([yeartostartat yeartostopat]);
        set(gca,'fontname','arial','fontsize',16,'fontweight','bold');

        subplot('Position',[0.09 0.05 0.76 0.16]);
        plot(years,avgwbtmaxbyyear,'linewidth',2,'color','k','linestyle','--');hold on;
        ylabel(sprintf('WBT (%cC)',char(176)),'fontname','arial','fontsize',16,'fontweight','bold');ylim([10 12]);yticks([10 11 12]);
        yyaxis right;plot(years,avgtmaxbyyear,'linewidth',2,'color',colors('gray'),'linestyle','--');set(gca,'YColor','k');
        ylabel(sprintf('T (%cC)',char(176)),'fontname','arial','fontsize',16,'fontweight','bold');ylim([15 19]);
        xlim([yeartostartat yeartostopat]);
        lgd2=legend({'WBT','T'},'Location','NortheastOutside');set(lgd2,'Position',[0.92 0.08 0.06 0.1]);
        set(gca,'fontname','arial','fontsize',16,'fontweight','bold');
        xlabel('Year','fontname','arial','fontsize',16,'fontweight','bold');

        height=12;
    else
        subplot(5,1,1);plot(years,num33coccurrencesbyyear,'linewidth',2,'color',colors('orange'));ylim([0 45]);
        subplot(5,1,2);plot(years,num31coccurrencesbyyear,'linewidth',2,'color',colors('green'));ylim([0 450]);
        subplot(5,1,3);plot(years,num29coccurrencesbyyear,'linewidth',2,'color',colors('light blue'));ylim([0 4500]);
        subplot(5,1,4);plot(years,num27coccurrencesbyyear,'linewidth',2,'color',colors('dark blue'));ylim([0 45000]);
    end
    figname='annualtrendsbythreshold';curpart=2;highqualityfiguresetup;
    
    %Get statistics on increases in each threshold, for reporting in paper
    %Use an ordinary least-squares regression for doing this
    [p,S]=polyfit(years,num33coccurrencesbyyear,1);
    f1=polyval(p,years); %fitted line
    ci=polyparci(p,S); %confidence intervals of line parameters
    percincre=round(100.*(f1(end)-f1(1))./f1(1));
end


%Seasonal pattern of 33-C and 35-C days by region
%Again, regions: SW North America is #1, N Africa is #2, SW Asia is #3, S Asia is #4, Australia is #5
if seasonalregionalpattern==1
    numstnsbyreg=zeros(5,1);
    for i=1:5;numextremeinstancesbyregandmonth{i}=zeros(12,1);end
    if choose33or35==33
        regionvec=stns33catleast3xregions;ordvec=stns33catleast3xords;wbtinstvec=wbt33cinstances;
    else
        regionvec=stns35catleast3xregions;ordvec=stns35catleast3xords;wbtinstvec=wbt35cinstances;
    end
    for stn=1:size(regionvec,1)
        thisstn=ordvec(stn);
        thisreg=regionvec(stn);
        if thisreg~=0
            numstnsbyreg(thisreg)=numstnsbyreg(thisreg)+1;
        
            temp=wbtinstvec(wbtinstvec(:,1)==thisstn,:);
            
            numextremeinstancesbyregandmonth{thisreg}(1)=...
                numextremeinstancesbyregandmonth{thisreg}(1)+sum(temp(:,6)>=1 & temp(:,6)<=31);
            numextremeinstancesbyregandmonth{thisreg}(2)=...
                numextremeinstancesbyregandmonth{thisreg}(2)+sum(temp(:,6)>=32 & temp(:,6)<=59);
            numextremeinstancesbyregandmonth{thisreg}(3)=...
                numextremeinstancesbyregandmonth{thisreg}(3)+sum(temp(:,6)>=60 & temp(:,6)<=90);
            numextremeinstancesbyregandmonth{thisreg}(4)=...
                numextremeinstancesbyregandmonth{thisreg}(4)+sum(temp(:,6)>=91 & temp(:,6)<=120);
            numextremeinstancesbyregandmonth{thisreg}(5)=...
                numextremeinstancesbyregandmonth{thisreg}(5)+sum(temp(:,6)>=121 & temp(:,6)<=151);
            numextremeinstancesbyregandmonth{thisreg}(6)=...
                numextremeinstancesbyregandmonth{thisreg}(6)+sum(temp(:,6)>=152 & temp(:,6)<=181);
            numextremeinstancesbyregandmonth{thisreg}(7)=...
                numextremeinstancesbyregandmonth{thisreg}(7)+sum(temp(:,6)>=182 & temp(:,6)<=212);
            numextremeinstancesbyregandmonth{thisreg}(8)=...
                numextremeinstancesbyregandmonth{thisreg}(8)+sum(temp(:,6)>=213 & temp(:,6)<=243);
            numextremeinstancesbyregandmonth{thisreg}(9)=...
                numextremeinstancesbyregandmonth{thisreg}(9)+sum(temp(:,6)>=244 & temp(:,6)<=273);
            numextremeinstancesbyregandmonth{thisreg}(10)=...
                numextremeinstancesbyregandmonth{thisreg}(10)+sum(temp(:,6)>=274 & temp(:,6)<=304);
            numextremeinstancesbyregandmonth{thisreg}(11)=...
                numextremeinstancesbyregandmonth{thisreg}(11)+sum(temp(:,6)>=305 & temp(:,6)<=334);
            numextremeinstancesbyregandmonth{thisreg}(12)=...
                numextremeinstancesbyregandmonth{thisreg}(12)+sum(temp(:,6)>=335 & temp(:,6)<=365);
        end
    end
    
    figure(72);clf;curpart=1;highqualityfiguresetup;
    plot(numextremeinstancesbyregandmonth{1},'color',colors('green'),'linewidth',2);hold on;
    plot(numextremeinstancesbyregandmonth{2},'color',colors('gold'),'linewidth',2);
    plot(numextremeinstancesbyregandmonth{3},'color',colors('rose'),'linewidth',2);
    plot(numextremeinstancesbyregandmonth{4},'color',colors('blue'),'linewidth',2);
    plot(numextremeinstancesbyregandmonth{5},'color',colors('light purple'),'linewidth',2);
    xlim([1 12]);
    legend({'SW N America','N Africa','SW Asia','S Asia','Australia'},'Location','Northwest');
    set(gca,'fontname','arial','fontweight','bold','fontsize',16);
    ylabel(strcat('Total Number of >=',num2str(choose33or35),'-C Occurrences'),...
        'fontname','arial','fontweight','bold','fontsize',18);
    xlabel('Month of Year','fontname','arial','fontweight','bold','fontsize',18);
    figname=strcat('seasonalregionalpattern',num2str(choose33or35),'c');curpart=2;highqualityfiguresetup;
end


%Make sure downloadhadisddata is properly set up, because it's called
    %multiple times from within this loop
%Also ensure makefigure=1 in subdailyanalysis
if subdailyneighboringcombo==1
    subplotstomake=[1 1 1 1 1 1 1 1];
    colorcutoffs=[23;25;27;29;31;33];
    markercolors=[colors('black');colors('purple');colors('blue');colors('light blue');...
        colors('green');colors('orange');colors('red')];
    allords=1:curnumstns;
    
    figure(900);clf;curpart=1;highqualityfiguresetup;
    theseaxes=tight_subplot(2,4,[.02 .02],[.12 .03],[.05 .12]); %[lower upper], [left right]
    
    
    if subplotstomake(1)==1
        disp('Subplot 1');
        axes(theseaxes(1));
        stnsthisreg=allords(finalstnlatlon(allords,1)>25.4 & finalstnlatlon(allords,1)<49.4 & ...
            finalstnlatlon(allords,2)>-104.4 & finalstnlatlon(allords,2)<-65.6)';
        indexstn1=find(stnsthisreg==6275);indexstn2=find(stnsthisreg==6127);indexstn3=find(stnsthisreg==6271);
        newi=1;clear stnsthisregreord;clear msizes;clear mshapes;
        for i=1:size(stnsthisreg,1)
            if i==indexstn1
                stnsthisregreord(size(stnsthisreg,1)-2)=6275;msizes(size(stnsthisreg,1)-2)=14;mshapes(size(stnsthisreg,1)-2)='p';
            elseif i==indexstn2
                stnsthisregreord(size(stnsthisreg,1)-1)=6127;msizes(size(stnsthisreg,1)-1)=11;mshapes(size(stnsthisreg,1)-1)='p';
            elseif i==indexstn3
                stnsthisregreord(size(stnsthisreg,1))=6271;msizes(size(stnsthisreg,1))=11;mshapes(size(stnsthisreg,1))='p';
            else
                stnsthisregreord(newi)=stnsthisreg(i);
                msizes(newi)=markersize(stnsthisreg(i)).*2.5;mshapes(newi)='s';
                newi=newi+1;
            end
        end
        finalwbtgivenday=finalwbtarraydj(stnsthisregreord,23570,3);
        quicklymapsomethingregion('eastern-usa-minusfl',finalwbtgivenday,...
            900,finalstnlatlon(stnsthisregreord,1),finalstnlatlon(stnsthisregreord,2),...
            mshapes,colorcutoffs,markercolors,msizes,0,0,figloc,'subdailyneighboringcombo');
        title('Jul 13, 1995','fontname','arial','fontweight','bold','fontsize',14);
        text(-0.1,1.03,'(a)','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
    end
    
    if subplotstomake(2)==1
        disp('Subplot 2');
        axes(theseaxes(2));
        stnsthisreg=allords(finalstnlatlon(allords,1)>10.6 & finalstnlatlon(allords,1)<44.4 & ...
            finalstnlatlon(allords,2)>30.6 & finalstnlatlon(allords,2)<79.4)';
        indexstn1=find(stnsthisreg==3526);indexstn2=find(stnsthisreg==3521);indexstn3=find(stnsthisreg==3516);
        newi=1;clear stnsthisregreord;clear msizes;clear mshapes;
        for i=1:size(stnsthisreg,1)
            if i==indexstn1
                stnsthisregreord(size(stnsthisreg,1)-2)=3526;msizes(size(stnsthisreg,1)-2)=14;mshapes(size(stnsthisreg,1)-2)='p';
            elseif i==indexstn2
                stnsthisregreord(size(stnsthisreg,1)-1)=3521;msizes(size(stnsthisreg,1)-1)=11;mshapes(size(stnsthisreg,1)-1)='p';
            elseif i==indexstn3
                stnsthisregreord(size(stnsthisreg,1))=3516;msizes(size(stnsthisreg,1))=11;mshapes(size(stnsthisreg,1))='p';
            else
                stnsthisregreord(newi)=stnsthisreg(i);
                msizes(newi)=markersize(stnsthisreg(i)).*2;mshapes(newi)='s';
                newi=newi+1;
            end
        end
        finalwbtgivenday=finalwbtarraytouse(stnsthisregreord,22869,3);
        quicklymapsomethingregion('middle-east',finalwbtgivenday,...
            900,finalstnlatlon(stnsthisregreord,1),finalstnlatlon(stnsthisregreord,2),...
            mshapes,colorcutoffs,markercolors,msizes,0,0,figloc,'subdailyneighboringcombo');
        title('Aug 11, 1993','fontname','arial','fontweight','bold','fontsize',14);
        text(-0.1,1.03,'(b)','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
    end
    
    if subplotstomake(3)==1
        disp('Subplot 3');
        axes(theseaxes(3));
        stnsthisreg=allords(finalstnlatlon(allords,1)>10.6 & finalstnlatlon(allords,1)<44.4 & ...
            finalstnlatlon(allords,2)>30.6 & finalstnlatlon(allords,2)<79.4)';
        indexstn1=find(stnsthisreg==3547);indexstn2=find(stnsthisreg==3549);indexstn3=find(stnsthisreg==3512);
        newi=1;clear stnsthisregreord;clear msizes;clear mshapes;
        for i=1:size(stnsthisreg,1)
            if i==indexstn1
                stnsthisregreord(size(stnsthisreg,1)-2)=3547;msizes(size(stnsthisreg,1)-2)=14;mshapes(size(stnsthisreg,1)-2)='p';
            elseif i==indexstn2
                stnsthisregreord(size(stnsthisreg,1)-1)=3549;msizes(size(stnsthisreg,1)-1)=11;mshapes(size(stnsthisreg,1)-1)='p';
            elseif i==indexstn3
                stnsthisregreord(size(stnsthisreg,1))=3512;msizes(size(stnsthisreg,1))=11;mshapes(size(stnsthisreg,1))='p';
            else
                stnsthisregreord(newi)=stnsthisreg(i);
                msizes(newi)=markersize(stnsthisreg(i)).*2;mshapes(newi)='s';
                newi=newi+1;
            end
        end
        finalwbtgivenday=nanmax(finalwbtarraytouse(stnsthisregreord,29035:29037,3),[],2);
        quicklymapsomethingregion('middle-east',finalwbtgivenday,...
           900,finalstnlatlon(stnsthisregreord,1),finalstnlatlon(stnsthisregreord,2),...
            mshapes,colorcutoffs,markercolors,msizes,0,0,figloc,'subdailyneighboringcombo');
        title('Jun 29-Jul 1, 2010','fontname','arial','fontweight','bold','fontsize',14);
        text(-0.1,1.03,'(c)','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
    end
    
    if subplotstomake(4)==1
        disp('Subplot 4');
        axes(theseaxes(4));
        stnsthisreg=allords(finalstnlatlon(allords,1)>10.6 & finalstnlatlon(allords,1)<38.4 & ...
            finalstnlatlon(allords,2)>-124.4 & finalstnlatlon(allords,2)<-85.6)';
        indexstn1=find(stnsthisreg==6526);indexstn2=find(stnsthisreg==6530);indexstn3=find(stnsthisreg==6524);
        newi=1;clear stnsthisregreord;clear msizes;clear mshapes;
        for i=1:size(stnsthisreg,1)
            if i==indexstn1
                stnsthisregreord(size(stnsthisreg,1)-2)=6526;msizes(size(stnsthisreg,1)-2)=14;mshapes(size(stnsthisreg,1)-2)='p';
            elseif i==indexstn2
                stnsthisregreord(size(stnsthisreg,1)-1)=6530;msizes(size(stnsthisreg,1)-1)=11;mshapes(size(stnsthisreg,1)-1)='p';
            elseif i==indexstn3
                stnsthisregreord(size(stnsthisreg,1))=6524;msizes(size(stnsthisreg,1))=11;mshapes(size(stnsthisreg,1))='p';
            else
                stnsthisregreord(newi)=stnsthisreg(i);
                msizes(newi)=markersize(stnsthisreg(i)).*2.5;mshapes(newi)='s';
                newi=newi+1;
            end
        end
        finalwbtgivenday=nanmax(finalwbtarraydj(stnsthisregreord,29096:29101,3),[],2);
        quicklymapsomethingregion('na-sw',finalwbtgivenday,...
            900,finalstnlatlon(stnsthisregreord,1),finalstnlatlon(stnsthisregreord,2),...
            mshapes,colorcutoffs,markercolors,msizes,0,0,figloc,'subdailyneighboringcombo');
        title('Aug 29-Sep 3, 2010','fontname','arial','fontweight','bold','fontsize',14);
        text(-0.1,1.03,'(d)','fontname','arial','fontweight','bold','fontsize',14,'units','normalized');
        origsize=get(gca,'Position');
        clear ctable;
        colorcutoffs=sort(colorcutoffs,'ascend');cutoffdiff=colorcutoffs(2)-colorcutoffs(1);
        ctable(1,:)=[colorcutoffs(1)-cutoffdiff markercolors(1,:).*255 colorcutoffs(1) markercolors(1,:).*255];
        for row=2:size(markercolors,1)-1
            ctable(row,:)=[colorcutoffs(row-1) markercolors(row,:).*255 colorcutoffs(row) markercolors(row,:).*255];
        end
        lastrow=size(markercolors,1);
        ctable(lastrow,:)=[colorcutoffs(lastrow-1) markercolors(lastrow,:).*255 colorcutoffs(lastrow-1)+cutoffdiff markercolors(lastrow,:).*255];
        save mycol.cpt ctable -ascii;
        cptcmap('mycol','mapping','direct');
        cbar=cptcbar(gca,'mycol','eastoutside',false);cb=cbar.cb;
        set(cbar.ax,'FontSize',10,'FontWeight','bold','FontName','Arial');cbarpos=get(cbar.ax,'Position');
        h=text(1.3,0.38,sprintf('WBT (%cC)',char(176)),'FontSize',12,'FontWeight','bold','FontName','Arial','units','normalized');
        set(h,'rotation',90);
        set(gca,'Position',origsize);
        set(cbar.ax,'Position',[cbarpos(1)+0.05 cbarpos(2)-0.08 cbarpos(3) cbarpos(4)+0.16]);
        delete mycol.cpt;
    end
    
    
    temp=findall(gcf,'type','axes');delete(temp(end));
    width=15;
    figname='subdailyneighboringcombo';curpart=2;highqualityfiguresetup;
end


%Historical 99.9th percentile and all-time maximum of daily-max WBT and T for each stn
if calcpct999==1
    clear histpct999wbt;clear histpct999t;
    for stn=1:curnumstns
        histpct999wbt(stn)=quantile(finalwbtarraydj(stn,startday:31777,3),0.999);
        histpct999t(stn)=quantile(finaltarray(stn,startday:31777,3),0.999);
        histalltimemaxwbt(stn)=max(finalwbtarraydj(stn,startday:31777,3));
        histalltimemaxt(stn)=max(finaltarray(stn,startday:31777,3));
    end
    temp=1:curnumstns;
    restrictto90pctavail=0;
    if restrictto90pctavail==1
        histpct999wbtgoodstns=histpct999wbt(~isnan(histpct999wbt));ordsgoodstnswbt=temp(temp(~isnan(histpct999wbt)));
        histpct999tgoodstns=histpct999t(~isnan(histpct999t));ordsgoodstnst=temp(temp(~isnan(histpct999t)));
        histalltimemaxwbtgoodstns=histalltimemaxwbt(~isnan(histalltimemaxwbt));ordsgoodstnswbt=temp(temp(~isnan(histalltimemaxwbt)));
        histalltimemaxtgoodstns=histalltimemaxt(~isnan(histalltimemaxt));ordsgoodstnst=temp(temp(~isnan(histalltimemaxt)));

        dist3rdclosestgoodstnswbt=distthirdclosest(finalstnlatlon(ordsgoodstnswbt,1),finalstnlatlon(ordsgoodstnswbt,2));
        for stn=1:size(ordsgoodstnswbt,2);markersizegoodstnswbt(stn)=(dist3rdclosestgoodstnswbt(stn)^0.75)./15;end
        markersizegoodstnswbt=markersizegoodstnswbt';
        dist3rdclosestgoodstnst=distthirdclosest(finalstnlatlon(ordsgoodstnst,1),finalstnlatlon(ordsgoodstnst,2));
        for stn=1:size(ordsgoodstnst,2);markersizegoodstnst(stn)=(dist3rdclosestgoodstnst(stn)^0.75)./15;end
        markersizegoodstnst=markersizegoodstnst';
    end
end


%All-time max SST at each gridpt, from OISST
if calcalltimemaxoisst==1
    gridptmaxima=-999.*ones(1440,720);
    for year=1982:2014
        for month=1:12
            if month<10;addzero='0';else;addzero='';end
            temp=load(strcat('tos_',num2str(year),'_',addzero,num2str(month),'.mat'));
            eval(['sstdata=temp.tos_',num2str(year),'_',addzero,num2str(month),';']);sstdata=sstdata{3};
            sstdatamax=nanmax(sstdata,[],3);
            gridptmaxima=max(gridptmaxima,sstdatamax);invalid=gridptmaxima<-10;gridptmaxima(invalid)=NaN;
        end
        disp(year);
    end
    gridptmaxima=[gridptmaxima(721:1440,:);gridptmaxima(1:720,:)];
end


if maperainterimhighestobs==1
    eratw=double(ncread('ERA-I_DJ_TIM_MAX.nc','TW'))';
    eratw=[eratw(:,241:480) eratw(:,1:240)];
    
    temp1=-90:180/240:90;temp2=-179.625:360/480:179.625;
    for i=1:size(temp1,2)
        for j=1:size(temp2,2)
            eralats(i,j)=temp1(i);
            eralons(i,j)=temp2(j);
        end
    end
    eralats=flipud(eralats);
    
    dontshow=eratw<28;eratw(dontshow)=NaN;
    
    data={eralats;eralons;eratw};
    vararginnew={'variable';'wet-bulb temp';'contour';0;...
        'underlaycaxismin';28;'underlaycaxismax';35;'underlayvariable';'wet-bulb temp';...
        'datatounderlay';data;'overlaynow';0;'centeredon';0};
    datatype='ERA-Interim';
    region='middle-east-india';
    h=plotModelData(data,region,vararginnew,datatype);curpart=1;highqualityfiguresetup;
    colormap(colormaps('orangered','more','not'));
    c=colorbar;c.Label.String=sprintf('All-Time Maximum Tw (%cC)',char(176));
    c.Label.FontSize=22; %for regional only
    set(gca,'fontweight','bold','fontname','arial','fontsize',20); %22 for regional, 14 for global
    curpart=2;figname='eraalltimemaxtw_middleeastindia';highqualityfiguresetup;
end


%Counts of ERA gridpts above 27, 29, 31, 33 thresholds
%As validation, for accompaniment of station counts
%Adjustment factors (1.02 and 1.5) for 27 and 29 counts are because they were not completely explicitly calculated, since for 
    %computational reasons I only calculated Tw for T values of >=31 C
    
    %The recognition that the missing 27 and 29 Tw values required T <31
    %C and RH of >86% and >73%, respectively, enables estimation of how
    %many of these there were, using the relative frequency of Tw
    %occurrences with these RHs in the array going into the validationtvsrh27c figure
if counteragridptsabovethreshs==1
    for year=1979:2017
        data=load(strcat('/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/savederatwarrays_globe',num2str(year)));
        thisyeartw=data.thisyeartw;
        sum33cbyyear(year-1978)=sum(sum(sum(thisyeartw>=33)));
        sum31cbyyear(year-1978)=sum(sum(sum(thisyeartw>=31)));
        sum29cbyyear(year-1978)=sum(sum(sum(thisyeartw>=29))).*1.02;
        sum27cbyyear(year-1978)=sum(sum(sum(thisyeartw>=27))).*1.5;
    end
    eragridptcounts=[sum33cbyyear' sum31cbyyear' sum29cbyyear' sum27cbyyear'];
    dlmwrite('eragridptcounts.txt',eragridptcounts,'delimiter','\t','precision',5);
end