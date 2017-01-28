data { 
	int<lower=1> M; 									// Number of rows 
	int<lower=1> N; 									// Number of columns 
	int<lower=1> K; 									// Number of ordinal variables
	int<lower=1, upper=K> mat[M,N];						// NxN matrix of data, note the code cannot handle zero values
	int<lower=0, upper=1> w[M,N];						// Hold-out matrix, 1 means that this value is not used for training
	vector[3] z[M];					// fixed-positions instead of latent space
}

parameters {
    real<lower=machine_precision()> rho_source;
    real<lower=machine_precision()> rho_target;
    ordered[K-1] b;														// The borders between the classes (note that b[0]=-infinity and b[K]=infinity. Since these are fixed they are not included in the b vector.
    real<lower=machine_precision(), upper=1> sigma;						// Scaling 
    vector[M] source; 													// random effects from source node
    vector[M] target; 													// random effects from target node
}

transformed parameters{
	matrix[M,M] l;
	vector[K+1] phi[M,M];
	vector[K] f[M,M];
	
	for(i in 1:M) {
		for(j in 1:M) {
			if(i!=j) {
				l[i,j] <- sqrt(dot_self(z[i]-z[j]));
			} else {
				l[i,j] <- 0;
			}
		}
	}
	
	for(i in 1:M) {
		for(j in 1:M) {
			if(i!=j) {
				for(k in 1:K+1){
					if(k==1){
						phi[i,j,k] <- 0;
					} else if(k==K+1) {
						phi[i,j,k] <- 1;
					} else {
						phi[i,j,k] <- Phi((b[k-1] + l[i,j] + source[i] + target[j])/sigma); // Phi is Normal(x;0,1) CDF
					}
				}
			}
		}
	}
	
	for(i in 1:M) {
		for(j in 1:M) {
			if(i!=j) {
				for(k in 1:K){
					f[i,j,k] <- phi[i,j,k+1] - phi[i,j,k];
				}
			}
		}
	}
}

model {
	// Since b, rho and sigma are distributed according to a flat distribution between their borders the distribution does not have to be defined.
	
	for (i in 1:M) {
		source[i] ~ normal(0, rho_source^2);
		target[i] ~ normal(0, rho_target^2);
	}

	for(i in 1:M) { 
		for(j in 1:N) {
			if (i!=j && !w[i,j]) {
				mat[i,j] ~ categorical(f[i,j]);
			}
		}	
	}
} 
