function quicklymapsomethingworld(valuestoplot,figc,latstouse,lonstouse,markertype,...
    colorcutoffs,markercolors,markersize,addcolorbar,cbarvarargs,savingdir,figurename)
%Quickly map (using geoshow) a series of points
%   The first three inputs must be identically-sized column vectors
%   'colorcutoffs' must be a column vector
%   'markertype' must be a string 
%   obviously, 'savingdir' and 'figname' must be strings as well
%   cbarvarargs is of the form {'cblabeltext';'This is my label';'cblabelfontsize';16}

%A good example of usage can be found in the docentroidplot loop of exploratorydataanalysis

plotBlankMap(figc,'world',0,0,'ghost white',0);curpart=1;highqualityfiguresetup;

if size(valuestoplot,1)==1
    valuestoplot=valuestoplot'; %make a column vector
end

if size(markersize,1)>1 || size(markersize,2)>1 %a vector, not just a number
    markersizeasvec=1;
else
    markersizeasvec=0;
end

colorcutoffs=sort(colorcutoffs,'ascend');


numvals=size(valuestoplot,1);
numcolors=size(colorcutoffs,1);
%disp(numvals);disp(numcolors);disp(colorcutoffs(1));

for valtoexamine=1:numvals
    if ~isnan(valuestoplot(valtoexamine))
        %disp('line 33');disp(valuestoplot(valtoexamine));disp(colorcutoffs(1));
        colortocheck=1;colormatchfound=0;
        while colortocheck<=numcolors
            %if i==1;disp(colorcutoffs);disp(markercolors);end
            if valuestoplot(valtoexamine)<colorcutoffs(colortocheck) && colormatchfound==0
                thiscolor=markercolors(colortocheck,:);%disp(colortocheck);
                colormatchfound=1;
                if markersizeasvec==1
                    h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',markertype,...
                        'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize(valtoexamine));
                else
                    h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',markertype,...
                        'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize);
                end
                hold on;
                %fprintf('Using color %d for valtoexamine %d\n',markercolors(colortocheck,3),valtoexamine);
            end
            colortocheck=colortocheck+1;
        end
        if colormatchfound==0
            thiscolor=markercolors(end,:);
            if markersizeasvec==1
                h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',markertype,...
                    'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize(valtoexamine));
            else
                h=geoshow(latstouse(valtoexamine),lonstouse(valtoexamine),'DisplayType','Point','Marker',markertype,...
                    'MarkerFaceColor',thiscolor,'MarkerEdgeColor',thiscolor,'MarkerSize',markersize);
            end
            hold on;
            %fprintf('Using color %d for valtoexamine %d\n',markercolors(end,3),valtoexamine);
        end
    end
    %fprintf('Just finished value %d\n',valtoexamine);
end

%Add colorbar
%3-digit colors in table = colors in markercolors.*255
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
    cbar=cptcbar(gca,'mycol','eastoutside',false);cbar.ax.Visible='off';cbar.p.Visible='off';
    cbar.cb.Visible='on';cbar.cb.Ticks=[ctable(2:end,1)];
    cbar.cb.Label.String=cblabeltext;cbar.cb.Label.FontSize=cblabelfontsize;
    cbar.cb.Label.FontName='Arial';cbar.cb.Label.FontWeight='bold';
    %set(cbar.ax,'FontSize',8,'FontWeight','bold','FontName','Arial');
    delete mycol.cpt;
end

curpart=2;figloc=savingdir;figname=figurename;highqualityfiguresetup;

end
