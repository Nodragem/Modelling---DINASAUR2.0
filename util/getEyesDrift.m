function [ccenter, s, new_drift_gaze] = getEyesDrift(drift_gaze, nb_nodes, update_drift)
  % -- Description --
  % 1-D Self-avoiding random walk in a quadratic potential (i.e. in a bowl),
  % modified from the original 2D version in Engbert 2011, which we implemented
  % in trySelfAvoidingWalk.m
  % This random walk is used in our model and in the model of Engbert to simu-
  % late the drift of eyes during fixational movement.
  %
  persistent lambda;
  persistent L;
  persistent tau;
  persistent potential_map; % as oriented-object is slow, we need to used persistent variables in function as replacement
  persistent memory_map;
  persistent center;
  if isempty(potential_map) % initialize variable when called for the first time
    center = round(nb_nodes/2);
    lambda = 1;
    L=51;
    tau = 0.5; %0.001;
    space_x = 1:nb_nodes;
    %FIXME: in fact we don't need to simulate with as many nodes as the DNF,
    % we could only simulate the space containing the inhibition bowl
    potential_map = lambda*L*(((space_x-center) / center).^2);
    memory_map = zeros([1, nb_nodes]);
  end

  ccenter = center;
  memory_map = memory_map * (1-tau);
  memory_map(memory_map < 0) = 0;
  s = potential_map + memory_map;
  if update_drift == true
    % px is coded from 0 to 99 (index starting at 1 makes a big
    % mess with modulo), we add + 1 to come back to 1 to 100 index
    px = center + drift_gaze;
    % directions looks at the activity on the left and the right of the current gaze
    directions = [s(mod(px+1, nb_nodes) + 1), s(mod(px-1, nb_nodes) + 1)];
    % direction 1 is left, direction 2 is right
    if directions(1) == directions(2)
        v = directions(1);
        choice = datasample([1,2], 1);
    else
        [v, choice] = min(directions);
    end
    % before to move we applies inhibition of return to the current position:
    memory_map(px + 1) = 1; % FIXME WARNING, in the original m = 1 instead of m += 1
    if choice == 1
        px = mod(px + 1, nb_nodes);
    elseif choice == 2
        px = mod(px - 1, nb_nodes);
    end
    new_drift_gaze = px - center;
  else
    new_drift_gaze = drift_gaze;
  end % update_drift == true


end  % function
