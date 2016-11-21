function y = gaussian(x,sigma)
for i=1:length(x)
    xx=x(i);
    y(i) = exp(-xx^2/(2*sigma^2)) / (sigma*sqrt(2*pi));
end
