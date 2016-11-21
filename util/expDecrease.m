function y = expDecrease(x, amplitude, start, tau)
  y = amplitude*exp(-(1/tau)*(x-start));
  y(x<start) = 0;
return
