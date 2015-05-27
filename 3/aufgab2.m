%% read data
% filename = '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/2/daten/input0/points.txt';
calibPoints = csvread ('/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img1_points.txt');
m = size (calibPoints, 1);

% calibImg = imread ('/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/daten/input0/input.ppm');
% imshow (calibImg);
% [iH, iW, ~] = size (calibImg);

%% prepare calibration point-coordinates
% o_x = round (iW / 2);
% o_y = round (iH / 2);
o_x = round (640 / 2);
o_y = round (480 / 2);

calibPointsNorm = calibPoints;
calibPointsNorm = calibPointsNorm  - repmat ([o_x, o_y], [m, 2]); % shift center to (o_x, o_y)
% scale image-coordinates to [-1, 1]
calibPointsNorm = calibPointsNorm ./ repmat ([o_x, o_y], [m, 2]);

[m, ~] = size (calibPointsNorm);

P1 = [calibPointsNorm(:, 1:2), ones(m, 1)];
P2 = [calibPointsNorm(:, 3:4), ones(m, 1)];

A =  [P2(:, 1) .* P1(:, 1), P2(:, 1) .* P1(:, 2), P2(:, 1) .* P1(:, 3), ...
      P2(:, 2) .* P1(:, 1), P2(:, 2) .* P1(:, 2), P2(:, 2) .* P1(:, 3), ...
      P2(:, 3) .* P1(:, 1), P2(:, 3) .* P1(:, 2), P2(:, 3) .* P1(:, 3)];
%% estimate the Fundamental matrix using all the point correspondencies
[U, D, V] = svd (A);
F = reshape (V(:, end)', [3, 3])';

rankTol = 1e-4;
if rank (F, rankTol) > 2
    warning ('Rank of F should be 2');
    
    % force F to have rank 2
    [U, D, V] = svd (F);
    D(:, end) = 0;
    F = U * D * V';
end % if

par = struct ('F', F);
sel = 1;

%% estimate the Fundamental matrix using RANSAC
nTrails = 5000;
rankTol = 1e-4;
sel = NaN (1, 8);
par = struct('F', NaN);
j = 1;
for i = 1:nTrails
    randomOderedPointIndices = randperm (m);
    ind = randomOderedPointIndices (1:8);
    
    A_selection = A(ind, :);
    
    [U, D, V] = svd (A_selection);
    F = reshape (V(:, end)', [3, 3])';
    
    if rank (F, rankTol) > 2
%         warning ('Rank of F should be 2');

        % force F to have rank 2
        [U, D, V] = svd (F);
        D(:, end) = 0;
        F = U * D * V';
    end % if
    
    sel(j, :) = ind;
    par(j) = struct ('F', F);
    j = j + 1;
end % for 

%% 
d = 0;
for i = 1:size (sel, 1)
    P1_selection = P1;
    P1_selection(sel(i, :), :) = [];
    P1_selection(:, 1:2) = P1_selection(:, 1:2) .* repmat ([o_x, o_y], [m - size(sel, 2), 1]);
        
    P2_selection = P2;
    P2_selection(sel(i, :), :) = [];
    P2_selection(:, 1:2) = P2_selection(:, 1:2) .* repmat ([o_x, o_y], [m - size(sel, 2), 1]);
    
    F = par(i).F;
    
    for j = 1:size (P2_selection, 2)
        d(i) = distPointLine (P2_selection(j, :)', F  * P1_selection(j, :)')^2 ...
             + distPointLine (P1_selection(j, :)', F' * P2_selection(j, :)')^2;
    end % for
end % for