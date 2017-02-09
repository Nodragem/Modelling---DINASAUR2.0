function [x, y] = SCtoVisual(u, v, to_polar)
  % according to Ottes et al. 1986 equations
  % the equation is working with degrees and mm
  % u is the rostro-caudal axis
  % v is the medial-ventral axis
  if nargin < 3
    to_polar = true;
  end

  %radius(u<0) = 3.0*sqrt(exp(2*abs(u(u<0))/1.4) - 2*exp(abs(u(u<0))/1.4)*cos(v/1.8) + 1 );
  radius = 3.0*sign(u).*sqrt(exp(2*abs(u)/1.4) - 2*exp(abs(u)/1.4)*cos(v/1.8) + 1 );

  phi = atan2( (exp(u/1.4)*sin(v/1.8)), ( exp(u/1.4)*cos(v/1.8)-1) );

  if to_polar
    % x = rad2deg(phi); y = rad2deg(radius);
    x = phi; y = radius;
  else
    [x, y] = pol2cart(phi, radius);
  end
% function end: 'SCtoVisual'
end
