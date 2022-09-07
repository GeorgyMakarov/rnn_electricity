txn       <- fread('historical_data.csv', stringsAsFactors = F)
drop_cols <- c('txn_id', 'cust_n')
txn       <- txn[, !drop_cols, with = F]
rm(drop_cols)

# Add dates to be able to merge with spx and fx
txn[, dates := as.Date(day_n - 1, 
                       origin = lubridate::as_date(paste0(year, '-01-01')))]

leave_cols <- c('dates', 'sku', 'cust_id', 'rating', 'price', 'mean_p', 'sd_p')
txn <- txn[, .SD, .SDcols = leave_cols]
rm(leave_cols)

return(txn)


