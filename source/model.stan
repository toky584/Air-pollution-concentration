functions {
  // Spectral density functions
	vector spd_se(vector omega, real alpha, real rho) {
		// Your code here
    return alpha^2 * sqrt(2 * pi()) * rho * exp(-(rho^2 * omega^2)/2);
	}

	vector spd_matern32(vector omega, real alpha, real rho) {
		// Your code here
    return alpha^2 * (12 * sqrt(3) / rho^3) * (3 / rho^2 + omega^2)^(-2);
	}

	vector spd_matern52(vector omega, real alpha, real rho) {
		// Your code here
    return alpha^2 * (16 * 5^(5.0/2) / (3 * rho^5)) * (5 / rho^2 + omega^2)^(-3);
	}

  // Eigenvalues and eigenvectors
  vector eigenvalues(int M, real L) {
		// Your code here
    vector[M] lambda;
    for (m in 1:M){
      lambda[m] = ( (m * pi() ) /  (2 * L) )^2;
    }
    return lambda;
	}

	matrix eigenvectors(vector x, int M, real L, vector lambda) {
		// Your code here
    int N = size(x);
    matrix[N,M] PHI;
    for (m in 1:M){
      for (n in 1:N){
        PHI[n,m] = sqrt(1/L) * sin(sqrt(lambda[m]) * (x[n] + L));
      }
    }
    return PHI;
	}

  // HSGP functions
  vector hsgp_se(vector x, real alpha, real rho, vector lambdas, matrix PHI, vector z) {
		int N = rows(x);
		int M = cols(PHI);
		vector[N] f;
		matrix[M, M] Delta;

    // Spectral densities evaluated at the square root of the eigenvalues
    vector[M] spd = spd_se(sqrt(lambdas), alpha, rho);

		// Construct the diagonal matrix Delta
    Delta = diag_matrix(spd);

		// Compute the HSGP sample
    f = PHI * (Delta * z);

		return f;
	}

  vector hsgp_matern32(vector x, real alpha, real rho, vector lambdas, matrix PHI, vector z) {
		int N = rows(x);
		int M = cols(PHI);
		vector[N] f;
		matrix[M, M] Delta;

    // Spectral densities evaluated at the square root of the eigenvalues
    vector[M] spd = spd_matern32(sqrt(lambdas), alpha, rho);

		// Construct the diagonal matrix Delta
    Delta = diag_matrix(spd);

		// Compute the HSGP sample
    f = PHI * (Delta * z);

		return f;
	}

  vector hsgp_matern52(vector x, real alpha, real rho, vector lambdas, matrix PHI, vector z) {
		int N = rows(x);
		int M = cols(PHI);
		vector[N] f;
		matrix[M, M] Delta;

    // Spectral densities evaluated at the square root of the eigenvalues
    vector[M] spd = spd_matern52(sqrt(lambdas), alpha, rho);

		// Construct the diagonal matrix Delta
    Delta = diag_matrix(spd);

		// Compute the HSGP sample
    f = PHI * (Delta * z);

		return f;
	}
}


data {
  int<lower=1> N;
  vector[N] x;
  vector[N] y;
  real<lower=0> C;
  int<lower=1> M;
}

transformed data {
  // Boundary condition
  real<lower=0> L = C * max(abs(x));

  // Compute the eigenvalues
  vector[M] lambdas = eigenvalues(M, L);

  // Compute the eigenvectors
  matrix[N, M] PHI = eigenvectors(x, M, L, lambdas);
}

parameters {
  real<lower=0> alpha;
  real<lower=0> sigma;
  real beta_0;
  real<lower=0> rho;
  vector[M] z;
}

transformed parameters {
  vector[N] f = hsgp_se(x, alpha, rho, lambdas, PHI, z);
  vector[N] mu = beta_0 + f;
}

model {
  // Priors
  alpha ~ cauchy(0, 1);
  rho ~ inv_gamma(5, 1);
  sigma ~ cauchy(0, 1);
  beta_0 ~ normal(0, 2);
  z ~ normal(0, 1);

  // Likelihood
  y ~ lognormal(mu, sigma);
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {
    log_lik[n] = lognormal_lpdf(y[n] | mu[n], sigma);
    y_rep[n] = lognormal_rng(mu[n], sigma);
  }
}
