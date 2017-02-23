function y = gaussian2(x, center, amplitude, sigma0, normed)
  if nargin < 5
    normed = false;
  end
  if normed == false
    y = amplitude * exp(-(x - center).^2/(2*sigma0^2)); % / (sigma0*sqrt(2*pi));
  else
    y = amplitude * exp(-(x - center).^2/(2*sigma0^2)) / (sigma0*sqrt(2*pi));
  end
end
