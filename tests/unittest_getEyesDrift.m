% test and showcase the function getEyesDrift.m
clearvars;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
NN = 100;
fixation = 50;
gaze = 50;
steps = 1000;
record_gaze = zeros([1000, 1]);
record_map = zeros([1000, 100]);

for i=1:steps;
  [map, gaze] = getEyesDrift(gaze, NN, fixation);
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
    plot(record_gaze(i, :), record_map(i, record_gaze(i, :)), 'ro' )
    hold off
    drawnow;
    writeVideo(vidObj, getframe(gca));
end
close(gcf)
%# save as AVI file, and open it using system video player
close(vidObj);
open('self_avoiding_random_walk_1D.avi')
disp('Done!')
