 function f1 = gainFunction(u)
 % gain function of the neurons in DNF: logistic function / sigmoid
    beta =.07;
    alpha=.0;%-100*(u>0);
   f1=1./(1+exp(-beta.*(u-alpha)));
 return
