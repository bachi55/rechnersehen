% clear all;
p = struct ('R', [-0.226322,  0.972695,   0.051411;   ...
                   0.683302,  0.196159,  -0.703292;   ...
                  -0.694174, -0.124042,  -0.709039],  ... 
            't', [ 7.115603,  0.824146 , 46.850660]', ...
            'f', 1.684674);

%% read data
% filename = '/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/2/daten/input0/points.txt';
calibPoints = csvread ('/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/2/daten/input0/points.txt');
m = size (calibPoints, 1);

calibImg = imread ('/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/2/daten/input0/input.ppm');
imshow (calibImg);
[iH, iW, ~] = size (calibImg);

%% prepare calibration point-coordinates
o_x = round (iW / 2);
o_y = round (iH / 2);
calibPointsNorm = calibPoints;
calibPointsNorm(:, 3:4) = calibPointsNorm(:, 3:4) - repmat ([o_x, o_y], [m, 1]); % shift center to (o_x, o_y)

% scale image-coordinates to [-1, 1]
% calibPointsNorm = calibPoints;
% calibPointsNorm(:, 3:4) = calibPointsNorm(:, 3:4) ./ repmat ([o_x, o_y], [m, 1]);

[m, ~] = size (calibPointsNorm);

%% plot Picture / Image coordinates
hold on;
% given calibration points
s = scatter (calibPoints(:, 3), calibPoints(:, 4), '*');
s.MarkerEdgeColor = 'y';
s.MarkerFaceColor = 'y';

% projected World coordinates according to the given parameters
Pw = [calibPointsNorm(:, 1:2), ones(49, 1)]; % World 

Pc      = (p.R * ([calibPoints(:, 1:2), ones(m, 1)])' + repmat(p.t, [1, m]))'; 
Pc_cart = Pc(:, 1:2) ./ repmat (Pc(:, 3), [1, 2]);                        
Pp      = Pc_cart * (p.f * 640);
Pp      = Pp + repmat ([o_x, o_y], [m, 1]);

s = scatter (Pp(:, 1), Pp(:, 2), 'o');
s.MarkerEdgeColor = 'r';

%% calibrate camera
[R, t, k, f] = estimateCameraParameters (calibPointsNorm);

nTrails = 100000;
rankTol = 1e-4;
sel = NaN (1, 6);
par = struct('R', NaN, 't', NaN, 'k', NaN, 'f', NaN);
j = 1;
for i = 1:nTrails
    randomOderedPointIndices = randperm (m);
    ind = randomOderedPointIndices (1:6);
    
    A = [(repmat ( calibPointsNorm(ind, 3), [1, 2]) .* calibPointsNorm(ind, 1:2)),  calibPointsNorm(ind, 3) ...
         (repmat (-calibPointsNorm(ind, 4), [1, 2]) .* calibPointsNorm(ind, 1:2)), -calibPointsNorm(ind, 4)];
    [~, n] = size (A);
     
    if rank (A, rankTol) > (n - 1)
%        warning ('Matrix A has full rank.');
    elseif rank (A, rankTol) < (n - 1)
%        warning ('Matrix A has a rank smaller then (n-1).');
    else
        [R, t, k, f] = estimateCameraParameters (calibPointsNorm(ind, :));
        if any (isnan (R))
            continue;
        end % if
            
        sel(j, :) = ind;
        par(j) = struct ('R', R, 't', t, 'k', k, 'f', f);
        j = j + 1;
    end %if
end % for 

%% evaluate estimated parameters
% sel = 1;
% [par(1).R, par(1).t, par(1).k, par(1).f] = estimateCameraParameters (calibPointsNorm);

if  ~any (isnan (sel))
    err = NaN;
    j = 1;
    for i = 1:size (sel, 2)
        R = par(i).R;
        t = par(i).t;
        f = par(i).f;
        
%         fprintf (1, ...
%             'r11 = %f\nr12 = %f\nr13 = %f\nr21 = %f\nr22 = %f\nr23 = %f\nr31 = %f\nr32 = %f\nr33 = %f\ntx = %f\nty = %f\ntz = %f\nf = %f (/ 640)\n', ...
%             R(1, 1), R(1, 2), R(1, 3), ...
%             R(1, 1), R(1, 2), R(1, 3), ...
%             R(1, 1), R(1, 2), R(1, 3), ...
%             t(1), t(2), t(3), ...
%             f / 640);
    
        % forward: World --> Cartesian Picture / Image
        Pc = (par(i).R * ([calibPoints(:, 1:2), ones(m, 1)])' + repmat(par(i).t, [1, m]))'; % World --> Camera
        Pc_cart = Pc(:, 1:2) ./ repmat (Pc(:, 3), [1, 2]);                                  % Camera --> Cartesian Camera 
        Pp = Pc_cart * (par(i).f);                                                          % Cartesian Camera --> Cartesian Picture / Image
        Pp = Pp + repmat ([o_x, o_y], [m, 1]);                                              % shift center (back) to (1, 1)

        err(j) = sum(sum((Pp - calibPoints(:, 3:4)).^2, 2)) / m;
        fprintf (1, 'err_= %f\n', err(i));
        
        j = j + 1;
    end % for
else 
    fprintf (1, 'Could not find an selection of the calibration point, which would produce a valid matrix A.\n');
end % if 

%% find the best selection
[e, ind] = min (err);
Pc = (par(ind).R * ([calibPoints(:, 1:2), ones(m, 1)])' + repmat(par(ind).t, [1, m]))'; % World --> Camera
Pc_cart = Pc(:, 1:2) ./ repmat (Pc(:, 3), [1, 2]);                                      % Camera --> Cartesian Camera 
Pp = Pc_cart * (par(ind).f);                                                            % Cartesian Camera --> Cartesian Picture / Image
Pp = Pp + repmat ([o_x, o_y], [m, 1]);                                                  % shift center (back) to (1, 1)

s = scatter (Pp(:, 1), Pp(:, 2), '.');
s.MarkerEdgeColor = 'g';

legend ('Calibration points', 'Project (World --> Picture) using reference calibration', 'Project (World --> Picture) using estimated calibration');