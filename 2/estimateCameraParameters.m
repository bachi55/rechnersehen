function [R, t, k, f] = estimateCameraParameters (calibPoints)
    %% Build up calibration point matrix and check its rank
    A = [(repmat ( calibPoints(:, 3), [1, 2]) .* calibPoints(:, 1:2)),  calibPoints(:, 3) ...
         (repmat (-calibPoints(:, 4), [1, 2]) .* calibPoints(:, 1:2)), -calibPoints(:, 4)];
%     [m, n] = size (A);
%     if rank (A, rankTol) > (n - 1)
%         warning ('Matrix A has full rank.');
%     elseif rank (A, rankTol) < (n - 1)
%         warning ('Matrix A has a rank smaller then (n-1).');
%     end %if

    %% 1) determine r1, r2, t_x, t_y and the scaling factor k 
    [~, ~, V] = svd (A);
    x = V(:, 6);

    % r11, r12, r21, r22, t_x and t_y
    r11 = x(4); r12 = x(5); tx = x(6);
    r21 = x(1); r22 = x(2); ty = x(3);

    % calculate the scaling factor k
    b = -(r11^2 + r12^2 + r21^2 + r22^2);
    c = (r11 * r22 - r12 * r21)^2;
    kq = (-b + sqrt (b^2 - 4 * c)) / 2;
    k = sqrt (kq);

    % calculate r13 and r23
    r13 = sqrt (kq - r11^2 - r12^2);
    r23 = sqrt (kq - r21^2 - r22^2);

    % put together r1 and r2
    R = zeros (3, 3) * NaN;
    R(1, :) = [r11, r12, r13] / k; 
    R(2, :) = [r21, r22, r23] / k;
    if ((norm (R(1, :)) ~= 1) || (norm (R(2, :)) ~= 1))
        warning ('The norm of r1 and r2 should be 1'); 
        R = NaN; t = NaN; f = NaN; k = NaN;
        return;
    else
        warning ('good');
    end % if
    
    % check the sign of r23
    if sign (R(2, 3)) ~= -sign((R(1, 1) * R(2, 1) + R(1, 2) * R(2, 2)) / R(1, 3));
        R(2, 3) = -R(2, 3);
    end % if
%     signum = -sign((R(1, 1) * R(2, 1) + R(1, 2) * R(2, 2)) / R(1, 3));
%     if signum < 0
%         R(2, 3) = abs (R(2, 3));
%     else 
%         R(2, 3) = -abs (R(2, 3));
%     end % if

    % get r3 as cross-product of r1 and r2
    R(3, :) = cross (R(1, :), R(2, :));
%     R(3, :) = R(3, :) / k; 
    if norm(R(3, :)) ~= 1 
%         error ('bla');
        R(3, :) = R(3, :) ./ norm(R(3, :)); 
    end % if
    
    t = [tx, ty, NaN]' / k;
    
    R
    
    %% 2) Determine the remaining parameters f and t_z
    [f, t(3)] = determineRemainingParameters (calibPoints, R, t, k);
    
    
    f
    t
    %% 3) check whether f is negativ
    if f < 0
        R(1, 3) = -R(1, 3);
        R(2, 3) = -R(2, 3);

        % get r3 as cross-product of r1 and r2
        R(3, :) = cross (R(1, :), R(2, :));
        if norm(R(3, :)) ~= 1 ; R(3, :) = R(3, :) ./ norm(R(3, :)); end % if
    
        [f, t(3)] = determineRemainingParameters (calibPoints, R, t, k);
    end % if
end % function 

function [f, tz] = determineRemainingParameters (calibPoints, R, t, k)
    [m, ~] = size (calibPoints);

    B = [calibPoints(:, 4) ...
         -sum(calibPoints(:, 1:2) .* repmat (R(2, 1:2), [m, 1]), 2) - repmat(t(2), [m, 1])];
     B
    c = -calibPoints(:, 4) .* repmat (R(3, 1), [m ,1]) .* calibPoints(:, 1) ...
        - calibPoints(:, 4) .* repmat (R(3, 2), [m ,1]) .* calibPoints(:, 2);
    c
    
    % get f and t_z using the formula: x = (B' * B)^(-1) * B'c
%     x = inv(B' * B) * B' * c;
%     
%     tz = x(1) / k;
%     f = x(2) / k;
    
    % fprintf (1, 'using invers:\ntz = %f\nf = %f\n', t(3), f);

    % uget f and t_z using the formula: x = (B' * B)^(+) *B'c
    x = pinv(B' * B) * B' * c;

    tz = x(1);
    f = x(2);
end % function