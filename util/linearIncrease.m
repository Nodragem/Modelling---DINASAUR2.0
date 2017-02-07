function y = linearIncrease(x, amplitude, start, stop, baseline)
  if nargin < 5;
    baseline = 0;
  end
  y = ones(size(x))*baseline;
  y(x>start & x<stop) = baseline + (amplitude/(stop-start))*x(x>0 & x<(stop-start) );
  y(x>=stop) = baseline + (amplitude/(stop-start))*x(stop-start);
return
