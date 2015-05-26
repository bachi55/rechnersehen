%% install vlfeat
run ('/home/va54tuz/Documents/ss15/rechnersehen-2/exercise/2/vlfeat/toolbox/vl_setup')

%% read images
img1 = imread ('daten/multi7_1/p0.pgm');
img2 = imread ('daten/multi7_1/p5.pgm');

% img1 = imread ('daten/hotel/cmu-long-hotel-010.pgm');
% img2 = imread ('daten/hotel/cmu-long-hotel-020.pgm');

%% get sift-descriptors
[f1,d1] = vl_sift(single (img1));
[f2,d2] = vl_sift(single (img2));

%% find point correspondencies
tic
[idx1, dis1] = knnsearch(d1',d2', 'K', 2);
% only clear decissions (first neighboor is much closer then the second)
% are kept
mask = (dis1(:, 1) < (0.75 * dis1(:, 2))) & (dis1(:, 1) < 150);
% now nearest neighboor is allowed to appear twice
for p = 1:size (idx1, 1)
    if mask(p)
        [idx, dis] = knnsearch (d2', d1(:, idx1(p, 1))', 'K', 2);
        mask(p) = (idx(1) == p) & (dis(1) < (0.75 * dis(2))) & (dis(1) < 150);
    end % if
end % for

kp2 = [round(f2(1, mask))', round(f2(2, mask))'];
kp1 = [round(f1(1, idx1(mask, 1)))', round(f1(2, idx1(mask, 1)))'];
toc
plotCorrespodingPoints(img1, img2, kp1, kp2)

% 
% 
% h1 = vl_plotframe(f) ;
% h2 = vl_plotframe(f) ;
% set(h1,'color','k','linewidth',3) ;
% set(h2,'color','y','linewidth',2) ;
