%Compute ERA-Interim climo

%Calculates 6-hourly climatologies of the desired variable quickly and cleanly, without
    %any of the messiness inherent in using code from a big pre-existing script
    
%Runtime: about 20 min per year
resetall=1;

yeariwf=2007;yeariwl=2007;

curDir='/Volumes/ExternalDriveD/ERA-Interim_6-hourly_data/';
saveDir='/Volumes/ExternalDriveC/Basics_ERA-Interim/';
varnames={'t';'q';'u';'v'};
timefreq='6-hourly';
pLevels=[1000];

%Set up climo arrays
if resetall==1
    for i=1:size(varnames,1)
        for day=1:365
            eval([varnames{i} 'climo1000{day,1}=zeros(361,720);']); %12 AM UTC
            eval([varnames{i} 'climo1000{day,2}=zeros(361,720);']); %6 AM UTC
            eval([varnames{i} 'climo1000{day,3}=zeros(361,720);']); %12 PM UTC
            eval([varnames{i} 'climo1000{day,4}=zeros(361,720);']); %6 PM UTC
        end
    end
end
disp('Finished resetting arrays');

%Do the actual calculation
for year=yeariwf:yeariwl

    fprintf('Computing ERA-Interim climo for year %d\n',year);disp(clock);

    %Read nc files
    tdata=ncread(strcat(curDir,num2str(year),'vars1000mb.nc'),'t');
    tdata=permute(tdata,[2 1 3]);tdata=[tdata(:,361:720,:) tdata(:,1:360,:)];clear tfile;fclose('all');
    qdata=ncread(strcat(curDir,num2str(year),'vars1000mb.nc'),'q');
    qdata=permute(qdata,[2 1 3]);qdata=[qdata(:,361:720,:) qdata(:,1:360,:)];clear qfile;fclose('all');
    udata=ncread(strcat(curDir,num2str(year),'vars1000mb.nc'),'u');
    udata=permute(udata,[2 1 3]);udata=[udata(:,361:720,:) udata(:,1:360,:)];clear ufile;fclose('all');
    vdata=ncread(strcat(curDir,num2str(year),'vars1000mb.nc'),'v');
    vdata=permute(vdata,[2 1 3]);vdata=[vdata(:,361:720,:) vdata(:,1:360,:)];clear vfile;fclose('all');
    disp('Finished reading .nc files');


    for day=1:365
        for i=1:size(varnames,1)
            if strcmp(timefreq,'6-hourly')
                eval([varnames{i} 'climo1000{day,1}=' varnames{i} 'climo1000{day,1}+' varnames{i} ...
                    'data(:,:,day*4-3);']);
                eval([varnames{i} 'climo1000{day,2}=' varnames{i} 'climo1000{day,2}+' varnames{i} ...
                    'data(:,:,day*4-2);']);
                eval([varnames{i} 'climo1000{day,3}=' varnames{i} 'climo1000{day,3}+' varnames{i} ...
                    'data(:,:,day*4-1);']);
                eval([varnames{i} 'climo1000{day,4}=' varnames{i} 'climo1000{day,4}+' varnames{i} ...
                    'data(:,:,day*4);']);
            end
        end
        tclimo1000{day,1}=tclimo1000{day,1}-273.15;tclimo1000{day,2}=tclimo1000{day,2}-273.15;
        tclimo1000{day,3}=tclimo1000{day,3}-273.15;tclimo1000{day,4}=tclimo1000{day,4}-273.15;
    end
    
    if rem(year,10)==0
        fprintf('At a checkpoint, so saving climatological arrays as computed thus far');
        disp(clock);
        %save(strcat(saveDir,'computeerainterimclimo'),'tclimo1000','qclimo1000','uclimo1000','vclimo1000','-v7.3');
    end
end

%Divide to go from sums to averages, and also compute WBT
for day=1:365
    for i=1:size(varnames,1)
        for j=1:4
            eval([varnames{i} 'climo1000{day,j}=' varnames{i} 'climo1000{day,j}./(yeariwl-yeariwf+1);']);
        end
    end
    for j=1:4;wbtclimo1000{day,j}=calcwbtfromTandshum(tclimo1000{day,j},qclimo1000{day,j},1);end
end
disp('Finished dividing and computing WBT');
%save(strcat(saveDir,'computeerainterimclimo'),'tclimo1000','qclimo1000','uclimo1000','vclimo1000','-v7.3');
save(strcat(curDir,'wbt1000mb',num2str(year),'.mat'),'wbtclimo1000','-v7.3');


%Use height of surface to compute climatologies that are at ground level (i.e. taking into account the terrain)
dothis=0;
if dothis==1
    for day=1:365
        for k=1:4
            temp1000=eval([varnames{k} 'climo1000{day};']);
            temp850=eval([varnames{k} 'climo850{day};']);
            temp700=eval([varnames{k} 'climo700{day};']);
            temp500=eval([varnames{k} 'climo500{day};']);
            tempinterp=NaN.*ones(144,73);
            for i=1:144
                for j=1:73
                    if lsmask(i,j)==1 %land only
                        if presofsfc(i,j)==1000
                            tempinterp(i,j)=temp1000(i,j);
                        elseif presofsfc(i,j)>850
                            wgt1000=(presofsfc(i,j)-850)./(1000-850);
                            wgt850=(1000-presofsfc(i,j))./(1000-850);
                            tempinterp(i,j)=wgt1000.*temp1000(i,j)+wgt850.*temp850(i,j);
                        elseif presofsfc(i,j)==850
                            tempinterp(i,j)=temp850(i,j);
                        elseif presofsfc(i,j)>700
                            wgt850=(presofsfc(i,j)-700)./(850-700);
                            wgt700=(850-presofsfc(i,j))./(850-700);
                            tempinterp(i,j)=wgt850.*temp850(i,j)+wgt700.*temp700(i,j);
                        elseif presofsfc(i,j)==700
                            tempinterp(i,j)=temp700(i,j);
                        else
                            wgt700=(presofsfc(i,j)-500)./(700-500);
                            wgt500=(700-presofsfc(i,j))./(700-500);
                            tempinterp(i,j)=wgt700.*temp700(i,j)+wgt500.*temp500(i,j);
                        end
                    end
                end
            end
        end
        wbtclimoterrainsfc{day}=calcwbtfromTandshum(tclimoterrainsfc{day},shumclimoterrainsfc{day},1);
    end
end