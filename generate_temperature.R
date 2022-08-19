source('helper_functions.R')

daily_cycles <- 24 * 60 / 4               ## number of cycles per day
total_cycles <- 120 * daily_cycles        ## total observations
series       <- c(5, 10, 15, 20, 25, 30)  ## possible series length

log_diams    <- c(20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40)
log_ncols    <- c( 5, 11,  8, 13,  7, 10,  8, 17,  9, 19, 20)
log_nrows    <- c( 4,  2,  3,  2,  4,  3,  4,  2,  4,  2,  2)
log_program  <- data.frame('diam'  = log_diams, 
                           'n_col' = log_ncols, 
                           'n_row' = log_nrows)


# Test if all computations are conformable
for (i in 1:nrow(log_program)){
  raw_material <- log_program[i, ]
  a <- matrix(abs(rnorm(raw_material[, 1])), 
              ncol = raw_material[, 2],
              nrow = raw_material[, 3])
  b <- matrix(abs(rnorm(raw_material[, 1])), 
              ncol = raw_material[, 3],
              nrow = raw_material[, 2])
  out <- a %*% b
  res <- round(sum(out), 2)
  rm(raw_material, a, b, i, out, res)
}


# Simulate one series
series_seed <- 123 ## use different seed for each series
set.seed(series_seed)
s_length <- sample(series, 1) ## series length
s_log    <- log_program[sample(nrow(log_program), 1), ] ## log selection
serie_id <- 1

s_report  <- as.data.frame(matrix(NA, nrow = s_length, ncol = 8))
colnames(s_report) <- c('series_id',
                        'log_id',
                        'log_diam',
                        'result',
                        'temp',
                        'sleep_t',
                        'acc_cycle',
                        'duration')

s_report$series_id <- serie_id
s_report$log_id    <- 1:s_length
s_report$log_diam  <- s_log[, 1]
s_report$sleep_t   <- 0

acc_cycle <- 0            ## accumulated number of cycles in the series

for (i in 1:s_length){
  start_time <- Sys.time()
  
  # Main operation cycle
  a <- matrix(abs(rnorm(s_log[, 1])), ncol = s_log[, 2], nrow = s_log[, 3])
  b <- matrix(abs(rnorm(s_log[, 1])), ncol = s_log[, 3], nrow = s_log[, 2])
  result    <- round(sum(a %*% b), 2)
  temper    <- collect_temperature(fn = 'collect_temp.sh', val = T)
  set.seed(series_seed + i)
  sleep_t   <- rnorm(1, mean = 2, sd = 0.2)
  Sys.sleep(sleep_t)
  acc_cycle <- acc_cycle + i
  sleep_t   <- round(sleep_t * 100 / 60, 3)
  
  stop_time <- Sys.time()
  duration  <- round((stop_time - start_time) * 100 / 60, 3) + 0.5
  
  # Write output
  s_report$result[i]     <- result
  s_report$temp[i]       <- temper
  s_report$sleep_t[i]    <- sleep_t
  s_report$acc_cycle[i]  <- acc_cycle
  s_report$duration[i]   <- duration
  
  # Clean up after execution
  rm(i, a, b, result, temper, sleep_t, duration, start_time, 
     stop_time)
}

sleep_t <- system(command = 'bash collect_temp.sh', intern = T)





