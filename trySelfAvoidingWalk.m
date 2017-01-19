N = 100;
trajectory.x = [];
trajectory.y = [];
center = 50;
p.x = 50; p.y = 50;
[X, Y] = meshgrid(1:N, 1:N);
lambda = 1;
L=51;
tau = 0.001;
threshold = 7.9;

potential_map = lambda*L*(((X-center) / center).^2 + ((Y- center)/center).^2);
memory_map = zeros(N,N);
record = zeros(N,N);
choices = [0,0,0,0]; % up, down, right, left


steps = 10000;
for i = 1:steps
    memory_map = memory_map * (1-tau);
    memory_map(memory_map < 0) = 0;    
    s = potential_map + memory_map;
    record(:,:,i) = memory_map;
    % p.y and p.x are coded from 0 to 99 (index starting at 1 makes a big
    % mess with modulo), we add + 1 to come back to 1 to 100 index
    directions = [s(p.x + 1, mod(p.y+1, N) + 1 ), s(p.x + 1, mod(p.y-1, N) + 1 ), s(mod(p.x+1, N ) + 1, p.y + 1), s(mod(p.x-1, N ) + 1, p.y + 1)];
    u = unique(directions);
    n = histc(directions, u);

    if any(n>1)
        v = min(u(n>1));
        d = find(v == directions);
        choice = datasample(d, 1);
    else
        [v, choice] = min(directions);
    end

    memory_map(p.x + 1, p.y + 1) = 1;
    if choice == 1 % p.y and p.x are coded from 0 to 99 (index starting at 1 makes a big mess with modulo)
        p.y = mod(p.y + 1, N);
    elseif choice == 2
        p.y = mod(p.y - 1, N);
    elseif choice == 3
        p.x = mod(p.x + 1, N);
    elseif choice == 4
        p.x = mod(p.x - 1, N);
    end
    trajectory.x = [trajectory.x p.x];
    trajectory.y = [trajectory.y p.y];
    
end


% set params
filename = 'd:/rand.wmv';
% allocate frames struct
fig = figure;

mov(steps) = struct('cdata',[],'colormap',[]);

for i = 1:steps
    imshow(record(:,:,i)')
    hold on
    plot(trajectory.x(i) + 1+ random('Normal', 0, 0.1, 1, 1), trajectory.y(i) +1+ random('Normal', 0, 0.1, 1, 1), 'o')
    hold off
    drawnow;    
    mov(i) = getframe(fig);
end
movie(fig, mov, 1, 30)

