function quickPlot(df, variable_name, condition_ID, yrange, typeline)
  figure;
  if nargin < 4
    yrange = [0 200];
    typeline = 'o';
  end
  select_cond = (df.condition_ID == condition_ID);
  for ii = unique(df.trial_ID(select_cond))'
    select_trial = (df.condition_ID == condition_ID) & (df.trial_ID == ii);
    shade = ii/length(unique(df.trial_ID(select_cond)) );
    plot(df.time(select_trial), df{select_trial, variable_name}, typeline, 'Color', [1-shade, 0, shade])
    hold on
  end
  hold off
  ylabel(variable_name);
  xlabel('time (ms)');
  title([variable_name, ' across trials (Condition ', int2str(condition_ID), ')' ]);
  if ~isempty(yrange)
    ylim(yrange);
  end
end
