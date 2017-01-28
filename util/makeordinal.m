function Aord = makeordinal(A,ths)

T = length(ths);
o = T;

Aord = zeros(size(A));
Aord(log10(A) > ths(1)) = o;

for i=2:T
    o = o - 1;
    Aord(log10(A) <= ths(i-1) & log10(A) > ths(i)) = o; 
end