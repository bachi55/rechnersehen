function [iWFused, iHFused] = plotCorrespodingPoints (img1, img2, kp1, kp2)
    if (any (size (img1) ~= size (img2)))
        error ('Images should have the same size.')
    end % if

    [iH, iW, iD] = size (img1);
    fusedImage = zeros (iH, 2 * iW, iD, 'uint8');
    fusedImage (1:iH, 1:iW, :)         = img1;
    fusedImage (1:iH, (iW + 1):end, :) = img2;
    
    imshow (fusedImage); title ('Point correspondencies');
    
    
    if (nargin > 3)
        hold on;
        
        if (any (size (kp1) ~= size (kp2)))
            error ('List of points should have same length and dimension');
        end % if
        
        labels = cellstr (num2str ([1:size(kp1, 1)]'));
        
        % left image
        plot (kp1(:, 1), kp1(:, 2), 'w.');
        text (kp1(:, 1), kp1(:, 2), labels, 'Color', 'white', ...
            'VerticalAlignment','bottom', 'HorizontalAlignment','center');
        
        % right image
        plot (kp2(:, 1) + iW, kp2(:, 2), 'w.');
        text (kp2(:, 1) + iW, kp2(:, 2), labels, 'Color', 'white', ...
             'VerticalAlignment','bottom', 'HorizontalAlignment','center');
%         
%         line ( ...
%             [kp1(:, 1)'; (kp2(:, 1) + iW)'], ...
%             [kp1(:, 2)'; kp2(:, 2)'], ...
%             'Color', 'green' ...
%         );
        hold off;
    end % if 
    
    [iHFused, iWFused, ~] = size (fusedImage);
end % function