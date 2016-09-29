 function rall=rnn_ode_u_A_fast(nstep,u,w,uexoall,uendoall,noise_t, tau,beta,dx,nn) %,alpha)
  % odefile for recurrent network
   tau_inv = 1./tau;      % inverse time constant
   I = ( uexoall(1:nstep,:) + uendoall(1:nstep,:) + noise_t(1:nstep,:) )'; %total input
   rall = zeros(nn,nstep);  
   r = 1 ./ (1 + exp(-beta*u));  rall(:,1)=r;
   for t=2:nstep
     u = u + tau_inv * (I(:,t-1) - u + w * r * dx);
     r = 1 ./ (1 + exp(-beta*u));
     rall(:,t) = r;
   end
