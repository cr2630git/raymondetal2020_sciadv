function quicklymapsomethingregion(regionname,valuestoplot,figc,latstouse,lonstouse,markertype,...
    colorcutoffs,markercolors,markersize,addcolorbar,cbarvarargs,savingdir,figurename)
%Quickly map (using geoshow) a series of points situated in any region
%listed in addborders
%   Some typical regionnames would be 'usa', 'ne-us'
%   The next three inputs must be identically-sized column vectors
%   'markertype' must be a string 
%   obviously, 'savingdir' and 'figname' must be strings as well

plotBlankMap(figc,regionname,0,0,'ghost white',0);curpart=1;highqualityfiguresetup;

if size(valuestoplot,1)==1
    valuestoplot=valuestoplot'; %make a column vector
end

if size(markersize,1)>1 || size(markersize,2)>1 %a vector, not just a number
    markersizeasvec=1;
else
    markersizeasvec=0;
end

if size(markertype,1)>1 || size(markertype,2)>1 %a vector, not just a number
    markertypeasvec=1;
else
    markertypeasvec=0;
end

colorcutoffs=sort(colorcutoffs,'ascend');


numvals=size(valuestoplot,1);
numcolors=size(colorcutoffs,1);

for valtoexamine=1:numvals
    colortocheck=1;colormatchfound=0;
    if markersizeasvec==1;thismsize=markersize(valtoexamine);else;thismsize=markersize;end
    if markertypeasvec==1;thismtype=markertype(valtoexamine);else;thismtype=markertype;end
    %disp('line 37');disp(thismtype);disp(thismsize);
    if ~isnan(valuestoplot(valtoexamine))
        while colortocheck<=numcolors
            %if i==1;disp(colorcutoffs);disp(markercolors);end
            if valuestoplot(valtoexamine)<colorcutoffs(colortocheck) && colormatchfound==0
                thiscolor=markercolors(colortocheck,:);%if colortocheck~=1;disp(colortocheck);disp(valtoexamine);end
                colormatchfound=1;
                %disp(valtoexamine);disp(thismtype);disp(thiscolor);disp(thismsize);
                h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',thismtype,...
                    'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',thismsize);
                hold on;
            end        
            colortocheck=colortocheck+1;
        end
        %Value must fall into the top category
        if colormatchfound==0
            thiscolor=markercolors(end,:);%fprintf('Top category for stn %d\n',valtoexamine);
            h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',thismtype,...
                'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',thismsize);
            hold on;
        end
    else
        h=geoshow(-90,-90,'DisplayType','Point','Marker',thismtype,...
            'MarkerFaceColor','white','MarkerEdgeColor','white','MarkerSize',thismsize);
    end
    
    a=thiscolor;
    if abs(a(1)-0.89804)<0.001 %thiscolor is red, basically
        %fprintf('Color is red for stn %d\n',valtoexamine);
    end
end

%Add colorbar
%3-digit colors in table are from colors in markercolors.*255
if addcolorbar==1
    for count=1:2:length(cbarvarargs)-1
        key=cbarvarargs{count};
        val=cbarvarargs{count+1};
        switch key
            case 'cblabeltext'
                cblabeltext=val;
            case 'cblabelfontsize'
                cblabelfontsize=val;
        end
    end
    
    clear ctable;
    colorcutoffs=sort(colorcutoffs,'ascend');
    cutoffdiff=colorcutoffs(2)-colorcutoffs(1);
    ctable(1,:)=[colorcutoffs(1)-cutoffdiff markercolors(1,:).*255 colorcutoffs(1) markercolors(1,:).*255];
    for row=2:size(markercolors,1)-1
        ctable(row,:)=[colorcutoffs(row-1) markercolors(row,:).*255 colorcutoffs(row) markercolors(row,:).*255];
    end
    lastrow=size(markercolors,1);
    ctable(lastrow,:)=[colorcutoffs(lastrow-1) markercolors(lastrow,:).*255 colorcutoffs(lastrow-1)+cutoffdiff markercolors(lastrow,:).*255];
    save mycol.cpt ctable -ascii;
    cptcmap('mycol','mapping','direct');
    cbar=cptcbar(gca,'mycol','eastoutside',false);cb=cbar.cb;
    set(cbar.ax,'FontSize',10,'FontWeight','bold','FontName','Arial');
    exist cblabeltext;
    if ans==1
        %c=colorbar;
        %c.TickLabels='';
        %c.Label.String=cblabeltext;
        %c.Label.FontSize=cblabelfontsize;
        t=text(1.15,0.3,cblabeltext,'units','normalized');
        %c.Label.FontWeight='bold';
        %c.Label.FontName='arial';
        set(t,'fontweight','bold','fontname','arial','fontsize',cblabelfontsize,'rotation',90);
    end
end

curpart=2;figloc=savingdir;figname=figurename;highqualityfiguresetup;
delete mycol.cpt;
end

