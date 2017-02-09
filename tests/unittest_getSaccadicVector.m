% test and showcase the function getSaccadicVector.m
% 1) we need to find good parameters for the sigma of the burst neurons
% receptive field
% Trappenberg et al 2001 did not use different sigma for burst and build up
% receptive field
% in Anderson et al 1998, the sigma of burst neurons seems 3-4 times smaller than that of build neurons.
% That is what we used,
% 2) we need to find the good weight of the burst neurons in the saccade
% averaging,
%   - using the averaging with the fixation,
%   we can find this out by looking at hypometric saccades for different eccentricity when
%   Fixation is ON (overlap condition)  or OFF (compared to a Gap condition)
%   - using the averaging with a Distractor, in Free Choice conditions
%

clearvars;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
fixation_pole = 50;
field_size = 200;
model_space = (1:field_size) - fixation_pole;
node_to_mm = 5/field_size; % we do as if there is 5mm of SC
burst_boost = 5;
sigma_x = 14; % build up receptive field
fixation_activity = 1* mirrorGaussian(fixation_pole, 1, sigma_x, field_size)';
LLBN_weight = (1:field_size) - fixation_pole;
tested_positions = 50:10:200;
record_saccade = zeros(size(tested_positions));
record_fr = zeros([field_size, length(tested_positions)]);
record_boost = zeros([field_size, length(tested_positions)]);

for ii=1:length(tested_positions);
  target_pole = tested_positions(1, ii);
  firing_rate = mirrorGaussian(target_pole, 1, sigma_x, field_size)' + ...
                fixation_activity;
  [sacc_location, with_boost] = getSaccadicVector(firing_rate, LLBN_weight, target_pole, burst_boost);
  record_saccade(1, ii) = sacc_location;
  record_fr(:, ii) = firing_rate;
  record_boost(:, ii) = with_boost;
end

%% -------------------------------------------------------
% No transformation; just test the averaging function
% -------------------------------------------------------
figure
title('Average in model space')
hold on
zoom_y = 3;
for ii=1:length(tested_positions);
  % we need to recenter the target position for the figure:
  target_pole = tested_positions(1, ii) - fixation_pole;
  sacc_location = record_saccade(1, ii); %no need to add the fixation_pole
  plot(model_space, zoom_y*record_fr(:, ii) + target_pole, 'r')
  plot(model_space, zoom_y*record_boost(:, ii) + target_pole, 'Color', '[1, 0.5, 0.5]')
  % DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
  % height = zoom_y*record_fr(round(sacc_location) , ii);
  height = 10;
  line([sacc_location, sacc_location], ...
        [target_pole, target_pole + height], 'Color', 'black')
  line([0, 0], ...
        [target_pole, target_pole + height])
  line([target_pole, target_pole], ...
        [target_pole, target_pole + height])
  line([model_space(1), model_space(end)], [target_pole, target_pole], ...
  'Color', '[0.25 0.25 0.25]')
end
hold off

%% -------------------------------------------------------
% Rostro-Caudal and average prior spatial transformation
% -------------------------------------------------------
% HERE: we consider that the average happen in the model space (SC), and
% the result in then projected to the visual/motor space
% HERE: our model is along the rostral-caudal axis,
% so that we are looking at the interation between the activity related to
% the fixation and the target
% Now, let us transform that to visual space landing positions
figure
title('Average prior spatial transformation (Rostro-Caudal)')
hold on
zoom_y = 3;
% (node_index - fixation_pole)*node_to_mm
[phi, tested_positions] = SCtoVisual((tested_positions - fixation_pole)*node_to_mm, 0);
fixation_pole = SCtoVisual(0, 0);
[phi, record_saccade] = SCtoVisual(record_saccade*node_to_mm, 0); % no need to substract the fixation_node here
[phi, visual_space] = SCtoVisual(model_space*node_to_mm, 0);
for ii=1:length(tested_positions);
  target_pole = tested_positions(1, ii);
  sacc_location = record_saccade(1, ii);
  plot(visual_space, zoom_y*record_fr(:, ii) + ii*10, 'r')
  plot(visual_space, zoom_y*record_boost(:, ii) + ii*10, 'Color', '[1, 0.5, 0.5]')
  % DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
  % height = zoom_y*record_fr(round(sacc_location) , ii);
  height = 10;
  line([sacc_location, sacc_location], ...
        [ii*10, ii*10 + height], 'Color', 'black')
  line([fixation_pole, fixation_pole], ...
        [ii*10, ii*10 + height])
  line([target_pole, target_pole], ...
        [ii*10, ii*10 + height])
  line([visual_space(1), visual_space(end)], [ii*10, ii*10], ...
  'Color', '[0.25 0.25 0.25]')
