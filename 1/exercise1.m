%% Exercise 1
% Rotation

img = imread ('punkte_orig.ppm');
% img = imread ('gitter_orig.ppm');

h = imshow (img);
inputPoints = ginput (2);
close all;

subplot (2, 2, 1);
imshow (img);

[imgHeight, imgWidth, ~] = size (img);
nPixel = imgWidth * imgHeight;

p = inputPoints(1, :);
P = [repmat(p', [1, nPixel]);
     zeros(3, nPixel)];
q = inputPoints(2, :);

alpha = -(degtorad (90) - atan2 (q(1) - p(1), q(2) - p(2)));

% use matlab's 'imrotate' as reference
tic;
imgRotatedMatlab = imrotate (img, radtodeg (alpha), 'bilinear');
toc;
subplot (2, 2, 2);
imshow (imgRotatedMatlab); title ('rotated matlab + interpolation');

% use own implementation
R = [cos(alpha), -sin(alpha), 0, 0, 0;
     sin(alpha),  cos(alpha), 0, 0, 0;
     0         ,  0         , 1, 0, 0;
     0         ,  0         , 0, 1, 0;
     0         ,  0         , 0, 0, 1];

tic
ySpace = repmat(1:imgHeight, [1, imgWidth]);
xSpace = repmat(1:imgWidth, imgHeight, 1);
xSpace = xSpace(:)';
S = [double(ySpace);
     double(xSpace); 
     double(reshape(img(:, :, 1), [1, nPixel]));
     double(reshape(img(:, :, 2), [1, nPixel])); 
     double(reshape(img(:, :, 3), [1, nPixel]))];
S = double (S);

SRotated = R * (S - P) + P;
toc;

tic;
SRotatedRange = range (SRotated, 2);
imgRotatedWidth  = ceil (SRotatedRange(2)) + 1;
imgRotatedHeight = ceil (SRotatedRange(1)) + 1;
imgRotated = zeros (imgRotatedHeight, imgRotatedWidth, 3);
nPixelRotated = imgRotatedWidth * imgRotatedHeight;

yCoordRotShifted = SRotated(1, :) - min (SRotated(1, :)) + 1;
xCoordRotShifted = SRotated(2, :) - min (SRotated(2, :)) + 1;

yCoordRotShiftedFloored = floor (yCoordRotShifted);
xCoordRotShiftedFloored = floor (xCoordRotShifted);

yErrorFloor = yCoordRotShifted - yCoordRotShiftedFloored;
yErrorCeil  = 1 - yErrorFloor;
xErrorFloor = xCoordRotShifted - xCoordRotShiftedFloored;
xErrorCeil  = 1 - xErrorFloor;

r = ones (1, length (yCoordRotShifted));
g = r + 1;
b = g + 1;
toc;

% no interpolation
tic;
indRed   = sub2ind (size (imgRotated), round (yCoordRotShifted), round (xCoordRotShifted), r);
indGreen = sub2ind (size (imgRotated), round (yCoordRotShifted), round (xCoordRotShifted), g);
indBlue  = sub2ind (size (imgRotated), round (yCoordRotShifted), round (xCoordRotShifted), b);

imgRotated(indRed) = SRotated(3, :);
imgRotated(indGreen) =  SRotated(4, :);
imgRotated(indBlue) =  SRotated(5, :);
toc;
subplot (2, 2, 3);
imshow (imgRotated); title ('rotated');

diffImgRotated = double(imgRotated) - ... 
    double(imresize (imgRotatedMatlab, [imgRotatedHeight, imgRotatedWidth]));
sqrt (sum (diffImgRotated(:).^2))

% interpolate
% floor x and y
tic;
indRed   = sub2ind (size (imgRotated), floor (yCoordRotShifted), floor (xCoordRotShifted), r);
indGreen = sub2ind (size (imgRotated), floor (yCoordRotShifted), floor (xCoordRotShifted), g);
indBlue  = sub2ind (size (imgRotated), floor (yCoordRotShifted), floor (xCoordRotShifted), b);

influence = yErrorCeil .* xErrorCeil;

imgRotated(indRed) = imgRotated(indRed) + influence .* SRotated(3, :);
imgRotated(indGreen) =  imgRotated(indGreen) + influence .* SRotated(4, :);
imgRotated(indBlue) =  imgRotated(indBlue) + influence .* SRotated(5, :);

% floor x and ceil y
indRed   = sub2ind (size (imgRotated), ceil (yCoordRotShifted), floor (xCoordRotShifted), r);
indGreen = sub2ind (size (imgRotated), ceil (yCoordRotShifted), floor (xCoordRotShifted), g);
indBlue  = sub2ind (size (imgRotated), ceil (yCoordRotShifted), floor (xCoordRotShifted), b);

influence = yErrorFloor .* xErrorCeil;

imgRotated(indRed) = imgRotated(indRed) + influence .* SRotated(3, :);
imgRotated(indGreen) =  imgRotated(indGreen) + influence .* SRotated(4, :);
imgRotated(indBlue) =  imgRotated(indBlue) + influence .* SRotated(5, :);

% ceil x and floor y
indRed   = sub2ind (size (imgRotated), floor (yCoordRotShifted), ceil (xCoordRotShifted), r);
indGreen = sub2ind (size (imgRotated), floor (yCoordRotShifted), ceil (xCoordRotShifted), g);
indBlue  = sub2ind (size (imgRotated), floor (yCoordRotShifted), ceil (xCoordRotShifted), b);

influence = yErrorCeil .* xErrorFloor;

imgRotated(indRed) = imgRotated(indRed) + influence .* SRotated(3, :);
imgRotated(indGreen) =  imgRotated(indGreen) + influence .* SRotated(4, :);
imgRotated(indBlue) =  imgRotated(indBlue) + influence .* SRotated(5, :);

% ceil x and y
indRed   = sub2ind (size (imgRotated), ceil (yCoordRotShifted), ceil (xCoordRotShifted), r);
indGreen = sub2ind (size (imgRotated), ceil (yCoordRotShifted), ceil (xCoordRotShifted), g);
indBlue  = sub2ind (size (imgRotated), ceil (yCoordRotShifted), ceil (xCoordRotShifted), b);

influence = yErrorFloor .* xErrorFloor;

imgRotated(indRed) = imgRotated(indRed) + influence .* SRotated(3, :);
imgRotated(indGreen) =  imgRotated(indGreen) + influence .* SRotated(4, :);
imgRotated(indBlue) =  imgRotated(indBlue) + influence .* SRotated(5, :);

toc

subplot (2, 2, 4)
imshow (imgRotated); title ('rotated + interpolation');

diffImgRotated = double(imgRotated) - ... 
    double(imresize (imgRotatedMatlab, [imgRotatedHeight, imgRotatedWidth]));
sqrt (sum (diffImgRotated(:).^2))

% difference images

