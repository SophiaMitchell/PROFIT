function [line_route, min_dist, FINAL_THETAS] = slo_fuzz(XY,radius,FUZZ_ROUTE,GA_ROUTE)

%Performs the optimization of the fuzzy path
%Returns an array of points and an integer
%These points correspond to the shortest path through the TSP based on a
%straight line optimization of the fuzzy path

%Assumption: The areas are circles

%Inputs:
%     XY(float) is an Nx2 matrix of target location centers, where N is the number of cities
%     RADIUS (scalar integer) integer value of the radius of all target areas  
%     FUZZ_ROUTE (integer array) optimal fuzzy path
%     
% Outputs:
%     line_route (integer array) is the best route found by the below algorithm
%        Nx3 matrix of [X coordinate, Y coordinate, flagged? (boolean)]
%     MIN_DIST (scalar float) is the length of the best route

%ASSUMPTION: going in order, so all points are at the point where the path
%enters each area.

%loop that figures out the path using the GA order
b = 1;
while b <= length(GA_ROUTE)
    realrouteraw(b,1) = XY(GA_ROUTE(b),1);
    realrouteraw(b,2) = XY(GA_ROUTE(b),2);
    b=b+1;
end

%For some reason the real route must be shifted up one (top put at the
%bottom) and the first target has to be copied to the end.

realrouteraw(length(realrouteraw)+1,:) = realrouteraw(1,:);

k = 2;
while k<=length(realrouteraw)
    realrouteraw(k-1,:) = realrouteraw(k,:);
    k=k+1;
end

realrouteraw(length(realrouteraw),:)=realrouteraw(1,:);

% %Search for the position of (0,0) and re-order both lists so that that goes first
% p = 1;
% while p<=length(realrouteraw)
%     if realrouteraw(p,1) == 0 || realrouteraw(p,2) == 0
%         zeropos = p;
%     end
%     p=p+1;
% end
% 
% t = 1;
% v = zeropos;
% r = 1;
% while t<=length(realrouteraw)
%     if v==length(realrouteraw)
%         newfuzz(t,:)=FUZZ_ROUTE(r,:);
%         realroute(t,:)=realrouteraw(r,:);
%         r=r+1;
%     else
%         newfuzz(t,:)=FUZZ_ROUTE(v,:);
%         realroute(t,:)=realrouteraw(v,:);
%         v = v+1;
%     end
%     t = t+1;
% end

realroute=realrouteraw;
newfuzz = FUZZ_ROUTE;
%First point is always the starting point (0,0) so, flag it and leave.
% line_route = [newfuzz(1,1) newfuzz(1,2) 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%I commented out the next section and use the following in it's
%place. I think it works better. God knows why. 

line_route = newfuzz;
for i = 1:size(realroute,1);
    skipcount = 0;
    sumd = 0;
    for j = 1:size(line_route,1);
        if abs(pdist([line_route(j-skipcount,:);realroute(i,:)]))<=radius
            sumd = sumd + 1;
            if sumd > 1
                line_route(j-skipcount,:) = [];
                skipcount = skipcount +1;
            end
        end
    end
end

line_route(:,3)=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Searches through and deletes redundant points to further optimize the
%fuzzy route.
% i = 2;
% while i<=length(newfuzz)
%     last = length(line_route(:,1));
%     ender = length(line_route(:,1))+1;
%     if abs(pdist([newfuzz(i,:);realroute(i-1,:)]))<= radius*2 && abs(pdist([newfuzz(i,:);XY(i,:)]))<= radius*2
%         if line_route(last,3) == 0
%             line_route(last,1) = newfuzz(i,1);
%             line_route(last,2) = newfuzz(i,2);
%             line_route(last,3) = 1;
%         else
%             line_route(ender,1) = newfuzz(i,1);
%             line_route(ender,2) = newfuzz(i,2);
%             line_route(ender,3) = 0;
%         end
%     elseif i~= length(newfuzz)
%         if abs(pdist([newfuzz(i,:);realroute(i+1,:)]))<=radius*2 && abs(pdist([newfuzz(i,:);XY(i,:)]))<= radius*2
%             line_route(ender,1) = newfuzz(i,1);
%             line_route(ender,2) = newfuzz(i,2);
%             line_route(ender,3) = 1;
%         end
%     else
%         line_route(ender,1) = newfuzz(i,1);
%         line_route(ender,2) = newfuzz(i,2);
%         line_route(ender,3) = 1;
%     end
%     i=i+1;
% end
% 
% last = length(line_route(:,1));
% ender = length(line_route(:,1));
% if abs(pdist([newfuzz(1,:);realroute(length(realroute(:,1)),:)]))<= radius*2
%     if line_route(last,3) == 0
%         line_route(last,1) = newfuzz(1,1);
%         line_route(last,2) = newfuzz(1,2);
%         line_route(last,3) = 1;
%     else
%         line_route(ender,1) = newfuzz(1,1);
%         line_route(ender,2) = newfuzz(1,2);
%         line_route(ender,3) = 0;
%     end
% elseif i~= length(newfuzz)
%     if abs(pdist([newfuzz(1,:);realroute(2,:)]))<=radius*2
%         line_route(ender,1) = newfuzz(1,1);
%         line_route(ender,2) = newfuzz(1,2);
%         line_route(ender,3) = 1;
%     end
% else
%     line_route(ender,1) = newfuzz(1,1);
%     line_route(ender,2) = newfuzz(1,2);
%     line_route(ender,3) = 1;
% end
% 
% line_route(:,3)=[1]; <------ note if you use your old code, this line was corrected, prior you were replacing your third row, not column.

%Need the angle of turning between each point AFTER the straight line
%optimization has occured for the Dubin's path code. Ugh. Here we go.
d = 2;
while d<length(line_route)
    A = line_route(d-1,:);
    B = line_route(d,:);
    C = line_route(d+1,:);
    FINAL_THETAS(d-1,:) = atan2(norm(cross(A-B,C-B)),dot(A-B,C-B));
    d=d+1;
end

A = line_route(d-1,:);
B = line_route(d,:);
C = line_route(1,:);
FINAL_THETAS(d-1,:) = atan2(norm(cross(A-B,C-B)),dot(A-B,C-B));

A = line_route(d,:);
B = line_route(1,:);
C = line_route(2,:);
FINAL_THETAS(d,:) = atan2(norm(cross(A-B,C-B)),dot(A-B,C-B));


min_dist = 0;
counting = 1;
while counting < length(line_route)
    min_dist = min_dist + (sqrt((line_route(counting,1)-line_route(counting+1,1)).^2+(line_route(counting,2)-line_route(counting+1,2)).^2));
    counting = counting +1;
end
min_dist = min_dist + (sqrt((line_route(length(line_route),1)-line_route(1,1)).^2+(line_route(length(line_route),2)-line_route(1,2)).^2));

%Adds the beginning point to the end of the route, to make a complete
%circut
line_route(length(line_route)+1,1) = line_route(1,1);
line_route(length(line_route),2) = line_route(1,2);
end

