%Look at subdaily T, Td, and Tw for a particular stn


%-1. If restarting from scratch, run masterscript
%0. Choose station (s) and day of interest (d)
%1. Recompute data for this stntoplot, using the computedailydata loop of downloadprephadisddata_sciadvpaper
    %(doing indivstn=1, all other options there =0)
%2. Set thisdayyear and thisdaydoy
%3. EITHER set trytodeterminesettingsautomatically==1 OR compare firsthourtoplot and subdailytimes(1:10) to identify the actual
    %desired start hour [adsh] and the actual hourinterval (the most common temporal resolution of the data in this timeslice)
%4. Run this entire script

%Total runtime: 30 sec


%%%%Requires first rerunning the computedailydata loop of downloadprephadisddata_sciadvpaper, 
    %and also the computedailydataaddlvars loop if stn wind dirs are desired%%%%
    
    
%When called from analyzeextremewbt:
    %makefigure=0,standaloneplot=0,trytodetermine=1
%For making figures here:
    %makefigure=1,standaloneplot=1,trytodetermine={user choice}


makefigure=0;
standaloneplot=0;
trytodeterminesettingsautomatically=1;
includestnwind=0;

validtimevec=0;

if standaloneplot==1
    fs=16;
else
    fs=8;
end

exist domainstn;
if ans==0;domainstn=1;end

if includestnwind==1
    exist finalwinddirarray;
    if ans==0
        disp('Need to run computedailydataaddlvars loop of downloadprephadisddata.m');return;
    end
end


%Time series of subdaily T, Td, and Tw at a given station on a given day
clear subdailytimes;clear subdailyt;clear subdailytd;clear subdailytw;
firsthourtoplot=(day-3)*24-23;lasthourtoplot=(day+3)*24;

