 function f1=rnn(u)
 % gain function: logistic
    beta =.07; 
    alpha=.0;%-100*(u>0); 
   f1=1./(1+exp(-beta.*(u-alpha)));
 return
