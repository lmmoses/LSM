function samples = sampler(model,data,opts,rvars,svars,cvars)


% user options
if ~exist('opts', 'var') || ~isfield(opts, 'nchains')
    nchains = 4;
else 
    nchains = opts.nchains;
end
if ~exist('opts', 'var') || ~isfield(opts, 'niter')
    niter = 5e3;
else
    niter = opts.niter;
end
if ~exist('opts', 'var') || ~isfield(opts, 'verbose')
    verbose = true;
else
    verbose = opts.verbose;
end
if ~exist('opts', 'var') || ~isfield(opts, 'Rlim')
    Rlim = 1.1;
else
    Rlim = opts.Rlim;
end
if ~exist('opts', 'var') || ~isfield(opts, 'nsamples')
    nsamples = 1e3;
else
    nsamples = opts.nsamples;
end
if ~exist('opts', 'var') || ~isfield(opts, 'mustconverge')
    mustconverge = true;
else
    mustconverge = opts.mustconverge;    
end
if mustconverge
    if ~exist('opts', 'var') || ~isfield(opts, 'iterincr')
        iterincr = 51e3;
    else
        iterincr = opts.iterincr;
    end
end


nC = length(cvars); % conditions, i.e. nr of latent dimensions or classes
suffix = '';
for c=1:nC
    suffix = [suffix '_' cvars{c} '_' num2str(data.stan_input.(cvars{c}))];
end



tic;
fit = stan('file',strcat('stan_models/',model,'.stan'),...
    'data',data.stan_input, ...
    'verbose',false, ... % verbosity of Stan is quite generous..., change for debugging
    'chains', nchains, ...
    'iter',niter, ...
    'inc_warmup',true, ...
    'sample_file', sprintf('tmp/samples_%s_%s%s.csv', data.name, model, suffix) ); 


if verbose
    fprintf('Model: stan_models/%s.stan\n', model);
    fprintf('Dataset: %s\n', data.name);
    fprintf('Sampling %d chains of %d iterations\n', nchains, niter);
end

fit.block();
results = fit.sim.samples;
toc;

nR = length(rvars);
rvals = zeros(nR,1);

if verbose
    fprintf('Sampling complete; assessing convergence\n');
end


for i=1:nR  
    y = [];
    rvar = rvars{i};
    for c=1:nchains
        yc = results(c).(rvar); % compute PSRF for this variable
        dims = size(yc);
        if length(dims) > 2
            yc = reshape(yc, [niter/2, prod(dims(2:end))]);
        end
        y(:,:,c) = yc;
    end
    R = psrf(y);
    R(isnan(R)) = 1.0;
    if verbose
        fprintf('%0.2f%% of %s has converged (max(R) = %0.2f)\n', nnz(R<Rlim)/length(R)*100, rvar, max(R));
    end
    rvals(i) = max(R);
end
Rmax = max(rvals);

rate = niter/nsamples;
range = rate:rate:niter;

if Rmax < Rlim
    if verbose
        fprintf('All chains have converged, downsampling to %d samples\n', nsamples);
    end
    nS = length(svars);  
    samples = struct;    
    for s=1:nS
        y = [];
        for c=1:nchains
            y = cat(1,y,results(c).(svars{s}));
        end
        ndims = length(size(y));
        switch ndims
            case 2
                ysub = y(range,:);
            case 3
                ysub = y(range,:,:);
            case 4
                ysub = y(range,:,:,:);
        end        
        samples.(svars{s}) = ysub;  
        samples.niter = niter;
    end
else    
    fprintf('Chains have not converged.\n');
    if mustconverge
        %fprintf('Redoing with %d+%d iterations.\n', niter, iterincr);
        opts.niter = niter+iterincr;
        clear samples;
        samples = sampler(model,data,opts,rvars,svars,cvars);
    end
end