end
hold off

%% -------------------------------------------------------
% Rostro-Caudal and average after spatial transformation
% -------------------------------------------------------
fixation_pole = 50;
field_size = 200;
model_space = (1:field_size) - fixation_pole;
node_to_mm = 5/field_size; % we do as if there is 5mm of SC
burst_boost = 5;
sigma_x = 14; % build up receptive field
fixation_activity = 0* mirrorGaussian(fixation_pole, 1, sigma_x, field_size)';
LLBN_weight = (1:field_size) - fixation_pole;
tested_positions = 50:10:200;
record_saccade = zeros(size(tested_positions));
record_fr = zeros([field_size, length(tested_positions)]);
record_boost = zeros([field_size, length(tested_positions)]);

%FIXME NOTE: for some reasons, it works better like that (with visualToSC,
%instead of SCToVisual)
% NEXT: in fact, we will need to make an interpolator object from the curve
% firingrate+boost and ask the weight for each degrees in the Visual Space
% between 0 to 103 degrees (0:1:103) using the visualToSC function
% function.
[phi, LLBN_weight] = visualToSC(LLBN_weight*node_to_mm, 0);
for ii=1:length(tested_positions);
  target_pole = tested_positions(1, ii);
  firing_rate = mirrorGaussian(target_pole, 1, sigma_x, field_size)' + ...
                fixation_activity;
  [sacc_location, with_boost] = getSaccadicVector(firing_rate, LLBN_weight, target_pole, burst_boost);
  record_saccade(1, ii) = sacc_location;
  record_fr(:, ii) = firing_rate;
  record_boost(:, ii) = with_boost;
end

figure
title('Average after spatial transformation (Rostro-Caudal)')
hold on
zoom_y = 3;
% (node_index - fixation_pole)*node_to_mm
[phi, tested_positions] = SCtoVisual((tested_positions - fixation_pole)*node_to_mm, 0);
fixation_pole = SCtoVisual(0, 0);
[phi, record_saccade] = SCtoVisual(record_saccade*node_to_mm, 0); % no need to substract the fixation_node here
[phi, visual_space] = SCtoVisual(model_space*node_to_mm, 0);
for ii=1:length(tested_positions);
  target_pole = tested_positions(1, ii);
  sacc_location = record_saccade(1, ii);
  plot(visual_space, zoom_y*record_fr(:, ii) + ii*10, 'r')
  plot(visual_space, zoom_y*record_boost(:, ii) + ii*10, 'Color', '[1, 0.5, 0.5]')
  % DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
  % height = zoom_y*record_fr(round(sacc_location) , ii);
  height = 10;
  line([sacc_location, sacc_location], ...
        [ii*10, ii*10 + height], 'Color', 'black')
  line([fixation_pole, fixation_pole], ...
        [ii*10, ii*10 + height])
  line([target_pole, target_pole], ...
        [ii*10, ii*10 + height])
  line([visual_space(1), visual_space(end)], [ii*10, ii*10], ...
  'Color', '[0.25 0.25 0.25]')
end
hold off

%
% figure
% plot(LLBN_weight/60, 'b')
