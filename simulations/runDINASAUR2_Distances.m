clearvars;
%clear functions;
close all;
addpath('/home/c1248317/Bitbucket/Dinasaur/util');
addpath('/home/c1248317/matlab/cosivina');

% Initially the model was made to explain the behavior of human participants
% during an experiment where we present them a target and a distractor.
% the experiment consist of a lot of trials of ~1s. From which we estimate the reaction time distributions.
% Because of that, here, the authors called an iteration a trial (because it correspond a trial of one participant in our experiment )
% and they call a simulation a bunch of N iterations/trials (that would correspond to a session of N trials for one participant).
% [simulation ID, SOA (time distance between target and distractor), nb trials, amplitude of white noise]

record_firing = false;
home_path = '/home/c1248317/Bitbucket/Dinasaur';
project_name = 'distance_test';
mkdir([home_path, '/results'], project_name);
save_to = [home_path, '/results/', project_name];

%% WRITE DOWN WHAT WE ARE GOING TO DO:
d.SOAs = 0:20:60;
d.Distances = [10, 20, 30];
d.fix_loc = 50; % this will be returned to determine the metric centre of the model
d.iterations = 10;
% condition_ID is mandatory, it is used to join condition and event tables
d.keys = {'condition_ID', 'SOAs', 'Distances', 'FixationLoc'};
savejson(save_to, d);
disp('To Simulate:')
disp(d);

%% PARSE YOUR CHANGES to the input details object
% DO WHAT WE WROTE WE WILL DO:
inp = loadjson('input_map.json');
inp.inputs{2}.weight = 0; % remove the distractor
inp.fixation_node = d.fix_loc;
inp.inputs{3}.location = d.fix_loc; % relocate the Fixation
all_event_tables = [];
cond_array = []
condition_ID = 1;
for dd = 1:length(d.Distances) % we run only 1 simulation of 100 iterations/trials here
  for soa = 1:length(d.SOAs)
    condition_ID = condition_ID + 1;
    disp('Current Simulation:  ');
    current_condition = [condition_ID, d.SOAs(soa), d.Distances(dd), d.fix_loc];
    disp(d.keys); disp(current_condition);
    tic
    inp.inputs{1}.locations = d.fix_loc + d.Distances(dd); %% NEXT TODO: FINISH INTEGRATING THE NEW WAY TO RUN THE MODEL
    inp.inputs{1}.onset = inp.inputs{3}.onset + d.SOAs(soa);
    [event_table, rall] = runDinasaur2(inp, condition_ID, d.iterations, record_firing);
    cond_array = [cond_array; repmat(current_condition, [10, 1])];
    all_event_tables = [all_event_tables; event_table];
    disp('time of simulation:')
    toc

    tic
    if record_firing
      firing_recording.input_template = inp;
      firing_recording.conditions = array2table(a_cond(end,:),  'VariableNames', d.keys); % the last row should contain the parameters of the last simulation
      firing_recording.firing_rate = rall;
      % note that we can transform the firing rate to membrane potential with
      % an inverse function.
      save([save_to, '/firing_', num2str(condition_ID), '_distance.mat'], 'firing_recording')
      disp('time saving firing rate data:')
      toc
    end
  end
  all_cond_tables = array2table(cond_array,  'VariableNames', d.keys);
  results = join(all_event_tables, all_event_tables);
  writetable(results, [save_to, '/event_table_distance.csv'])
  writetable(all_cond_tables, [save_to, '/condition_table.csv'])

end
save
