%% read data
[calibPoints, img1, img2] = readDataToWorkspace ( ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_points.txt', ... 
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_0.jpg', ...
    '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/3/data/img2_1.jpg' ...
    );

if any (size (img1) ~= size (img2))
    error ('Images have to have the same size!');
end % if
[iH, iW, ~] = size (img1);

m = size (calibPoints, 1);

%% prepare calibration point-coordinates
o_x = round (iW / 2);
o_y = round (iH / 2);

calibPointsNorm = calibPoints;
calibPointsNorm = calibPointsNorm  - repmat ([o_x, o_y], [m, 2]); % shift center to (o_x, o_y)
calibPointsNorm = calibPointsNorm ./ repmat ([o_x, o_y], [m, 2]); % scale image-coordinates to [-1, 1]

[m, ~] = size (calibPointsNorm);

P1 = [calibPointsNorm(:, 1:2), ones(m, 1)]; % equals x
P2 = [calibPointsNorm(:, 3:4), ones(m, 1)]; % equals x'

A =  [P2(:, 1) .* P1(:, 1), P2(:, 1) .* P1(:, 2), P2(:, 1) .* P1(:, 3), ...
      P2(:, 2) .* P1(:, 1), P2(:, 2) .* P1(:, 2), P2(:, 2) .* P1(:, 3), ...
      P2(:, 3) .* P1(:, 1), P2(:, 3) .* P1(:, 2), P2(:, 3) .* P1(:, 3)];
  
%% estimate the Fundamental matrix using all the point correspondencies
[U, D, V] = svd (A);
F_all = reshape (V(:, end)', [3, 3])';

rankTol = 1e-4;
if rank (F_all, rankTol) > 2
    warning ('Rank of F should be 2');
    
    % force F to have rank 2
    [U, D, V] = svd (F_all);
    D(:, end) = 0;
    F_all = U * D * V';
end % if

[support_all, e_all] = getSupportForFundamentalMatrix (struct ('F', F_all), [], ...
    P1 .* repmat ([o_x, o_y, 1], [m, 1]), ...
    P2 .* repmat ([o_x, o_y, 1], [m, 1]) ...
);

%% estimate the Fundamental matrix using RANSAC
nTrails = 10000;
rankTol = 1e-4;
nTrainExamples = 8;
trainSel = NaN (1, nTrainExamples);
par = struct('F', NaN);
j = 1;
for i = 1:nTrails
    randomOderedPointIndices = randperm (m);
    ind = randomOderedPointIndices (1:nTrainExamples);
    
    A_trainSel = A(ind, :);
    
    [U, D, V] = svd (A_trainSel);
    F = reshape (V(:, end)', [3, 3])';
    
    % force F to have rank 2
    if rank (F, rankTol) > 2
        [U, D, V] = svd (F);
        D(:, end) = 0;
        F = U * D * V';
    end % if
    
    trainSel(j, :) = ind;
    par(j) = struct ('F', F);
    j = j + 1;
end % for 

%% calculate the mean-symmetric distance of a 
[support, e] = getSupportForFundamentalMatrix (par, trainSel, ...
    P1 .* repmat ([o_x, o_y, 1], [m, 1]), ...
    P2 .* repmat ([o_x, o_y, 1], [m, 1]) ...
);

[maxSupport, bestFInd] = max (support);