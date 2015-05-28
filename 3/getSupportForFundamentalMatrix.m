% input: F ... vector of structs ('F', Fundamental-Matrix_i)
function [support, e] = getSupportForFundamentalMatrix (F, trainSel, P1, P2, supportThreshold)
    if nargin < 5
        supportThreshold = 2;
    end % if

    [m, ~] = size (P1);
    nTrails = length (F);
    [~, nTrainExamples] = size (trainSel);

    %% calculate the mean-symmetric distance of a 
    support = zeros (1, nTrails);
    e = zeros (nTrails, m - nTrainExamples);
    for i = 1:nTrails
        P1_testSel = P1;
        P2_testSel = P2;
        
        % throw out the particular training data
        if nTrainExamples > 0 
            P1_testSel(trainSel(i, :), :) = []; 
            P2_testSel(trainSel(i, :), :) = []; 
        end % if

        support(i) = 0;
        for j = 1:(m - nTrainExamples)
            e(i, j) = distPointLine (P2_testSel(j, :)', F(i).F  * P1_testSel(j, :)')^2 ...
                    + distPointLine (P1_testSel(j, :)', F(i).F' * P2_testSel(j, :)')^2;
            if e(i, j) <= supportThreshold
                support(i) = support(i) + 1;
            end
        end % for
    end % for
end % for

%% Function to calculate the (normalized) distance between a point and a line
function d = distPointLine (p, l)
    l = l ./ norm (l(1:2));
    p = p ./ p(3);
    d = p' * l;
end % function