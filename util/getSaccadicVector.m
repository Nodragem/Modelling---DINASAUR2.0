function [saccadic_vector, with_boost] = getSaccadicVector(firing_rate, weight_output, epicenter_location, epicenter_boost)
% -- DESCRIPTION --
% getSaccadicVector will compute a spatially weighted averaging to return
% a saccade vector from the current activtion on the DNF.
% The weight define the translation DNF space to motor space; that is similar
% to SC space to motor space/visual space in the visuo-oculomotor system.
%
% We added a boost to the zone that triggered the saccade (epicenter), we assume that:
% - the stochastic threshold to trigger a saccade represents the chance to trigger a reaction
% chain in the burst neurons,
% - the zone (epicenter) that reaches the threshold triggers a chain reaction in the burst neurons layer,
% - there is a saccadic burst in the burst neurons layer, centered on that epicenter,
% - there is activity related to all inputs presented until now in the build up neurons layer,
% - the LLBN receives both the activity of the build up and burst neurons,
% - thus there is a global avering other all the SC with the epicenter having more weight than others places
%
% FIXME: we may want to decrease the weight of the contralateral input too.
% NOTE: in Anderson et al 1998, the sigma of burst neurons seems 3-4 times smaller than that of build neurons.
% NOTE: Trappenberg et al 2001 did not use different sigma for burst and build up
% receptive fields

with_boost = firing_rate + gaussian(1:size(firing_rate, 2), ...
                                            epicenter_location, epicenter_boost, 4);

%FIXME we may want to get the sigma from SC recording?
% we accept nan for the weight, so that the colliculus mays not consider one of its side
saccadic_vector = nansum((with_boost .* weight_output), 2)/nansum(with_boost, 2);
% DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
% TO THE SACCADIC VECTOR IN ORDER TO OBTAIN THE LANDING POSITION
end % function end: 'getSaccadicVector'
