function [s, new_center_of_gaze] = getEyesDrift(center_of_gaze, nb_nodes, model_fixation_pole)
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
  if isempty(potential_map) % initialize variable when called for the first time
    center = model_fixation_pole;
    lambda = 1;
    L=51;
    tau = 0.01%0.001;
    space_x = 1:nb_nodes;
    %FIXME: in fact we don't need to simulate with as many nodes as the DNF,
    % we could only simulate the space containing the inhibition bowl
    potential_map = lambda*L*(((space_x-center) / center).^2);
    memory_map = zeros([1, nb_nodes]);
  end

  memory_map = memory_map * (1-tau);
  memory_map(memory_map < 0) = 0;
  s = potential_map + memory_map;
  % px is coded from 0 to 99 (index starting at 1 makes a big
  % mess with modulo), we add + 1 to come back to 1 to 100 index
  px = center_of_gaze - 1;
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
  new_center_of_gaze = px + 1;


end  % function
