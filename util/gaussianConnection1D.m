function w = gaussianConnection1D(nn, sig, A, I)
w=zeros(nn);
for loc=1:nn;
    for i=1:nn;
        di=min(abs(i-loc),nn-abs(i-loc));
        w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;
    end

end

return

% -- WARNING, FIXME ----------
% 
% there was a huge inconsistency between legacy and new version, 
% they were not returning the same firing rate for the same
% stimulus configuration! 
% I could not figure out why: everything was the same in the
% parameters in rnn_ode_A_fast and computeMapActivityAcrossSaccade
% I finally found out that the bug was from here, the use of circular
% connections is mandaroty to replicate the dynamic of the legacy version,
% with same parameters.
% I guess that if we want to use non-cirlcular connection, we will need to
% adjust the weight of the inhibition.

% --------
% bugged code
% --------
% di=min(abs(i-loc),2*pi-abs(i-loc)); // that was cancelling the mirror/circularity
% w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;
%
% -------------
% legacy version
% -------------
% di=min(abs(i*dx-loc*dx),2*pi-abs(i*dx-loc*dx));
% w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;