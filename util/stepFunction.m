function y = stepFunction(x, amplitude, start, stop, baseline)
  if nargin < 5;
    y = zeros(size(x));
  else
    y = ones(size(x))*baseline;
  end
  y(x>start & x<stop) = amplitude;
return
