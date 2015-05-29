%% read data
[~, img1, img2] = readDataToWorkspace ( ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_points.txt', ... 
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_0.jpg', ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_1.jpg' ...
    );

if any (size (img1) ~= size (img2))
    error ('Images have to have the same size!');
end % if
[iH, iW, ~] = size (img1);

[iWFused, iHFused] = plotCorrespodingPoints (img1, img2, ...
    calibPoints(trainSel(bestFInd, :), 1:2), calibPoints(trainSel(bestFInd, :), 3:4));
hold on;

%% check whether the Fundamental Matrix has been already extimated
if ~exist ('par', 'var') || ~exist ('bestFInd', 'var')
    close all;
    error ('Please run script "aufgabe2.m" first.');
end % if

%% start interactive point selection and epipolar plot 
warning ('To stop the interactive input please select a point outside the image region.');

% plot calculated epipol into left image
[~, ~, V] = svd (par(bestFInd).F);
epipolLeft = V(:, 3) ./ V(3, 3);
epipolLeft = epipolLeft .* [iW / 2, iH / 2, 1]' + [iW / 2, iH / 2, 0]';
plot (epipolLeft(1), epipolLeft(2), 'w*');
text (epipolLeft(1), epipolLeft(2), 'epipol', 'Color', 'white', ...
    'VerticalAlignment','bottom', 'HorizontalAlignment','center');

% plot calculated epipol into right image
[~, ~, V] = svd (par(bestFInd).F');
epipolRight = V(:, 3) ./ V(3, 3);
epipolRight = epipolRight .* [iW / 2, iH / 2, 1]' + [iW / 2 + iW, iH / 2, 0]';
plot (epipolRight(1), epipolRight(2), 'w*');
text (epipolRight(1), epipolRight(2), 'epipol', 'Color', 'white', ...
    'VerticalAlignment','bottom', 'HorizontalAlignment','center');

[x, y] = ginput (1);
colors = [1, 1, 0; 0, 1, 1; 1, 0, 0; 0, 1, 0; 1, 1, 1];
while all ([x, y] <= [iWFused, iHFused]) && all ([x, y] >= [1, 1]) 
    % check whether the point has been selected in the left or in the right image
    colId = randi (length (colors));
    
    s = scatter (x, y);
    s.MarkerEdgeColor = colors(colId, :);
    
    xSpace = linspace (-1, 1, 2 * iW);
    y = (y - (iH / 2)) / (iH / 2);
    
    if x <= iW % left image
        x = (x - (iW / 2)) / (iW / 2);
        l = par(bestFInd).F * [x, y, 1]';
        l = l ./ l(3);

        ySpace = (-l(3) - l(1) * xSpace) / l(2);   
        xSpace = xSpace * (iW / 2) + (iW / 2) + iW;
    else       % right image
        x = (x - (iW / 2) - iW) / (iW / 2);
        l = par(bestFInd).F' * [x, y, 1]';
        l = l ./ l(3);
                
        ySpace = (-l(3) - l(1) * xSpace) / l(2);  
        xSpace = xSpace * (iW / 2) + (iW / 2);    
    end % if
    ySpace = ySpace * (iH / 2) + (iH / 2);
    plot (xSpace, ySpace, 'Color', colors(colId, :))
    
    [x, y] = ginput (1);
end % while

close all;