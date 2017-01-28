function A = amat(f)

[~,p,~,K] = size(f);

A = zeros(p);
for k=1:K
    A = A + k*squeeze(mean(f(:,:,:,k),1));
end
A(find(eye(p))) = K;

A = A - 1;