% test and showcase the function projectInput.m
clearvars;
addpath(genpath('/home/c1248317/Bitbucket/Dinasaur'))
fix_conn = mirrorGaussian(60, 1, 14, 120)';
plot(fix_conn, 'ro')
hold on
for i=-50:10:50
  disp(i)
  if i > 0
    plot(projectInput(fix_conn, 10, 100, i), 'g') % border is (120-100)/2
  elseif i == 0
    plot(projectInput(fix_conn, 10, 100, i), 'b')
  else
    plot(projectInput(fix_conn, 10, 100, i), 'r')
  end
end
