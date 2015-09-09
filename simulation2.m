%+-------------------------------------------------------+%
%|                 Fuzzy Path Planning                   |%
%|                   Sophia Mitchell                     |%
%+-------------------------------------------------------+%

function [min_dist,min_dist_fuzz] = simulation2()

%close all
%clear all
%clc

%----------------------CONSTANTS----------------------

%layout/structure
WALL_WIDTH = 5;
FIGURE_WIDTH = 600; %pixels
FIGURE_HEIGHT = 600; %pixels
PLOT_W = 100; %width in plot units. this will be main units for program
PLOT_H = 100; %height

%appearance
FIGURE_COLOR = [0, 0, 0]; %program background
AXIS_COLOR = [.9, .7, .4]; %the court
WALL_COLOR = [0, 0, 0]; %format string for drawing walls
TARGET_COLOR = [0, 0, 0]; %the targets
TARGET_CIRCLE_PRE_COLOR = [1, 0, 0]; %The target circle is red until it has been met by the robot.
TARGET_X = [];
TARGET_Y =[];
start_point = [];
XYS = [];
opt_rte = [];
fuzzy_rte = [];
fuzzy_rte_rev = [];

%Prompts the user for the number of targets if none were given in calling
%the function
prompt = {'Enter number of targets:'};
dlg_title = 'Define Targets';
num_lines = 1;
def = {'15'};
target = inputdlg(prompt,dlg_title,num_lines,def);
TARGET_NUM = str2double(target);


make_targets();
min_dist_fuzz_rev = [];
opt_rte_rev = [];
n = length(XYS');
pop_size = 60;
num_iter = 1e4;
show_prog = 1;
show_res = 1;
a = meshgrid(1:n);
dmat = reshape(sqrt(sum((XYS(a,:)-XYS(a',:)).^2,2)),n,n);

radius = 5;

ROVER_COLOR = [.1, .7, 1];
roverPlot = [];
%min_dist = [];
min_dist_fuzz = [];
%gaoff = true; 
fuzzoff = true;
%ScreenSize is a four-element vector: [left, bottom, width, height]:
scrsz = get(0,'ScreenSize');

fig = []; %main program figure
fig = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
            (scrsz(4)-FIGURE_HEIGHT)/2 ...
            FIGURE_WIDTH, FIGURE_HEIGHT]);
fuzz = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
            (scrsz(4)-FIGURE_HEIGHT)/2 ...
            FIGURE_WIDTH, FIGURE_HEIGHT]);
gene = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
             (scrsz(4)-FIGURE_HEIGHT)/2 ...
             FIGURE_WIDTH, FIGURE_HEIGHT]);
doubfuz = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
            (scrsz(4)-FIGURE_HEIGHT)/2 ...
            FIGURE_WIDTH, FIGURE_HEIGHT]);
% both = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
%             (scrsz(4)-FIGURE_HEIGHT)/2 ...
%             FIGURE_WIDTH, FIGURE_HEIGHT]);

%----------------------VARIABLES----------------------

quitGame = false; %guard for main loop. when true, program ends
xstuff = [];
ystuff = [];  
areaX = [];
areaY = [];

%-----------------------SUBROUTINES----------------------

%------------createFigure------------
%sets up main program figure
%plots robot, walls, targets and regions
%called once at start of program
    function createFigure(currentfig) %#ok<*INUSD>
                
        currentfig = figure('Position',[(scrsz(3)-FIGURE_WIDTH)/2 ...
            (scrsz(4)-FIGURE_HEIGHT)/2 ...
            FIGURE_WIDTH, FIGURE_HEIGHT]);
        
        figure(currentfig);
       
        %register keydown and keyup listeners
        set(currentfig,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp);
        
        %figure can't be resized
        set(currentfig, 'Resize', 'off');
        axis([0 PLOT_W 0 PLOT_H]);
        axis manual;
        
        %set color for the court, hide axis ticks.
        set(gca, 'color', AXIS_COLOR, 'YTick', [], 'XTick', []);
        
        %set background color for figure
        set(currentfig, 'color', FIGURE_COLOR);
        hold on;
        
        %plot walls
        topWallXs = [0,0,PLOT_W,PLOT_W];
        topWallYs = [(PLOT_H/2),PLOT_H,PLOT_H,(PLOT_H/2)];
        bottomWallXs = [0,0,PLOT_W,PLOT_W];
        bottomWallYs = [(PLOT_H/2),0,0,(PLOT_H/2)];
        plot(topWallXs, topWallYs, '-', ...
            'LineWidth', WALL_WIDTH, 'Color', WALL_COLOR);
        plot(bottomWallXs, bottomWallYs, '-', ...
            'LineWidth', WALL_WIDTH, 'Color', WALL_COLOR);
        
        %randomly places targets with cirlces around them
        plot(TARGET_X, TARGET_Y, '+', 'Color', TARGET_COLOR);
        long=length(TARGET_X);
        %        index = length(TARGET_X);
        while long>0;
            circle(TARGET_X(long), TARGET_Y(long), radius);
            areaX(long,:) = xstuff; %#ok<*SETNU>
            areaY(long,:) = ystuff;
            %            index(long) = long;
            long = long-1;
        end
        
        %places the rover on the screen
        roverPlot = plot(0,0, '-', 'LineWidth',2);
        set(roverPlot, 'Color', ROVER_COLOR);        
    end

