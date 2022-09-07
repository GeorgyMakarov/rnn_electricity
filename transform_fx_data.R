lf      <- list.files(pattern = 'usd_rub')
list_fx <- lapply(1:length(lf), function(i){fread(lf[i], stringsAsFactors = F)})
fx_dt   <- rbindlist(list_fx, fill = T)
fx_dt   <- fx_dt[, .SD, .SDcols = c('Date', 'Close')]

setnames(fx_dt, colnames(fx_dt), c('dates', 'fx'))

fx       <- copy(fx_dt)
fx$dates <- lubridate::as_date(fx$dates)
fx$fx    <- suppressWarnings(as.numeric(fx$fx))

# Replace NA values with mean of their neighbors to allow consistency
for (i in which(is.na(fx$fx))){
  fx$fx[i] <- mean(c(fx$fx[i - 1], fx$fx[i + 1]))
  rm(i)
}

rm(lf, fx_dt, list_fx)

return(fx)