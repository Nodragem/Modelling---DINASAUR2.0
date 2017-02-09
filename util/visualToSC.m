function [u, v] = visualToSC(x, y, from_polar)
  % according to Ottes et al. 1986 equations
  % the equation is working with degrees and mm
  % u is the rostro-caudal axis
  % v is the medial-ventral axis
  if nargin < 3
    from_polar = true;
  end

  if from_polar
    phi = x;
    r = y;
  else
    [phi, r] = cart2pol(x, y);
  end

  u =  1.4 * log( sqrt(r.^2 + 2*3.0*r.*cos(phi) + 3.0^2 ) / 3.0);
  v =  1.8 * atan2( r.*sin(phi), r.*cos(phi)+3.0 );

  % function end: 'myFunction'
end
