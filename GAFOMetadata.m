function GAFOMetadata()

min = 10; % Minimum number of targets
max = 60; % Maximum number of targets
inc = 10; % Increment to increase target number by
repeat = 1; % Number of maps at each target increment
metaData = fopen('metaData_GAFO.txt','w'); %First parameter = metadata file name
fprintf(metaData,'%s %s %s %s\n','No. Targets |',' GAFO Path Dist. |',' GAFO Time |',' Solution File Name');
index = min;
pindex = 0;
delta = min+inc;
ext = '.jpeg'; %Plot extention type

% Create the list of maps. Mapmaker saves the list of created 
% maps to its own file called mapList.txt but in here we need A.
A = Mapmaker(min,max,inc,repeat);

%disp(A);

% Figure out how many maps we'll be making
numMaps = repeat*((max/inc)-((min/inc)-1));

% Loop to retreive and solve maps, saves metadata to file
j = 1;

while j<numMaps+1

    for i = 1:repeat;
        
        % Get the targets for this map
        B = A(pindex+1:index,1:2);
        
        % Create a name for the figure
        svname = sprintf('GAFO_%d_%d',length(B),i);
        
        % Solve for this map & save data to metadata file
        tic;
        [gafo_result] = GAFO(B,svname);
        svname = strcat(svname,ext);
        gafo_time = toc;
        fprintf(metaData,'%d %6.2f %4.4f %s\n',length(B),...
            gafo_result,gafo_time,svname);
        
        % Change indexing for a new loop
        pindex = index+1;
        if i==repeat
          index = index + delta+1;
          delta = delta + inc;
        else
          index = index + delta+1;  
        end
    end
    j=j+1;
end

fclose(metaData);
end 