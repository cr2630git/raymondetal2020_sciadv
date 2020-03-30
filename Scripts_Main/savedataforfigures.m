%Saves data (usually produced in analyzeextremewbt) for various final
%figures in nice text files
savingdir='~/iclouddrive/General_Academics/Research/Extreme_WBT_Meteorology/';

%Figure 1
%Columns are latitude | longitude | all-time max WBT | p99.9 of WBT
%Rows are stations (=7877)
for stn=1:7877;histalltimemaxwbt(stn)=max(finalwbtarraydj(stn,17533:31777,3));end
for stn=1:7877;histpct999wbt(stn)=quantile(finalwbtarraydj(stn,17533:31777,3),0.999);end
bigarr=[finalstnlatlon(:,1) finalstnlatlon(:,2) histalltimemaxwbt' histpct999wbt'];
dlmwrite(strcat(savingdir,'figure1s1data.txt'),bigarr);


%Figure 2
%Columns are num35coccurrencesbyyear | num33coccurrencesbyyear |
    %num31coccurrencesbyyear | num29coccurrencesbyyear | num27coccurrencesbyyear
%Rows are years, 1979-2017
bigarr=[num35coccurrencesbyyear' num33coccurrencesbyyear' num31coccurrencesbyyear' num29coccurrencesbyyear' num27coccurrencesbyyear'];
dlmwrite(strcat(savingdir,'figure2data.txt'),bigarr);


%Figure 3, top panel
%Columns are T_early | T_late | Dewpt_early | Dewpt_late
%Rows are pentads
bigarr=[assoctbypentadallstnsearly assoctbypentadallstnslate assoctdbypentadallstnsearly assoctdbypentadallstnslate];
dlmwrite(strcat(savingdir,'figure3toppaneldata.txt'),bigarr);


%Figure 3, bottom panel
%Columns are Climo_number_occurrences_early | Climo_number_occurrences_late
%Rows are pentads
%Note that estavgmonsoonstartpentadearlyhalf=32, and that estavgmonsoonstartpentadlatehalf=38
bigarr=[pentad31callstnsearly pentad31callstnslate];
dlmwrite(strcat(savingdir,'figure3bottompaneldata.txt'),bigarr);