%-----------circle----------------
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
    function circle(x,y,r)
        ang=0:0.01:2*pi;
        xp=r*cos(ang);
        yp=r*sin(ang);
        xstuff = x+xp;
        ystuff = y+yp;
        plot(xstuff,ystuff,'color',TARGET_CIRCLE_PRE_COLOR);
    end

%------------make_targets-------------
%Makes an array of target points
    function make_targets
        XYS = rand(TARGET_NUM,2)*100; %###Change the first number here to change number of targets
        TARGET_X = XYS(:,1);
        TARGET_Y = XYS(:,2);
        start_point = [0,0];
        XYS = [start_point;XYS];
        n = length(XYS');
        pop_size = 60;
        num_iter = 1e4;
        show_prog = 1;
        show_res = 1;
        a = meshgrid(1:n);
        dmat = reshape(sqrt(sum((XYS(a,:)-XYS(a',:)).^2,2)),n,n);
    end

%------------keyDown------------
%listener registered in createFigure
%listens for input
%sets appropriate variables and calls functions
    function keyDown(src,event) %#ok<*INUSL>
        switch event.Key
            case 'r'
                clear all;
                close all;
                clc
                make_targets();
                createFigure(fig);
                newGame;
            case 'c'
                close('all');
            case 'g'
                %Calls the genetic algorithm
%                 [opt_rte,min_dist] = tsp_ga(XYS,dmat,pop_size,num_iter,show_prog,show_res);
%                 close('all');
%                 gaoff = false;
%                 writeOnGA(opt_rte, min_dist, gene, XYS);
                %outputs
                            
            case 'f'
                %Runs the fuzzy system forwards
%                 [fuzzy_rte,min_dist_fuzz] = tsp_fuzz(XYS,radius,opt_rte);
%                 close('all');
%                 fuzzoff = false;
%                 writeOnFuzzy(fuzzy_rte,min_dist_fuzz,fuzz,XYS,1);
%                             
            case 'o'
                %Runs the fuzzy solver in reverse
%                 close('all');
%                 opt_rte_rev = fliplr(opt_rte);
%                 [fuzzy_rte_rev, min_dist_fuzz_rev] = tsp_fuzz(XYS, radius, opt_rte_rev);
%                 writeOnFuzzy(fuzzy_rte,min_dist_fuzz,doubfuz,XYS,1);
%                 writeOnFuzzy(fuzzy_rte_rev,min_dist_fuzz_rev,doubfuz,XYS,2);
            
%             case 'b'
%                 % if both the GA and TSP haven't been run yet, you
%                 % can't map them.
%                 close('all');
%                 if gaoff && fuzzoff
%                     error('Must run GA and FA before plotting!')
%                 else
%                     writeOnGA(opt_rte, min_dist, both, XYS); %#ok<*NODEF>
%                     writeOnFuzzy(fuzzy_rte, min_dist_fuzz, both, XYS,1);
%                 end
            case 'q'
                close('all');
                quitGame = true;
        end
    end


%Inputs are the route and minimum distance for the GA solution,
%as well as the xy coordinate list and the figure you're going to
%draw on. The figure should be the same one as the mars simulation
%figure plot.
    function writeOnGA(rte_opt, min, currentfig, xy)
        createFigure(currentfig);
        route = rte_opt([1:n 1]);
        plot(xy(route, 1), xy(route, 2), 'g.-');
        title(sprintf('Total Distance = %1.4f',min),'Color','w');
    end

%Delets the GA from the current figure and plots on the fuzzy solution
%that includes the areas on the problem.
    function writeOnFuzzy(rte_fuzz, min, currentfig, xy,no)
        createFigure(currentfig);
        plot(rte_fuzz(:,1),rte_fuzz(:,2), 'b.-');
        title(sprintf('Total Distance = %1.4f',min),'Color','w');
        ylabel(no,'Color','w');
    end

%Closes and clears whatever figure is in the input.
    function clearCurrent(currentfig) %#ok<*DEFNU>
        close(currentfig);
    end

%----------------------MAIN SCRIPT----------------------
createFigure(fig);

%calls the genetic algorithm
[opt_rte,min_dist] = tsp_ga(XYS,dmat,pop_size,num_iter,show_prog,show_res);
close('all');
writeOnGA(opt_rte, min_dist, gene, XYS);

%runs the fuzzy system 
[fuzzy_rte,min_dist_fuzz] = tsp_fuzz(XYS,radius,opt_rte);
close('all')
fuzzoff = false;
writeOnFuzzy(fuzzy_rte,min_dist_fuzz,fuzz,XYS,1);

end