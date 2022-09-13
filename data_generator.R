pkgs <- c('dplyr', 'data.table', 'lubridate')
dpnd <- lapply(pkgs, library, character.only = T)
rm(pkgs, dpnd)

source('aggregate_spx_fx.R')
source('helper_functions.R')

# Find number of days in each year to provide it to sine calculator
n_days <- get_year(dt[['dates']])

# Find b value of sine equation y = a * sin(b * t) used for seasonality
# Use two frequencies:
# weekly  -- for Sundays
# monthly -- for maintenance
freqs  <- list('7' = c(267, 269), '30' = c(64, 66))
b_coef <- lapply(names(freqs), function(i){get_b_coef(rng      = freqs[[i]],
                                                      nd       = n_days,
                                                      freq_req = i)})
names(b_coef) <- names(freqs)

# Compute all sines using coefficient `a` to define the amplitude
a_coef <- list('7' = 20, '30' = 30)
sines  <- lapply(
  names(freqs), 
  function(i){
    as.numeric(a_coef[[i]]) * sin(b_coef[[i]] * seq(from = 0, 
                                                    to   = 4*pi, 
                                                    length.out = sum(n_days)))})
setDT(sines)
setnames(sines, old = colnames(sines), new = paste0('sine', names(freqs)))
sines <- rowSums(sines)
rm(a_coef, b_coef, freqs)

# Add linear trends of different slopes to the data by year



