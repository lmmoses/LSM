close all; clear all;
% paths to your Stan interface directories
addpath ~/MatlabStan/;
addpath ~/MatlabProcessManager/;


addpath util/;

if ~exist('tmp/', 'dir')
    mkdir('tmp'); 
end
if ~exist('samples/', 'dir')
    mkdir('samples'); 
end


dataset = 'felleman_vanessen';

adj_mat = csvread(sprintf('data/%s.csv', dataset));
w = int8(isnan(adj_mat));                   % unobserved connections
k = length(unique(adj_mat(find(~w))));      % number of ordinal values
adj_mat(find(w)) = 0; 
adj_mat = adj_mat + 1;                      % Stan cannot deal with zero-connections, but the NaN's are ignored through w

[M,N] = size(adj_mat);

% input
data.name = dataset;                % name for output purposes
stan_input.M = M;
stan_input.N = N;
stan_input.d = 2;                   % latent dimensionality
stan_input.K = k;
stan_input.mat = adj_mat;           % Stan doesn't understand 0 entries
stan_input.w = w;                   % edges to ignore

data.stan_input = stan_input;


% sampling options; see sampler.m for defaults
opts.niter = 2e3;           % number of iterations (will be increased for later runs if mustconverge==true
opts.nchains = 4;           % number of parallel chains
opts.nsamples = 1e3;        % thin to this number
opts.mustconverge = true;   % keep sampling until convergence
opts.iterincr = 1e3;        % increases the number of iters by this amount for the next attempt to converge

model = 'lsm_directionaleffects';

rvars = {'phi', 'l', 'sigma'}; 									% variables to monitor convergence of
svars = {'f', 'z', 'b', 'sigma', 'lp__'}; 		% variables to store (see model definition)
cvars = {'d'};                                                      % variables to append to temporary file names (for parallelization)

% Sampling may take a while. Grab some popcorn and watch the contents of
% tmp/ ! :-)

samples = sampler(model, data, opts, rvars, svars, cvars);

samplesfile = sprintf('samples/%s_%s_D_%d.mat', data.name, model, data.stan_input.d);
save(samplesfile, 'samples', '-v7.3');
load(samplesfile);

A_expectation = amat(samples.f);

A_data = adj_mat - 1;
A_data(find(w)) = 0.5;
A_data(find(eye(M))) = 1;

figure; 
subplot 121;
imagesc(A_data); colormap bone; axis square; caxis([0, k-1]); cb = colorbar;
labels = nodelabels(data.name);
xlabel('node'); ylabel('node'); ylabel(cb, 'connection weight');
set(gca, 'xtick', 1:M, 'xticklabels', labels(1:M), 'ytick', 1:N, ...
    'yticklabels', labels(1:N), 'fontname', 'century gothic', 'fontsize', 6, ...
    'ticklength', [0 0]);  
title(sprintf('Observed connectivity for %s', data.name))
subplot 122;
imagesc(A_expectation); colormap bone; axis square; caxis([0, k-1]); cb = colorbar;
labels = nodelabels(data.name);
xlabel('node'); ylabel('node'); ylabel(cb, 'connection weight');
set(gca, 'xtick', 1:M, 'xticklabels', labels(1:M), 'ytick', 1:N, ...
    'yticklabels', labels(1:N), 'fontname', 'century gothic', 'fontsize', 6, ...
    'ticklength', [0 0]);  
title(sprintf('Expected connectivity for %s, with %d latent dimensions', data.name, data.stan_input.d))




