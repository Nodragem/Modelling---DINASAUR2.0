% test and showcase the function escapeProbabilityFunction.m
clearvars;
clear functions;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
space = -1:0.01:0; % REMEMBER: the distance is negative when under threshold
% current parameters:
default_tau = 0.1;
default_beta0 = 10.0; %default is 10
figure

subplot(3,1,1)
title('varying tau and beta0')
hold on
for tau=0.1:0.2:1
  for beta0=1:2:20
    plot(space, escapeProbabilityFunction(space, tau, beta0, 1), 'Color', [0, beta0/20, tau/1])
  end
end

subplot(3,1,2)
title('varying beta0 only')
hold on
tau = default_tau;
 for beta0=1:2:20
    plot(space, escapeProbabilityFunction(space, tau, beta0, 1), 'Color', [0, beta0/20, tau/1])
end
plot(space, escapeProbabilityFunction(space, default_tau, default_beta0, 1), 'r')

subplot(3,1,3)
title('varying tau only')
hold on
beta0 = default_beta0;
for tau=0.1:0.1:1
    plot(space, escapeProbabilityFunction(space, tau, beta0, 1), 'Color', [0, beta0/10, tau/1])
end
plot(space, escapeProbabilityFunction(space, default_tau, default_beta0, 1), 'r')
