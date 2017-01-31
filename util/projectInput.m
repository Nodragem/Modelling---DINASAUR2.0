function [ projectedInput ] = projectInput( input_map, border, output_size, drift )
  % |--------|--------|  input_map
  %      |-----|-----|   neural field
  %          |-|         drift
  %
  % |--------|--------|  input_map
  %    |-----|-----|     neural field
  %                |--|  border

  % negative drift 1:
  % |--------|--------|  input_map
  %      |-----|-----|   neural field
  % |--|-|           ||  [border - drift] and [border + drift]
  % negative drift 2 with zeros:
  % |--------|--------|       input_map
  %           |-----|-----|   neural field
  % |--|------|       |---|   [border - drift] and [-drift - border]
  % positive drift 1:
  % |--------|--------|   input_map
  %  |-----|-----|        neural field
  % ||           |--|-|   [border - drift] and [border + drift]
  % positive drift 2 with zeros:
  %     |--------|--------|  input_map
  % |-----|-----|             neural field
  % |---|       |------|--|  [drift - border] and [border + drift]


  if drift < 0
    cut_start = max([0, border-drift]) + 1;
    place_holders = max([0, -drift-border]);
    cut_end = cut_start + output_size - place_holders - 1;
    projectedInput = [input_map(cut_start: cut_end), zeros([1, place_holders])];
  else
    cut_start = max([0, border-drift]) + 1;
    place_holders = max([0, drift-border]);
    cut_end =  cut_start + output_size - place_holders - 1;
    projectedInput = [zeros(1, place_holders), input_map(cut_start:cut_end)];
  end
end  % function
