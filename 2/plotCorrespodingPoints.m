function plotCorrespodingPoints (img1, img2, kp1, kp2)
    if (any (size (img1) ~= size (img2)))
        error ('Images should have the same size.')
    end % if

    [iH, iW, iD] = size (img1);
    if (iD ~= 1)
        error ('Only gray-scale images allowed.')
    end % if
    
    fusedImage = zeros (iH, 2 * iW, 'uint8');
    fusedImage (1:iH, 1:iW)         = img1;
    fusedImage (1:iH, (iW + 1):end) = img2;
    
    imshow (fusedImage); title ('Point correspondencies');
    
    if (nargin > 3)
        line ( ...
            [kp1(:, 1)'; (kp2(:, 1) + iW)'], ...
            [kp1(:, 2)'; kp2(:, 2)'], ...
            'Color', 'green' ...
        );
    end % if 
end % function