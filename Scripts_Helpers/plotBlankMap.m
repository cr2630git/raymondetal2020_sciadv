function plotBlankMap(figct,region,varargin,centeredon,shadingcolor,labels)

%varargin is necessary only when plotting a custom region centered on a point
    %it's given in the form [southlat,northlat,westlon,eastlon]

%shadingcolor is typically given as 'ghost white' or 'gray', but can be any
    %color in the colors script
    
%default centeredon longitude is 0, but can also be 180 -- affects only
    %'world' region at the moment
    
%Example usage: plotBlankMap(1,'world',0,0,'ghost white',0);
    
%Runtime: about 1 min for world, proportionately less for individual regions

fg=figure(figct);
exist dontclear;
if ans==1
    if dontclear==1
        disp('line 18');
    else
        clf;
    end
end
fgTitle = '';fgXaxis = '';fgYaxis = '';
%fprintf('Region chosen is: %s\n',region);

if strcmp(region, 'world')
    if centeredon==0
        southlat=-90;northlat=90;westlon=-180;eastlon=180;mapproj='robinson';
    elseif centeredon==180
        southlat=-90;northlat=90;westlon=-360;eastlon=0;mapproj='robinson';
    end
elseif strcmp(region, 'nnh')
    southlat=30;northlat=90;westlon=-180;eastlon=180;mapproj='stereo';
elseif strcmp(region,'nh0to60')
    southlat=0;northlat=60;westlon=-180;eastlon=180;mapproj='stereo';
elseif strcmp(region,'placesivebeen')
    southlat=-40;northlat=70;westlon=-165;eastlon=45;mapproj='mercator';
elseif strcmp(region,'placeswevebeen')
    southlat=-40;northlat=60;westlon=-110;eastlon=40;mapproj='mercator';
elseif strcmp(region,'north-atlantic')
    southlat=25;northlat=75;westlon=-75;eastlon=10;mapproj='lambert';
elseif strcmp(region,'north-america')
    southlat=20;northlat=80;westlon=-170;eastlon=-35;mapproj='lambert';
elseif strcmp(region, 'na-east')
    southlat=25;northlat=55;westlon=-100;eastlon=-50;mapproj='lambert';
elseif strcmp(region,'na-sw')
    %exact boundaries necessary for the subdailyneighboringcombo loop of analyzeextremewbt
    southlat=10;northlat=39;westlon=-125;eastlon=-85;mapproj='mercator';
elseif strcmp(region,'usa-full')
    southlat=15;northlat=75;westlon=-180;eastlon=-60;mapproj='lambert';
elseif strcmp(region,'usaminushawaii-tight')
    southlat=22;northlat=73;westlon=-175;eastlon=-65;mapproj='robinson';
elseif strcmp(region, 'usa-exp')
    southlat=23;northlat=60;westlon=-135;eastlon=-55;mapproj='lambert';
elseif strcmp(region, 'usa')
    southlat=23;northlat=50;westlon=-127;eastlon=-64;mapproj='robinson';
elseif strcmp(region, 'midwestern-usa')
    southlat=35;northlat=50;westlon=-100;eastlon=-80;mapproj='mercator';
elseif strcmp(region, 'greater-eastern-usa')
    southlat=18;northlat=50;westlon=-102;eastlon=-65;mapproj='robinson';
elseif strcmp(region, 'eastern-usa')
    southlat=23;northlat=50;westlon=-100;eastlon=-65;mapproj='robinson'; %should be mercator for some applications, though
elseif strcmp(region,'eastern-usa-minusfl') 
    %exact boundaries necessary for the subdailyneighboringcombo loop of analyzeextremewbt
    southlat=24.8;northlat=50;westlon=-105;eastlon=-65;mapproj='mercator';
elseif strcmp(region, 'northeasternquadrant-usa')
    southlat=35;northlat=50;westlon=-95;eastlon=-65;mapproj='mercator';
elseif strcmp(region,'western-europe')
    southlat=35;northlat=65;westlon=-15;eastlon=20;mapproj='mercator';
elseif strcmp(region,'mainland-europe')
    southlat=33;northlat=72;westlon=-12;eastlon=40;mapproj='lambert';
elseif strcmp(region,'eastern-europe')
    southlat=40;northlat=70;westlon=20;eastlon=60;mapproj='mercator';
elseif strcmp(region,'middle-east-india')
    southlat=5;northlat=45;westlon=30;eastlon=100;mapproj='mercator';
elseif strcmp(region,'middle-east')
    southlat=10;northlat=45;westlon=30;eastlon=80;mapproj='mercator';
elseif strcmp(region,'persian-gulf')
    southlat=20;northlat=32;westlon=43;eastlon=60;mapproj='mercator';
elseif strcmp(region,'south-asia')
    southlat=5;northlat=35;westlon=60;eastlon=95;mapproj='mercator';
elseif strcmp(region,'south-asia-larger')
    southlat=5;northlat=37;westlon=60;eastlon=100;mapproj='mercator';
elseif strcmp(region, 'africa')
    southlat=-30;northlat=30;westlon=-20;eastlon=60;mapproj='lambert';
elseif strcmp(region, 'west-africa')
    southlat=0;northlat=30;westlon=-20;eastlon=40;mapproj='mercator';
elseif strcmp(region,'australia')
    southlat=-45;northlat=-8;westlon=111;eastlon=155;mapproj='mercator';
elseif strcmp(region, 'us-ne')
    southlat=35;northlat=50;westlon=-85;eastlon=-60;mapproj='mercator';
elseif strcmp(region, 'us-ne-small')
    southlat=38;northlat=46;westlon=-80;eastlon=-68;mapproj='mercator';
elseif strcmp(region, 'nyc-area')
    southlat=39;northlat=42;westlon=-76;eastlon=-72;mapproj='mercator';
elseif strcmp(region, 'nyc-area-small')
    southlat=40.2;northlat=41.2;westlon=-74.6;eastlon=-73.3;mapproj='mercator';
elseif strcmp(region, 'centeredonpoint')
    southlat=varargin(1);northlat=varargin(2);westlon=varargin(3);eastlon=varargin(4);mapproj='mercator';
else
    worldmap(region);
    data{1}(:, end+1) = data{1}(:, end) + (data{1}(:, end)-data{1}(:, end-1));
    data{2}(:, end+1) = data{2}(:, end) + (data{2}(:, end)-data{2}(:, end-1));
end

h=axesm(mapproj,'MapLatLimit',[southlat northlat],'MapLonLimit',[westlon eastlon]);
framem on;gridm off;if labels==1;mlabel on;plabel on;else;mlabel off; plabel off;end
axis on;axis off; %this is not crazy -- it somehow gets the frame lines to be all the same width


%Set color to shade the land areas (each US state and all countries in the domain)
co=colors(shadingcolor);
cbc='k'; %countryboundarycolor

%Add borders & coasts
addborders;

%Finish up
%tightmap;

%xlim([-0.5 0.5]);
if strcmp(region,'us-ne') || strcmp(region,'us-ne-small')
    zoom(2.5);
    ylim([0.6 1.0]);
end
%tightmap;
clear dontclear;
    
end
