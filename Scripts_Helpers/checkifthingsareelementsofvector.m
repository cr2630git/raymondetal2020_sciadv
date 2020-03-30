function outputvec = checkifthingsareelementsofvector(inputvec,thingstocheck)
%One by one, checks if thingstocheck are elements of inputvec
%   Returns outputvec, with 1 (0) for each thing that is (isn't) an element of inputvec
%   Designed for matrices oriented such that the search progresses by row
%       (i.e. if they are 1D, they must be column vectors)
%   If 2D, all elements in a row must match for a row to be considered matching


%Turn row vectors into column vectors
if size(thingstocheck,1)==1;thingstocheck=thingstocheck';end
%if size(inputvec,1)==1;inputvec=inputvec';end

%Do the search -- progresses row by row, whether for 1D or 2D searching
for i=1:size(thingstocheck,1)
    %Current thing to check is thingstocheck(i)
    curthingfound=0;
    for j=1:size(inputvec,1)
        if size(inputvec,2)>1 %i.e. searching over the rows of a 2D array
            if isequal(thingstocheck(i,:),inputvec(j,:))
                curthingfound=1;
            end
        else
            if thingstocheck(i)==inputvec(j)
                curthingfound=1;
            end
        end
    end
    outputvec(i)=curthingfound;
end

end

