% test and showcase the function getEyesDrift.m
clearvars;
clear getEyesDrift
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
NN = 200;
fixation = 50;
global gaze_drift;
gaze_drift = 50;
steps = 1000;
record_gaze = zeros([1000, 1]);
record_map = zeros([1000, NN]);

for i=1:steps;
  [center, map, gaze] = getEyesDrift(NN, true, false);
  % gaze_drift = 150;
  record_gaze(i, :) = gaze;
  record_map(i, :) = map;
end

% set up figure
figure('visible', 'on'), set(gcf, 'Color','white')
set(gca, 'nextplot','replacechildren', 'Visible','off');

% create AVI object
nFrames = steps;
vidObj = VideoWriter('self_avoiding_random_walk_1D.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 30;
open(vidObj);

for i = 1:steps
    plot(record_map(i, :))
    hold on
    plot(record_gaze(i, :)+center, record_map(i, record_gaze(i, :)+center), 'ro' )
    hold off
    drawnow;
    writeVideo(vidObj, getframe(gca));
end
close(gcf)
%# save as AVI file, and open it using system video player
close(vidObj);
%open('self_avoiding_random_walk_1D.avi')
disp('Done!')
