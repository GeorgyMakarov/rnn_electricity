# 4. launch from bash script
# 5. collect temperature, cpu load from bash scripts
# 6. observations = (8 hours * 60 times per hour) * (1 month * 30 days) = 14400
# ps -C rsession -o %cpu,%mem


# Helper function --------------------------------------------------------------

compute_output <- function(log_diams, log_outs, try_seed, k_seed){
  
  # Convert arguments to numeric to be able to use in computations
  try_seed <- as.numeric(try_seed)
  k_seed   <- as.numeric(k_seed)
  
  # Compute log volume in sq. mm allows to prepare matrix size
  set.seed(try_seed)
  log_inp <- sample(log_diams, 1)
  log_vol <- round(3.14 * ((log_inp / 2) ^ 2) * 60, -3)
  
  # Find possible output combination allows to compute ncol and nrow of a matrix
  tmp <- which(as.logical(lapply(log_outs, function(i){log_vol %% i == 0})))
  set.seed(try_seed + k_seed)
  side_a <- log_outs[sample(tmp, 1)]
  side_b <- round(log_vol / side_a, 0)
  size_m <- side_a * side_b
  
  # Compute result output
  set.seed(try_seed)
  z <- abs(rnorm(size_m))
  a <- matrix(z, nrow = side_a, ncol = side_b)
  b <- matrix(z, nrow = side_b, ncol = side_a)
  m <- round(round(sum(a %*% b), 0) / 1000000, 3)
  
  # Return log diam, result output
  res <- list('res_vol' = m, 'log_diam' = log_inp)
  
  return(res)
}


# Main process code ------------------------------------------------------------

args   <- commandArgs(trailingOnly = T)
try_s  <- args[1]
k_s    <- args[2]

log_d <- seq(12, 70, 0.5) ## constant dictionary
log_o <- seq(40, 225, 5)  ## constant dictionary

sys_out <- system.time(res <- compute_output(log_d, log_o, try_s, k_s))[3]
res_vol <- res[['res_vol']]
log_dia <- res[['log_diam']]

sys_out <- as.numeric(sys_out) ## to eliminate names

out_res <- c(sys_out, res_vol, log_dia)
out_res
