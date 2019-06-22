%Look at subdaily T, Td, and WBT for a particular stn in the vector stns35catleast3xords

%0. Choose station (s) and day of interest (d)
%1. Recompute data for this stntoplot, using the computedailydata loop of downloadprephadisddata
%2. Set thisdayyear and thisdaydoy and run this script
%3. EITHER set trytodeterminesettingsautomatically==1 OR compare firsthourtoplot and subdailytimes(1:10) to identify the actual
    %desired start hour [adsh] and the actual hourinterval (the most common temporal resolution of the data in this timeslice)
%4. Run the entire script

%Total runtime: 30 sec


%%%%Requires first rerunning the computedailydata loop of downloadprephadisddata, 
    %and also the computedailydataaddlvars loop if stn wind dirs are desired%%%%
    
    
%When called from analyzeextremewbt:
    %makefigure=0,standaloneplot=0,trytodetermine=1
%For making figures here:
    %makefigure=1,standaloneplot=1,trytodetermine={user choice}


makefigure=0;
standaloneplot=0;
trytodeterminesettingsautomatically=1;
includestnwinddirs=0;

%exist lasthourtoplot;disp(ans);

if standaloneplot==1
    fs=16;
else
    fs=8;
end

exist domainstn;
if ans==0;domainstn=1;end


i=size(finaltarray,2);foundyet=0;
while i>=1 && foundyet==0
    if finaltarray(s,i,1)==thisdayyear && finaltarray(s,i,2)==thisdaydoy
        daytoplot=i;foundyet=1;
    end
    i=i-1;
end
if DOYtoMonth(thisdaydoy,thisdayyear)==1
    mtext='Jan';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==2
    mtext='Feb';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==3
    mtext='Mar';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==4
    mtext='Apr';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==5
    mtext='May';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==6
    mtext='Jun';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==7
    mtext='Jul';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==8
    mtext='Aug';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==9
    mtext='Sep';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==10
    mtext='Oct';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==11
    mtext='Nov';
elseif DOYtoMonth(thisdaydoy,thisdayyear)==12
    mtext='Dec';
end   
ymtext=strcat([mtext,' ',num2str(thisdayyear)]);

%for stn=1:size(stns35catleast3xords,1)
%    if stns35catleast3xords(stn)==stntoplot
%        ordamong35cstns=stn;
%    end
%end

%Time series of subdaily T, Td, and WBT at a given station  

exist doingnytanalysis;
if ans==1
    disp('Proceeding with NYT analysis');
    %Subdaily data for entire year
    firsthourtoplot=daytoplot*24-23;lasthourtoplot=firsthourtoplot+8759;
    %[a,b]=max(subdailywbt);
    %fprintf('Assoc T for country %s is %d\n',countrylist{kk},subdailyt(b));
    %fprintf('Assoc Td for country %s is %d\n',countrylist{kk},subdailytd(b));
else
    %Get subdaily data from 3 days before to 3 days after
    firsthourtoplot=(daytoplot-3)*24-23;lasthourtoplot=(daytoplot+3)*24;
end

subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailyt=temperature(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailytd=dewpoint(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailywbt=wbt(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);

if trytodeterminesettingsautomatically==0
    if daytoplot==22869
        if s==3526 || s==3521 %Sur, Oman; or Sohar, Oman
            adsh=548763;hourinterval=3;
        elseif s==3510 %Muharraq, Bahrain
            adsh=548761;hourinterval=1;
        end
    elseif daytoplot==23570
        if s==6275 || s==6127 || s==6271 %Appleton, WI; Cedar Rapids, IA; or Green Bay, WI
            adsh=565585;hourinterval=1;
        end
    elseif daytoplot==24644
        adsh=591363;hourinterval=3;
    elseif daytoplot==24690
        adsh=592467;hourinterval=3;
    elseif daytoplot==26009
        adsh=624121;hourinterval=3;
    elseif daytoplot==26487
        adsh=635593;hourinterval=1;
    elseif daytoplot==28516 && s==7308
        adsh=684289;hourinterval=3;
    elseif daytoplot==28524 && s==7308
        adsh=684481;hourinterval=3;
    elseif daytoplot==28675
        adsh=688105;hourinterval=1;
    elseif daytoplot==28693
        adsh=688537;hourinterval=1;
    elseif daytoplot==28903
        adsh=693577;hourinterval=3;
    elseif daytoplot==28975
        adsh=695307;hourinterval=3;
    elseif daytoplot==29035
        if s==3547 %Jacobabad, Pakistan
            adsh=696747;hourinterval=3;
        elseif s==3549 || s==3512 %Nawabshah, Pakistan; or Ras Al Khaimah, UAE
            adsh=696745;hourinterval=1;
        end
    elseif daytoplot==29037
        adsh=696795;hourinterval=3;
    elseif daytoplot==29337
        if s==6566 %Matlapa, Mexico
            adsh=704007;hourinterval=3;
        elseif s==6574 %Tuxpan, Mexico
            adsh=703995;hourinterval=3;
        elseif s==6555 %Soto la Marina, Mexico
            adsh=704004;hourinterval=3;
        end
    elseif daytoplot==30034
        adsh=720721;hourinterval=1;
    elseif daytoplot==30270
        adsh=726385;hourinterval=1;
    elseif daytoplot==31006
        adsh=744049;hourinterval=1;
    elseif daytoplot==31014
        adsh=744241;hourinterval=1;
    else
        disp('Please manually determine adsh and hourinterval for this stn & day');return;
    end
else
    adsh=max(firsthourtoplot,subdailytimes(1));
    subdailytimesoffset=subdailytimes(2:end);diffs=subdailytimesoffset-subdailytimes(1:end-1);
    hourinterval=mode(diffs);
end
fprintf('This hour interval is %d\n',hourinterval);

deshour=adsh;numhr=(lasthourtoplot-firsthourtoplot+1)/hourinterval;
cursubdailytimeindex=1;
clear subdailytimesadj;clear subdailytadj;clear subdailytdadj;clear subdailywbtadj;
for i=1:numhr
    %disp('line 158');disp(deshour);disp(subdailytimes(cursubdailytimeindex));
    if cursubdailytimeindex<=size(subdailytimes,1)
        if checkifthingsareelementsofvector(subdailytimes(cursubdailytimeindex),deshour)
            subdailytimesadj(i)=subdailytimes(cursubdailytimeindex);
            subdailytadj(i)=subdailyt(cursubdailytimeindex);
            subdailytdadj(i)=subdailytd(cursubdailytimeindex);
            subdailywbtadj(i)=subdailywbt(cursubdailytimeindex);
            localhourofday(i)=rem(subdailytimes(cursubdailytimeindex)+finalstntzs(s),24);
            utchourofday(i)=rem(subdailytimes(cursubdailytimeindex),24);
            cursubdailytimeindex=cursubdailytimeindex+1;
        else
            subdailytimesadj(i)=NaN;
            subdailytadj(i)=NaN;
            subdailytdadj(i)=NaN;
            subdailywbtadj(i)=NaN;
            localhourofday(i)=NaN;
            utchourofday(i)=NaN;
        end
    else
        subdailytimesadj(i)=NaN;
        subdailytadj(i)=NaN;
        subdailytdadj(i)=NaN;
        subdailywbtadj(i)=NaN;
        localhourofday(i)=NaN;
        utchourofday(i)=NaN;
    end

    if localhourofday(i)>24;localhourofday(i)=localhourofday(i)-24;end
    if utchourofday(i)>24;utchourofday(i)=utchourofday(i)-24;end
    deshour=deshour+hourinterval;
end
invalid=subdailytadj==0;subdailytadj(invalid)=NaN;
invalid=subdailytdadj==0;subdailytdadj(invalid)=NaN;
invalid=subdailywbtadj==0;subdailywbtadj(invalid)=NaN;


%Also get stn wind dirs
%Basically only works if stn hour interval = 1
if includestnwinddirs==1
    stnwinddirs=[finalwinddirarray{s}((daytoplot-15341)-3,:)';finalwinddirarray{s}((daytoplot-15341)-2,:)';...
        finalwinddirarray{s}((daytoplot-15341)-1,:)';...
        finalwinddirarray{s}((daytoplot-15341),:)';finalwinddirarray{s}((daytoplot-15341)+1,:)';...
        finalwinddirarray{s}((daytoplot-15341)+2,:)';finalwinddirarray{s}((daytoplot-15341)+3,:)'];
    for i=1:numhr
        if rem(i/3,1)==0
            stnwinddirs3hourly(i)=stnwinddirs(i);
        else
            stnwinddirs3hourly(i)=NaN;
        end
    end
end


%Make figure
if makefigure==1

    %Plot T, Td, and Tw, adding linear interpolation as necessary for hour intervals >1
    if hourinterval==3
        clear subdailytadjinterp;clear subdailytdadjinterp;clear subdailywbtadjinterp;
        loweroldindex=0;upperoldindex=1;
        for newindex=1:166
            if rem((newindex-1)/3,1)==0
                loweroldindex=loweroldindex+1;
                upperoldindex=upperoldindex+1;
            end
            
            if rem((newindex-1),3)==0
                subdailytadjinterp(newindex)=subdailytadj(loweroldindex);
                subdailytdadjinterp(newindex)=subdailytdadj(loweroldindex);
                subdailywbtadjinterp(newindex)=subdailywbtadj(loweroldindex);
            elseif rem((newindex-1),3)==1
                subdailytadjinterp(newindex)=0.67*subdailytadj(loweroldindex)+0.33*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.67*subdailytdadj(loweroldindex)+0.33*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.67*subdailywbtadj(loweroldindex)+0.33*subdailywbtadj(upperoldindex);
            else
                subdailytadjinterp(newindex)=0.33*subdailytadj(loweroldindex)+0.67*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.33*subdailytdadj(loweroldindex)+0.67*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.33*subdailywbtadj(loweroldindex)+0.67*subdailywbtadj(upperoldindex);
            end

            %if newindex<10;disp(newindex);disp(loweroldindex);fprintf('\n');end
        end
        subdailytadj=subdailytadjinterp;
        subdailytdadj=subdailytdadjinterp;
        subdailywbtadj=subdailywbtadjinterp;
    elseif hourinterval~=1
        disp('Please select a different station, or modify this code in subdailyanalysis');
    end
    if standaloneplot==1
        figure(100);clf;curpart=1;highqualityfiguresetup;
        plot(subdailytadj,'r','linewidth',2);hold on;
        plot(subdailytdadj,'b','linewidth',2);
        plot(subdailywbtadj,'color',colors('emerald'),'linewidth',2);
    else
        if domainstn==1
            h=plot(subdailytadj,'r','linewidth',1.5);h.Color=[h.Color 0.3];hold on;
            h=plot(subdailytdadj,'color',colors('moderate dark blue'),'linewidth',1.5);h.Color=[h.Color 0.3];
            plot(subdailywbtadj,'k','linewidth',1.5);
        elseif dostn2==1
            plot(subdailywbtadj,'k--','linewidth',1.5);
        elseif dostn3==1
            plot(subdailywbtadj,'k:','linewidth',1.5);
        end
    end
    
    %Plot winds
    if includestnwinddirs==1
        for i=1:size(stnwinddirs3hourly,1)
            if ~isnan(stnwinddirs3hourly(i))
                x=[i i];y=[5 8];
                [xaf,yaf]=ds2nfu(x,y);
                annotation('arrow',xaf,yaf);
            end
        end
    end
    
    %Include ticks and labels
    doysplotted=thisdaydoy-3:thisdaydoy+5;
    for i=1:size(doysplotted,2);thismonthday{i}=DOYtoDate(doysplotted(i),thisdayyear);end
    oldhourmethod=0;
    if oldhourmethod==1 %local
        if localhourofday(1)<10;addzero='0';else;addzero='';end;namehourlabel1=strcat(addzero,num2str(localhourofday(1)));
        if localhourofday(1)>=12;hourlabel2=localhourofday(1)-12;else;hourlabel2=localhourofday(1)+12;end
        if hourlabel2<10;addzero='0';else;addzero='';end;namehourlabel2=strcat(addzero,num2str(hourlabel2));
        hournames={namehourlabel1;namehourlabel2};
        xticks(1:12/hourinterval:numhr);
        if localhourofday(1)<12 %starts in the morning
            xticklabels({strcat([namehourlabel1,' LST ',thismonthday{1}]),...
            strcat([namehourlabel2,' LST ',thismonthday{1}]),strcat([namehourlabel1,' LST ',thismonthday{2}]),...
            strcat([namehourlabel2,' LST ',thismonthday{2}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),strcat([namehourlabel2,' LST ',thismonthday{3}]),...
            strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel2,' LST ',thismonthday{4}]),strcat([namehourlabel1,' LST ',thismonthday{5}]),...
            strcat([namehourlabel2,' LST ',thismonthday{5}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),strcat([namehourlabel2,' LST ',thismonthday{6}]),...
            strcat([namehourlabel1,' LST ',thismonthday{7}]),strcat([namehourlabel2,' LST ',thismonthday{7}])});
        else %starts in the afternoon or evening
            xticklabels({strcat([namehourlabel1,' LST ',thismonthday{1}]),...
            strcat([namehourlabel1,' LST ',thismonthday{2}]),strcat([namehourlabel1,' LST ',thismonthday{2}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),...
            strcat([namehourlabel1,' LST ',thismonthday{3}]),strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel1,' LST ',thismonthday{4}]),...
            strcat([namehourlabel1,' LST ',thismonthday{5}]),strcat([namehourlabel1,' LST ',thismonthday{5}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),...
            strcat([namehourlabel1,' LST ',thismonthday{6}]),strcat([namehourlabel1,' LST ',thismonthday{7}]),...
            strcat([namehourlabel1,' LST ',thismonthday{7}]),strcat([namehourlabel1,' LST ',thismonthday{8}])});
        end
    else %display UTC
        xticks(1:24/hourinterval:size(subdailytadj,2));
        xticklabels({strcat(['00 UTC ',thismonthday{2}]),strcat(['00 UTC ',thismonthday{3}]),strcat(['00 UTC ',thismonthday{4}]),...
            strcat(['00 UTC ',thismonthday{5}]),strcat(['00 UTC ',thismonthday{6}]),strcat(['00 UTC ',thismonthday{7}]),...
            strcat(['00 UTC ',thismonthday{8}]),strcat(['00 UTC ',thismonthday{9}])});
    end
    xtickangle(45);xlim([1 size(subdailytadj,2)]);
    if standaloneplot==1
        ylabel('Value (C)','fontsize',fs,'fontweight','bold','fontname','arial');
    else
        exist addylabel;
        if ans==1
            ylabel('Value (C)','fontsize',fs,'fontweight','bold','fontname','arial');
        end
    end
    if standaloneplot==1
        if daytoplot==22869
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Northeast');
        elseif daytoplot==23570
            legend('T','T_d_','WBT','Location','Southeast');
        else
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Southwest');
        end
    end
    set(gca,'fontsize',fs,'fontweight','bold','fontname','arial');
    if standaloneplot==1
        title(strcat(['Subdaily Data for ',finalstnnames{s},', for the WBT Extreme of ',ymtext]),...
            'fontsize',18,'fontweight','bold','fontname','arial');
        figname=strcat('subdailytimeseriesday',num2str(daytoplot));curpart=2;highqualityfiguresetup;
    end
    clear addylabel;
end

clear doingnytanalysis;