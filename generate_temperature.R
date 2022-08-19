source('helper_functions.R')

# Define general parameters
total_cycles       <- 1 * (24 * 60 / 8)
series             <- readRDS('series_length.rds')
log_program        <- readRDS('log_warehouse.rds')
accumulated_cycles <- 0
series_seed        <- 123
serie_id           <- 1
report_columns     <- readRDS('report_columns.rds')
sim_results        <- data.frame()

while (accumulated_cycles < total_cycles){
  
  print(paste0('Computing series: ', serie_id))
  
  # Set up general parameters
  set.seed(series_seed)
  s_length <- sample(series, 1)
  s_log    <- log_program[sample(nrow(log_program), 1), ]
  
  # Simulate one series
  s_report  <- as.data.frame(matrix(NA, nrow = s_length, ncol = 12))
  colnames(s_report) <- report_columns
  
  s_report$series_id <- serie_id
  s_report$log_id    <- 1:s_length
  s_report$log_diam  <- s_log[, 1]
  s_report$sleep_t   <- 0
  
  acc_cycle <- 0
  
  for (i in 1:s_length){
    
    print(paste0('-- Simulation of cycle:', i))
    
    start_time <- Sys.time()
    
    # Main operation cycle
    a <- matrix(abs(rnorm(s_log[, 1])), ncol = s_log[, 2], nrow = s_log[, 3])
    b <- matrix(abs(rnorm(s_log[, 1])), ncol = s_log[, 3], nrow = s_log[, 2])
    result    <- round(sum(a %*% b), 2)
    temper    <- collect_temperature(fn = 'collect_temp.sh', val = T)
    set.seed(series_seed + i)
    sleep_t   <- rnorm(1, mean = 2, sd = 0.2)
    Sys.sleep(sleep_t)
    acc_cycle <- acc_cycle + 1
    sleep_t   <- round(sleep_t * 100 / 60, 3)
    
    stop_time <- Sys.time()
    duration  <- round((stop_time - start_time) * 100 / 60, 3) + 0.5
    
    # Write output
    s_report$result[i]     <- result
    s_report$t_main[i]     <- temper$t_main
    s_report$t1[i]         <- temper$t1
    s_report$t2[i]         <- temper$t2
    s_report$t3[i]         <- temper$t3
    s_report$t4[i]         <- temper$t4
    s_report$sleep_t[i]    <- sleep_t
    s_report$acc_cycle[i]  <- acc_cycle
    s_report$duration[i]   <- duration
    
    # Clean up after execution
    rm(i, a, b, result, temper, sleep_t, duration, start_time, 
       stop_time)
  }
  
  sim_results <- rbind(sim_results, s_report)
  
  # Update general parameters to be used for the next cycle
  accumulated_cycles <- accumulated_cycles + s_length
  series_seed        <- series_seed + 1
  serie_id           <- serie_id    + 1
  
  Sys.sleep(10)
}










