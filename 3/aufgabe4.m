%% read data
[~, img1, img2] = readDataToWorkspace ( ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img1_points.txt', ... 
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img1_0.jpg', ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img1_1.jpg' ...
    );

if any (size (img1) ~= size (img2))
    error ('Images have to have the same size!');
end % if
[iH, iW, ~] = size (img1);

[iWFused, iHFused] = plotFusedImage (img1, img2);
hold on;

%% check whether the Fundamental Matrix has been already extimated
if ~exist ('par', 'var') || ~exist ('bestFInd', 'var')
    close all;
    error ('Please run script "aufgabe2.m" first.');
end % if

%% start interactive point selection and epipolar plot 
warning ('To stop the interactive input please select a point outside the image region.');
[x, y] = ginput (1);
colors = [1, 1, 0; 0, 1, 1; 1, 0, 0; 0, 1, 0; 1, 1, 1];
while all ([x, y] <= [iWFused, iHFused]) && all ([x, y] >= [1, 1])
    % check the point has been selected in the left or in the right image
    colId = randi (length (colors));
    
    s = scatter (x, y);
    s.MarkerEdgeColor = colors(colId, :);
    
    if x <= iW % left image
        l = par(bestFInd).F * [x - (iW / 2), y - (iH / 2), 1]';

        xSpace = linspace (-(iW / 2), iW / 2, 2 * iW);
        ySpace = -(l(1) * xSpace + l(3)) / l(2);
        xSpace = xSpace + (iW / 2) + iW;
        ySpace = ySpace + (iH / 2);
    else       % right image
        l = par(bestFInd).F' * [x - (iW / 2) - iW, y - (iH / 2), 1]';
        
        xSpace = linspace (-(iW / 2), iW / 2, 2 * iW);
        ySpace = -(l(1) * xSpace + l(3)) / l(2);
        xSpace = xSpace + (iW / 2);
        ySpace = ySpace + (iH / 2);
    end % if
    plot (xSpace, ySpace, 'Color', colors(colId, :))
    
    [x, y] = ginput (1);
end % while

close all;