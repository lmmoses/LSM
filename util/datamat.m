function datamat = datamat(dsname)

switch dsname
    case 'fve'
        A = csvread('data/felleman_vanessen.csv');     
        w = find(isnan(A).*~eye(size(A)));
        nw = find(~isnan(A).*~eye(size(A)));
        %A(isnan(A))=0.5;
        A(find(eye(size(A))))=1;
        datamat.A = A;
        datamat.K = length(unique(A))-1;
        datamat.labels = nodelabels(dsname);
        datamat.w = w;
        datamat.nw = nw;
        [~,z] = macaque_surface_fve;
        datamat.z = z;
    case 'mkv'
        A = makeordinal(csvread('data/markov_retrograde.csv',1,1), [-2 -4 -Inf]);
        [M,N] = size(A);
        A(:,(N+1):M) = NaN;
        A((1:N) + (0:(N-1)).*M) = 3;
        tmp = ~eye(M);
        w = find(tmp);
        nw = find(~tmp .* ~eye(M));
        datamat.A = A;       
        datamat.K = length(unique(A));
        datamat.labels = nodelabels(dsname);
        datamat.w = w;
        datamat.nw = nw;
        [~,z] = macaque_surface_mkv;
        datamat.z = z;
    case {'zng_df', 'zng'}
        A = csvread('data/zingg_anterograde.csv'); A(find(eye(49)))=3;
        R = csvread('data/zingg_retrograde.csv'); R(find(eye(49)))=3;
        datamat.A = A;
        datamat.R = R;
        datamat.K = length(unique(A));
        datamat.labels = nodelabels(dsname);
        datamat.w = [];
        datamat.nw = find(~eye(size(A)));
    case 'zng_ant'
        A = csvread('data/zingg_anterograde.csv'); A(find(eye(49)))=3;
        datamat.A = A;
        datamat.K = length(unique(A));
        datamat.labels = nodelabels(dsname);
        datamat.w = [];
        datamat.nw = find(~eye(size(A)));
    case 'zng_ret'
        R = csvread('data/zingg_retrograde.csv'); R(find(eye(49)))=3;
        datamat.R = R;
        datamat.K = length(unique(R));
        datamat.labels = nodelabels(dsname);
        datamat.w = [];
        datamat.nw = find(~eye(size(R)));
end