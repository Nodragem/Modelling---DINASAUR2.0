function w = gaussianConnection1D(nn,sig,A,I)
w=zeros(nn);
for loc=1:nn;
    for i=1:nn;
        di=min(abs(i-loc),nn-abs(i-loc));
        w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;
    end

end

return