subdailytimes=time(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailyt=temperature(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailytd=dewpoint(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);
subdailytw=wetbulb(time(:,1)>=firsthourtoplot & time(:,1)<=lasthourtoplot);

if trytodeterminesettingsautomatically==0
    if day==22869
        if s==3526 || s==3521 %Sur, Oman; or Sohar, Oman
            adsh=548763;hourinterval=3;
        elseif s==3510 %Muharraq, Bahrain
            adsh=548761;hourinterval=1;
        end
    elseif day==23570
        if s==6275 || s==6127 || s==6271 %Appleton, WI; Cedar Rapids, IA; or Green Bay, WI
            adsh=565585;hourinterval=1;
        end
    elseif day==24644
        adsh=591363;hourinterval=3;
    elseif day==24690
        adsh=592467;hourinterval=3;
    elseif day==26009
        adsh=624121;hourinterval=3;
    elseif day==26487
        adsh=635593;hourinterval=1;
    elseif day==28516 && s==7308
        adsh=684289;hourinterval=3;
    elseif day==28524 && s==7308
        adsh=684481;hourinterval=3;
    elseif day==28675
        adsh=688105;hourinterval=1;
    elseif day==28693
        adsh=688537;hourinterval=1;
    elseif day==28903
        adsh=693577;hourinterval=3;
    elseif day==28975
        adsh=695307;hourinterval=3;
    elseif day==29035
        if s==3547 %Jacobabad, Pakistan
            adsh=696747;hourinterval=3;
        elseif s==3549 || s==3512 %Nawabshah, Pakistan; or Ras Al Khaimah, UAE
            adsh=696745;hourinterval=1;
        end
    elseif day==29037
        adsh=696795;hourinterval=3;
    elseif day==29337
        if s==6566 %Matlapa, Mexico
            adsh=704007;hourinterval=3;
        elseif s==6574 %Tuxpan, Mexico
            adsh=703995;hourinterval=3;
        elseif s==6555 %Soto la Marina, Mexico
            adsh=704004;hourinterval=3;
        end
    elseif day==30034
        adsh=720721;hourinterval=1;
    elseif day==30270
        adsh=726385;hourinterval=1;
    elseif day==31006
        adsh=744049;hourinterval=1;
    elseif day==31014
        adsh=744241;hourinterval=1;
    else
        disp('Please manually determine adsh and hourinterval for this stn & day');return;
    end
else
    if size(subdailytimes,1)>=1
        adsh=max(firsthourtoplot,subdailytimes(1));
        subdailytimesoffset=subdailytimes(2:end);diffs=subdailytimesoffset-subdailytimes(1:end-1);
        hourinterval=mode(diffs);
    else
        validtimevec=0;
    end
end
%fprintf('This hour interval is %d\n',hourinterval);

if validtimevec==1
    deshour=adsh;numhr=(lasthourtoplot-firsthourtoplot+1)/hourinterval;
    cursubdailytimeindex=1;
    clear subdailytimesadj;clear subdailytadj;clear subdailytdadj;clear subdailytwadj;
    for i=1:numhr
        %disp('line 183');disp(deshour);
        if cursubdailytimeindex<=size(subdailytimes,1)
            %disp(subdailytimes(cursubdailytimeindex));
            if checkifthingsareelementsofvector(subdailytimes(cursubdailytimeindex),deshour)
                subdailytimesadj(i)=subdailytimes(cursubdailytimeindex);
                subdailytadj(i)=subdailyt(cursubdailytimeindex);
                subdailytdadj(i)=subdailytd(cursubdailytimeindex);
                subdailytwadj(i)=subdailytw(cursubdailytimeindex);
                localhourofday(i)=rem(subdailytimes(cursubdailytimeindex)+finalstntzs(s),24);
                utchourofday(i)=rem(subdailytimes(cursubdailytimeindex),24);
                cursubdailytimeindex=cursubdailytimeindex+1;
            else
                subdailytimesadj(i)=NaN;
                subdailytadj(i)=NaN;
                subdailytdadj(i)=NaN;
                subdailytwadj(i)=NaN;
                localhourofday(i)=NaN;
                utchourofday(i)=NaN;
            end
        else
            subdailytimesadj(i)=NaN;
            subdailytadj(i)=NaN;
            subdailytdadj(i)=NaN;
            subdailytwadj(i)=NaN;
            localhourofday(i)=NaN;
            utchourofday(i)=NaN;
        end

        if localhourofday(i)>24;localhourofday(i)=localhourofday(i)-24;end
        if utchourofday(i)>24;utchourofday(i)=utchourofday(i)-24;end
        deshour=deshour+hourinterval;
    end
    invalid=subdailytadj==0;subdailytadj(invalid)=NaN;
    invalid=subdailytdadj==0;subdailytdadj(invalid)=NaN;
    invalid=subdailytwadj==0;subdailytwadj(invalid)=NaN;
end


%Also get stn wind dirs
%Only works if stn hour interval = 1
if includestnwind==1 && validtimevec==1
    stnwinddirs=[finalwinddirarray{s}((day-15341)-3,:)';finalwinddirarray{s}((day-15341)-2,:)';...
        finalwinddirarray{s}((day-15341)-1,:)';...
        finalwinddirarray{s}((day-15341),:)';finalwinddirarray{s}((day-15341)+1,:)';...
        finalwinddirarray{s}((day-15341)+2,:)';finalwinddirarray{s}((day-15341)+3,:)'];
     stnwindspds=[finalwindspdarray{s}((day-15341)-3,:)';finalwindspdarray{s}((day-15341)-2,:)';...
        finalwindspdarray{s}((day-15341)-1,:)';...
        finalwindspdarray{s}((day-15341),:)';finalwindspdarray{s}((day-15341)+1,:)';...
        finalwindspdarray{s}((day-15341)+2,:)';finalwindspdarray{s}((day-15341)+3,:)'];
    for i=1:numhr
        if rem(i/3,1)==0
            stnwinddirs3hourly(i)=stnwinddirs(i);
            stnwindspds3hourly(i)=stnwindspds(i);
        else
            stnwinddirs3hourly(i)=NaN;
            stnwindspds3hourly(i)=NaN;
        end
    end
end


%Make figure
if makefigure==1 && validtimevec==1
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
                subdailywbtadjinterp(newindex)=subdailytwadj(loweroldindex);
            elseif rem((newindex-1),3)==1
                subdailytadjinterp(newindex)=0.67*subdailytadj(loweroldindex)+0.33*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.67*subdailytdadj(loweroldindex)+0.33*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.67*subdailytwadj(loweroldindex)+0.33*subdailytwadj(upperoldindex);
            else
                subdailytadjinterp(newindex)=0.33*subdailytadj(loweroldindex)+0.67*subdailytadj(upperoldindex);
                subdailytdadjinterp(newindex)=0.33*subdailytdadj(loweroldindex)+0.67*subdailytdadj(upperoldindex);
                subdailywbtadjinterp(newindex)=0.33*subdailytwadj(loweroldindex)+0.67*subdailytwadj(upperoldindex);
            end

            %if newindex<10;disp(newindex);disp(loweroldindex);fprintf('\n');end
        end
        subdailytadj=subdailytadjinterp;
        subdailytdadj=subdailytdadjinterp;
        subdailytwadj=subdailywbtadjinterp;
    elseif hourinterval~=1
        disp('Please select a different station, or modify this code in subdailyanalysis');
    end
    if standaloneplot==1
        disp('line 265');
        figure(100);clf;curpart=1;highqualityfiguresetup;
        plot(subdailytadj,'r','linewidth',2);hold on;
        plot(subdailytdadj,'b','linewidth',2);
        plot(subdailytwadj,'color',colors('emerald'),'linewidth',2);
    else
        if domainstn==1
            h=plot(subdailytadj,'r','linewidth',1.5);h.Color=[h.Color 0.3];hold on;
            h=plot(subdailytdadj,'color',colors('moderate dark blue'),'linewidth',1.5);h.Color=[h.Color 0.3];
            plot(subdailytwadj,'k','linewidth',1.5);
        elseif dostn2==1
            plot(subdailytwadj,'k--','linewidth',1.5);
        elseif dostn3==1
            plot(subdailytwadj,'k:','linewidth',1.5);
        end
    end
    
    %Plot winds
    %Vectors are currently scaled assuming a max u or v wind speed
    %component of 20 knots, and this would take up a fractional size equal to double the xspacing
    if includestnwind==1
        result=get(gca,'Position');l=result(1);b=result(2);w=result(3);h=result(4);
        xspacing=w/size(stnwinddirs3hourly,2);
        sf=20; %scaling factor
        for i=1:size(stnwinddirs3hourly,2)
            thiswinddir=stnwinddirs3hourly(i);
            thiswindspd=stnwindspds3hourly(i);
            
            
            if ~isnan(thiswinddir) && ~isnan(thiswindspd)
                [u,v]=uandvfromwinddirandspeed(thiswinddir,thiswindspd);
                uscaled=(u/sf)*xspacing;vscaled=(v/sf)*xspacing;
                
                xleft=l+xspacing*i;
                x=[xleft xleft+uscaled];
                top=b+h;
                if vscaled>=0;y=[top top+vscaled];else;y=[top-vscaled top];end
                annotation('arrow',x,y);
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
        if day==22869
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Northeast');
        elseif day==23570
            legend('T','T_d_','WBT','Location','Southeast');
        else
            legend('Temperature','Dewpoint','Wet-Bulb','Location','Southwest');
        end
    end
    set(gca,'fontsize',fs,'fontweight','bold','fontname','arial');
    if standaloneplot==1
        %title(strcat(['Subdaily Data for ',finalstnnames{s},', for the WBT Extreme of ',ymtext]),...
        %    'fontsize',18,'fontweight','bold','fontname','arial');
        figname=strcat('subdailytimeseriesday',num2str(day));curpart=2;highqualityfiguresetup;
    end
    clear addylabel;
end

