function [iWFused, iHFused] = plotFusedImage (img1, img2)
    if (any (size (img1) ~= size (img2)))
        error ('Images should have the same size.')
    end % if

    [iH, iW, iD] = size (img1);
    
    fusedImage = zeros (iH, 2 * iW, iD, 'uint8');
    fusedImage (1:iH, 1:iW, :)         = img1;
    fusedImage (1:iH, (iW + 1):end, :) = img2;
    
    imshow (fusedImage); title ('Epipolarlines');
    
    
    
    [iHFused, iWFused, ~] = size (fusedImage);
end % function