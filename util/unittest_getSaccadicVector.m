addpath(genpath('/home/c1248317/Bitbucket/Dinasaur/home/c1248317/Bitbucket/Dinasaur'))
fixation_pole = 60;
fixation = mirrorGaussian(fixation_pole, 0, 5, 120)';
target = mirrorGaussian(30, 1, 5, 120)';

field = target + fixation;
weight = (1:120) - 60;
sacc_location = getSaccadicVector(field, weight);

plot(field, 'r')
hold on
plot(weight/60, 'b')
% DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
line([sacc_location, sacc_location]+fixation_pole, [0, 2])
line([fixation_pole, fixation_pole], [0, 2])
ylim([0, 2])
