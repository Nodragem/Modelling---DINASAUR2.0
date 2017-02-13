% test and showcase the function projectInput.m
clearvars;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
fix_conn = mirrorGaussian(60, 1, 14, 140)' + mirrorGaussian(120, 1, 14, 140)';
plot(fix_conn, 'ro')
hold on
for i=-80:20:80
  disp(i)
  if i > 0
      % take the border into account
    plot( (1:100) + 20, projectInput(fix_conn, 20, 100, i), 'g') % border is (120-100)/2
  elseif i == 0
    plot( (1:100) + 20, projectInput(fix_conn, 20, 100, i), 'b')
  else
    plot((1:100) + 20, projectInput(fix_conn, 20, 100, i), 'r')
  end
  size(projectInput(fix_conn, 20, 100, i))
end
