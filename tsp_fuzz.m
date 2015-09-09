function varargout = tsp_fuzz(XY,RADIUS,GA_ROUTE)

%Performs the type two fuzzy analysis
%Returns an array of points
%These points correspond to the shortest fuzzy path through

%ASSUMPTION: The areas are circles.

% Inputs:
%     XY (float) is an Nx2 matrix of target location centers, where N is the number of cities
%     RADIUS (scalar integer) integer value of the radius of all target areas  
%     GA_ROUTE (integer array) best route found by the GA
%     
% Outputs:
%     OPT_RTE (integer array) is the best route found by the algorithm
%     MIN_DIST (scalar float) is the cost of the best route
    
navigate = readfis('nav');
current = [];

fuzz_rte = [];

%loop that figures out the path using the GA order
b = 1;
index = length(fuzz_rte);
while b <= length(GA_ROUTE)
    
    GA_ROUTE(b);
    
    %Find the next two targets after this one
    %The if else statements take care of figuring out what to do when you
    %get to the end of the array.
    current(1) = XY(GA_ROUTE(b),1);
    current(2) = XY(GA_ROUTE(b),2);
    
    if b == (length(GA_ROUTE)-1)
    temp1(1) = XY(GA_ROUTE(b+1),1);
    temp1(2) = XY(GA_ROUTE(b+1),2);
    temp2(1) = XY(GA_ROUTE(1),1);
    temp2(2) = XY(GA_ROUTE(1),2);
    
    elseif b == (length(GA_ROUTE))
    temp1(1) = XY(GA_ROUTE(1),1);
    temp1(2) = XY(GA_ROUTE(1),2); 
    temp2(1) = XY(GA_ROUTE(2),1);
    temp2(2) = XY(GA_ROUTE(2),2);
    
    else
        
    temp1(1) = XY(GA_ROUTE(b+1),1);
    temp1(2) = XY(GA_ROUTE(b+1),2);
    temp2(1) = XY(GA_ROUTE(b+2),1);
    temp2(2) = XY(GA_ROUTE(b+2),2);
    end
    
        diffx = temp1(1) - current(1);
        diffy = temp1(2) - current(2);
        diffx2 = temp2(1) - temp1(1);
        diffy2 = temp2(2) - temp1(2);
        
        teta = (atan2(diffy, diffx))*(180/pi);
        teta2 = (atan2(diffy2, diffx2))*(180/pi);
        
        if teta < 0
            teta = 360+teta;
        end
        if teta2 < 0
            teta2 = 360+teta2;
        end
                
            point = evalfis([teta;teta2],navigate)+90+teta;
            
            
        fuzz_rte(index+1,1) = temp1(1)+(cosd(point)*RADIUS); %#ok<*AGROW>
        fuzz_rte(index+1,2) = temp1(2)+(sind(point)*RADIUS);
        thetas(index+1) = teta;
    %end
    
    index = index +1;
    b=b+1;
 end

%Searches to find if the route goes out of bounds, if it does, replaces it
%with the nearest in-bound place
co = 1;
while co < length(fuzz_rte)
    %Check in the y direction
    if fuzz_rte(co,1) > 101
        fuzz_rte(co,1) = 98;
    elseif fuzz_rte(co,1)<(-1)
        fuzz_rte(co,1) = 2;
    %Check in the x direction
    elseif fuzz_rte(co,2) > 101
        fuzz_rte(co,2) = 98;
    elseif fuzz_rte(co,2)< (-1)
        fuzz_rte(co,2) = 2;
    end
    co = co+1;
end

% %Searches through and replaces the zero (beginning) point with a zero
% %destination
% ind = 0;
% counter = 1;
% while ind ~= 1 && counter < length(GA_ROUTE)
%     ind = GA_ROUTE(counter);
%     counter = counter + 1;
% end
% if counter-2==0
%     %if GA_ROUTE(counter)==ind
%         fuzz_rte(length(GA_ROUTE),1) = 0;
%         fuzz_rte(length(GA_ROUTE),2) = 0;
%     %end
% else%if GA_ROUTE(counter) == ind
%     fuzz_rte(counter-2,1) = 0;
%     fuzz_rte(counter-2,2) = 0;
% end

%Calculates the total distance of the route
fuzzy_dist = 0;
counting = 1;
while counting < length(fuzz_rte)
    fuzzy_dist = fuzzy_dist + (sqrt((fuzz_rte(counting,1)-fuzz_rte(counting+1,1)).^2+(fuzz_rte(counting,2)-fuzz_rte(counting+1,2)).^2));
    counting = counting +1;
end
fuzzy_dist = fuzzy_dist + (sqrt((fuzz_rte(length(fuzz_rte),1)-fuzz_rte(1,1)).^2+(fuzz_rte(length(fuzz_rte),2)-fuzz_rte(1,2)).^2));

%Adds the beginning point to the end of the route, to make a complete
%circut
fuzz_rte(length(fuzz_rte)+1,1) = fuzz_rte(1,1);
fuzz_rte(length(fuzz_rte),2) = fuzz_rte(1,2);

%output
varargout{1} = fuzz_rte;
varargout{2} = fuzzy_dist;
varargout{3} = thetas;

    function [new] = take_out(OLD_GA_RTE,iter) %#ok<*DEFNU>
        
        new = [];
        inter = 1;
        while inter < iter
            new(inter) = GA_ROUTE(inter);
            inter = inter+1;
        end
        
        while inter < (length(OLD_GA_RTE))
            new(inter) = GA_ROUTE(inter+1);
            inter = inter+1;
        end
        
        
    end

end