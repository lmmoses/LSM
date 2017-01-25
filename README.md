# LSM
Latent space model (LSM) for link prediction

This Git-repository features the Matlab code as well as the Stan models that were used in [1]. Using the Matlab-scripts requires

1. A Stan installation. Stan 2.9 was used for this project and may be found at http://mc-stan.org/. 
2. The MatlabStan interface, which may be acquired at http://mc-stan.org/interfaces/matlab-stan. 

Please note that Stan outputs temporary files to store the HMC samples. The way this is implemented in the MatlabStan wrapper is NOT thread-safe! If you want to have LSM samplers run in parallel, you need to modify the MatlabStan scripts to associate a unique ID which each sampling chain temp file.

The following Stan models are available:

1. The core LSM (lsm.stan).
2. The LSM extended with random effects for sources and targets (lsm_directionaleffects.stan).
3. The LSM for datafusion, combining two input connectivity matrices (lsm_directionaleffects_datafusion.stan).
4. A model with only the random effects (directionaleffects.stan).
5. A model with only the random effects, combining two input connectivity matrices (directionaleffects_datafusion.stan).
6. A model with fixed instead of latent positions, with random effects (fpm_directionaleffects.stan).

The core Matlab script is sampler.m. Examples of how to use this script are shown in DEMO.m. The sampler takes care of:

1. Collecting, thinning and storing the HMC samples.
2. Monitoring convergence using the Potential Scale Reduction Factor (PSRF) measure. Depending on user settings, the sampler will automatically restart itself with more iterations if convergence has not been achieved. The default threshold for the PSRF is 1.1 (applied to *all* elements of the indicated variables). Which variables must be monitored for convergence is a user-supplied parameter.
3. Training on hold-out data. If a fold number f is provided, the sampler will train on all edges with fold index ~f. This is used in evaluating performance of the model, by looking at the error in recovery of the connections with label f. Fold labels must be defined a priori for each data set and are stored in /data/xfolds/<dataset_name>_folds.mat.





[1] Max Hinne, Annet Meijers, Rembrandt Bakker, Paul Tiesinga, Morten Mørup and Marcel van Gerven, 2017. The Missing Link: Predicting Connectomes from Noisy and Partially Observed Tract Tracing Data. PLoS Computational Biology.
