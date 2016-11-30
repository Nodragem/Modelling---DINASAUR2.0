function w = gaussianConnection2D(nn, sig, A, I)
w=zeros(nn);
for loc=1:nn;
    for i=1:nn;
        di=min(abs(i-loc),2*pi-abs(i-loc));
        w(loc,i)=(A+I) * exp(-di^2/(2*sig^2)) - I;
    end

end

return
