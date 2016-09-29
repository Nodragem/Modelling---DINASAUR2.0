 function y = in_signal_pbc(loc,ampl,sig,nn,dx)
    y=zeros(nn,1);
    for i=1:nn;
         di=min(abs(i*dx-loc),2*pi-abs(i*dx-loc));
         y(i)=ampl*exp(-di^2/(2*sig^2));
    end
 return

 %dx=angular distance between 2 nodes
 %nn=number of nodes
 %loc=node where the stimulus is
 %generates a (discrete) gaussian activity around the stimulus for each
 %node