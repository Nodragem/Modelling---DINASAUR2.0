function quick_peak(df, condition_ID, trial_ID)
  select = (df.condition_ID == condition_ID) & (df.trial_ID == trial_ID);
  plot(df.time(select), df.winner_ecc(select), 'ro-')
  title('one trial')
  ylim([0, 200])

  quickPlot(df, 'winner_ecc', condition_ID)
  quickPlot(df, 'saccade_ecc', condition_ID)
  quickPlot(df, 'gaze_pos', condition_ID, [], '-')

  df_sacc = df(df.saccade_ecc > 0, :);
  df_sacc.cum_sacc = zeros([height(df_sacc), 1]);
  for cc = unique(df_sacc.condition_ID)'
    for tt = unique(df_sacc.trial_ID)'
      selection = (df_sacc.trial_ID == tt) & (df_sacc.condition_ID == cc);
      df_sacc.cum_sacc(selection) = cumsum(df_sacc.saccade_ecc(selection));
    end
  end

  quickPlot(df_sacc, 'cum_sacc', condition_ID, [], 'o-')
end
