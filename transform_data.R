pkgs <- c('dplyr', 'ggplot2', 'data.table')
dpnd <- lapply(pkgs, library, character.only = T)
source('helper_functions.R')
rm(pkgs, dpnd)

# Read all raw files into one character vector
raw_files <- list.files(pattern = '*.txt')
raw_data  <- c()

for (fn in raw_files){
  raw_file <- readLines(fn)
  raw_data <- c(raw_data, raw_file)
  rm(fn, raw_file)
}

# Make raw vector more appropriate for reading
raw_data <- gsub("\\[1\\] ", "", raw_data)
raw_data <- gsub(" ", ",", raw_data)

# Transfor string data into data.table
raw_dt <- data.table::as.data.table(raw_data)
raw_cl <- c('el_t', 'qty', 'log_in', 'temp', 'cpu_bef', 'cpu_aft') 
raw_dt[,  (raw_cl) := tstrsplit(raw_data, ",", fixed = T)][, raw_data := NULL]
raw_dt <- raw_dt[, lapply(.SD, as.numeric)]

# Give columns meaningful names to allow us make easier insights
col_order <- c('qty_y' = 'qty',
               'speed' = 'el_t',
               'l_dia' = 'log_in',
               'temp'  = 'temp',
               'pwr_a' = 'cpu_bef',
               'pwr_b' = 'cpu_aft')

raw_dt <- raw_dt[, .SD, .SDcols = col_order]
setnames(raw_dt, old = col_order, new = names(col_order))
rm(raw_data, raw_cl, col_order, raw_files)


# Identify outs using SD, MAD, IQR methods. We decide if a point is an out
# if 2 out of 3 tests showed that it is an out.
test_outs       <- apply(raw_dt, 2, find_outs)
test_outs$qty_y <- NULL


# Replace outliers with mean values of their neighbors
cols    <- names(test_outs)
nout_dt <- raw_dt[, 
                  (cols) := lapply(.SD, 
                                   function(i){
                                     smooth_out(i, test_outs, raw_dt)}), 
                  .SDcols = cols]
rm(raw_dt, test_outs, cols)
rm(find_out_iqr, find_out_mad, find_out_sd, find_outs, smooth_out)

# Use average power instead of power before and after process execution
nout_dt <- nout_dt[, pwr := (pwr_a + pwr_b) / 2]
nout_dt <- nout_dt[, c('pwr_a', 'pwr_b') := NULL]

# Add timestamps
start_ts       <- as.POSIXct("2021-01-10 10:00:00")
time_st        <- seq(start_ts, by = 10 * 60, length.out = nrow(nout_dt))
nout_dt$tstamp <- time_st

cols    <- colnames(nout_dt)
nout_dt <- nout_dt[, .SD, .SDcols = c('tstamp', cols[cols != 'tstamp'])]

write.csv(nout_dt, file = 'ts_data.csv', row.names = F)
