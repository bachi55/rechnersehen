function [calibPoints, img1, img2] = readDataToWorkspace (calibPointsFilename, img1Filename, img2Filename)
    calibPoints = csvread (calibPointsFilename);
    img1 = imread (img1Filename);
    img2 = imread (img2Filename);
end % function