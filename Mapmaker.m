function [XYS_out] = Mapmaker(min, max, inc, repeat)
%% Returns a text file with target coordinate centers for use with path
% planning mapping. The returned file has 2 columns [X coordinates, Y
% coordinates] and a "-" denotes a break between map coordniates.

%%
% min = minimum number of targets you want
% max = maximum number of targets you want
% inc = increment you want to increase target number when going from min to
% max
% repeat = number of maps at each target number.

%%
XYS_out = [];
spacer = [101,101];
mapData = fopen('mapList.txt','w');
for i = min:inc:max
    k = repeat;
    while (k>0)
        XYS = rand(i,2)*100;
        Xcol = XYS(:,1);
        Ycol = XYS(:,2);
        for n=1:i
            fprintf(mapData,'%6.2f %6.2f\n',Xcol(n), Ycol(n));
            disp(n);
        end
        fprintf(mapData,'%6s %6s\n','-', '-');
        k = k-1;
        XYS_out = [XYS_out;XYS;spacer];
    end
end
fclose(mapData);
end