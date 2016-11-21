function h = gaussfilter(n,sigma)
for i = 1 : n
    h(i) = gaussian(i-(n+1)/2,sigma);
end
h = h / sum(h);
