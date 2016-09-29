 function udot_exo=rnn(t,uexo,flag,tau)
 % odefile for recurrent network
   tau_inv = 1./tau;      % inverse time constant
   udot_exo=tau_inv.*(-uexo);
 return
