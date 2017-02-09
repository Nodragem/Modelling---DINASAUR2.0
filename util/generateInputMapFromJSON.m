function [I_map, nsteps] = generateInputMapFromJSON(s, displayed)

  % delta exo and delta endo are the delay between stimulus appearance and exogenous/endogenous signals
  % s is a structure

  time = 1:s.time_step:s.end_simulation;
  nsteps=size(time, 2);

  %% CONNECTIONS OF THE INPUTS WITH THE DNF:
  % make gaussian shapes at the target, distractor and fixation locations.
  % here the parameters of the gaussian (sigma and amplitudes):
  I_conn = zeros([length(s.inputs), s.field_size]);
  I_all = zeros([length(s.inputs), nsteps]);
  for ii = 1:length(s.inputs)
    inp = s.inputs{ii};
    % inputs spatial shape:
    I_conn(ii, :) = mirrorGaussian(inp.location, inp.weight, ...
                                    inp.sigma, s.field_size)';
    % inputs time course:
    I_all(ii, :) = stepFunction(time, inp.w_endo, ...
                                inp.onset + s.delay_endogenous,...
                                inp.onset + inp.duration + s.delay_endogenous)...
                  + expDecrease(time, inp.w_exo, ...
                                inp.onset + s.delay_exogenous,...
                                s.tau_on);
  end

  %% CREATION OF THE INPUT SIGNAL TO THE DNF:
  % the time course of I_fix (col 1) will  be mapped to the connection pattern if fix_conn (row 1), etc...
  I_map = I_conn' * I_all;

  if nargin > 1 and displayed == true
    figure();
    imshow(I_map);
    colormap heat
  end
  % surf(I_conn * I_all, 'EdgeColor','none','LineStyle','none','FaceLighting','phong')

end
