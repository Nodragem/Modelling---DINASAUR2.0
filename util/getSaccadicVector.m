function saccadic_vector = getSaccadicVector(firing_rate, weight_output)
% -- DESCRIPTION --
% getSaccadicVector will compute a spatially weighted averaging to return
% a saccade vector from the current activtion on the DNF.
% The weight define the translation DNF space to motor space; that is similar
% to SC space to motor space/visual space in the visuo-oculomotor system.
persistent weight
if isempty(weight)
  weight = weight_output;
end
% we accept nan for the weight, so that the colliculus mays not consider one of its side
saccadic_vector = nansum((firing_rate .* weight), 2)/nansum(firing_rate, 2);
% DONT FORGET THAT YOU NEED TO ADD THE CURRENT FIXATION POSITION
% TO THE SACCADIC VECTOR IN ORDER TO OBTAIN THE LANDING POSITION
end % function end: 'getSaccadicVector'
