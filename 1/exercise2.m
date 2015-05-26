% Exercise 2
% Porjection

% read image
img = imread ('verzerrt.png');
[iHeight, iWidth, ~] = size (img);

% get corresponding points
h = imshow (img);
inputPoints = ginput (4);

q1 = [inputPoints(1, :), 1]';
q2 = [inputPoints(2, :), 1]';
q3 = [inputPoints(3, :), 1]';
q4 = [inputPoints(4, :), 1]';

% points in the original plane
p1 = [0, 0, 1]';
p2 = [1, 0, 1]';
p3 = [1, 1, 1]';
p4 = [0, 1, 1]';

% build up A matrix
A = [-p1', 0, 0, 0, (q1(1) * p1)' ; 0, 0, 0, -p1', (q1(2) * p1)';
     -p2', 0, 0, 0, (q2(1) * p2)' ; 0, 0, 0, -p2', (q2(2) * p2)';
     -p3', 0, 0, 0, (q3(1) * p3)' ; 0, 0, 0, -p3', (q3(2) * p3)';
     -p4', 0, 0, 0, (q4(1) * p4)' ; 0, 0, 0, -p4', (q4(2) * p4)';
    ];

% get basis of the null-space of Ax = 0
NS = null (A);

% get homographie
H = reshape (NS, [3,3])';
Hinv = inv (H);

%% perform projection
% get size of the transformed image
c1 = [0, 0, 1]';
c2 = [iHeight, 1, 1]';
c3 = [iHeight, iWidth, 1]';
c4 = [1, iWidth, 1]';

d1 = Hinv * c1; d1 = d1(1:2) ./ d1(3);
d2 = Hinv * c2; d2 = d2(1:2) ./ d2(3);
d3 = Hinv * c3; d3 = d3(1:2) ./ d3(3);
d4 = Hinv * c4; d4 = d4(1:2) ./ d4(3);

% plot transformed corners of the original image
dHeight = [d1(1), d2(1), d3(1), d4(1)];
dWidth = [d1(2), d2(2), d3(2), d4(2)];
% dHomo = [d1(3), d2(3), d3(3), d4(3)];
% scatter ([d1(1), d2(1), d3(1), d4(1)], [d1(2), d2(2), d3(2), d4(2)]); 

% get s
s = [min(dHeight), min(dWidth), 0];

% calculate size of the output image
% bboxHeight = range (dHeight);
% bboxWidth  = range (dWidth);
bboxHeight = range (dHeight);
bboxWidth = range (dWidth);
% bboxHomo = range (dHomo);



% scale = iWidth / bboxWidth;

ySpace = repmat(linspace (min(dHeight), max(dHeight) + 1,  iHeight * 3), [1, iWidth]);
xSpace = repmat(linspace (min(dWidth), max(dWidth) + 1, iWidth * 3), iHeight, 1);
xSpace = xSpace(:)';
S = [(double(ySpace)); (double(xSpace)); ones(1, length (xSpace))];
Sinhom = S(1:2, :) ./ repmat (S(3, :), [2, 1]);

% transform coordinates of the output image and transform to eucl. coord.
Strans = H * S;
Strans = Strans(1:2, :) ./ repmat (Strans(3, :), [2, 1]);

% write out transformation to the output image
imgResult = zeros (round (range (Strans(1, :))), round (range (Strans(2, :))), 3, 'uint8');
% imgResult = zeros (iHeight, iWidth, 3, 'uint8');
[oHeight, oWidth, ~] = size (imgResult);

scale = 200;

minY = min (S(1, :));
minX = min (S(2, :));

for i = 1:size (Strans, 2)
    q = round (Strans(:, i)) + 1;
    
    if all (q > 0) && all (q <= [iWidth, iHeight]')
        ss = round((S(1:2, i) - [minY, minX]') .* [329.3988 282.8354]') + [1, 1]';
        imgResult(ss(2), ss(1), :) = img(q(2), q(1), :);
    else
        ss = round((S(1:2, i) - [minY, minX]') .* [329.3988 282.8354]') + [1, 1]';
        imgResult(ss(2), ss(1), :) = 255;
    end % if
end % for

% for y = 0:oHeight
%     for x = 0:oWidth
%         ss = [x / oWidth; y / oHeight; 1];
%         q = H * ss;
%         q = round (q(1:2) ./ q(3));
%         imgResult(y + 1, x + 1, :) = img(q(2), q(1), :);
%     end % for
% end % for

figure;
imshow (imgResult)
% 
% indRed   = sub2ind (size (imgResult), round (yCoordRotShifted), round (xCoordRotShifted), r);
% indGreen = sub2ind (size (imgResult), round (yCoordRotShifted), round (xCoordRotShifted), g);
% indBlue  = sub2ind (size (imgResult), round (yCoordRotShifted), round (xCoordRotShifted), b);






