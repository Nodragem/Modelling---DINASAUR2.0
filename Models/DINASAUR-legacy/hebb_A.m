function w = hebb_A(nn,dx,sig,A,I)
w=zeros(nn);
for loc=1:nn;
    for i=1:nn;
        di=min(abs(i*dx-loc*dx),2*pi-abs(i*dx-loc*dx));
        w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;
    end

end

return
